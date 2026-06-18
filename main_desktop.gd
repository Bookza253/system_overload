extends Control

@onready var win_task_manager = $Window_TaskManager
@onready var win_router = $Window_Router
@onready var win_firewall = $Window_Firewall
# 🌟 เปลี่ยนจาก Window_PDPA มาเป็น Window_VLAN ตามธีม Network ใหม่
@onready var win_vlan = $Window_VLAN 

func _ready():
	# 🔒 ซ่อนหน้าต่าง Popup ทั้งหมดก่อน
	if win_task_manager: win_task_manager.hide()
	if win_router: win_router.hide()
	if win_firewall: win_firewall.hide()
	if win_vlan: win_vlan.hide()
	
	# 🔒 ซ่อนปุ่มไอคอนทั้งหมดบน Desktop ไว้ก่อน เพื่อรอเปิดตามโหมด
	_hide_all_desktop_buttons()
	
	# 🎮 ตรวจสอบเงื่อนไขโหมดที่ถูกส่งมาจากหน้าเลือกโหมด
	if Global.is_mix_mode:
		# โหมดผสม: โชว์ไอคอนแอปทั้งหมด
		_show_button("Button_TaskManager_M")
		_show_button("Button_Firewall")
		_show_button("Button_Router")
		_show_button("Button_PDPA") 
	else:
		# โหมดแยกวิชา: โชว์เฉพาะปุ่มที่เลือกเรียน
		match Global.selected_topic:
			"network":
				_show_button("Button_Firewall")
			"task_manager":
				_show_button("Button_TaskManager_M")
			"router":
				_show_button("Button_Router")
			"vlan":
				_show_button("Button_PDPA") # ปุ่มเปิดแอปวิชา VLAN

# ฟังก์ชันช่วยซ่อนปุ่มแบบปลอดภัย
func _hide_all_desktop_buttons():
	if has_node("Button_TaskManager_M"): $Button_TaskManager_M.hide()
	if has_node("Button_Firewall"): $Button_Firewall.hide()
	if has_node("Button_Router"): $Button_Router.hide()
	if has_node("Button_PDPA"): $Button_PDPA.hide()

# ฟังก์ชันช่วยเปิดปุ่มแบบปลอดภัย (เช็กก่อนเปิด เกมจะได้ไม่เด้ง)
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
	# 🌟 ชี้ไปที่ Window_TaskManager และโมดูล TaskManager_Mod
	$Window_TaskManager/TaskManager_Module.position = Vector2(0, 0) 
	
	win_task_manager.popup()       
	win_task_manager.grab_focus()   

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป Firewall
func _on_button_firewall_pressed():
	# 🌟 ชี้ไปที่ Window_Firewall และโมดูล Firewall_Module
	$Window_Firewall/Firewall_Module.position = Vector2(0, 0) 
	
	win_firewall.popup()
	win_firewall.grab_focus()

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป Router
func _on_button_router_pressed():
	# 🌟 ชี้ไปที่ Window_Router และโมดูล Router_Module (อันนี้เดิมถูกแล้ว)
	$Window_Router/Router_Module.position = Vector2(0, 0) 
	
	win_router.popup()
	win_router.grab_focus()

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป VLAN (ปุ่ม PDPA เดิม)
func _on_button_pdpa_pressed():
	# 🌟 ชี้ไปที่ Window_VLAN และโมดูล PDPA_Module (ที่รอเปลี่ยนร่างเป็น VLAN)
	$Window_VLAN/PDPA_Module.position = Vector2(0, 0) 
	
	win_vlan.popup()
	win_vlan.grab_focus()

func _on_window_router_close_requested():
	win_router.hide() # 🟢 ถูกต้อง: ปิดตัวมันเอง

func _on_window_task_manager_close_requested() -> void:
	win_task_manager.hide() # 🟢 แก้ไข: ให้ปิดหน้าต่าง Task Manager

func _on_window_firewall_close_requested() -> void:
	win_firewall.hide() # 🟢 แก้ไข: ให้ปิดหน้าต่าง Firewall

func _on_window_vlan_close_requested() -> void:
	win_vlan.hide() # 🟢 แก้ไข: ให้ปิดหน้าต่าง VLAN
