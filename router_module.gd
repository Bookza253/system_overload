extends Control

# ==============================================================================
# 📢 EVENT SIGNALS
# ==============================================================================
signal alert_status_changed(is_alert)

# ==============================================================================
# 🚨 1. ONREADY VARIABLES
# ==============================================================================
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else null 
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

# ==============================================================================
# CHALLENGE SCENARIO PROPERTIES & DASHBOARD METRICS
# ==============================================================================
var target_vlan = 10
var target_port = "fa0/11"
var target_ip = "192.168.1.99"
var selected_department = "Marketing"

var current_vlan_configured = false
var ping_success = false
var step_ping_passed = false 
var is_game_over = false

var current_cli_mode = 0 

# 📊 ระบบเก็บสถิติด่านเพื่อส่งเข้า Dashboard
var start_time: float = 0.0
var wrong_commands_count: int = 0
var base_score: int = 1000

# ==============================================================================
# ⚙️ 2. CORE GAMEPLAY SIMULATION
# ==============================================================================
func _ready():
	if command_input: 
		command_input.text = ""
	if log_text_edit:
		log_text_edit.text = ""
		
	setup_switch_challenge()
	
	if command_input and not command_input.text_changed.is_connected(_on_line_edit_text_changed):
		command_input.text_changed.connect(_on_line_edit_text_changed)

func setup_switch_challenge():
	is_game_over = false
	current_vlan_configured = false
	ping_success = false
	step_ping_passed = false 
	current_cli_mode = 0 
	wrong_commands_count = 0
	start_time = Time.get_ticks_msec() / 1000.0 # เริ่มจับเวลาภารกิจ
	
	if command_input: 
		command_input.text = ""
	
	# ตั้งค่าโจทย์ให้ตรงกับ Scenario Briefing (ด่าน Marketing VLAN 10)
	target_vlan = 10
	target_port = "fa0/11"
	target_ip = "192.168.1.99"
	selected_department = "Marketing"
			
	if log_text_edit:
		log_text_edit.text = "--- VLAN ACCESS MANAGEMENT ---\n"
		log_text_edit.text += "Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M).\n"
		log_text_edit.text += "Device Boot Completed. Ready for configuration...\n"
		log_text_edit.text += "ALERT: Department [" + selected_department + "] link-state changed to DOWN (VLAN Mismatch).\n\n"
		_print_prompt()

	if command_input:
		command_input.call_deferred("grab_focus")

	emit_signal("alert_status_changed", true)

func _print_prompt():
	if not log_text_edit: return
	match current_cli_mode:
		0: log_text_edit.text += "Switch> "
		1: log_text_edit.text += "Switch# "
		2: log_text_edit.text += "Switch(config)# "
		3: log_text_edit.text += "Switch(config-if)# "
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
	_process_cli_command(raw_command)

	if command_input:
		command_input.call_deferred("grab_focus")

# ==============================================================================
# CLI COMMAND PROCESSING (WITH DYNAMIC SYNTAX SUPPORT)
# ==============================================================================
func _process_cli_command(raw_command: String):
	var low_cmd = raw_command.to_lower().strip_edges()
	
	# 🟢 [Level 0]: User Mode
	if current_cli_mode == 0:
		if low_cmd == "enable" or low_cmd == "en":
			current_cli_mode = 1
		elif low_cmd.begins_with("ping ") or low_cmd.begins_with("interface ") or low_cmd.begins_with("int ") or low_cmd.begins_with("switchport ") or low_cmd == "exit" or low_cmd == "ex" or low_cmd == "save":
			_print_to_terminal("% Command rejected: ต้องพิมพ์ 'enable' หรือ 'en' ก่อนเข้าจัดการระบบ")
			wrong_commands_count += 1
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")
			wrong_commands_count += 1
	
	# 🟢 [Level 1]: Privileged EXEC Mode
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
				step_ping_passed = true 
				_print_to_terminal("Reply from " + ip_arg + ": bytes=32 time=4ms TTL=64")
				_print_to_terminal("📊 Ping statistics: Success Rate 100%")
			else:
				ping_success = false
				_print_to_terminal("Request timed out.")
				_print_to_terminal("📊 Ping statistics: Lost = 100% (Destination Host Unreachable)")
				
		elif low_cmd == "save" or low_cmd == "do copy run start" or low_cmd == "wr":
			if step_ping_passed:
				_print_to_terminal("\n🛡️ STATUS: VLAN RE-ASSIGNMENT ACTIVE & LOCKED!")
				_print_to_terminal("🟢 PORT " + target_port.to_upper() + " RUNNING ON VLAN " + str(target_vlan))
				_print_to_terminal("🟢 CONFIGURATION SUCCESSFULLY SAVED TO RUNNING-CONFIG.")
				_check_win_condition()
				if is_game_over: return
			else:
				_print_to_terminal("% Command rejected: กรุณาแก้ไข VLAN และทดสอบ ping ให้สำเร็จก่อนทำการบันทึก")
				wrong_commands_count += 1
				
		elif low_cmd.begins_with("interface ") or low_cmd.begins_with("int ") or low_cmd.begins_with("switchport "):
			_print_to_terminal("% Command rejected: กรุณาเข้าโหมด Config โดยพิมพ์ 'conf t' ก่อน")
			wrong_commands_count += 1
		elif low_cmd == "exit" or low_cmd == "ex":
			current_cli_mode = 0
			_print_to_terminal("% Connection closed.")
		else:
			_print_to_terminal("% Unknown command. (คำสั่งที่แนะนำ: 'conf t', 'ping [IP]', 'save')")
			wrong_commands_count += 1

	# 🟢 [Level 2]: Global Configuration Mode
	elif current_cli_mode == 2:
		if low_cmd.begins_with("interface ") or low_cmd.begins_with("int "):
			var port_arg = raw_command.replace("interface ", "").replace("int ", "").strip_edges()
			var check_port = port_arg.replace(" ", "").to_lower() 
			var target_check = target_port.replace(" ", "").to_lower()
			
			if check_port == target_check:
				current_cli_mode = 3
				_print_to_terminal("Entered Interface configuration mode.")
			else:
				trigger_game_over("PORT ERROR:\nคุณเข้าพอร์ตผิดพลาด (" + port_arg + ")! พอร์ตนี้ไม่ได้เชื่อมต่อกับอุปกรณ์เป้าหมาย")
				return
				
		elif low_cmd.begins_with("switchport ") or low_cmd.begins_with("sw "):
			_print_to_terminal("% Command rejected: ต้องเข้าอินเตอร์เฟสพอร์ตก่อน เช่น 'int " + target_port + "'")
			wrong_commands_count += 1
		elif low_cmd == "save" or low_cmd == "wr":
			_print_to_terminal("% Command rejected: ไม่สามารถเซฟในโหมดนี้ได้ พิมพ์ 'ex' ออกไปโหมดด้านนอกก่อน")
			wrong_commands_count += 1
		elif low_cmd == "exit" or low_cmd == "ex":
			current_cli_mode = 1
			_print_to_terminal("Leaving Configuration Mode.")
		else:
			_print_to_terminal("% Invalid syntax. (พิมพ์ 'int " + target_port + "' เพื่อเข้าพอร์ต)")
			wrong_commands_count += 1

	# 🟢 [Level 3]: Interface Configuration Mode
	elif current_cli_mode == 3:
		# รองรับทั้ง 'switchport access vlan X' และคำสั่งย่อ 'sw acc vlan X'
		if low_cmd.begins_with("switchport access vlan ") or low_cmd.begins_with("sw acc vlan "):
			var vlan_arg = low_cmd.replace("switchport access vlan ", "").replace("sw acc vlan ", "").strip_edges()
			if vlan_arg == str(target_vlan):
				current_vlan_configured = true
				_print_to_terminal("Success: Interface " + target_port + " moved to VLAN " + vlan_arg + ".")
			else:
				trigger_game_over("VLAN CRASH:\nคุณใส่หมายเลข VLAN ผิด (" + vlan_arg + ") ทำให้ระบบเครือข่ายลูปชนกันล้มเหลว!")
				return
		elif low_cmd == "save" or low_cmd == "wr":
			_print_to_terminal("% Command rejected: กรุณาพิมพ์ 'ex' ออกไปโหมด EXEC ด้านนอกก่อนเซฟ")
			wrong_commands_count += 1
		elif low_cmd == "exit" or low_cmd == "ex":
			current_cli_mode = 2
			_print_to_terminal("Leaving Interface configuration mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่ถูกต้อง: 'sw acc vlan " + str(target_vlan) + "')")
			wrong_commands_count += 1

	_print_prompt()

# ==============================================================================
# 🎯 3. TERMINAL DISPLAY CONTROL & SCORE CALCULATION
# ==============================================================================
func _print_to_terminal(text: String):
	if log_text_edit:
		log_text_edit.text += text + "\n"
		_scroll_to_bottom()

func _scroll_to_bottom():
	if log_text_edit:
		log_text_edit.scroll_vertical = log_text_edit.get_line_count()

# ==============================================================================
# WIN/LOSS LIFE CYCLE & DASHBOARD DATA INTEGRATION
# ==============================================================================
func _check_win_condition():
	if current_vlan_configured and ping_success and step_ping_passed:
		_print_to_terminal("\n🟢 SWITCH CONFIGURATION COMPLETE! NETWORK STABLE.")
		emit_signal("alert_status_changed", false)
		
		# ⏱️ คำนวณเวลาที่ใช้ และคะแนนสะสม
		var time_taken = (Time.get_ticks_msec() / 1000.0) - start_time
		var final_score = max(300, base_score - (wrong_commands_count * 50) - int(time_taken * 2))
		
		# ⭐ คำนวณดาว (1 - 3 ดาว)
		var stars = 3
		if wrong_commands_count >= 3 or time_taken > 60:
			stars = 1
		elif wrong_commands_count >= 1 or time_taken > 35:
			stars = 2
			
		# 📊 อัปเดตข้อมูลลง Global เพื่อแสดงผลใน Dashboard หน้าหลัก
		if "level_data" in Global:
			Global.level_data["VLAN"] = {
				"cleared": true,
				"score": final_score,
				"stars": stars,
				"time_spent": int(time_taken)
			}
			
		if "completed_modules_count" in Global:
			Global.completed_modules_count += 1
		if "total_score" in Global:
			Global.total_score += final_score

		_print_to_terminal("🏆 SCORE: " + str(final_score) + " PTS | STARS: " + str(stars) + "★")
		
		await get_tree().create_timer(2.0).timeout
		_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	Global.game_over_reason = reason_text
	emit_signal("alert_status_changed", false)
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()

# ==============================================================================
# 🔊 4. HARDWARE INPUT SFX CONTROLLER
# ==============================================================================
func _on_line_edit_text_changed(_new_text: String):
	if AudioManager and AudioManager.sfx_type:
		AudioManager.sfx_type.play()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if AudioManager and AudioManager.sfx_click:
				AudioManager.sfx_click.play()
			
# 🟢 ตัวอย่างการเรียกใช้เมื่อผู้เล่นทำภารกิจสำเร็จ
func _check_mission_complete():
	# 1. คำนวณเวลาที่ใช้และข้อผิดพลาด
	var time_spent = 24       # เวลาที่ใช้จริง (SEC)
	var errors = 1           # จำนวนครั้งที่พิมพ์ผิด
	var total_score = 902    # คะแนนสุทธิ
	var stars = 2            # ดาวที่ได้ (1-3)
	
	# 2. สั่งให้ Pop-up สรุปผลเด้งขึ้นมา
	$StageClearPopup.setup_data("ROUTING", total_score, stars, time_spent, errors)
