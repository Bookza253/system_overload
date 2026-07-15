extends Control

# ==============================================================================
# 📢 EVENT SIGNALS
# - alert_status_changed: ยิงสัญญาณสื่อสารเพื่อส่งสเตตัสแจ้งเตือนภัย/ความปลอดภัยกลับไปที่ Desktop หลัก
# ==============================================================================
signal alert_status_changed(is_alert)

# ==============================================================================
# 🚨 1. ONREADY VARIABLES (Safe Node Lifecycle Detection)
# - ดำเนินการตรวจสอบโครงสร้างโหนดแบบ Fallback เพื่อความปลอดภัยในการเรียกใช้งานโหนดแสดงผล
# - ป้องกันปัญหาความล่าช้าในการดึงโหนดขณะเริ่มต้นรันไทม์ (Null Instance Prevention)
# ==============================================================================
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else null 
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

# ==============================================================================
# CHALLENGE SCENARIO PROPERTIES (VLAN Configuration State)
# - เก็บค่าพารามิเตอร์ของระบบเครือข่ายจำลอง เพื่อนำมาเทียบความถูกต้อง (Matching Check)
# - current_cli_mode: ระดับสิทธิ์คำสั่งใน Cisco CLI (0: User, 1: Privileged, 2: Config, 3: Interface Mode)
# ==============================================================================
var target_vlan = 0
var target_port = ""
var target_ip = ""

var current_vlan_configured = false
var ping_success = false
var step_ping_passed = false 
var is_game_over = false

var current_cli_mode = 0 

# ==============================================================================
# ⚙️ 2. CORE GAMEPLAY SIMULATION (Life Cycle Methods)
# - จัดเตรียมสถานะเริ่มต้นของ UI และตั้งค่าโจทย์จำลองประจำสถานการณ์
# - ดำเนินการผูกสัญญาณ Event-Driven เข้ากับระบบเสียง SFX ของ AudioManager
# ==============================================================================
func _ready():
	if command_input: 
		command_input.text = ""
	if log_text_edit:
		log_text_edit.text = ""
		
	setup_switch_challenge()
	
	# 🎹 Dynamic Event Binding: ลิงก์ระบบเสียงพิมพ์คีย์บอร์ดเข้ากับสัญญาณพิมพ์ LineEdit
	if command_input:
		command_input.text_changed.connect(_on_line_edit_text_changed)

func setup_switch_challenge():
	is_game_over = false
	current_vlan_configured = false
	ping_success = false
	step_ping_passed = false 
	current_cli_mode = 0 
	
	if command_input: 
		command_input.text = ""
	
	# Pool ข้อมูลสำหรับด่านการกำหนดค่าพอร์ตเสมือนแบ่งกลุ่มเครือข่าย (VLAN Access Scenario Dataset)
	var scenarios = ["Marketing", "Engineering", "Guest_WiFi"]
	var selected = scenarios[randi() % scenarios.size()]
	
	# Random Scenario Generation: สุ่มดึงชุดข้อมูลออกมา 1 Scenario
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
		command_input.call_deferred("grab_focus") # 🟢 บังคับจับโฟกัสช่องรับข้อมูลในเธรดถัดไปทันที เพื่อความเสถียรของคีย์บอร์ดอินพุต

	# 🚨 ยิงสัญญาณบอก Desktop หลัก เพื่อเปิดเอฟเฟกต์สีแดงฉุกเฉินกะพริบทันทีเมื่อเริ่มมินิเกม
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
	
	# จำลองความหน่วงการประมวลผลคำสั่งของอุปกรณ์สวิตช์จริง (Execution Latency Simulation)
	await get_tree().create_timer(0.1).timeout
	_process_cli_command(raw_command)

	if command_input:
		command_input.call_deferred("grab_focus") # 🟢 บังคับล็อกโฟกัสป้องกันการหลุดฟอร์มหลังประมวลผลเสร็จ

# ==============================================================================
# CLI COMMAND PROCESSING (VLAN PORT ASSIGNMENT & ICMP PING CHECK)
# - ตรรกะคัดกรองระดับสิทธิ์คำสั่ง Cisco CLI (Switch Authorization Level Parsing)
# - ควบคุมการทำงานของแต่ละระดับโหมด (User, Privileged, Global Config, Interface Config)
# ==============================================================================
func _process_cli_command(raw_command: String):
	var low_cmd = raw_command.to_lower().strip_edges()
	
	# 🟢 [Authorization Level 0]: User Mode (ตรวจสอบสิทธิ์ความปลอดภัยขั้นต้น)
	if current_cli_mode == 0:
		if low_cmd == "enable":
			current_cli_mode = 1
		elif low_cmd.begins_with("ping ") or low_cmd.begins_with("interface ") or low_cmd.begins_with("int ") or low_cmd.begins_with("switchport ") or low_cmd == "exit" or low_cmd == "ex" or low_cmd == "save":
			_print_to_terminal("% Command rejected: ต้องพิมพ์ 'enable' ก่อนเข้าจัดการระบบ")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")
	
	# 🟢 [Authorization Level 1]: Privileged EXEC Mode (โหมดตรวจสอบและทดสอบสัญญาณด้วย ICMP)
	elif current_cli_mode == 1:
		if low_cmd == "configure terminal" or low_cmd == "conf t":
			current_cli_mode = 2
			_print_to_terminal("Enter configuration commands, one per line. End with CNTL/Z.")
		elif low_cmd.begins_with("ping "):
			var ip_arg = raw_command.replace("ping ", "").strip_edges()
			_print_to_terminal("Pinging " + ip_arg + " with 32 bytes of data:")
			
			await get_tree().create_timer(0.3).timeout
			# จำลองผลการตอบรับการติดต่อ (ICMP Echo Reply Success Simulation) เมื่อตั้งค่า VLAN ตรงตามพารามิเตอร์ไอพีโจทย์
			if current_vlan_configured and ip_arg == target_ip:
				ping_success = true
				step_ping_passed = true 
				_print_to_terminal("Reply from " + ip_arg + ": bytes=32 time=4ms TTL=64")
				_print_to_terminal("📊 Ping statistics: Success Rate 100%")
			else:
				ping_success = false
				_print_to_terminal("Request timed out.")
				_print_to_terminal("📊 Ping statistics: Lost = 100% (Destination Host Unreachable)")
				
		# Save Guard Handler: บันทึกค่าคอนฟิกไปเป็น Running Config เมื่อทำแบบทดสอบผ่านแล้ว
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

	# 🟢 [Authorization Level 2]: Global Configuration Mode (โหมดระดับการคัดแยกพอร์ตอินเตอร์เฟส)
	elif current_cli_mode == 2:
		if low_cmd.begins_with("interface ") or low_cmd.begins_with("int "):
			var port_arg = raw_command.replace("interface ", "").replace("int ", "").strip_edges()
			var check_port = port_arg.replace(" ", "") 
			var target_check = target_port.replace(" ", "")
			
			if check_port.to_lower() == target_check.to_lower():
				current_cli_mode = 3
				_print_to_terminal("Entered Interface configuration mode.")
			else:
				# Failure Defensive Logic: กรณีการระบุพอร์ตสื่อสารผิดช่องพิกัดจะส่งผลให้ระบบป้องกันดักจับเกมโอเวอร์ทันที
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

	# 🟢 [Authorization Level 3]: Interface Configuration Mode (โหมดระดับการผูกความสัมพันธ์ของพอร์ตกับกลุ่ม VLAN)
	elif current_cli_mode == 3:
		if low_cmd.begins_with("switchport access vlan "):
			var vlan_arg = raw_command.replace("switchport access vlan ", "").strip_edges()
			if vlan_arg == str(target_vlan):
				current_vlan_configured = true
				_print_to_terminal("Success: Interface " + target_port + " moved to VLAN " + vlan_arg + ".")
			else:
				# Failure Defensive Logic: บันทึกกฎเสมือนผิดประเภทส่งผลให้เครือข่ายเกิดสภาวะ Broadcast Storm
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
# 🎯 3. TERMINAL DISPLAY CONTROL SUB-SYSTEMS
# - ฟังก์ชันการควบคุมการแสดงผลกล่องข้อความและระบบจัดหน้าจออย่างราบรื่นไม่ติดขัด
# ==============================================================================
func _print_to_terminal(text: String):
	if log_text_edit:
		log_text_edit.text += text + "\n"
		_scroll_to_bottom()

func _scroll_to_bottom():
	if log_text_edit:
		log_text_edit.scroll_vertical = log_text_edit.get_line_count()

# ==============================================================================
# STATE TRANSITIONS (WIN/LOSS LIFE CYCLE)
# ==============================================================================
func _check_win_condition():
	if current_vlan_configured and ping_success and step_ping_passed:
		_print_to_terminal("\n🟢 SWITCH CONFIGURATION COMPLETE! NETWORK STABLE.")
		
		# ✅ ดับระบบไซเรนแจ้งเตือนขอบสีแดงที่หน้าจอหลักทันทีเพื่อส่งมอบความปลอดภัยคืนระบบ
		emit_signal("alert_status_changed", false)
		
		if "completed_modules_count" in Global:
			Global.completed_modules_count += 1
			
		await get_tree().create_timer(1.5).timeout
		_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	Global.game_over_reason = reason_text
	
	# ✅ ยุติการแจ้งเตือนภัยบนเดสก์ท็อปชั่วคราวก่อนดำเนินการเปลี่ยน Scene-tree ไปยังหน้า Blue Screen
	emit_signal("alert_status_changed", false)
	
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()

# ==============================================================================
# 🔊 4. HARDWARE INPUT SFX CONTROLLER (Autoload Integration)
# ==============================================================================
func _on_line_edit_text_changed(_new_text: String):
	if AudioManager and AudioManager.sfx_type:
		AudioManager.sfx_type.play()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if AudioManager and AudioManager.sfx_click:
				AudioManager.sfx_click.play()
