extends Control

@onready var boot_ui = $BootUI
@onready var login_ui = $LoginUI

func _ready():
	# 1. ตอนเปิดเกมมา ให้โชว์หน้า Boot ส่วนหน้า Login ซ่อนไว้ก่อน
	boot_ui.show()
	login_ui.hide()
	
	# 2. สั่งให้เกม "รอ" 3 วินาที (จำลองการโหลดเปิดเครื่อง)
	await get_tree().create_timer(3.0).timeout
	
	# 3. พอครบ 3 วินาที สั่งสลับหน้าจอเอาหน้า Login ขึ้นมาแทน!
	boot_ui.hide()
	login_ui.show()

# 4. ฟังก์ชันเชื่อมต่อปุ่มเข้าเกม
func _on_button_pressed():
	get_tree().change_scene_to_file("res://mode_selection.tscn")
