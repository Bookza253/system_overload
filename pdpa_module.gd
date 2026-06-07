extends Control

@onready var request_label = $Panel/Label_Request
@onready var timer_label = $Panel/Label_Timer
@onready var blue_screen = $blue_screen
@onready var error_label = $blue_screen/ErrorText

var current_request_answer: bool = false # true = ควรอนุญาต (Allow), false = ควรปฏิเสธ (Deny)
var time_left: float = 12.0
var is_game_over: bool = false

# 📜 คลังโจทย์สุ่มคำร้องจรรยาบรรณ & กฎหมาย PDPA
var challenges = [
	{
		"text": "นักศึกษาฝึกงาน (Intern) ส่งคำร้อง:\n ขอเข้าถึง 'ไฟล์โครงสร้างเงินเดือนผู้บริหาร' เพื่อศึกษาระบบงานคลัง",
		"allow": false,
		"reason": "🚨 ผิดพลาด! นักศึกษาฝึกงานไม่มีสิทธิ์เข้าถึงข้อมูลความลับทางการเงินระดับสูงของบริษัท!"
	},
	{
		"text": "ฝ่ายบุคคล (HR) ส่งคำร้อง:\n ขอเข้าถึง 'ประวัติและข้อมูลติดต่อพนักงานใหม่' เพื่อใช้ลงทะเบียนประกันสังคม",
		"allow": true,
		"reason": "🚨 ผิดพลาด! ฝ่ายบุคคลมีสิทธิ์ชอบธรรมในการจัดการข้อมูลพนักงานตามฐานสัญญาจ้าง"
	},
	{
		"text": "ฝ่ายการตลาด (Marketing) ส่งคำร้อง:\n ขอดึง 'เบอร์โทรศัพท์ลูกค้าทั้งหมด' ไปขายต่อให้บริษัทประกันภายนอก โดยไม่ได้แจ้งขอ Consent",
		"allow": false,
		"reason": "🚨 ผิดกฎหมาย PDPA รุนแรง! การนำข้อมูลส่วนบุคคลไปเผยแพร่ให้บุคคลภายนอกโดยไม่มีฐานความยินยอม ถือเป็นความผิดร้ายแรง!"
	},
	{
		"text": "คุณสมชาย (ลูกค้าเก่า) ส่งอีเมล:\n 'ขอใช้สิทธิ์ตามกฎหมาย PDPA สั่งให้ระบบลบประวัติและเบอร์โทรของตนออกจากระบบทั้งหมด'",
		"allow": true,
		"reason": "🚨 ผิดกฎหมาย PDPA! เจ้าของข้อมูลมีสิทธิ์ขอให้ลบหรือทำลายข้อมูล (Right to Erasure) คุณไม่มีสิทธิ์ปฏิเสธคำขอ!"
	},
	{
		"text": "ผู้จัดการทั่วไป (Manager) ส่งคำร้อง:\n ขอเปิดดู 'ไฟล์รายงานสรุปงบประมาณประจำเดือน' ของบริษัทเพื่อตรวจสอบบัญชี",
		"allow": true,
		"reason": "🚨 ผิดพลาด! ระดับผู้จัดการ (Manager) มีสิทธิ์อันชอบธรรมในการเข้าถึงข้อมูลสรุปการเงินภายในองค์กร"
	}
]

func _ready():
	setup_new_request()

func _process(delta):
	if is_game_over: return
	
	time_left -= delta
	timer_label.text = "เวลาที่เหลือ: " + str(ceil(time_left)) + " วิ"
	
	if time_left <= 0:
		trigger_game_over("🚨 หมดเวลาตัดสินใจ! ปล่อยให้คำร้องค้างคา คลุมเครือ ผิดจรรยาบรรณวิชาชีพ!")

# 🎲 ฟังก์ชันสุ่มโจทย์ใหม่
func setup_new_request():
	is_game_over = false
	blue_screen.hide()
	time_left = 12.0 # ให้เวลาข้อละ 12 วินาที
	
	var random_idx = randi() % challenges.size()
	var current_challenge = challenges[random_idx]
	
	request_label.text = current_challenge["text"]
	current_request_answer = current_challenge["allow"]

# 🟩 ปุ่ม ALLOW (อนุญาต)
func _on_button_allow_pressed():
	if is_game_over: return
	if current_request_answer == true:
		print("เลือกถูกทาง! อนุมัติถูกต้องตามกฎหมาย")
		status_complete()
	else:
		trigger_game_over(challenges[challenges.find_custom(func(c): return c["text"] == request_label.text)]["reason"])

# 🟥 ปุ่ม DENY (ปฏิเสธ)
func _on_button_deny_pressed():
	if is_game_over: return
	if current_request_answer == false:
		print("เลือกถูกทาง! ปฏิเสธสิทธิ์ปกป้องข้อมูลสำเร็จ")
		status_complete()
	else:
		trigger_game_over(challenges[challenges.find_custom(func(c): return c["text"] == request_label.text)]["reason"])

func status_complete():
	is_game_over = true # สั่งหยุดเวลานับถอยหลังชั่วคราว
	
	# เปลี่ยนข้อความในกล่องโจทย์ให้กลายเป็นตัวหนังสือสีเขียวแจ้งสถานะสำเร็จ
	request_label.text = "🟢 [ COMPLIANCE SUCCESS ]\nการดำเนินงานถูกต้องตามกฎหมาย PDPA และจรรยาบรรณวิชาชีพเรียบร้อย!"
	
	# สั่งให้ตัวเอนจินรอเวลาหน่วงหน้าจอไว้เป็นเวลา 1.5 วินาที เพื่อให้คนเล่นได้อ่าน
	await get_tree().create_timer(1.5).timeout
	
	# พอครบ 1.5 วิแล้ว ค่อยสั่งปิดหน้าต่างแอปนี้ลงไปเพื่อกลับสู่หน้าจอเดสก์ท็อปหลัก
	self.hide()

func trigger_game_over(reason_text):
	is_game_over = true
	error_label.text = reason_text
	blue_screen.show()

# 🔄 ปุ่ม RESTART บนหน้าจอฟ้า
func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://start_screen.tscn")
