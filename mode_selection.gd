extends Control

@onready var sub_menu = $VBoxContainer/TrainingSubMenu

func _ready():
	# 🔌 เชื่อมต่อสัญญาณปุ่มหลัก
	$VBoxContainer/TrainingButton.pressed.connect(_on_training_pressed)
	$VBoxContainer/MixModeButton.pressed.connect(_on_mix_mode_pressed)
	
	# 🔌 เชื่อมต่อสัญญาณปุ่มย่อย (เช็กชื่อ Node ลูกใน VBoxContainer ให้ตรงนะครับ)
	if $VBoxContainer/TrainingSubMenu.has_node("NetworkButton"):
		$VBoxContainer/TrainingSubMenu/NetworkButton.pressed.connect(_on_network_pressed)
	if $VBoxContainer/TrainingSubMenu.has_node("SystemButton"):
		$VBoxContainer/TrainingSubMenu/SystemButton.pressed.connect(_on_system_pressed)
	if $VBoxContainer/TrainingSubMenu.has_node("RouterButton"):
		$VBoxContainer/TrainingSubMenu/RouterButton.pressed.connect(_on_button_router_topic_pressed)
	if $VBoxContainer/TrainingSubMenu.has_node("VlanButton"):
		$VBoxContainer/TrainingSubMenu/VlanButton.pressed.connect(_on_button_pdpa_topic_pressed)

# 🟢 กดปุ่ม Training Mode (เปิด-ปิดเมนูย่อย)
func _on_training_pressed():
	sub_menu.visible = !sub_menu.visible

# 🌐 เลือกหัวข้อ Network -> ไปหน้า Desktop
func _on_network_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "network"
	_go_to_desktop()

# 🖥️ เลือกหัวข้อ System -> ไปหน้า Desktop
func _on_system_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "task_manager"
	_go_to_desktop()

# 📶 เลือกหัวข้อ Router -> ไปหน้า Desktop
func _on_button_router_topic_pressed():
	Global.is_mix_mode = false             
	Global.selected_topic = "router"       
	_go_to_desktop()

# 🌟 เลือกหัวข้อ VLAN -> ไปหน้า Desktop
func _on_button_pdpa_topic_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "vlan" # ใช้ "vlan" ให้ตรงกับหน้า Desktop
	_go_to_desktop()

# 🔴 เลือกโหมดผสม -> ไปหน้า Desktop
func _on_mix_mode_pressed():
	Global.is_mix_mode = true
	Global.selected_topic = "mix"
	_go_to_desktop()

# 🚀 ฟังก์ชันส่วนกลางสำหรับวาร์ปไปหน้า Desktop
func _go_to_desktop():
	# ⚠️ เช็กในโฟลเดอร์ FileSystem ด้านซ้ายของโปรแกรม Godot ว่าไฟล์ชื่อ main_desktop.tscn จริงไหม
	# ถ้าอยู่ในโฟลเดอร์อื่น เช่น res://Scenes/main_desktop.tscn ให้แก้ path ตรงนี้ให้ตรงครับ
	var desktop_path = "res://main_desktop.tscn"
	
	if ResourceLoader.exists(desktop_path):
		get_tree().change_scene_to_file(desktop_path)
	else:
		print("🚨 หาไฟล์ฉากเดสก์ท็อปไม่เจอ! ตรวจสอบชื่อไฟล์ main_desktop.tscn อีกครั้งใน FileSystem")
