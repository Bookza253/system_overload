extends Control

@onready var manual_panel = $Panel/ManualPanel  # 📖 ตัวแปรชี้ไปที่แผงคู่มือ
@onready var status_label = $Panel/Label_Status
@onready var instruction_label = $Panel/Label_Instruction
@onready var ip_input = $Panel/LineEdit_IP
@onready var port_button = $Panel/Button_TogglePort
@onready var blue_screen = $blue_screen
@onready var error_label = $blue_screen/ErrorText

var target_ip = ""
var target_port = 0
var is_port_open = false
var is_game_over = false

func _ready():
	blue_screen.hide()
	port_button.text = "PORT: CLOSED"
	setup_router_challenge()

# 🎲 ฟังก์ชันสุ่มโจทย์ระบบล่มตามแผนกต่างๆ
func setup_router_challenge():
	is_game_over = false
	blue_screen.hide()
	ip_input.text = ""
	is_port_open = false
	port_button.text = "PORT: CLOSED"
	
	manual_panel.hide() # 🌟 สั่งให้คู่มือปิดลงก่อนทุกครั้งที่ขึ้นโจทย์ใหม่
	
	var departments = ["Accounting", "HR", "Marketing", "R&D"]
	var selected_dept = departments[randi() % departments.size()]
	
	# สุ่มชุดข้อมูล IP และพอร์ตที่ถูกต้อง (ให้ตรงกับเงื่อนไขในคู่มือเพื่อน)
	match selected_dept:
		"Accounting":
			target_ip = "192.168.1.50"
			target_port = 8080
		"HR":
			target_ip = "192.168.2.10"
			target_port = 22
		"Marketing":
			target_ip = "192.168.3.99"
			target_port = 443
		"R&D":
			target_ip = "10.0.0.4"
			target_port = 3128
			
	status_label.text = "🚨 CRITICAL: " + selected_dept + " Department Network DISCONNECTED!"
	instruction_label.text = "Enter valid Routing Path & Open required Gateway Port."

# 🔘 กดปุ่มเพื่อสลับเปิด-ปิด Port
func _on_button_toggle_port_pressed():
	if is_game_over: return
	is_port_open = !is_port_open
	if is_port_open:
		port_button.text = "PORT: OPEN (Listening)"
	else:
		port_button.text = "PORT: CLOSED"

# 🚀 กดปุ่ม Apply เพื่อตรวจสอบความถูกต้อง
func _on_button_apply_pressed():
	if is_game_over: return
	
	var user_entered_ip = ip_input.text.strip_edges()
	
	# ตรวจเช็กเงื่อนไข (สมมติว่าคู่มือกำหนดให้กรอก IP ถูกต้อง และในด่านนี้ต้องเปิดพอร์ตเสมอ)
	if user_entered_ip == target_ip and is_port_open:
		print("✅ เชื่อมต่อเน็ตเวิร์กสำเร็จ!")
		status_label.text = "🟢 STATUS: NETWORK ONLINE"
		await get_tree().create_timer(1.5).timeout
		self.hide() # ผ่านด่านแล้ว ปิดหน้าต่างตัวเองลง
	else:
		# ❌ ถ้าตั้งค่าผิดพลาด เน็ตเวิร์กช็อตตัดเข้าจอฟ้าทันที!
		trigger_game_over("ROUTER DETONATED: \nการตั้งค่าล้มเหลว! เกิดสภาวะ IP Conflict หรือลืมเปิด Port สื่อสาร!")

func trigger_game_over(reason_text):
	is_game_over = true
	error_label.text = reason_text
	blue_screen.show()

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://start_screen.tscn")


# 🖱️ ปุ่มกดเพื่อ เปิด หรือ ปิด หน้าต่างคู่มือสลับกันไปมา
func _on_button_manual_pressed():
	if is_game_over: return
	
	# ตรรกะสลับค่า: ถ้าเปิดอยู่ให้ปิด ถ้าปิดอยู่ให้เปิด
	manual_panel.visible = !manual_panel.visible
