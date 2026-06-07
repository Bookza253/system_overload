extends Control

@onready var sub_menu = $VBoxContainer/TrainingSubMenu

func _ready():
	# 🔌 เชื่อมสายไฟสัญญาณปุ่มหลักและปุ่มย่อยเข้ากับโค้ด
	$VBoxContainer/TrainingButton.pressed.connect(_on_training_pressed)
	$VBoxContainer/MixModeButton.pressed.connect(_on_mix_mode_pressed)
	
	$VBoxContainer/TrainingSubMenu/NetworkButton.pressed.connect(_on_network_pressed)
	$VBoxContainer/TrainingSubMenu/SystemButton.pressed.connect(_on_system_pressed)

# 🟢 เมื่อกดปุ่ม Training Mode หลัก
func _on_training_pressed():
	# สลับสถานะ: ถ้าซ่อนอยู่ให้โผล่ ถ้าโผล่อยู่ให้ซ่อน (ระบบเมนูกางเข้า-ออก)
	sub_menu.visible = !sub_menu.visible

# 🌐 เมื่อกดเลือกหัวข้อ Network (Firewall)
func _on_network_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "network"
	get_tree().change_scene_to_file("res://main_desktop.tscn")

# 🖥️ เมื่อกดเลือกหัวข้อ System (Task Manager)
func _on_system_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "task_manager"
	get_tree().change_scene_to_file("res://main_desktop.tscn")

# 🔴 เมื่อกดโหมดผสมสุดโหด
func _on_mix_mode_pressed():
	Global.is_mix_mode = true
	Global.selected_topic = "mix"
	get_tree().change_scene_to_file("res://main_desktop.tscn")


func _on_button_router_topic_pressed():
	Global.is_mix_mode = false             # ปิดโหมดผสม เพราะเราจะซ้อมแยกวิชา
	Global.selected_topic = "router"       # สั่งส่งค่า "router" ไปบอกสมองกลาง
	get_tree().change_scene_to_file("res://main_desktop.tscn") # วาร์ปไปหน้าเดสก์ท็อปหลัก


func _on_button_pdpa_topic_pressed():
	Global.is_mix_mode = false
	Global.selected_topic = "pdpa" # 🌟 ส่งค่าไปบอกสมองกลางให้เปิดวิชากฎหมาย
	get_tree().change_scene_to_file("res://main_desktop.tscn")
