extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES
# ==============================================================================
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else null 
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

var target_dept = ""
var target_ip = "" 

var is_game_over = false
var current_cli_mode = 0 # 0: User, 1: Privileged, 2: Config Mode

var step_ip_blocked = false

# ==============================================================================
# ⚙️ 2. MAIN FIREWALL SYSTEM
# ==============================================================================
func _ready():
	if command_input: 
		command_input.text = ""
	if log_text_edit:
		log_text_edit.text = ""
		
	setup_firewall_challenge()

func setup_firewall_challenge():
	is_game_over = false
	current_cli_mode = 0 
	step_ip_blocked = false
	
	if command_input: 
		command_input.text = ""
		
	var departments = [
		{"name": "Accounting", "ip": "192.168.1.50"},
		{"name": "HR", "ip": "192.168.2.10"},
		{"name": "Marketing", "ip": "192.168.3.99"},
		{"name": "R&D", "ip": "192.168.4.25"}
	]
	
	var selected = departments[randi() % departments.size()]
	target_dept = selected["name"]
	target_ip = selected["ip"] 
	
	if log_text_edit:
		log_text_edit.text = "--- FIREWALL ---\n"
		log_text_edit.text += "ALERT: Cyber Attack Detected on [" + target_dept + " Dept.]\n"

		_print_prompt()
		
	if command_input:
		command_input.call_deferred("grab_focus") # 🟢 ป้องกันโฟกัสหลุดตอนเริ่มเกม

func _print_prompt():
	if not log_text_edit: return
	match current_cli_mode:
		0: log_text_edit.text += "Router> "
		1: log_text_edit.text += "Router# "
		2: log_text_edit.text += "Router(config)# "
	_scroll_to_bottom()

func _on_line_edit_ip_text_submitted(new_text: String) -> void:
	if is_game_over or not is_visible_in_tree(): return
	
	var raw_command = new_text.strip_edges()
	if command_input: 
		command_input.text = "" 
		
	if raw_command == "": 
		_print_to_terminal("")
		_print_prompt()
		if command_input: 
			command_input.call_deferred("grab_focus")
		return
		
	if log_text_edit:
		log_text_edit.text += raw_command + "\n"
		
	await get_tree().create_timer(0.1).timeout
	_process_firewall_command(raw_command)
	
	if command_input:
		command_input.call_deferred("grab_focus") # 🟢 บังคับล็อกโฟกัสหลังพิมพ์เสร็จทุกครั้ง ไม่ต้องคอยกดคลิกใหม่

# ==============================================================================
# 🎮 CLI COMMAND PROCESSING (ACCESS-LIST UPDATE)
# ==============================================================================
func _process_firewall_command(raw_command: String):
	
	# 🟩 โหมดที่ 0: User Mode
	if current_cli_mode == 0:
		if raw_command == "enable":
			current_cli_mode = 1
		elif raw_command == "conf t" or raw_command.begins_with("access-list ") or raw_command == "exit" or raw_command == "ex" or raw_command == "save":
			_print_to_terminal("% Command rejected: ต้องกรอกคำสั่ง 'enable' เพื่อเข้าสิทธิ์แอดมินก่อน")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")

	# 🟩 โหมดที่ 1: Privileged EXEC Mode
	elif current_cli_mode == 1:
		if raw_command == "configure terminal" or raw_command == "conf t":
			current_cli_mode = 2
			_print_to_terminal("Enter configuration commands, one per line. End with 'exit' or 'ex'.")
		elif raw_command == "save":
			if step_ip_blocked:
				_print_to_terminal("\n🛡️ STATUS: ATTACK STOPPED! " + target_dept + " Dept. IS NOW SECURE.")
				_print_to_terminal("🟢 FIREWALL RULES SUCCESSFULLY SAVED.")
				_check_win_condition()
				if is_game_over: return
			else:
				_print_to_terminal("% Command rejected: คุณยังไม่ได้เขียนกฎบล็อก IP แฮกเกอร์เลย!")
		elif raw_command == "exit" or raw_command == "ex": 
			_print_to_terminal("% Connection closed.")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'conf t' เพื่อตั้งค่า หรือ 'save' เพื่อบันทึก)")

	# 🟩 โหมดที่ 2: Global Configuration Mode
	elif current_cli_mode == 2:
		
		# 🛑 ตรวจสอบคำสั่งขึ้นต้นด้วย access-list 1 deny 
		if raw_command.begins_with("access-list 1 deny "):
			var ip_arg = raw_command.replace("access-list 1 deny ", "").strip_edges()
			if ip_arg == target_ip: 
				step_ip_blocked = true
				_print_to_terminal("Success: Standard Access List 1 updated. Traffic from " + ip_arg + " is now dropped.")
			else:
				trigger_game_over("FATAL BLOCK ERROR:\nคุณใส่ IP ผิดพลาด! ไปสั่งบล็อกแผนกอื่นที่ไม่ได้โดนโจมตี ทำให้ระบบล่ม")
				return
		
		# ดักกรณีพิมพ์สั้นไป หรือพิมพ์ผิดรูปแบบ
		elif raw_command.begins_with("deny ip "):
			_print_to_terminal("% Invalid command: ในโหมดเลเยอร์นี้ ต้องระบุกลุ่มหมายเลขด้วย เช่น 'access-list 1 deny host [IP]'")
				
		elif raw_command == "save":
			_print_to_terminal("% Command rejected: ไม่สามารถเซฟในโหมดปรับแต่งได้ กรุณาพิมพ์ 'ex' ออกไปก่อน")
				
		elif raw_command == "exit" or raw_command == "ex": 
			current_cli_mode = 1
			_print_to_terminal("Leaving Configuration Mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่รองรับในโหมดนี้: 'access-list 1 deny [IP]', 'ex')")

	_print_prompt()

# ==============================================================================
# 🎯 3. SUB SYSTEMS
# ==============================================================================
func _print_to_terminal(text: String):
	if log_text_edit:
		log_text_edit.text += text + "\n"
		_scroll_to_bottom()

func _scroll_to_bottom():
	if log_text_edit:
		log_text_edit.scroll_vertical = log_text_edit.get_line_count()

func _check_win_condition():
	if "completed_modules_count" in Global:
		Global.completed_modules_count += 1
		
	is_game_over = true
	await get_tree().create_timer(1.5).timeout
	_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	Global.game_over_reason = "❌ FIREWALL SECURITY COLLAPSE\n" + reason_text
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()
