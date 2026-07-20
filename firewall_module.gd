extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES (Safe Node Detection)
# - ตรวจสอบและดักจับอินสแตนซ์ของโหนดในระบบแบบ Fallback เพื่อความปลอดภัยในการเรียกใช้งาน
# - ป้องกันปัญหาความล่าช้าในการดึงโหนดขณะเริ่มต้นรันไทม์ (Null Instance Prevention)
# ==============================================================================
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else null 
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

# ==============================================================================
# CHALLENGE SCENARIO PROPERTIES
# - target_dept, target_ip: ข้อมูลแผนกและไอพีปลายทางที่ระบบสุ่มขึ้นมาเพื่อเป็นโจทย์
# - current_cli_mode: ระดับสิทธิ์คำสั่งใน Cisco CLI (0: User, 1: Privileged, 2: Config Mode)
# ==============================================================================
var target_dept = ""
var target_ip = "" 

var is_game_over = false
var current_cli_mode = 0 
var step_ip_blocked = false

# ==============================================================================
# ⚙️ SYSTEM INITIALIZATION (LIFE CYCLE)
# - จัดเตรียมสถานะเริ่มต้นของ UI และล้างค่าประวัติ Terminal 
# - ทำการลงทะเบียนเชื่อมโยง Event สัญญาณพิมพ์คีย์บอร์ดเข้ากับ AudioManager แบบ Dynamic
# ==============================================================================
func _ready():
	if command_input: 
		command_input.text = ""
	if log_text_edit:
		log_text_edit.text = ""
		
	setup_firewall_challenge()
	
	# 🎹 Dynamic Event Binding: ลิงก์ระบบเสียงพิมพ์กับสัญญาณการกดแป้นพิมพ์
	if command_input:
		command_input.text_changed.connect(_on_line_edit_text_changed)

func setup_firewall_challenge():
	is_game_over = false
	current_cli_mode = 0 
	step_ip_blocked = false
	
	if command_input: 
		command_input.text = ""
		
	# Pool ข้อมูลสำหรับการจำลองสถานการณ์สุ่มรับมือภัยคุกคาม (Simulation Scenario Dataset)
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
		command_input.call_deferred("grab_focus") # 🟢 บังคับจับโฟกัสช่องรับข้อมูลในเธรดถัดไปทันที เพื่อลดข้อผิดพลาดของการรับอินพุต

# ==============================================================================
# CLI COMMAND PROCESSING (ACCESS-LIST SECURITY RULE PARSING)
# - ตรรกะแยกย่อยตามลำดับขั้นของสิทธิ์สวิตช์ควบคุม (Cisco CLI Authorization Levels)
# - ตรวจจับไวยากรณ์คำสั่งมาตรฐานของ ACL (Standard Access Control List Rule Definition)
# ==============================================================================
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
		
	# รันจังหวะประมวลผลคำสั่งแบบดีเลย์สั้นเพื่อจำลองความหน่วงของการตอบสนองฮาร์ดแวร์จริง (Latency Simulation)
	await get_tree().create_timer(0.1).timeout
	_process_firewall_command(raw_command)
	
	if command_input:
		command_input.call_deferred("grab_focus") # 🟢 ป้องกันการหลุดโฟกัสหลังการประมวลผลคำสั่งเสร็จสิ้น

func _process_firewall_command(raw_command: String):
	# แปลงคำสั่งที่รับมาเป็นตัวพิมพ์เล็กทั้งหมด และตัดช่องว่างส่วนเกินหัว-ท้ายออกเพื่อความปลอดภัย
	var clean_cmd = raw_command.strip_edges().to_lower()
	
	# 🟩 [Authorization Mode 0]: User Mode (ตรวจสอบสิทธิ์การไต่ระดับระบบ)
	if current_cli_mode == 0:
		if clean_cmd == "enable" or clean_cmd == "en":
			current_cli_mode = 1
		elif clean_cmd == "conf t" or clean_cmd.begins_with("access-list") or clean_cmd == "exit" or clean_cmd == "ex" or clean_cmd == "save":
			_print_to_terminal("% Command rejected: ต้องกรอกคำสั่ง 'enable' เพื่อเข้าสิทธิ์แอดมินก่อน")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")

	# 🟩 [Authorization Mode 1]: Privileged EXEC Mode (โหมดจัดการข้อมูลบันทึกและพอร์ต)
	elif current_cli_mode == 1:
		if clean_cmd == "configure terminal" or clean_cmd == "conf t":
			current_cli_mode = 2
			_print_to_terminal("Enter configuration commands, one per line. End with 'exit' or 'ex'.")
		elif clean_cmd == "save":
			if step_ip_blocked:
				_print_to_terminal("\n🛡️ STATUS: ATTACK STOPPED! " + target_dept + " Dept. IS NOW SECURE.")
				_print_to_terminal("🟢 FIREWALL RULES SUCCESSFULLY SAVED.")
				_check_win_condition()
				if is_game_over: return
			else:
				_print_to_terminal("% Command rejected: คุณยังไม่ได้เขียนกฎบล็อก IP แฮกเกอร์เลย!")
		elif clean_cmd == "exit" or clean_cmd == "ex": 
			_print_to_terminal("% Connection closed.")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'conf t' เพื่อตั้งค่า หรือ 'save' เพื่อบันทึก)")

	# 🟩 [Authorization Mode 2]: Global Configuration Mode (โหมดแก้ไขไฟล์การตั้งค่าระบบหลัก)
	elif current_cli_mode == 2:
		
		# ดักจับคำสั่งวิเคราะห์พารามิเตอร์การตั้งค่ากฎ ACL (รองรับทั้งแบบเคาะเว้นวรรคเดี่ยวและหลายช่อง)
		if clean_cmd.begins_with("access-list 1 deny"):
			# แยกดึงเอาไอพีอาร์กิวเมนต์ตัวท้ายสุดออกมาตรวจสอบ
			var parts = clean_cmd.split(" ", false)
			var ip_arg = ""
			if parts.size() >= 5:
				ip_arg = parts[4].strip_edges() # ดึงค่าบล็อกลำดับที่ 5 (ต่อจาก access-list 1 deny)
			else:
				ip_arg = clean_cmd.replace("access-list 1 deny", "").strip_edges()
				
			if ip_arg == target_ip.to_lower() or ip_arg == "host " + target_ip.to_lower() or ip_arg.contains(target_ip.to_lower()): 
				step_ip_blocked = true
				_print_to_terminal("Success: Standard Access List 1 updated. Traffic from " + target_ip + " is now dropped.")
			else:
				# ป้องกันเผื่อผู้เรียนพิมพ์คำสั่ง ACL ขาดพิมพ์ไม่ครบ ไม่ให้ปรับแพ้ทันที ให้โอกาสพิมพ์ใหม่
				if ip_arg == "":
					_print_to_terminal("% Incomplete command: กรุณาระบุ IP ที่ต้องการบล็อกด้วย")
				else:
					# Defensive Failure Logic: กรณีใส่ไอพีของแผนกปกติจะส่งผลให้ระบบการสื่อสารภายในพังทลาย
					trigger_game_over("FATAL BLOCK ERROR:\nคุณใส่ IP ผิดพลาด! ไปสั่งบล็อกแผนกอื่นที่ไม่ได้โดนโจมตี ทำให้ระบบล่ม")
					return
		
		# ระบบตรวจจับแจ้งความผิดพลาดเพื่อแนะนำรูปแบบไวยากรณ์ (Syntax Suggestion Parser)
		elif clean_cmd.begins_with("deny ip "):
			_print_to_terminal("% Invalid command: ในโหมดเลเยอร์นี้ ต้องระบุกลุ่มหมายเลขด้วย เช่น 'access-list 1 deny [IP]'")
				
		elif clean_cmd == "save":
			_print_to_terminal("% Command rejected: ไม่สามารถเซฟในโหมดปรับแต่งได้ กรุณาพิมพ์ 'ex' ออกไปก่อน")
				
		elif clean_cmd == "exit" or clean_cmd == "ex": 
			current_cli_mode = 1
			_print_to_terminal("Leaving Configuration Mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่รองรับในโหมดนี้: 'access-list 1 deny [IP]', 'ex')")

	_print_prompt()

# ==============================================================================
# 🎯 TERMINAL DISPLAY CONTROL SUB-SYSTEMS
# ==============================================================================
func _print_to_terminal(text: String):
	if log_text_edit:
		log_text_edit.text += text + "\n"
		_scroll_to_bottom()

func _scroll_to_bottom():
	if log_text_edit:
		log_text_edit.scroll_vertical = log_text_edit.get_line_count()

# ==============================================================================
# WIN/LOSS STATE HANDLERS
# ==============================================================================
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

# ==============================================================================
# 🔊 SFX SOUND CONTROL (Autoload Bridge)
# ==============================================================================
func _on_line_edit_text_changed(_new_text: String):
	if AudioManager and AudioManager.sfx_type:
		AudioManager.sfx_type.play()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if AudioManager and AudioManager.sfx_click:
				AudioManager.sfx_click.play()
