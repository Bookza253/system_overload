extends Control

@onready var boot_ui = $BootUI
@onready var login_ui = $LoginUI

@onready var progress_bar = $BootUI/ProgressBar
@onready var system_logs = $BootUI/SystemLogs 
@onready var start_button = $LoginUI/Button

var load_value: float = 0.0
var is_booted: bool = false

# 📑 รายการระบบ (ล้างช่องว่างประหลาดออกเพื่อให้ระบบคำนวณความยาวได้แม่นยำ)
var log_steps = [
	{"text": "  CORE SYSTEM", "target": 15},
	{"text": "  MEMORY CHECK", "target": 28},
	{"text": "  DEVICE INTERFACE", "target": 42},
	{"text": "  NETWORK PROTOCOL", "target": 55},
	{"text": "  SECURITY MODULE", "target": 68},
	{"text": "  USER PROFILE", "target": 80},
	{"text": "  SYSTEM FILES", "target": 90}
]

func _ready():
	boot_ui.show()
	login_ui.hide()
	# 🎶 สั่งเปิดเสียงแรกในหน้า Start (และจะดังต่อเนื่องยาวไปจนถึงหน้า Mode Selection เอง)
	AudioManager.play_bg_sound("res://freesound_community-dark-server-76461.mp3")
	
	if system_logs:
		system_logs.bbcode_enabled = true
		system_logs.text = "■ INITIALIZING SYSTEM...\n\n"
		
	if progress_bar: progress_bar.value = 0
	make_button_blink()

func _process(delta):
	if is_booted: return
	
	if load_value < 100.0:
		var load_speed: float
		if load_value < 90.0:
			load_speed = randf_range(15.0, 30.0)
		else:
			load_speed = 60.0 
			
		load_value += load_speed * delta
		if load_value > 100.0: load_value = 100.0
		
		if progress_bar: progress_bar.value = load_value
		
		update_system_logs()
	else:
		is_booted = true
		boot_ui.hide()
		login_ui.show()

# 📝 ฟังก์ชันพิมพ์ข้อความเวอร์ชันจัดระเบียบคอลัมน์ (มีเส้นหน้า มีช่องไฟ แถวตรงเป๊ะตามเรฟ)
func update_system_logs():
	if not system_logs: return
	
	system_logs.bbcode_enabled = true
	var full_text = "■ INITIALIZING SYSTEM...\n\n"
	
	# 🌟 สร้างตารางแบบ 3 คอลัมน์: 
	# คอลัมน์ 1: เส้นแนวตั้งกับช่องไฟด้านหน้า (กว้าง 40px)
	# คอลัมน์ 2: ชื่อระบบแต่ละตัว (กว้าง 260px)
	# คอลัมน์ 3: คำว่า [ OK ] (จะเด้งไปอยู่ตำแหน่งถัดไปเท่ากันทุกแถว)
	full_text += "[table=3, 40, 260]"
	
	for step in log_steps:
		# 1. คอลัมน์แรก: ใส่เส้นตรงแนวตั้งสีฟ้าสว่างล้อตามรูปเรฟเฟอเรนซ์
		full_text += "[cell][color=#5ce1e6]  │   [/color][/cell]"
		
		# 2. คอลัมน์สอง: ใส่ชื่อระบบ
		full_text += "[cell]" + step["text"] + "[/cell]"
		
		# 3. คอลัมน์สาม: เช็กสถานะการพิมพ์ [ OK ] 
		if load_value >= step["target"]:
			# 💡 อยากให้คำว่า [ OK ] ขยับขวาหนีห่างออกไปอีก ให้มาเพิ่ม Spacebar เปล่าๆ ตรงข้างหน้าคำว่า [  OK  ] ในช่องนี้ได้เลยครับ!
			full_text += "[cell]                                                     [color=#5ce1e6][  OK  ][/color][/cell]"
		else:
			full_text += "[cell][/cell]"
			
	full_text += "[/table]"
	
	system_logs.text = full_text

func make_button_blink():
	if not start_button: return
	var tween = create_tween().set_loops()
	tween.tween_property(start_button, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(start_button, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://mode_selection.tscn")
