extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES
# ==============================================================================
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else null 
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

var target_vlan = 0
var target_port = ""
var target_ip = ""

var current_vlan_configured = false
var ping_success = false
var is_game_over = false

# 🔑 ระดับสถานะโหมด CLI (0: User Mode, 1: Privileged Mode, 2: Config Mode, 3: Interface Mode)
var current_cli_mode = 0 

# ==============================================================================
# ⚙️ 2. MAIN SIMULATOR SYSTEM
# ==============================================================================
func _ready():
	if command_input: 
		command_input.text = ""
	if log_text_edit:
		log_text_edit.text = ""
		
	setup_switch_challenge()

func setup_switch_challenge():
	is_game_over = false
	current_vlan_configured = false
	ping_success = false
	current_cli_mode = 0 
	
	if command_input: 
		command_input.text = ""
	
	var scenarios = ["Marketing", "Engineering", "Guest_WiFi"]
	var selected = scenarios[randi() % scenarios.size()]
	
	match selected:
		"Marketing":
			target_vlan = 10
			target_port = "fa0/11"
			target_ip = "192.168.1.99"
		"Engineering":
			target_vlan = 20
			target_port = "fa0/25"
			target_ip = "192.168.2.99"
		"Guest_WiFi":
			target_vlan = 30
			target_port = "fa0/17"
			target_ip = "192.168.3.77"
			
	if log_text_edit:
		log_text_edit.text = "--- VLAN ---\n"
		log_text_edit.text += "Device Boot Completed. Ready for configuration...\n"
		log_text_edit.text += "ALERT: Port " + target_port + " link-state changed to DOWN (VLAN Mismatch).\n"

		_print_prompt()

	if command_input:
		command_input.call_deferred("grab_focus")

# ฟังก์ชันพิมพ์สถานะโหมดเริ่มต้นของบรรทัด
func _print_prompt():
	if not log_text_edit: return
	match current_cli_mode:
		0: log_text_edit.text += "Switch> "
		1: log_text_edit.text += "Switch# "
		2: log_text_edit.text += "Switch(config)# "
		3: log_text_edit.text += "Switch(config-if)# " # 🟢 เพิ่ม Prompt โหมด Interface
	_scroll_to_bottom()

# 🚀 ฟังก์ชันเชื่อมสัญญาณกด Enter จากช่องพิมพ์ด้านล่าง (LineEdit_IP)
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
	
	_process_cli_command(raw_command)

	if command_input:
		command_input.call_deferred("grab_focus")

# ระบบตัวจำลองการตรวจคำสั่ง
func _process_cli_command(raw_command: String):
	# 🟢 โหมดที่ 0: User Mode
	if current_cli_mode == 0:
		if raw_command == "enable":
			current_cli_mode = 1
		elif raw_command.begins_with("ping ") or raw_command.begins_with("interface ") or raw_command.begins_with("int ") or raw_command.begins_with("switchport ") or raw_command == "exit" or raw_command == "ex":
			_print_to_terminal("% Command rejected: ต้องพิมพ์ 'enable' ก่อนเข้าจัดการระบบ")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")
	
	# 🟢 โหมดที่ 1: Privileged EXEC Mode
	elif current_cli_mode == 1:
		if raw_command == "configure terminal" or raw_command == "conf t":
			current_cli_mode = 2
			_print_to_terminal("Enter configuration commands, one per line. End with CNTL/Z.")
		elif raw_command.begins_with("ping "):
			var ip_arg = raw_command.replace("ping ", "").strip_edges()
			_print_to_terminal("Pinging " + ip_arg + " with 32 bytes of data:")
			
			await get_tree().create_timer(0.3).timeout
			if current_vlan_configured and ip_arg == target_ip:
				ping_success = true
				_print_to_terminal("Reply from " + ip_arg + ": bytes=32 time=4ms TTL=64")
				_print_to_terminal("📊 Ping statistics: Success Rate 100%")
				_check_win_condition()
				if is_game_over: return
			else:
				ping_success = false
				_print_to_terminal("Request timed out.")
				_print_to_terminal("📊 Ping statistics: Lost = 100% (Destination Host Unreachable)")
		elif raw_command.begins_with("interface ") or raw_command.begins_with("int ") or raw_command.begins_with("switchport "):
			_print_to_terminal("% Command rejected: กรุณาเข้าโหมด Config โดยพิมพ์ 'conf t' ก่อน")
		elif raw_command == "exit" or raw_command == "ex":
			_print_to_terminal("% Connection closed.")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'conf t' หรือ 'ping [IP]')")

	# 🟢 โหมดที่ 2: Global Configuration Mode
	elif current_cli_mode == 2:
		# ตรวจสอบการพิมพ์เข้า Port (รองรับทั้งคำเต็ม 'interface' และคำย่อ 'int')
		if raw_command.begins_with("interface ") or raw_command.begins_with("int "):
			var port_arg = raw_command.replace("interface ", "").replace("int ", "").strip_edges()
			
			# แปลงฟอร์แมตตัวย่อ (เช่น fa 0/1 หรือ fa0/1 ให้เข้าใจตรงกัน)
			var check_port = port_arg.replace(" ", "") 
			var target_check = target_port.replace(" ", "")
			
			if check_port == target_check:
				current_cli_mode = 3 # ➡️ ย้ายเข้าสู่โหมด Interface
				_print_to_terminal("Entered Interface configuration mode.")
			else:
				trigger_game_over("PORT ERROR:\nคุณเข้าพอร์ตผิดพลาด! พอร์ตนี้ไม่ได้เชื่อมต่อกับเป้าหมายที่เกิดปัญหา")
				return
				
		elif raw_command.begins_with("switchport access vlan "):
			_print_to_terminal("% Command rejected: ต้องพิมพ์เข้าพอร์ตก่อน เช่น 'int " + target_port + "'")
		elif raw_command == "exit" or raw_command == "ex":
			current_cli_mode = 1
			_print_to_terminal("Leaving Configuration Mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่รองรับในโหมดนี้: 'interface [ชื่อพอร์ต]', 'ex')")

	# 🟢 โหมดที่ 3: Interface Configuration Mode (โหมดที่เพิ่มขึ้นมาใหม่)
	elif current_cli_mode == 3:
		if raw_command.begins_with("switchport access vlan "):
			var vlan_arg = raw_command.replace("switchport access vlan ", "").strip_edges()
			if vlan_arg == str(target_vlan):
				current_vlan_configured = true
				_print_to_terminal("Success: Interface " + target_port + " moved to VLAN " + vlan_arg + ".")
				_print_to_terminal("ℹ️ [System]: ตั้งค่าเสร็จแล้ว พิมพ์ 'ex' ถอยออกไปเรื่อยๆ จนถึงโหมดปกติเพื่อลอง ping")
			else:
				trigger_game_over("VLAN CRASH:\nคุณใส่หมายเลข VLAN ผิดพลาด ทำให้ระบบลูปชนกันเสียหาย!")
				return
		elif raw_command == "exit" or raw_command == "ex":
			current_cli_mode = 2 # ⬅️ ถอยกลับมาที่โหมด Global Config ก่อนหนึ่งขั้น
			_print_to_terminal("Leaving Interface configuration mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่รองรับในโหมดนี้: 'switchport access vlan [เลข]', 'ex')")

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
	if current_vlan_configured and ping_success:
		_print_to_terminal("\n🟢 SWITCH CONFIGURATION COMPLETE! NETWORK STABLE.")
		if "completed_modules_count" in Global:
			Global.completed_modules_count += 1
			
		await get_tree().create_timer(1.5).timeout
		_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	Global.game_over_reason = reason_text
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()
