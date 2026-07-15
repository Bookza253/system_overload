extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES (UI Node References)
# - sub_menu: อ้างอิงโหนด Container ของเมนูย่อย เพื่อใช้ควบคุมการแสดงผล (Visibility)
# ==============================================================================
@onready var sub_menu = $VBoxContainer/TrainingSubMenu

# ==============================================================================
# ⚙️ 2. LIFE CYCLE METHODS (_ready)
# - ดำเนินการผูกสัญญาณ Event-Driven (Signal Connection) ของปุ่มเมนูหลักและเมนูย่อย
# - มีการใช้โครงสร้างเชิงป้องกัน (Defensive Checking) ด้วย has_node เพื่อรับประกันความปลอดภัยของระบบ
# ==============================================================================
func _ready():
	# 🔌 เชื่อมโยงสัญญาณการกดปุ่มเมนูหลัก (Main Topic Button)
	if has_node("VBoxContainer/TrainingButton"):
		$VBoxContainer/TrainingButton.pressed.connect(_on_training_pressed)
	
	# 🔌 เชื่อมโยงสัญญาณการกดปุ่มเมนูย่อย (Sub-Topic Buttons) แบบปลอดภัย
	if sub_menu:
		if sub_menu.has_node("NetworkButton"):
			sub_menu.get_node("NetworkButton").pressed.connect(_on_network_pressed)
		if sub_menu.has_node("SystemButton"):
			sub_menu.get_node("SystemButton").pressed.connect(_on_system_pressed)
		if sub_menu.has_node("RouterButton"):
			sub_menu.get_node("RouterButton").pressed.connect(_on_button_router_topic_pressed)
		if sub_menu.has_node("VlanButton"):
			sub_menu.get_node("VlanButton").pressed.connect(_on_button_pdpa_topic_pressed)

# ==============================================================================
# 🎮 INTERFACE EVENT HANDLERS (Signal Callbacks)
# - ควบคุมตรรกะการสลับแสดงผลของ UI และการลงทะเบียนสเตทการเล่นไปยัง Global Singleton
# ==============================================================================

# 🟢 Toggle Sub-Menu Visibility (ฟังก์ชันเปิด-ปิดเมนูย่อยในการกวาดสายตาคัดสรรหัวข้อ)
func _on_training_pressed():
	if sub_menu:
		sub_menu.visible = !sub_menu.visible

# 🌐 Set Network Topic Mode (กำหนดสเตทสำหรับการเรียนรู้หมวดหมู่เครือข่ายความปลอดภัย)
func _on_network_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "network"
	_go_to_desktop()

# 🖥️ Set System Topic Mode (กำหนดสเตทสำหรับการจัดการระบบปฏิบัติการ)
func _on_system_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "task_manager"
	_go_to_desktop()

# 📶 Set Router Topic Mode (กำหนดสเตทสำหรับการตั้งค่าและคัดกรองเส้นทาง Routing)
func _on_button_router_topic_pressed():
	Global.is_mix_mode = false             
	Global.selected_topic = "router"       
	_go_to_desktop()

# 🌟 Set VLAN Topic Mode (กำหนดสเตทสำหรับการจัดการแบ่งกลุ่มเครือข่ายเสมือน)
func _on_button_pdpa_topic_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "vlan" 
	_go_to_desktop()

# ==============================================================================
# 🚀 SCENE TRANSITION HELPER (Safe Navigation)
# - _go_to_desktop: ทำหน้าที่ตรวจสอบความถูกต้องของ Scene File บนหน่วยความจำก่อนสับเปลี่ยนซีนจริง
# - ป้องกันปัญหาการพยายามโหลดไฟล์ที่ไม่มีอยู่จริงเพื่อลดข้อผิดพลาดในระดับ Engine (Assertion Guard)
# ==============================================================================
func _go_to_desktop():
	var desktop_path = "res://main_desktop.tscn"
	
	# Resource Guard Check: ตรวจสอบความมีอยู่ของไฟล์ .tscn ก่อนดำเนินการเปลี่ยนซีน
	if ResourceLoader.exists(desktop_path):
		get_tree().change_scene_to_file(desktop_path)
	else:
		push_error("System Navigation Error: Unable to locate main_desktop.tscn in project assets.")
