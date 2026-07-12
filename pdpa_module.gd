extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES (ระบบตรวจเช็กโหนดปลอดภัย)
# ==============================================================================
# โค้ดจะมองหาชื่อใหม่ TextEdit_Log ถ้าไม่เจอจะสลับไปมองหา Label_Request ของเก่าให้อัตโนมัติ ป้องกันเกมแครช
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else ($Panel/Label_Request if has_node("Panel/Label_Request") else null)
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

# ข้อมูลโจทย์สุ่มสำหรับการตั้งค่า NAT
var target_acl = 0
var target_interface = ""
var public_ip = ""

var is_game_over: bool = false
var current_cli_mode = 0 # 0: User, 1: Privileged, 2: Config Mode
var step_nat_configured = false

# ==============================================================================
# ⚙️ 2. MAIN SIMULATOR SYSTEM
# ==============================================================================
func _ready():
	if command_input: 
		command_input.text = ""
	_clear_terminal_display()
	setup_nat_challenge()

func setup_nat_challenge():
	is_game_over = false
	current_cli_mode = 0 
	step_nat_configured = false
	
	if command_input: 
		command_input.text = ""
		
	# สุ่มอินเตอร์เฟสและไอพีขาออก (Public IP) ของ ISP
	var interfaces = ["Gi0/1", "Gi0/2", "fa0/1"]
	target_interface = interfaces[randi() % interfaces.size()]
	target_acl = [1, 5, 10][randi() % 3] 
	
	var ip_list = ["192.168.1.50", "192.168.2.10", "192.168.3.99"]
	public_ip = ip_list[randi() % ip_list.size()]
	
	# ข้อความต้อนรับเข้าสู่ด่านและแจ้งคำสั่งโจทย์
	var startup_msg = "--- GATEWAY SWITCH NAT ---\n"
	startup_msg += "🚨 EMERGENCY: Internal users cannot access the Internet (No NAT Translation).\n"

	
	_write_to_terminal_safe(startup_msg)
	_print_prompt()
		
	if command_input:
		command_input.call_deferred("grab_focus")

func _print_prompt():
	var prompt_text = ""
	match current_cli_mode:
		0: prompt_text = "Switch> "
		1: prompt_text = "Switch# "
		2: prompt_text = "Switch(config)# "
	
	_append_to_terminal_safe(prompt_text)

func _on_line_edit_ip_text_submitted(new_text: String) -> void:
	if is_game_over or not is_visible_in_tree(): return
	
	var raw_command = new_text.strip_edges()
	if command_input: 
		command_input.text = "" 
		
	if raw_command == "": 
		_append_to_terminal_safe("\n")
		_print_prompt()
		if command_input: 
			command_input.call_deferred("grab_focus")
		return
		
	_append_to_terminal_safe(raw_command + "\n")
	
	await get_tree().create_timer(0.1).timeout
	_process_nat_command(raw_command)
	
	if command_input:
		command_input.call_deferred("grab_focus")

# ==============================================================================
# 🎮 CLI COMMAND PROCESSING (NAT OVERLOAD SYSTEM)
# ==============================================================================
func _process_nat_command(raw_command: String):
	
	# 🟩 โหมดที่ 0: User Mode
	if current_cli_mode == 0:
		if raw_command.to_lower() == "enable":
			current_cli_mode = 1
		elif raw_command.to_lower() == "conf t" or raw_command.to_lower().begins_with("ip nat ") or raw_command.to_lower() == "exit" or raw_command.to_lower() == "ex" or raw_command.to_lower() == "save":
			_append_to_terminal_safe("% Command rejected: ต้องกรอกคำสั่ง 'enable' เพื่อเข้าสิทธิ์แอดมินก่อน\n")
		else:
			_append_to_terminal_safe("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)\n")

	# 🟩 โหมดที่ 1: Privileged EXEC Mode
	elif current_cli_mode == 1:
		var low_cmd = raw_command.to_lower()
		if low_cmd == "configure terminal" or low_cmd == "conf t":
			current_cli_mode = 2
			_append_to_terminal_safe("Enter configuration commands, one per line. End with 'exit' or 'ex'.\n")
		elif low_cmd == "save":
			if step_nat_configured:
				_append_to_terminal_safe("\n🛡️ STATUS: DYNAMIC NAT OVERLOAD ACTIVATED!\n")
				_append_to_terminal_safe("🟢 IP TRANSLATION TABLE LINKED TO PUBLIC IP: " + public_ip + "\n")
				_append_to_terminal_safe("🟢 CONFIGURATION SUCCESSFULLY SAVED.\n")
				_check_win_condition()
				if is_game_over: return
			else:
				_append_to_terminal_safe("% Command rejected: อินเทอร์เน็ตยังใช้งานไม่ได้! กรุณาเข้าไปตั้งค่า NAT ก่อน\n")
		elif low_cmd == "exit" or low_cmd == "ex":
			_append_to_terminal_safe("% Connection closed.\n")
		else:
			_append_to_terminal_safe("% Unknown command. (พิมพ์ 'conf t' เพื่อเข้าโหมดคอนฟิก หรือ 'save' เพื่อบันทึก)\n")

	# 🟩 โหมดที่ 2: Global Configuration Mode
	elif current_cli_mode == 2:
		
		# 🛑 ตรวจสอบคำสั่งตั้งค่าความสัมพันธ์ของระบบ NAT Overload (PAT)
		if raw_command.to_lower().begins_with("ip nat inside source list "):
			# แยก arguments ออกมาโดยยังคงตัวพิมพ์เดิมไว้ก่อน เผื่อใช้แสดงผลตอนพิมพ์ผิด
			var nat_args = raw_command.right(-26).strip_edges() 
			var parts = nat_args.split(" ", false)
			
			if parts.size() == 4 and parts[1].to_lower() == "interface" and parts[3].to_lower() == "overload":
				var input_acl = parts[0]
				var input_interface = parts[2]
				
				#  จุดสำคัญ: ใช้ .to_lower() เปรียบเทียบชื่อพอร์ต ทำให้พิมพ์ตัวเล็กหรือตัวใหญ่ก็ผ่าน
				if input_acl == str(target_acl) and input_interface.to_lower() == target_interface.to_lower():
					step_nat_configured = true
					_append_to_terminal_safe("Success: NAT Overload translation registered dynamically on " + input_interface + ".\n")
					_append_to_terminal_safe("ℹ️ [System]: พิมพ์ 'ex' ออกด้านนอก แล้วพิมพ์ 'save' เพื่อเริ่มปล่อยแพ็กเก็ตออนไลน์\n")
				else:
					var fail_reason = "คุณกำหนดพารามิเตอร์การแปลงพอร์ตผิดพลาด ลิงก์ระบบปลายทางล่ม:\n"
					fail_reason += "ค่าที่คุณใส่: Access-List=" + input_acl + " Interface=" + input_interface
					trigger_game_over(fail_reason)
					return
			else:
				_append_to_terminal_safe("% Incomplete syntax: รูปแบบคือ 'ip nat inside source list [เลขACL] interface [ชื่ออินเตอร์เฟส] overload'\n")
				
		elif raw_command.to_lower() == "save":
			_append_to_terminal_safe("% Command rejected: ไม่สามารถบันทึกค่าในโหมดคอนฟิกได้ กรุณาพิมพ์ 'ex' ออกไปก่อน\n")
				
		elif raw_command.to_lower() == "exit" or raw_command.to_lower() == "ex": 
			current_cli_mode = 1
			_append_to_terminal_safe("Leaving Configuration Mode.\n")
		else:
			_append_to_terminal_safe("% Invalid syntax. (คำสั่งที่รองรับ: 'ip nat inside source list [เลข] interface [ชื่อ] overload', 'ex')\n")
	_print_prompt()

# ==============================================================================
# 🎯 3. SAFE SUB SYSTEMS (ระบบควบคุมกล่องข้อความแบบไม่แครช)
# ==============================================================================
func _write_to_terminal_safe(text: String):
	if log_text_edit and "text" in log_text_edit:
		log_text_edit.text = text
		_scroll_to_bottom()

func _append_to_terminal_safe(text: String):
	if log_text_edit and "text" in log_text_edit:
		log_text_edit.text += text
		_scroll_to_bottom()

func _clear_terminal_display():
	if log_text_edit and "text" in log_text_edit:
		log_text_edit.text = ""

func _scroll_to_bottom():
	if log_text_edit and "scroll_vertical" in log_text_edit:
		log_text_edit.scroll_vertical = log_text_edit.get_line_count()

func _check_win_condition():
	is_game_over = true
	if "completed_modules_count" in Global:
		Global.completed_modules_count += 1
	await get_tree().create_timer(1.5).timeout
	_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	Global.game_over_reason = "❌ NAT OVERLOAD TRANSLATION FAILURE\n" + reason_text
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()
