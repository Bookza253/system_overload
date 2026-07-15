extends Node

# ==============================================================================
# 🔊 GLOBAL AUDIO MANAGER (AUTOLOAD SINGLETON)
# - สคริปต์ระบบเสียงส่วนกลาง ทำหน้าที่จัดการสตรีมมิ่งเสียงประกอบ (SFX) และเสียงบรรยากาศ (BGM)
# - ดักจับการทำงานระดับฮาร์ดแวร์ (Hardware Input Detection) เพื่อแก้ปัญหาสัญญาณอินพุตหลุดข้าม Viewport
# ==============================================================================

var sfx_click: AudioStreamPlayer
var sfx_type: AudioStreamPlayer
var bg_music: AudioStreamPlayer

# 🖱️ State Tracking: ตัวแปรจัดเก็บสถานะสถานะเมาส์เฟรมก่อนหน้า เพื่อหาจังหวะ Just Pressed (เริ่มคลิก)
var was_mouse_pressed: bool = false

# ==============================================================================
# ⚙️ INITIALIZATION
# - ทำการสร้างอินสแตนซ์ AudioStreamPlayer ขึ้นมาใน Scene Tree แบบไดนามิก
# - โหลดไฟล์เสียงเริ่มต้นเพื่อเตรียมความพร้อม (Asset Pre-loading)
# ==============================================================================
func _ready():
	sfx_click = AudioStreamPlayer.new()
	sfx_type = AudioStreamPlayer.new()
	bg_music = AudioStreamPlayer.new()
	
	add_child(sfx_click)
	add_child(sfx_type)
	add_child(bg_music)
	
	# โหลดข้อมูลไฟล์เสียงประกอบพื้นฐานเข้าสู่หน่วยความจำ
	sfx_click.stream = load("res://click_sound_1.mp3") 
	sfx_type.stream = load("res://keyboard_key_press_01.ogg")
	
	# ปรับค่าระดับความดังเสียงพื้นหลัง (Gain Volume db)
	bg_music.volume_db = -15 

# ==============================================================================
# 🎵 BACKGROUND MUSIC STREAM CONTROLLER
# - play_bg_sound: ใช้สลับและรันเสียงบรรยากาศพื้นหลังตาม Path ทรัพยากรที่ส่งเข้ามา
# - มีระบบตรวจสอบสภาพการรันไฟล์ซ้ำ (Duplication Guard) เพื่อไม่ให้เริ่มเล่นเพลงเดิมซ้ำตั้งแต่ต้น
# ==============================================================================
func play_bg_sound(file_path: String):
	# Guard Clause: หากระบบกำลังเล่นเพลงนี้อยู่แล้ว ให้สคริปต์ดีดตัวกลับทันทีเพื่อความต่อเนื่อง
	if bg_music.stream and bg_music.stream.resource_path == file_path and bg_music.playing:
		return
		
	bg_music.stop()
	bg_music.stream = load(file_path)
	if bg_music.stream:
		bg_music.play()

# ==============================================================================
# 🖱️ HARDWARE LEVEL INPUT DETECTION
# - ทำการตรวจจับอินพุตการคลิกเมาส์ในระดับฮาร์ดแวร์ผ่าน _process (ทุก ๆ เฟรม)
# - ช่วยให้มั่นใจว่าเสียงคลิกปุ่มจะดังเสมอ แม้ปุ่มหรือโหนดเหล่านั้นจะอยู่ใน SubViewport อื่น ๆ 
# ==============================================================================
func _process(_delta):
	var is_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	# ตรรกะตรวจหาจังหวะขอบขาขึ้น (Edge Triggered: เฟรมก่อนไม่กด เฟรมนี้กดลงไป)
	if is_pressed and not was_mouse_pressed:
		if sfx_click and sfx_click.stream:
			sfx_click.play()
			
	was_mouse_pressed = is_pressed

# ==============================================================================
# 🎹 KEYBOARD INPUT CAPTURE
# - ดักจับการกดแป้นพิมพ์เพื่อจำลองเสียงแป้นพิมพ์พิมพ์ CLI (Terminal Typing)
# - ยกเว้นปุ่มฟังก์ชันพิเศษกลุ่ม Modifier Keys (Shift, Ctrl, Alt) เพื่อป้องกันเสียงออกซ้ำซ้อน
# ==============================================================================
func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.is_echo():
			if event.keycode not in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_CAPSLOCK]:
				if sfx_type and sfx_type.stream:
					sfx_type.play()
