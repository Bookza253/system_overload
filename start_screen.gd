extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES (Safe Node References)
# - ดำเนินการดักจับพิกัดโหนด UI สำหรับระบบบูต และระบบลงชื่อเข้าใช้งานล่วงหน้าเพื่อป้องกันข้อผิดพลาด
# ==============================================================================
@onready var boot_ui = $BootUI
@onready var login_ui = $LoginUI

@onready var progress_bar = $BootUI/ProgressBar
@onready var system_logs = $BootUI/SystemLogs 
@onready var start_button = $LoginUI/Button

# ==============================================================================
# SYSTEM STATE PROPERTIES
# - load_value: ค่าเปอร์เซ็นต์ปัจจุบันของการจำลองระบบโหลดข้อมูลเริ่มต้น (0.0 - 100.0)
# - log_steps: อาเรย์ข้อมูลสถานะระบบ (System Init Stages) และเงื่อนไขขีดจำกัดการตรวจสอบ (Target Value)
# ==============================================================================
var load_value: float = 0.0
var is_booted: bool = false

var log_steps = [
	{"text": "  CORE SYSTEM", "target": 15},
	{"text": "  MEMORY CHECK", "target": 28},
	{"text": "  DEVICE INTERFACE", "target": 42},
	{"text": "  NETWORK PROTOCOL", "target": 55},
	{"text": "  SECURITY MODULE", "target": 68},
	{"text": "  USER PROFILE", "target": 80},
	{"text": "  SYSTEM FILES", "target": 90}
]

# ==============================================================================
#⚙️ 2. LIFE CYCLE INITIALIZATION (_ready)
# - ตั้งค่าควบคุมอินเตอร์เฟสเบื้องต้นเพื่อเตรียมแสดงผลระบบบูตจำลอง
# - เรียกใช้ระบบสตรีมเสียงสัญญาณแบ็คกราวด์เริ่มต้น (Ambient Sound System) ผ่าน AudioManager
# ==============================================================================
func _ready():
	boot_ui.show()
	login_ui.hide()
	
	# 🎶 Ambient Music Dispatcher: เล่นเสียงบรรยากาศเซิร์ฟเวอร์แบบเบสต่ำเพื่อดึงอารมณ์ฉากแรก
	AudioManager.play_bg_sound("res://freesound_community-dark-server-76461.mp3")
	
	if system_logs:
		system_logs.bbcode_enabled = true
		system_logs.text = "■ INITIALIZING SYSTEM...\n\n"
		
	if progress_bar: 
		progress_bar.value = 0
		
	make_button_blink()

# ==============================================================================
# 🔄 REAL-TIME PROCESS LOOP (_process)
# - จัดการคำนวณสปีดจำลองการโหลดแบบสุ่มความเร็ว (Variable Loading Speed)
# - สลับการแสดงผลระหว่าง Boot Phase และ Login Phase แบบไร้รอยต่อเมื่อโหลดครบ 100%
# ==============================================================================
func _process(delta):
	if is_booted: return
	
	if load_value < 100.0:
		var load_speed: float
		# จำลองความเร็วการประมวลผลช่วงสเตจกลางให้แกว่งสุ่มเพื่อความสมจริง (Stochastic Speed Simulation)
		if load_value < 90.0:
			load_speed = randf_range(15.0, 30.0)
		else:
			load_speed = 60.0 
			
		load_value += load_speed * delta
		if load_value > 100.0: load_value = 100.0
		
		if progress_bar: 
			progress_bar.value = load_value
		
		update_system_logs()
	else:
		is_booted = true
		boot_ui.hide()
		login_ui.show()

# ==============================================================================
# 📝 SYSTEM LOG RENDERER (Rich Text BBCode Table Builder)
# - ดำเนินการจัดทำฟอร์แมตข้อมูลประวัติระบบแบบคอลัมน์ (Tabular Layout Output)
# - ใช้ BBCode [table] ในการล็อกความกว้างพิกัดช่องไฟ เพื่อป้องกันตัวอักษรยับหรือเบี้ยวข้ามบรรทัด
# ==============================================================================
func update_system_logs():
	if not system_logs: return
	
	system_logs.bbcode_enabled = true
	var full_text = "■ INITIALIZING SYSTEM...\n\n"
	
	# สั่งเปิดตารางจำนวน 3 คอลัมน์พร้อมระบุขอบเขตความกว้างพิกเซลของแต่ละเฟสคอลัมน์
	# Column 1: ขอบเชื่อมโยงเส้นแนวดิ่ง (40px)
	# Column 2: ป้ายข้อมูลระบบ (260px)
	# Column 3: ค่าตอบรับสถานะ [ OK ]
	full_text += "[table=3, 40, 260]"
	
	for step in log_steps:
		# 1. Column 1: ดึงเส้นแนวตั้งตกแต่งสีฟ้าตามสไตล์โครงสร้างแฮกเกอร์คอมพิวเตอร์
		full_text += "[cell][color=#5ce1e6]  │    [/color][/cell]"
		
		# 2. Column 2: เรนเดอร์ป้ายชื่อระบบ
		full_text += "[cell]" + step["text"] + "[/cell]"
		
		# 3. Column 3: ตรวจสอบระดับการโหลดเพื่อปลดสติกเกอร์สถานะ [ OK ] แบบสอดคล้องกับค่าเวลาจริง
		if load_value >= step["target"]:
			full_text += "[cell]                                             [color=#5ce1e6][  OK  ][/color][/cell]"
		else:
			full_text += "[cell][/cell]"
			
	full_text += "[/table]"
	
	system_logs.text = full_text

# ==============================================================================
# ✨ BUTTON VISUAL EFFECTS (Tween Animations)
# - ใช้เทคนิค Tween Interpolation ในการคุมระดับความโปร่งใส (Alpha Transparency Modulation)
# - สั่งวนซ้ำแบบลูปอินฟินิตี้ (Infinite Loop) เพื่อสร้างเอฟเฟกต์ไฟกะพริบแจ้งเตือนระดับนุ่มนวล
# ==============================================================================
func make_button_blink():
	if not start_button: return
	var tween = create_tween().set_loops()
	tween.tween_property(start_button, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(start_button, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

# ==============================================================================
# 🚪 SCENE TRANSITION
# ==============================================================================
func _on_button_pressed():
	# สั่งสลับไปฉากการคัดเลือกหัวข้อบทเรียนถัดไปอย่างปลอดภัย
	get_tree().change_scene_to_file("res://mode_selection.tscn")
