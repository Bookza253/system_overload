extends Control

func _ready():
	# สั่งให้เมาส์โชว์ปกติ เผื่อกรณีเมาส์หายตอนเล่นเกม
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# 🌟 สัญญาณจากการกดปุ่ม RestartButton (Reboot Server)
func _on_restart_button_pressed() -> void:
	# ล้างค่าคะแนนหรือค่าการสะสมแต้มผ่านด่านใน Global ทิ้งไปให้หมดก่อนเริ่มใหม่
	Global.completed_modules_count = 0
	
	# 🟢 แก้ไขพาร์ทไฟล์จาก node_selection เป็น mode_selection ให้ถูกต้อง
	get_tree().change_scene_to_file("res://mode_selection.tscn")
