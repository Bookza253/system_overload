extends Control

# 📢 เพิ่มบรรทัดนี้ที่ด้านบนสุดของไฟล์ router_module.gd ด้วยครับงับ!
signal alert_status_changed(is_alert)

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
var step_ping_passed = false # 🌟 เพิ่มตัวแปรเช็กสถานะว่า ping ผ่านแล้ว
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
	
	# 🎹 เพิ่มบรรทัดนี้: เมื่อผู้เล่นพิมพ์ตัวหนังสือในช่อง LineEdit ให้เรียกฟังก์ชันทำเสียงพิมพ์
	if command_input:
		command_input.text_changed.connect(_on_line_edit_text_changed)

func setup_switch_challenge():
	is_game_over = false
	current_vlan_configured = false
	ping_success = false
	step_ping_passed = false # 🌟 รีเซ็ตสถานะ ping ผ่าน
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
		log_text_edit.text += "ALERT: Department [" + selected + "] link-state changed to DOWN (VLAN Mismatch).\n"

		_print_prompt()

	if command_input:
		command_input.call_deferred("grab_focus")

	# 🚨 ยิงสัญญาณเตือนภัยขอบแดงกะพริบทันทีเมื่อมินิเกมด่านนี้พร้อมรัน
	emit_signal("alert_status_changed", true)

# ฟังก์ชันพิมพ์สถานะโหมดเริ่มต้นของบรรทัด
func _print_prompt():
	if not log_text_edit: return
	match current_cli_mode:
		0: log_text_edit.text += "Switch> "
		1: log_text_edit.text += "Switch# "
		2: log_text_edit.text += "Switch(config)# "
		3: log_text_edit.text += "Switch(config-if)# "
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
	var low_cmd = raw_command.to_lower().strip_edges()
	
	# 🟢 โหมดที่ 0: User Mode
	if current_cli_mode == 0:
		if low_cmd == "enable":
			current_cli_mode = 1
		elif low_cmd.begins_with("ping ") or low_cmd.begins_with("interface ") or low_cmd.begins_with("int ") or low_cmd.begins_with("switchport ") or low_cmd == "exit" or low_cmd == "ex" or low_cmd == "save":
			_print_to_terminal("% Command rejected: ต้องพิมพ์ 'enable' ก่อนเข้าจัดการระบบ")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")
	
	# 🟢 โหมดที่ 1: Privileged EXEC Mode
	elif current_cli_mode == 1:
		if low_cmd == "configure terminal" or low_cmd == "conf t":
			current_cli_mode = 2
			_print_to_terminal("Enter configuration commands, one per line. End with CNTL/Z.")
		elif low_cmd.begins_with("ping "):
			var ip_arg = raw_command.replace("ping ", "").strip_edges()
			_print_to_terminal("Pinging " + ip_arg + " with 32 bytes of data:")
			
			await get_tree().create_timer(0.3).timeout
			if current_vlan_configured and ip_arg == target_ip:
				ping_success = true
				step_ping_passed = true # 🌟 ปรับสถานะว่า ping ผ่านแล้ว
				_print_to_terminal("Reply from " + ip_arg + ": bytes=32 time=4ms TTL=64")
				_print_to_terminal("📊 Ping statistics: Success Rate 100%")
			else:
				ping_success = false
				_print_to_terminal("Request timed out.")
				_print_to_terminal("📊 Ping statistics: Lost = 100% (Destination Host Unreachable)")
				
		# 🌟 เพิ่มระบบตรวจการพิมพ์คำสั่ง save ในโหมดนี้
		elif low_cmd == "save":
			if step_ping_passed:
				_print_to_terminal("\n🛡️ STATUS: VLAN RE-ASSIGNMENT ACTIVE & LOCKED!")
				_print_to_terminal("🟢 PORT " + target_port.to_upper() + " RUNNING ON VLAN " + str(target_vlan))
				_print_to_terminal("🟢 CONFIGURATION SUCCESSFULLY SAVED TO RUNNING-CONFIG.")
				_check_win_condition()
				if is_game_over: return
			else:
				_print_to_terminal("% Command rejected: ระบบยังทำงานไม่สมบูรณ์! กรุณาทำตามโจทย์และตรวจสอบผลการ ping ให้สำเร็จก่อน")
				
		elif low_cmd.begins_with("interface ") or low_cmd.begins_with("int ") or low_cmd.begins_with("switchport "):
			_print_to_terminal("% Command rejected: กรุณาเข้าโหมด Config โดยพิมพ์ 'conf t' ก่อน")
		elif low_cmd == "exit" or low_cmd == "ex":
			_print_to_terminal("% Connection closed.")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'conf t', 'ping [IP]' หรือ 'save')")

	# 🟢 โหมดที่ 2: Global Configuration Mode
	elif current_cli_mode == 2:
		if low_cmd.begins_with("interface ") or low_cmd.begins_with("int "):
			var port_arg = raw_command.replace("interface ", "").replace("int ", "").strip_edges()
			var check_port = port_arg.replace(" ", "") 
			var target_check = target_port.replace(" ", "")
			
			if check_port.to_lower() == target_check.to_lower():
				current_cli_mode = 3
				_print_to_terminal("Entered Interface configuration mode.")
			else:
				trigger_game_over("PORT ERROR:\nคุณเข้าพอร์ตผิดพลาด! พอร์ตนี้ไม่ได้เชื่อมต่อกับเป้าหมายที่เกิดปัญหา")
				return
				
		elif low_cmd.begins_with("switchport access vlan "):
			_print_to_terminal("% Command rejected: ต้องพิมพ์เข้าพอร์ตก่อน เช่น 'int " + target_port + "'")
		elif low_cmd == "save":
			_print_to_terminal("% Command rejected: ไม่สามารถบันทึกค่าในโหมดคอนฟิกได้ กรุณาพิมพ์ 'ex' ออกไปด้านนอกก่อน")
		elif low_cmd == "exit" or low_cmd == "ex":
			current_cli_mode = 1
			_print_to_terminal("Leaving Configuration Mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่รองรับในโหมดนี้: 'interface [ชื่อพอร์ต]', 'ex')")

	# 🟢 โหมดที่ 3: Interface Configuration Mode
	elif current_cli_mode == 3:
		if low_cmd.begins_with("switchport access vlan "):
			var vlan_arg = raw_command.replace("switchport access vlan ", "").strip_edges()
			if vlan_arg == str(target_vlan):
				current_vlan_configured = true
				_print_to_terminal("Success: Interface " + target_port + " moved to VLAN " + vlan_arg + ".")
			else:
				trigger_game_over("VLAN CRASH:\nคุณใส่หมายเลข VLAN ผิดพลาด ทำให้ระบบลูปชนกันเสียหาย!")
				return
		elif low_cmd == "save":
			_print_to_terminal("% Command rejected: ไม่สามารถบันทึกค่าในโหมดอินเตอร์เฟสได้ กรุณาพิมพ์ 'ex' ถอยออกไปก่อน")
		elif low_cmd == "exit" or low_cmd == "ex":
			current_cli_mode = 2
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
	if current_vlan_configured and ping_success and step_ping_passed:
		_print_to_terminal("\n🟢 SWITCH CONFIGURATION COMPLETE! NETWORK STABLE.")
		
		# ✅ ส่งสัญญาณบอกหน้าจอหลักว่า "แก้เสร็จแล้ว ดับขอบจอแดงได้!"
		emit_signal("alert_status_changed", false)
		
		if "completed_modules_count" in Global:
			Global.completed_modules_count += 1
			
		await get_tree().create_timer(1.5).timeout
		_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	Global.game_over_reason = reason_text
	
	# 🚨 ดับขอบจอแดงก่อนที่ระบบจะย้ายซีนไปหน้า Blue Screen
	emit_signal("alert_status_changed", false)
	
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()

# ==============================================================================
# 🔊 4. SFX SOUND CONTROLLER (ดึงเสียงตรงจาก AudioManager)
# ==============================================================================

# 🎹 ฟังก์ชันทำเสียงพิมพ์แกร๊ก ๆ
func _on_line_edit_text_changed(_new_text: String):
	if AudioManager and AudioManager.sfx_type:
		AudioManager.sfx_type.play()

# 🖱️ ฟังก์ชันดักจับเมาส์คลิกซ้ายบนหน้าต่างมินิเกมนี้ แล้วสั่งเล่นเสียงคลิก
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if AudioManager and AudioManager.sfx_click:
				AudioManager.sfx_click.play()
