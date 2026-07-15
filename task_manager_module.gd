extends Control

# ==============================================================================
# 📢 EVENT SIGNALS
# - alert_status_changed: ยิงสัญญาณสื่อสารเพื่อส่งสเตตัสแจ้งเตือนภัย/ความปลอดภัยกลับไปที่ Desktop หลัก
# ==============================================================================
signal alert_status_changed(is_alert)

# ==============================================================================
# 🚨 1. ONREADY VARIABLES (Safe Node Detection)
# - ดำเนินการตรวจสอบและดักจับอินสแตนซ์ของโหนดในระบบแบบ Fallback เพื่อความปลอดภัยในการเรียกใช้งาน
# ==============================================================================
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else null 
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

# ==============================================================================
# CHALLENGE SCENARIO PROPERTIES (Static Routing State)
# - ดึงและจัดเก็บค่าพารามิเตอร์ของระบบเครือข่ายจำลอง เพื่อนำมาเทียบความถูกต้อง (Matching Check)
# - current_cli_mode: ระดับสิทธิ์คำสั่งใน Cisco CLI (0: User, 1: Privileged, 2: Config Mode)
# ==============================================================================
var destination_name = ""
var target_network = ""
var target_mask = ""
var target_next_hop = ""

var is_game_over = false  
var current_cli_mode = 0 
var step_route_added = false

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
		
	setup_route_challenge()
	
	# 🎹 Dynamic Event Binding: ลิงก์ระบบเสียงพิมพ์คีย์บอร์ดเข้ากับสัญญาณพิมพ์ LineEdit
	if command_input:
		command_input.text_changed.connect(_on_line_edit_text_changed)

func setup_route_challenge():
	is_game_over = false
	current_cli_mode = 0 
	step_route_added = false
	
	if command_input: 
		command_input.text = ""
		
	# Pool ข้อมูลสำหรับด่านจัดการทิศทางเส้นทางข้อมูล (Routing Scenario Dataset)
	var scenarios = [
		{"dest": "HQ_Server", "net": "192.168.55.0", "mask": "255.255.255.0", "next": "192.168.1.1"},
		{"dest": "Branch_Office", "net": "192.168.50.0", "mask": "255.255.255.0", "next": "192.168.2.55"},
		{"dest": "Cloud_Storage", "net": "192.168.71.0", "mask": "255.255.255.0", "next": "192.168.10.254"}
	]
	
	# Random Scenario Generation: สุ่มดึงชุดข้อมูลออกมา 1 Scenario
	var selected = scenarios[randi() % scenarios.size()]
	destination_name = selected["dest"]
	target_network = selected["net"]
	target_mask = selected["mask"]
	target_next_hop = selected["next"]
	
	if log_text_edit:
		log_text_edit.text = "--- ROUTING ---\n"
		log_text_edit.text += "⚠️ ALERT: Connection to [" + destination_name + "] is DOWN! (No Route to Host)\n"
		_print_prompt()
		
	if command_input:
		command_input.call_deferred("grab_focus") # 🟢 ป้องกันการหลุดโฟกัสช่องรับข้อมูลในเธรดถัดไป

	# 🚨 ยิงสัญญาณบอก Desktop หลัก เพื่อเปิดเอฟเฟกต์สีแดงฉุกเฉินกะพริบทันทีเมื่อเริ่มมินิเกม
	emit_signal("alert_status_changed", true)

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
		
	# จำลองความหน่วงการประมวลผลคำสั่งของอุปกรณ์สวิตช์จริง (Execution Latency Simulation)
	await get_tree().create_timer(0.1).timeout
	_process_router_command(raw_command)
	
	if command_input:
		command_input.call_deferred("grab_focus") # 🟢 บังคับล็อกโฟกัสป้องกันการหลุดฟอร์มหลังประมวลผลเสร็จ

# ==============================================================================
# CLI COMMAND PROCESSING (STATIC ROUTE PARSING & VALIDATION)
# - ตรรกะตรวจเช็กคำสั่ง IP Route โดยทำการแยกพารามิเตอร์แบบ String Split
# - ควบคุมการทำงานของแต่ละระดับโหมด (User, Privileged, Global Config)
# ==============================================================================
func _process_router_command(raw_command: String):
	# Normalize Command String: แปลงค่าเป็นพิมพ์เล็กเพื่อใช้ตรวจสอบความปลอดภัยไวยากรณ์เบื้องต้น
	var low_raw = raw_command.to_lower().strip_edges()
	
	# 🟢 [Authorization Level 0]: User Exec Mode
	if current_cli_mode == 0:
		if low_raw == "enable":
			current_cli_mode = 1
		elif low_raw == "conf t" or low_raw.begins_with("ip route") or low_raw == "exit" or low_raw == "ex" or low_raw == "save":
			_print_to_terminal("% Command rejected: ต้องกรอกคำสั่ง 'enable' เพื่อเข้าสิทธิ์แอดมินก่อน")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")

	# 🟢 [Authorization Level 1]: Privileged EXEC Mode (โหมดกู้คืนข้อมูลระบบและบันทึกค่า)
	elif current_cli_mode == 1:
		if low_raw == "configure terminal" or low_raw == "conf t":
			current_cli_mode = 2
			_print_to_terminal("Enter configuration commands, one per line. End with 'exit' or 'ex'.")
		elif low_raw == "save":
			if step_route_added:
				_print_to_terminal("\n🛡️ STATUS: STATIC ROUTE ACTIVATED! ROUTE TO " + destination_name + " IS ONLINE.")
				_print_to_terminal("🟢 RUNNING CONFIGURATION SUCCESSFULLY SAVED.")
				_check_win_condition()
				if is_game_over: return
			else:
				_print_to_terminal("% Command rejected: เครือข่ายยังล่มอยู่! กรุณาเข้าไปตั้งค่าเส้นทางก่อน")
		elif low_raw == "exit" or low_raw == "ex":
			_print_to_terminal("% Connection closed.")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'conf t' เพื่อเข้าโหมดคอนฟิก หรือ 'save' เพื่อบันทึก)")

	# 🟢 [Authorization Level 2]: Global Configuration Mode (โหมดจัดเส้นทางการเชื่อมโยงเครือข่ายเสมือน)
	elif current_cli_mode == 2:
		
		# ดักตรวจสอบไวยากรณ์คำสั่งตั้งค่าเส้นทางเพื่อเชื่อมต่อเครือข่ายส่วนตัว (Static Routing Config Parser)
		if low_raw.begins_with("ip route "):
			var route_args = raw_command.replace("ip route ", "").strip_edges()
			var parts = route_args.split(" ", false)
			
			if parts.size() == 3:
				var input_net = parts[0]
				var input_mask = parts[1]
				var input_next = parts[2]
				
				# ตรวจสอบโครงสร้างและวิเคราะห์พารามิเตอร์ปลายทางที่ส่งเข้ามา
				if input_net == target_network and input_mask == target_mask and input_next == target_next_hop:
					step_route_added = true
					_print_to_terminal("Success: Static route added to routing table. Packet delivery test passed.")
				else:
					# Failure Defensive Logic: บันทึกกฎเส้นทางปลายทางผิดพิกัดส่งผลให้ Gateway ตัดการเชื่อมต่อทันที
					var fail_reason = "คุณป้อนพารามิเตอร์เส้นทางผิดพลาด! ข้อมูลไม่แมตช์กับเครือข่ายปลายทาง:\n"
					fail_reason += "ค่าที่คุณใส่: Net=" + input_net + " Mask=" + input_mask + " Next-Hop=" + input_next
					trigger_game_over(fail_reason)
					return
			else:
				_print_to_terminal("% Incomplete command: รูปแบบต้องเป็น 'ip route [Network] [Subnet_Mask] [Next_Hop]'")
		
		# Syntax Guard: ดักจับความผิดพลาดการรันคำสั่งบันทึกข้อมูลในชั้นที่ไม่เหมาะสม
		elif low_raw == "save":
			_print_to_terminal("% Command rejected: กรุณาพิมพ์ 'ex' ออกจากโหมดคอนฟิกก่อนจึงจะเซฟได้")
				
		elif low_raw == "exit" or low_raw == "ex": 
			current_cli_mode = 1
			_print_to_terminal("Leaving Configuration Mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่รองรับในโหมดนี้: 'ip route [Network] [Mask] [Next_Hop]', 'ex')")

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
	is_game_over = true
	
	# ✅ ดับระบบไซเรนแจ้งเตือนขอบสีแดงที่หน้าจอหลักทันทีเพื่อส่งมอบความปลอดภัยคืนระบบ
	emit_signal("alert_status_changed", false)
	
	if "completed_modules_count" in Global:
		Global.completed_modules_count += 1
		
	await get_tree().create_timer(1.5).timeout
	_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	
	# ✅ ยุติการแจ้งเตือนภัยบนเดสก์ท็อปชั่วคราวก่อนดำเนินการเปลี่ยน Scene-tree ไปยังหน้า Blue Screen
	emit_signal("alert_status_changed", false)
	
	Global.game_over_reason = "❌ ROUTING TABLE INVERSION\n" + reason_text
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()

func _on_panel_mouse_entered() -> void:
	pass # Reserved for potential panel highlighting logic

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
