extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES
# ==============================================================================
@onready var log_text_edit = $Panel/TextEdit_Log if has_node("Panel/TextEdit_Log") else null 
@onready var command_input = $Panel/LineEdit_IP if has_node("Panel/LineEdit_IP") else null 

# ข้อมูล Scenario เครือข่ายปลายทางที่ขาดหายไป
var destination_name = ""
var target_network = ""
var target_mask = ""
var target_next_hop = ""

var is_game_over = false  
var current_cli_mode = 0 # 0: User, 1: Privileged, 2: Config Mode
var step_route_added = false

# ==============================================================================
# ⚙️ 2. MAIN SIMULATOR SYSTEM
# ==============================================================================
func _ready():
	if command_input: 
		command_input.text = ""
	if log_text_edit:
		log_text_edit.text = ""
		
	setup_route_challenge()

func setup_route_challenge():
	is_game_over = false
	current_cli_mode = 0 
	step_route_added = false
	
	if command_input: 
		command_input.text = ""
		
	# สุ่มเลือก Scenario เส้นทางเน็ตเวิร์กที่ล่ม
	var scenarios = [
		{"dest": "HQ_Server", "net": "192.168.55.0", "mask": "255.255.255.0", "next": "192.168.1.1"},
		{"dest": "Branch_Office", "net": "192.168.50.0", "mask": "255.255.255.0", "next": "192.168.2.55"},
		{"dest": "Cloud_Storage", "net": "192.168.71.0", "mask": "255.255.255.0", "next": "192.168.10.254"}
	]
	
	var selected = scenarios[randi() % scenarios.size()]
	destination_name = selected["dest"]
	target_network = selected["net"]
	target_mask = selected["mask"]
	target_next_hop = selected["next"]
	
	if log_text_edit:
		log_text_edit.text = "--- SWITCH OS TERMINAL ---\n"
		log_text_edit.text += "⚠️ ALERT: Connection to [" + destination_name + "] is DOWN! (No Route to Host)\n"
		log_text_edit.text += "Required Path: Network: " + target_network + " | Mask: " + target_mask + " | Next-Hop: " + target_next_hop + "\n"
		_print_prompt()
		
	if command_input:
		command_input.call_deferred("grab_focus")

func _print_prompt():
	if not log_text_edit: return
	match current_cli_mode:
		0: log_text_edit.text += "Switch> "
		1: log_text_edit.text += "Switch# "
		2: log_text_edit.text += "Switch(config)# "
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
	_process_router_command(raw_command)
	
	if command_input:
		command_input.call_deferred("grab_focus")

# ==============================================================================
# 🎮 CLI COMMAND PROCESSING (IP ROUTE SYSTEM)
# ==============================================================================
func _process_router_command(raw_command: String):
	
	# 🟩 โหมดที่ 0: User Mode
	if current_cli_mode == 0:
		if raw_command == "enable":
			current_cli_mode = 1
		elif raw_command == "conf t" or raw_command.begins_with("ip route") or raw_command == "exit" or raw_command == "ex" or raw_command == "save":
			_print_to_terminal("% Command rejected: ต้องกรอกคำสั่ง 'enable' เพื่อเข้าสิทธิ์แอดมินก่อน")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'enable' เพื่อเริ่มต้น)")

	# 🟩 โหมดที่ 1: Privileged EXEC Mode
	elif current_cli_mode == 1:
		if raw_command == "configure terminal" or raw_command == "conf t":
			current_cli_mode = 2
			_print_to_terminal("Enter configuration commands, one per line. End with 'exit' or 'ex'.")
		elif raw_command == "save":
			if step_route_added:
				_print_to_terminal("\n🛡️ STATUS: STATIC ROUTE ACTIVATED! ROUTE TO " + destination_name + " IS ONLINE.")
				_print_to_terminal("🟢 RUNNING CONFIGURATION SUCCESSFULLY SAVED.")
				_check_win_condition()
				if is_game_over: return
			else:
				_print_to_terminal("% Command rejected: เครือข่ายยังล่มอยู่! กรุณาเข้าไปตั้งค่าเส้นทางก่อน")
		elif raw_command == "exit" or raw_command == "ex":
			_print_to_terminal("% Connection closed.")
		else:
			_print_to_terminal("% Unknown command. (พิมพ์ 'conf t' เพื่อเข้าโหมดคอนฟิก หรือ 'save' เพื่อบันทึก)")

	# 🟩 โหมดที่ 2: Global Configuration Mode
	elif current_cli_mode == 2:
		
		# 🛑 ตรวจสอบคำสั่งตั้งค่าเส้นทาง ip route
		if raw_command.begins_with("ip route "):
			var route_args = raw_command.replace("ip route ", "").strip_edges()
			var parts = route_args.split(" ", false)
			
			if parts.size() == 3:
				var input_net = parts[0]
				var input_mask = parts[1]
				var input_next = parts[2]
				
				if input_net == target_network and input_mask == target_mask and input_next == target_next_hop:
					step_route_added = true
					_print_to_terminal("Success: Static route added to routing table. Packet delivery test passed.")
					_print_to_terminal("ℹ️ [System]: พิมพ์ 'ex' ออกไปด้านนอก แล้วสั่ง 'save' เพื่อเปิดใช้งานระบบถาวร")
				else:
					var fail_reason = "คุณป้อนพารามิเตอร์เส้นทางผิดพลาด! ข้อมูลไม่แมตช์กับเครือข่ายปลายทาง:\n"
					fail_reason += "ค่าที่คุณใส่: Net=" + input_net + " Mask=" + input_mask + " Next-Hop=" + input_next
					trigger_game_over(fail_reason)
					return
			else:
				_print_to_terminal("% Incomplete command: รูปแบบต้องเป็น 'ip route [Network] [Subnet_Mask] [Next_Hop]'")
		
		elif raw_command == "save":
			_print_to_terminal("% Command rejected: กรุณาพิมพ์ 'ex' ออกจากโหมดคอนฟิกก่อนจึงจะเซฟได้")
				
		elif raw_command == "exit" or raw_command == "ex": 
			current_cli_mode = 1
			_print_to_terminal("Leaving Configuration Mode.")
		else:
			_print_to_terminal("% Invalid syntax. (คำสั่งที่รองรับในโหมดนี้: 'ip route [Network] [Mask] [Next_Hop]', 'ex')")

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
	is_game_over = true
	if "completed_modules_count" in Global:
		Global.completed_modules_count += 1
		
	await get_tree().create_timer(1.5).timeout
	_close_this_popup()

func trigger_game_over(reason_text):
	is_game_over = true
	Global.game_over_reason = "❌ ROUTING TABLE INVERSION\n" + reason_text
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

func _close_this_popup():
	var parent_node = get_parent()
	if parent_node and (parent_node is Window or parent_node.name.begins_with("Window")):
		parent_node.hide()
	else:
		self.hide()


func _on_panel_mouse_entered() -> void:
	pass # Replace with function body.
