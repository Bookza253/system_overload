extends Control

@onready var win_task_manager = $Window_TaskManager
@onready var win_router = $Window_Router
@onready var win_firewall = $Window_Firewall
@onready var win_vlan = $Window_VLAN 
@onready var win_terminal = $Window_Terminal # หน้าต่างคู่มือบอกข้อมูลสเปกด่าน

func _ready():
	# 🔒 ซ่อนหน้าต่าง Popup ทั้งหมดก่อนเริ่มเกม
	if has_node("Window_TaskManager"): win_task_manager.hide()
	if has_node("Window_Router"): win_router.hide()
	if has_node("Window_Firewall"): win_firewall.hide()
	if has_node("Window_VLAN"): win_vlan.hide()
	if has_node("Window_Terminal"): win_terminal.hide() 
	
	# 🔒 แช่แข็งลูปเกมของทุกโมดูลไว้ชั่วคราว
	if has_node("Window_TaskManager/TaskManager_Module"): $Window_TaskManager/TaskManager_Module.set_process(false)
	if has_node("Window_Firewall/Firewall_Module"): $Window_Firewall/Firewall_Module.set_process(false)
	if has_node("Window_Router/Router_Module"): $Window_Router/Router_Module.set_process(false)
	if has_node("Window_VLAN/PDPA_Module"): $Window_VLAN/PDPA_Module.set_process(false)
	if has_node("Window_Terminal/Terminal_Module"): $Window_Terminal/Terminal_Module.set_process(false) 
	
	# 🔒 ซ่อนปุ่มไอคอนทั้งหมดบนเดสก์ท็อปก่อน
	_hide_all_desktop_buttons()
	
	# 🟢 บังคับให้ปุ่มคู่มือโจทย์ (Button_Terminal) แสดงขึ้นมาในทุกๆ โหมดเสมอ
	_show_button("Button_Terminal")
	
	# 🎮 เปิดแสดงปุ่มของภารกิจหลักตามวิชาที่เลือกมา
	match Global.selected_topic:
		"network": 
			_show_button("Button_Firewall")
		"task_manager": 
			_show_button("Button_TaskManager_Mod")
		"router": 
			_show_button("Button_Router")
		"vlan": 
			_show_button("Button_PDPA")

# ฟังก์ชันช่วยซ่อนปุ่มแบบปลอดภัย
func _hide_all_desktop_buttons():
	if has_node("Button_TaskManager_Mod"): $Button_TaskManager_Mod.hide()
	if has_node("Button_Firewall"): $Button_Firewall.hide()
	if has_node("Button_Router"): $Button_Router.hide()
	if has_node("Button_PDPA"): $Button_PDPA.hide()
	if has_node("Button_Terminal"): $Button_Terminal.hide() 

# ฟังก์ชันช่วยเปิดปุ่มแบบปลอดภัย
func _show_button(button_name: String):
	if has_node(button_name): 
		get_node(button_name).show()

# =========================================================
# 🖱️ SECTION: ฟังก์ชันเปิดหน้าต่างแอป (เมื่อคลิกไอคอน)
# =========================================================

func _on_button_pressed(): # ปุ่ม Task Manager
	_open_window(win_task_manager, $Window_TaskManager/TaskManager_Module)

func _on_button_firewall_pressed():
	_open_window(win_firewall, $Window_Firewall/Firewall_Module)

func _on_button_router_pressed():
	_open_window(win_router, $Window_Router/Router_Module)

func _on_button_pdpa_pressed():
	_open_window(win_vlan, $Window_VLAN/PDPA_Module)

func _on_button_terminal_pressed(): 
	# สั่งให้อัปเดตข้อความข้อมูลของด่านปัจจุบันก่อนเปิดหน้าต่างขึ้นมาแสดงผล
	if $Window_Terminal/Terminal_Module.has_method("update_cheat_sheet_info"):
		$Window_Terminal/Terminal_Module.update_cheat_sheet_info()
	_open_window(win_terminal, $Window_Terminal/Terminal_Module)

# ฟังก์ชันส่วนกลางสำหรับจัดการขั้นตอนเปิดหน้าต่าง
func _open_window(win_node, module_node):
	if not win_node or not module_node: return
	
	module_node.position = Vector2(0, 0)
	if module_node.has_method("set_process"): 
		module_node.set_process(true)
		
	var target_size = module_node.custom_minimum_size
	if target_size != Vector2.ZERO: 
		win_node.size = target_size
		
	win_node.popup()
	win_node.grab_focus()

# =========================================================
# ❌ SECTION: ฟังก์ชันปิดหน้าต่าง (ถอดระบบย้อมสีออกแล้ว)
# =========================================================

func _on_window_task_manager_close_requested():
	_close_window(win_task_manager, $Window_TaskManager/TaskManager_Module)

func _on_window_firewall_close_requested():
	_close_window(win_firewall, $Window_Firewall/Firewall_Module)

func _on_window_router_close_requested():
	_close_window(win_router, $Window_Router/Router_Module)

func _on_window_vlan_close_requested():
	_close_window(win_vlan, $Window_VLAN/PDPA_Module)

func _on_window_terminal_close_requested(): 
	_close_window(win_terminal, $Window_Terminal/Terminal_Module)

# ฟังก์ชันส่วนกลางสำหรับจัดการขั้นตอนปิดหน้าต่าง (เหลือเฉพาะการซ่อนและปิดลูปสคริปต์)
func _close_window(win_node, module_node):
	if win_node: 
		win_node.hide()
	if module_node: 
		module_node.set_process(false)

# =========================================================
# 🚪 SECTION: LOGOUT ระบบ
# =========================================================
func _on_button_logout_pressed() -> void:
	if "completed_modules_count" in Global: 
		Global.completed_modules_count = 0
	get_tree().change_scene_to_file("res://mode_selection.tscn")


func _on_window_terminal_pressed() -> void:
	pass # Replace with function body.
