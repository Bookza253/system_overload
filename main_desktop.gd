extends Control

@onready var win_task_manager = $Window_TaskManager
@onready var win_router = $Window_Router
@onready var win_firewall = $Window_Firewall
@onready var win_vlan = $Window_VLAN 

# =========================================================
# 🚀 1. ลงทะเบียนฉากมินิเกมทั้งหมดเตรียมไว้
# =========================================================
const FIREWALL_TRAINING_SCENE = preload("res://firewall_module.tscn")
const ROUTER_TRAINING_SCENE = preload("res://router_module.tscn")
const VLAN_TRAINING_SCENE = preload("res://pdpa_module.tscn")
const TASK_TRAINING_SCENE = preload("res://task_manager_module.tscn")

func _ready():
	# 🔒 ซ่อนหน้าต่าง Popup ทั้งหมดก่อนเมื่อเริ่ม
	if win_task_manager: win_task_manager.hide()
	if win_router: win_router.hide()
	if win_firewall: win_firewall.hide()
	if win_vlan: win_vlan.hide()
	
	# 🌟 โชว์ไอคอนครบ 4 ตัวบนหน้าจอเหมือนเดิม
	_show_all_desktop_buttons()

func _show_all_desktop_buttons():
	if has_node("Button_TaskManager_M"): $Button_TaskManager_M.show()
	if has_node("Button_Firewall"): $Button_Firewall.show()
	if has_node("Button_Router"): $Button_Router.show()
	if has_node("Button_PDPA"): $Button_PDPA.show()


# =========================================================
# 🖱️ SECTION: ระบบโหลดเกม (ทุกโหมดจะมาโผล่ที่แอป Router เสมอ)
# =========================================================

# 🖱️ icon ที่ 3: แอป Router (ศูนย์รวมเกมของทุกโหมด)
func _on_button_router_pressed():
	win_router.show()
	win_router.grab_focus()
	
	# ล้างหน้าต่างให้ว่างก่อนสุ่มร่างใหม่
	_clear_window_content(win_router)
	
	# 🎯 เช็กเงื่อนไขโหมดจากหน้าแรก แล้วเปลี่ยนเกมในหน้าต่าง Router ตามโหมดนั้น ๆ ทันที!
	if Global.is_mix_mode:
		print("🎮 โหมดผสม: โหลดด่าน Router เป็นหลักชั่วคราว")
		_load_game_into_window(win_router, ROUTER_TRAINING_SCENE)
	else:
		match Global.selected_topic:
			"router":
				print("🎯 เลือกวิชา Router -> โหลดเกม Router เข้า icon 3")
				_load_game_into_window(win_router, ROUTER_TRAINING_SCENE)
			"network":
				print("🎯 เลือกวิชา Network -> โหลดเกม Firewall เข้า icon 3")
				_load_game_into_window(win_router, FIREWALL_TRAINING_SCENE)
			"vlan":
				print("🎯 เลือกวิชา VLAN -> โหลดเกม VLAN เข้า icon 3")
				_load_game_into_window(win_router, VLAN_TRAINING_SCENE)
			"task_manager":
				print("🎯 เลือกวิชา Task Manager -> โหลดเกม Task Manager เข้า icon 3")
				_load_game_into_window(win_router, TASK_TRAINING_SCENE)
			



# 🖱️ icon ที่ 1: แอป Task Manager (กดแล้วขึ้นหน้าต่างเปล่า)
func _on_button_pressed():
	win_task_manager.show()
	win_task_manager.grab_focus()
	_clear_window_content(win_task_manager) # ล้างเป็นหน้าต่างว่าง

# 🖱️ icon ที่ 2: แอป Firewall (กดแล้วขึ้นหน้าต่างเปล่า)
func _on_button_firewall_pressed():
	win_firewall.show()
	win_firewall.grab_focus()
	_clear_window_content(win_firewall) # ล้างเป็นหน้าต่างว่าง

# 🖱️ icon ที่ 4: แอป VLAN / PDPA (กดแล้วขึ้นหน้าต่างเปล่า)
func _on_button_pdpa_pressed():
	win_vlan.show()
	win_vlan.grab_focus()
	_clear_window_content(win_vlan) # ล้างเป็นหน้าต่างว่าง


# =========================================================
# 🛠️ ฟังก์ชันการจัดการ Node ย่อย
# =========================================================

# ฟังก์ชันเคลียร์ Node เก่าข้างในหน้าต่าง
func _clear_window_content(target_window: Window):
	if not target_window: return
	for child in target_window.get_children():
		child.queue_free()

# ฟังก์ชันเสกตัวเกมใส่เข้าหน้าต่าง
func _load_game_into_window(target_window: Window, game_scene: PackedScene):
	if not target_window or not game_scene: return
	
	var new_game = game_scene.instantiate()
	if new_game is Control:
		new_game.position = Vector2(0, 0)
		
	target_window.add_child(new_game)


# =========================================================
# ❌ SECTION: ปิดหน้าต่าง (ซ่อนลงไปเฉยๆ)
# =========================================================
func _on_window_router_close_requested(): win_router.hide() 
func _on_window_task_manager_close_requested() -> void: win_task_manager.hide() 
func _on_window_firewall_close_requested() -> void: win_firewall.hide() 
func _on_window_vlan_close_requested() -> void: win_vlan.hide()
