extends Control

@onready var cpu_bar = $Panel/ProgressBar
@onready var blue_screen = $ColorRect  
@onready var error_label = $ColorRect/ErrorText # 🌟 1. เพิ่มบรรทัดนี้ให้โค้ดรู้จักตัวหนังสือบนจอฟ้า

var is_game_over = false  
var viruses_left = 5  

func _ready():
	cpu_bar.value = 0
	blue_screen.hide() 
	
	shuffle_buttons() # 🌟 เพิ่มบรรทัดนี้: สั่งให้สลับปุ่มทันทีที่โหลดหน้าต่างเสร็จ

func _process(delta):
	if is_game_over == false:
		
		if viruses_left == 0:
			print("กำจัดไวรัสสำเร็จ! ระบบปลอดภัยแล้ว")
			self.hide()
			return      
		
		# ✨ ให้แก้เป็นเอาตัวคูณจากสมองกลางมาคูณเข้าไปด้วย:
		cpu_bar.value += 10 * delta * Global.mix_cpu_multiplier
		
		# 🌟 โค้ดที่เพิ่มเข้ามา: ลูกเล่นเปลี่ยนสีหลอด
		if cpu_bar.value >= 70:
			# ถ้าทะลุ 70% สั่งให้หลอดเปลี่ยนเป็นสีแดง (Red)
			cpu_bar.modulate = Color(1, 0, 0) 
		else:
			# ถ้ายังไม่ถึง ให้เป็นสีปกติ (White คือการใช้สีดั้งเดิมที่เราตั้งไว้)
			cpu_bar.modulate = Color(1, 1, 1)
		
		if cpu_bar.value >= 100:
			trigger_game_over("SYSTEM CRASHED: \nหลอด CPU ร้อนทะลุ 100% เพราะกำจัดไวรัสไม่ทัน!")

# 🌟 3. ปรับฟังก์ชันแพ้ ให้รับ "ข้อความ" เข้ามาเปลี่ยนบนหน้าจอด้วย
func trigger_game_over(reason_text):
	is_game_over = true
	error_label.text = reason_text # สั่งเปลี่ยนข้อความตามที่ส่งมา
	blue_screen.show()
	print("SYSTEM CRASHED!")


# ==========================================
# กลุ่มที่ 1: ปุ่มไวรัส (กดแล้วดี)
# ==========================================
func _on_button_1_pressed():
	cpu_bar.value -= 30
	viruses_left -= 1   
	$Panel/VBoxContainer/Button1.queue_free()

func _on_button_2_pressed():
	cpu_bar.value -= 30
	viruses_left -= 1  
	$Panel/VBoxContainer/Button2.queue_free()


# ==========================================
# กลุ่มที่ 2: ปุ่มไฟล์ระบบ (กับดัก! กดแล้วซวย)
# ==========================================
func _on_button_3_pressed():
	print("FATAL: เผลอปิดไฟล์ระบบ!")
	# 🌟 4. ถ้าแพ้เพราะกดปุ่ม 3 (System32) ให้ส่งประโยคนี้ไปด่า
	trigger_game_over("FATAL ERROR: \nคุณเผลอไปกดลบไฟล์ระบบ (System32) ระบบล่มทันที!") 

func _on_button_4_pressed() -> void:
	print("WARNING: ปิดระบบป้องกัน ความร้อนพุ่งสูง!")
	cpu_bar.value += 40 
	$Panel/VBoxContainer/Button4.queue_free()
	
func _on_button_5_pressed():
	cpu_bar.value -= 30
	viruses_left -= 1   
	$Panel/VBoxContainer/Button5.queue_free() # สั่งลบ Button5

func _on_button_6_pressed():
	cpu_bar.value -= 30
	viruses_left -= 1   
	$Panel/VBoxContainer/Button6.queue_free() # สั่งลบ Button6

func _on_button_7_pressed():
	cpu_bar.value -= 30
	viruses_left -= 1   
	$Panel/VBoxContainer/Button7.queue_free() # สั่งลบ Button7

# ==========================================
# 🌟 ฟังก์ชันพิเศษ: สุ่มตำแหน่งปุ่ม
# ==========================================
func shuffle_buttons():
	var container = $Panel/VBoxContainer
	var buttons = container.get_children()
	
	# วนลูปจับปุ่มแต่ละอัน ไปแทรกในตำแหน่งแบบสุ่ม (สลับคิว)
	for button in buttons:
		var random_index = randi() % container.get_child_count()
		container.move_child(button, random_index)

func _on_restart_button_pressed():
	# 🔄 วาร์ปกลับไปเริ่มระบบปฏิบัติการใหม่ตั้งแต่หน้าเปิดเครื่อง (Boot Screen)
	get_tree().change_scene_to_file("res://mode_selection.tscn")
