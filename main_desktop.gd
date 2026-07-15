extends Control

# ==============================================================================
# STATE MANAGEMENT
# - is_popup_enabled: ใช้สำหรับควบคุม Lifecycle ของระบบแจ้งเตือนภายนอก (Popup Loop)
# - เพื่อให้สามารถสับสวิตช์หยุดการประมวลผลของหน้าต่างแจ้งเตือนได้ทันทีเมื่อเกิด Event เคลียร์ภารกิจ
# ==============================================================================
var is_popup_enabled: bool = true

# ==============================================================================
# NODE REFERENCES (PRE-INITIALIZATION)
# - ใช้ @onready เพื่อดักจับ Path โหนดล่วงหน้า ป้องกันปัญหา Null Instance ขณะรันไทม์
# ==============================================================================
@onready var win_task_manager = $SubViewportContainer/SubViewport/Window_TaskManager
@onready var win_router = $SubViewportContainer/SubViewport/Window_Router
@onready var win_firewall = $SubViewportContainer/SubViewport/Window_Firewall
@onready var win_vlan = $SubViewportContainer/SubViewport/Window_VLAN
@onready var win_terminal = $SubViewportContainer/SubViewport/Popup_Terminal

@onready var mod_task_manager = $SubViewportContainer/SubViewport/Window_TaskManager/TaskManager_Module
@onready var mod_firewall = $SubViewportContainer/SubViewport/Window_Firewall/Firewall_Module
@onready var mod_router = $SubViewportContainer/SubViewport/Window_Router/Router_Module
@onready var mod_vlan = $SubViewportContainer/SubViewport/Window_VLAN/PDPA_Module
@onready var mod_terminal = $SubViewportContainer/SubViewport/Popup_Terminal/Terminal_Module

@onready var btn_task_manager = $SubViewportContainer/SubViewport/Button_TaskManager_Mod
@onready var btn_firewall = $SubViewportContainer/SubViewport/Button_Firewall
@onready var btn_router = $SubViewportContainer/SubViewport/Button_Router
@onready var btn_pdpa = $SubViewportContainer/SubViewport/Button_PDPA
@onready var btn_terminal = $SubViewportContainer/SubViewport/Window_Terminal

@onready var alert_overlay = $RedAlertOverlay

# ==============================================================================
# LIFE CYCLE METHODS (_ready)
# - จัดเตรียมสถานะเริ่มต้นของ UI และแช่แข็งการประมวลผลสคริปต์ย่อย (set_process = false) เพื่อประหยัด CPU Resource
# - โหลด Config โหมดการเล่นจาก Global Singleton และผูกสัญญาณแบบ Dynamic Connect
# ==============================================================================
func _ready():
	# 🔒 Initialize UI State: ซ่อน Popup และ Component ที่ยังไม่เปิดใช้งาน
	if win_task_manager: win_task_manager.visible = false
	if win_router: win_router.visible = false
	if win_firewall: win_firewall.visible = false
	if win_vlan: win_vlan.visible = false
	if win_terminal: win_terminal.visible = false
	
	# 🔒 CPU Optimization: ปิดระบบประมวลผลชั่วคราวของโมดูลย่อย จนกว่าหน้าต่างจะถูกเรียกเปิด
	if mod_task_manager: mod_task_manager.set_process(false)
	if mod_firewall: mod_firewall.set_process(false)
	if mod_router: mod_router.set_process(false)
	if mod_vlan: mod_vlan.set_process(false)
	if mod_terminal: mod_terminal.set_process(false)
	
	_hide_all_desktop_buttons()
	
	if btn_terminal: btn_terminal.show()
	
	# 🎮 Dynamic Interface Selection: แสดงปุ่มตามรายวิชา/หมวดหมู่ที่ Global คัดเลือกไว้
	match Global.selected_topic:
		"network": 
			if btn_firewall: btn_firewall.show()
		"task_manager": 
			if btn_task_manager: btn_task_manager.show()
		"router": 
			if btn_router: btn_router.show()
		"vlan": 
			if btn_pdpa: btn_pdpa.show()

	# 🎶 Ambient Sound Management: เปลี่ยนเสียงบรรยากาศเป็นห้อง Server ทำงานปกติ
	AudioManager.play_bg_sound("res://freesound_community-machine-room-55632.mp3")
	
	# ==========================================================================
	# DYNAMIC SIGNAL BINDING
	# - ดึงโหนดมินิเกมและทำลายข้อจำกัดเชิงสถาปัตยกรรม (ข้าม Viewport) 
	# - โดยนำสัญญาณ alert_status_changed มาผูกไว้กับสคริปต์หลักแบบ Event-Driven
	# ==========================================================================
	var vlan_module = get_node_or_null("SubViewportContainer/SubViewport/Window_VLAN/PDPA_Module")
	if vlan_module and vlan_module.has_signal("alert_status_changed"):
		vlan_module.connect("alert_status_changed", _on_minigame_alert_status_changed)
		
	var router_module = get_node_or_null("SubViewportContainer/SubViewport/Window_Router/Router_Module")
	if router_module and router_module.has_signal("alert_status_changed"):
		router_module.connect("alert_status_changed", _on_minigame_alert_status_changed)

	# สั่งรันหน้าต่างจำลองสถานการณ์ขัดข้องเริ่มต้น
	spawn_annoying_popup("SYSTEM ERROR 404", "พบข้อผิดพลาดร้ายแรงมั้งนะ?")

func _hide_all_desktop_buttons():
	if btn_task_manager: btn_task_manager.hide()
	if btn_firewall: btn_firewall.hide()
	if btn_router: btn_router.hide()
	if btn_pdpa: btn_pdpa.hide()
	if btn_terminal: btn_terminal.hide() 

# =========================================================
# APPLICATION WINDOW CONTROLLER (SIGNAL HANDLERS)
# =========================================================

func _on_button_pressed(): 
	_open_window(win_task_manager, mod_task_manager)

func _on_button_firewall_pressed():
	_open_window(win_firewall, mod_firewall)

func _on_button_router_pressed():
	_open_window(win_router, mod_router)

func _on_button_pdpa_pressed():
	_open_window(win_vlan, mod_vlan)

func _on_window_terminal_pressed() -> void:
	_open_window(win_terminal, mod_terminal)

# ==============================================================================
# WINDOW LIFE CYCLE HELPER FUNCTIONS
# - _open_window: ย้ายโหนด เปิดใช้การประมวลผล (set_process = true) และโฟกัสหน้าต่างย่อย
# - _close_window: ซ่อน UI และหยุดรันการประมวลผล (set_process = false) เพื่อประหยัด Memory
# ==============================================================================
func _open_window(win_node, module_node):
	if not win_node or not module_node: return
	
	module_node.position = Vector2(0, 0)
	if module_node.has_method("set_process"): 
		module_node.set_process(true) # 🟢 Resume module logic processing
		
	var target_size = module_node.custom_minimum_size
	if target_size != Vector2.ZERO: 
		win_node.size = target_size
		
	win_node.popup()
	win_node.grab_focus()

func _close_window(win_node, module_node):
	if win_node: 
		win_node.visible = false
	if module_node: 
		module_node.set_process(false) # 🔴 Pause module logic processing

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

# =========================================================
# SYSTEM LOGOUT
# =========================================================
func _on_button_logout_pressed() -> void:
	if "completed_modules_count" in Global: 
		Global.completed_modules_count = 0
		
	AudioManager.play_bg_sound("res://freesound_community-dark-server-76461.mp3")
	get_tree().change_scene_to_file("res://mode_selection.tscn")

# ==============================================================================
# GLOBAL THREAT ALERT SYSTEM (DYNAMIC EVENT HANDLER)
# - จัดการเอฟเฟกต์กะพริบขอบจอ (RedAlertOverlay) และความถี่เสียงไซเรนตามระดับภัยคุกคาม
# - หากเคลียร์ความล้มเหลวสำเร็จ (is_alert = false) จะทำการคืนค่าหน้าจอปกติและปิดระบบแจ้งเตือนภายนอกทั้งหมด
# ==============================================================================
func _on_minigame_alert_status_changed(is_alert: bool):
	if not alert_overlay: return
	
	if is_alert:
		if alert_overlay.has_method("start_alert"):
			alert_overlay.start_alert(3.0, 0.8)
		AudioManager.play_bg_sound("res://49053354-electronic-ping-305767.mp3")
	else:
		if alert_overlay.has_method("stop_alert"):
			alert_overlay.stop_alert()
		AudioManager.play_bg_sound("res://freesound_community-machine-room-55632.mp3")
		
		# 🛑 Deactivate Popup Thread: ปิดสวิตช์ระบบจำลองปัญหา เพื่อหยุดส่งขยะป๊อปอัพกวนผู้เล่น
		is_popup_enabled = false

# ==============================================================================
# SYSTEM ANOMALY SIMULATOR (POP-UP TIMING LOOP)
# - spawn_annoying_popup: ทำหน้าที่จำลองไวรัส/กล่องเตือนป๊อปอัพแบบสุ่มตำแหน่งเพื่อเพิ่มความกดดัน
# - ตรรกะความปลอดภัย (Defensive Programming Guard Clause):
#   * ก่อนการสร้าง จะตรวจจับสวิตช์ `is_popup_enabled` และสถิติความสำเร็จใน Global เสมอ
#   * มีการเช็กซ้ำหลังพ้นช่วง Delay 5.0 วินาที เพื่อหยุดสปอนตัวใหม่ทันทีเมื่อเกมถูกบันทึกสำเร็จ (Save)
# ==============================================================================
func spawn_annoying_popup(title_text: String, message_text: String):
	# Guard Clause 1: สะกัดการสร้างหน้าต่างหากระบบถูกแก้ไขเรียบร้อยแล้ว
	if not is_popup_enabled or ("completed_modules_count" in Global and Global.completed_modules_count > 0):
		return

	var annoying_win = AcceptDialog.new()
	annoying_win.title = title_text
	annoying_win.dialog_text = message_text
	annoying_win.initial_position = 1 # WINDOW_POSITION_CENTER_MAIN_WINDOW_SCREEN
	annoying_win.min_size = Vector2i(280, 100)
	
	# เชื่อม Event ปิดกล่องรับทราบย้อนกลับมาตรวจสอบสถานะและส่งเสียง SFX
	annoying_win.confirmed.connect(func():
		_on_annoying_popup_closed(title_text, message_text)
	)
	annoying_win.canceled.connect(func():
		_on_annoying_popup_closed(title_text, message_text)
	)
	
	add_child(annoying_win)
	annoying_win.popup() 

func _on_annoying_popup_closed(title: String, msg: String):
	if AudioManager and AudioManager.sfx_click:
		AudioManager.sfx_click.play()
	
	# ⏳ Async Delay Loop: พักหน้าจอไว้ 5.0 วินาทีตามข้อกำหนดก่อนเช็กเพื่อสร้างใหม่
	await get_tree().create_timer(10.0).timeout
	
	# Guard Clause 2 (Double-Check): หยุดการสร้างหน้าต่างแบบสุ่มทันทีหากผู้เล่นกู้ระบบ (Save) ได้สำเร็จในเวลาดีเลย์
	if not is_popup_enabled or ("completed_modules_count" in Global and Global.completed_modules_count > 0):
		return
	
	var new_win = AcceptDialog.new()
	new_win.title = title
	new_win.dialog_text = "คิดว่าจะปิดฉันได้ง่ายๆ เหรอ? 😏"
	
	# Random Vector Generation: สุ่มหาตำแหน่งพิกัดใหม่บนความละเอียดหน้าจอแสดงผลจริง
	var screen_size = get_viewport().get_visible_rect().size
	var random_pos = Vector2i(
		randi() % int(screen_size.x - 300),
		randi() % int(screen_size.y - 150)
	)
	new_win.position = random_pos
	new_win.min_size = Vector2i(300, 100)
	
	# ผูก Callback วนกลับมาจำลองแบบลูป (Recursion-Like Loop)
	new_win.confirmed.connect(func(): _on_annoying_popup_closed(title, msg))
	new_win.canceled.connect(func(): _on_annoying_popup_closed(title, msg))
	
	add_child(new_win)
	new_win.popup()
