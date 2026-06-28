extends Control

@onready var win_task_manager = $Window_TaskManager
@onready var win_router = $Window_Router
@onready var win_firewall = $Window_Firewall
@onready var win_vlan = $Window_VLAN 

func _ready():
	# 🔒 ซ่อนหน้าต่าง Popup ทั้งหมดก่อนแบบปลอดภัย
	if has_node("Window_TaskManager"): win_task_manager.hide()
	if has_node("Window_Router"): win_router.hide()
	if has_node("Window_Firewall"): win_firewall.hide()
	if has_node("Window_VLAN"): win_vlan.hide()
	
	# 🔒 🌟 แช่แข็งลูปเกมของทุกโมดูลไว้ก่อนตอนเริ่มเกม
	if has_node("Window_TaskManager/TaskManager_Module"): 
		$Window_TaskManager/TaskManager_Module.set_process(false)
	if has_node("Window_Firewall/Firewall_Module"): 
		$Window_Firewall/Firewall_Module.set_process(false)
	if has_node("Window_Router/Router_Module"): 
		$Window_Router/Router_Module.set_process(false)
	if has_node("Window_VLAN/PDPA_Module"): 
		$Window_VLAN/PDPA_Module.set_process(false)
	
	# 🔒 ซ่อนปุ่มไอคอนทั้งหมดบน Desktop ไว้ก่อนเพื่อรอเปิดตามโหมด
	_hide_all_desktop_buttons()
	
	# 🎮 ตรวจสอบเงื่อนไขโหมด
	if Global.is_mix_mode:
		_show_button("Button_TaskManager_M")
		_show_button("Button_Firewall")
		_show_button("Button_Router")
		_show_button("Button_PDPA") 
	else:
		match Global.selected_topic:
			"network":
				_show_button("Button_Firewall")
			"task_manager":
				_show_button("Button_TaskManager_M")
			"router":
				_show_button("Button_Router")
			"vlan":
				_show_button("Button_PDPA")

# ฟังก์ชันช่วยซ่อนปุ่มแบบปลอดภัย
func _hide_all_desktop_buttons():
	if has_node("Button_TaskManager_M"): $Button_TaskManager_M.hide()
	if has_node("Button_Firewall"): $Button_Firewall.hide()
	if has_node("Button_Router"): $Button_Router.hide()
	if has_node("Button_PDPA"): $Button_PDPA.hide()

# ฟังก์ชันช่วยเปิดปุ่มแบบปลอดภัย
func _show_button(button_name: String):
	if has_node(button_name):
		get_node(button_name).show()
	else:
		print("🚨 คำเตือน: หา Node ปุ่มที่ชื่อว่า ", button_name, " ไม่เจอในหน้า Desktop")

# =========================================================
# 🖱️ SECTION: ฟังก์ชันเมื่อคลิกปุ่มไอคอนบนหน้าจอ Desktop 
# =========================================================

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป Task Manager
func _on_button_pressed():
	$Window_TaskManager/TaskManager_Module.position = Vector2(0, 0) 
	
	if $Window_TaskManager/TaskManager_Module.has_method("set_process"):
		$Window_TaskManager/TaskManager_Module.set_process(true)
	
	var target_size = $Window_TaskManager/TaskManager_Module.custom_minimum_size
	if target_size != Vector2.ZERO:
		win_task_manager.size = target_size
	
	win_task_manager.popup()       
	win_task_manager.grab_focus()   

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป Firewall
func _on_button_firewall_pressed():
	$Window_Firewall/Firewall_Module.position = Vector2(0, 0) 
	
	if $Window_Firewall/Firewall_Module.has_method("set_process"):
		$Window_Firewall/Firewall_Module.set_process(true)
		   
	var target_size = $Window_Firewall/Firewall_Module.custom_minimum_size
	if target_size != Vector2.ZERO:
		win_firewall.size = target_size
	
	win_firewall.popup()
	win_firewall.grab_focus()

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป Router
func _on_button_router_pressed():
	$Window_Router/Router_Module.position = Vector2(0, 0) 
	
	if $Window_Router/Router_Module.has_method("set_process"):
		$Window_Router/Router_Module.set_process(true)
	
	var target_size = $Window_Router/Router_Module.custom_minimum_size
	if target_size != Vector2.ZERO:
		win_router.size = target_size
	
	win_router.popup()
	win_router.grab_focus()

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป VLAN
func _on_button_pdpa_pressed():
	$Window_VLAN/PDPA_Module.position = Vector2(0, 0) 
	
	if $Window_VLAN/PDPA_Module.has_method("set_process"):
		$Window_VLAN/PDPA_Module.set_process(true)
	
	var target_size = $Window_VLAN/PDPA_Module.custom_minimum_size
	if target_size != Vector2.ZERO:
		win_vlan.size = target_size
	
	win_vlan.popup()
	win_vlan.grab_focus()

# =========================================================
# ❌ SECTION: ฟังก์ชันเมื่อกดปุ่มปิดหน้าต่าง (Close Requested) 
# =========================================================

func _on_window_router_close_requested():
	win_router.hide() 
	if has_node("Window_Router/Router_Module"): 
		$Window_Router/Router_Module.set_process(false)

func _on_window_task_manager_close_requested() -> void:
	win_task_manager.hide() 
	if has_node("Window_TaskManager/TaskManager_Module"): 
		$Window_TaskManager/TaskManager_Module.set_process(false)

func _on_window_firewall_close_requested() -> void:
	win_firewall.hide() 
	if has_node("Window_Firewall/Firewall_Module"): 
		$Window_Firewall/Firewall_Module.set_process(false)

func _on_window_vlan_close_requested() -> void:
	win_vlan.hide() 
	if has_node("Window_VLAN/PDPA_Module"): 
		$Window_VLAN/PDPA_Module.set_process(false)
