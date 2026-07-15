extends Control

@onready var win_task_manager = $SubViewportContainer/SubViewport/Window_TaskManager
@onready var win_router = $SubViewportContainer/SubViewport/Window_Router
@onready var win_firewall = $SubViewportContainer/SubViewport/Window_Firewall
@onready var win_vlan = $SubViewportContainer/SubViewport/Window_VLAN
@onready var win_terminal = $SubViewportContainer/SubViewport/Popup_Terminal

# อ้างอิง Path ของโมดูลข้างในหน้าต่างย่อย
@onready var mod_task_manager = $SubViewportContainer/SubViewport/Window_TaskManager/TaskManager_Module
@onready var mod_firewall = $SubViewportContainer/SubViewport/Window_Firewall/Firewall_Module
@onready var mod_router = $SubViewportContainer/SubViewport/Window_Router/Router_Module
@onready var mod_vlan = $SubViewportContainer/SubViewport/Window_VLAN/PDPA_Module
@onready var mod_terminal = $SubViewportContainer/SubViewport/Popup_Terminal/Terminal_Module

# อ้างอิง Path ของปุ่มไอคอนต่าง ๆ
@onready var btn_task_manager = $SubViewportContainer/SubViewport/Button_TaskManager_Mod
@onready var btn_firewall = $SubViewportContainer/SubViewport/Button_Firewall
@onready var btn_router = $SubViewportContainer/SubViewport/Button_Router
@onready var btn_pdpa = $SubViewportContainer/SubViewport/Button_PDPA
@onready var btn_terminal = $SubViewportContainer/SubViewport/Window_Terminal

# อ้างอิงโหนดขอบแดงแบบดั้งเดิม
@onready var alert_overlay = $RedAlertOverlay

func _ready():
	# 🔒 ซ่อนหน้าต่าง Popup ทั้งหมดก่อนเริ่มเกม (เปลี่ยนเป็น .visible = false)
	if win_task_manager: win_task_manager.visible = false
	if win_router: win_router.visible = false
	if win_firewall: win_firewall.visible = false
	if win_vlan: win_vlan.visible = false
	if win_terminal: win_terminal.visible = false
	
	# 🔒 แช่แข็งลูปเกมของทุกโมดูลไว้ชั่วคราว
	if mod_task_manager: mod_task_manager.set_process(false)
	if mod_firewall: mod_firewall.set_process(false)
	if mod_router: mod_router.set_process(false)
	if mod_vlan: mod_vlan.set_process(false)
	if mod_terminal: mod_terminal.set_process(false)
	
	# 🔒 ซ่อนปุ่มไอคอนทั้งหมดบนเดสก์ท็อปก่อน
	_hide_all_desktop_buttons()
	
	# 🟢 บังคับให้ปุ่มคู่มือโจทย์ แสดงขึ้นมาในทุกๆ โหมดเสมอ
	if btn_terminal: btn_terminal.show()
	
	# 🎮 เปิดแสดงปุ่มของ ภารกิจหลักตามวิชาที่เลือกมา
	match Global.selected_topic:
		"network": 
			if btn_firewall: btn_firewall.show()
		"task_manager": 
			if btn_task_manager: btn_task_manager.show()
		"router": 
			if btn_router: btn_router.show()
		"vlan": 
			if btn_pdpa: btn_pdpa.show()

	# 🎶 พอเปลี่ยนฉากเข้าหน้า Desktop ปุ๊บ ให้เปลี่ยนเป็นเสียงพัดลมเครื่องทำงานทันที
	AudioManager.play_bg_sound("res://freesound_community-machine-room-55632.mp3")
	
	# 🔗 เชื่อมสัญญาณจากหน้าต่าง VLAN (PDPA_Module)
	var vlan_module = get_node_or_null("SubViewportContainer/SubViewport/Window_VLAN/PDPA_Module")
	if vlan_module and vlan_module.has_signal("alert_status_changed"):
		vlan_module.connect("alert_status_changed", _on_minigame_alert_status_changed)
		
	# 🔗 เชื่อมสัญญาณจากหน้าต่าง Router (Router_Module) 
	var router_module = get_node_or_null("SubViewportContainer/SubViewport/Window_Router/Router_Module")
	if router_module and router_module.has_signal("alert_status_changed"):
		router_module.connect("alert_status_changed", _on_minigame_alert_status_changed)

	# 😈 [จุดแก้ที่ 1]: เริ่มเปิดหน้าต่างกวนประสาททันทีที่เข้าหน้าเดสก์ท็อป
	spawn_annoying_popup("SYSTEM ERROR 404", "พบข้อผิดพลาดร้ายแรงมั้งนะ?")

# ฟังก์ชันช่วยซ่อนปุ่มแบบปลอดภัยผ่านตัวแปร
func _hide_all_desktop_buttons():
	if btn_task_manager: btn_task_manager.hide()
	if btn_firewall: btn_firewall.hide()
	if btn_router: btn_router.hide()
	if btn_pdpa: btn_pdpa.hide()
	if btn_terminal: btn_terminal.hide() 

# =========================================================
# 🖱️ SECTION: ฟังก์ชันเปิดหน้าต่างแอป (เมื่อคลิกไอคอน)
# =========================================================

func _on_button_pressed(): # ปุ่ม Task Manager
	_open_window(win_task_manager, mod_task_manager)

func _on_button_firewall_pressed():
	_open_window(win_firewall, mod_firewall)

func _on_button_router_pressed():
	_open_window(win_router, mod_router)

func _on_button_pdpa_pressed():
	_open_window(win_vlan, mod_vlan)

func _on_window_terminal_pressed() -> void:
	_open_window(win_terminal, mod_terminal)

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
# ❌ SECTION: ฟังก์ชันปิดหน้าต่าง 
# =========================================================

func _on_window_task_manager_close_requested():
	_close_window(win_task_manager, mod_task_manager)

func _on_window_firewall_close_requested():
	_close_window(win_firewall, mod_firewall)

func _on_window_router_close_requested():
	_close_window(win_router, mod_router)

func _on_window_vlan_close_requested():
	_close_window(win_vlan, mod_vlan)

func _on_popup_terminal_close_requested() -> void:
	_close_window(win_terminal, mod_terminal)

# ฟังก์ชันส่วนกลางสำหรับจัดการขั้นตอนปิดหน้าต่าง
func _close_window(win_node, module_node):
	if win_node: 
		win_node.visible = false
	if module_node: 
		module_node.set_process(false)

# =========================================================
# 🚪 SECTION: LOGOUT ระบบ
# =========================================================
func _on_button_logout_pressed() -> void:
	if "completed_modules_count" in Global: 
		Global.completed_modules_count = 0
		
	AudioManager.play_bg_sound("res://freesound_community-dark-server-76461.mp3")
	get_tree().change_scene_to_file("res://mode_selection.tscn")

# =========================================================
# 🚨 SECTION: ระบบรับสัญญาณ ALERT ดั้งเดิม
# =========================================================
func _on_minigame_alert_status_changed(is_alert: bool):
	if not alert_overlay: return
	
	if is_alert:
		# 🚨 สั่งเปิดขอบจอแดงกะพริบและเล่นเสียงปี๊บลูปทันที
		if alert_overlay.has_method("start_alert"):
			alert_overlay.start_alert(3.0, 0.8)
		AudioManager.play_bg_sound("res://49053354-electronic-ping-305767.mp3")
	else:
		# ✅ สั่งปิดขอบจอแดง คืนเสียงห้องเครื่องปกติ
		if alert_overlay.has_method("stop_alert"):
			alert_overlay.stop_alert()
		AudioManager.play_bg_sound("res://freesound_community-machine-room-55632.mp3")

# =========================================================
# 😈 [จุดแก้ที่ 2]: SECTION ระบบหน้าต่างกวนประสาท (Pop-up Delay Loop)
# =========================================================
func spawn_annoying_popup(title_text: String, message_text: String):
	var annoying_win = AcceptDialog.new()
	annoying_win.title = title_text
	annoying_win.dialog_text = message_text
	annoying_win.initial_position = 1 
	annoying_win.min_size = Vector2i(280, 100)
	
	# เชื่อมสัญญาณปุ่มยืนยันหรือกดกากบาทปิด
	annoying_win.confirmed.connect(func():
		_on_annoying_popup_closed(title_text, message_text)
	)
	annoying_win.canceled.connect(func():
		_on_annoying_popup_closed(title_text, message_text)
	)
	
	add_child(annoying_win)
	annoying_win.popup() 

func _on_annoying_popup_closed(title: String, msg: String):
	# สั่งคลิกเสียงปุ่มปิดตามปกติ
	if AudioManager and AudioManager.sfx_click:
		AudioManager.sfx_click.play()
	
	# ⏳ ดีเลย์ 3.0 วินาทีตามใจอยาก 
	await get_tree().create_timer(5.0).timeout
	
	var new_win = AcceptDialog.new()
	new_win.title = title
	new_win.dialog_text = "คิดว่าจะปิดฉันได้ง่ายๆ เหรอ? 😏"
	
	# สุ่มตำแหน่งใหม่บนหน้าจอเมื่อมันเด้ง
	var screen_size = get_viewport().get_visible_rect().size
	var random_pos = Vector2i(
		randi() % int(screen_size.x - 300),
		randi() % int(screen_size.y - 150)
	)
	new_win.position = random_pos
	new_win.min_size = Vector2i(300, 100)
	
	# เชื่อมลูปวนกลับมาเรียกตัวเองซ้ำเรื่อย ๆ แบบถ่อมตัว
	new_win.confirmed.connect(func(): _on_annoying_popup_closed(title, msg))
	new_win.canceled.connect(func(): _on_annoying_popup_closed(title, msg))
	
	add_child(new_win)
	new_win.popup()
