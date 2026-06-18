extends Control

@onready var win_task_manager = $Window_TaskManager
@onready var win_router = $Window_Router
@onready var win_firewall = $Window_Firewall
# 🌟 เปลี่ยนจาก Window_PDPA มาเป็น Window_VLAN ตามธีม Network ใหม่
@onready var win_vlan = $Window_VLAN 

func _ready():
	# 🔒 สั่งซ่อนหน้าต่าง Window ทั้งหมดตอนเริ่มเกมก่อน (ป้องกันการเด้งซ้อนกัน)
	win_task_manager.hide()
	win_router.hide()
	win_firewall.hide()
	win_vlan.hide()
	
	if Global.is_mix_mode:
		# 🔴 ถ้าเป็นโหมดผสม: เปิดให้เห็นไอคอนเลือกแอปครบทุกตัวบน Desktop
		$Button_TaskManager_M.show()
		$Button_Firewall.show()
		$Button_Router.show()
		$Button_PDPA.show() # 💡 พาร์ท UI ปุ่มบน Desktop ค่อยไปเปลี่ยน Text ในแอป Canva/Godot ให้เป็นชื่อ VLAN นะครับ
	else:
		# 🟢 ถ้าเลือกโหมดฝึกซ้อมแยกวิชา (เปิดโชว์เฉพาะปุ่มที่เลือกเรียน)
		if Global.selected_topic == "network":
			$Button_Firewall.show()
			$Button_TaskManager_M.hide()
			$Button_Router.hide()
			$Button_PDPA.hide()
			
		elif Global.selected_topic == "task_manager":
			$Button_Firewall.hide()
			$Button_TaskManager_M.show()
			$Button_Router.hide()
			$Button_PDPA.hide()
			
		elif Global.selected_topic == "router":
			$Button_Firewall.hide()
			$Button_TaskManager_M.hide()
			$Button_Router.show()
			$Button_PDPA.hide()
			
		elif Global.selected_topic == "vlan": # 🌟 เปลี่ยนชื่อเคสลงทะเบียนจาก pdpa เป็น vlan
			$Button_Firewall.hide()
			$Button_TaskManager_M.hide()
			$Button_Router.hide()
			$Button_PDPA.show()

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
