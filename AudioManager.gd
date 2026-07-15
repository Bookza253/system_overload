extends Node

var sfx_click: AudioStreamPlayer
var sfx_type: AudioStreamPlayer
var bg_music: AudioStreamPlayer

# 🖱️ ตัวแปรสำหรับจำสถานะการคลิกในเฟรมก่อนหน้า เพื่อตรวจจับจังหวะ "เริ่มกด" (Just Pressed)
var was_mouse_pressed: bool = false

func _ready():
	sfx_click = AudioStreamPlayer.new()
	sfx_type = AudioStreamPlayer.new()
	bg_music = AudioStreamPlayer.new()
	
	add_child(sfx_click)
	add_child(sfx_type)
	add_child(bg_music)
	
	sfx_click.stream = load("res://click_sound_1.mp3") 
	sfx_type.stream = load("res://keyboard_key_press_01.ogg")
	
	bg_music.volume_db = -15 

# 🎵 ฟังก์ชันสำหรับสั่งสลับเสียงฉากหลัง
func play_bg_sound(file_path: String):
	if bg_music.stream and bg_music.stream.resource_path == file_path and bg_music.playing:
		return
		
	bg_music.stop()
	bg_music.stream = load(file_path)
	if bg_music.stream:
		bg_music.play()

# 🖱️ เช็กสถานะปุ่มเมาส์โดยตรงจากระดับระบบ (Hardware) ทุกเฟรม ทะลุทะลวงทุก Viewport!
func _process(_delta):
	var is_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	# ถ้าเฟรมนี้กดอยู่ แต่เฟรมที่แล้วไม่ได้กด = เพิ่งคลิกเมาส์ลงไปปึ๊บ!
	if is_pressed and not was_mouse_pressed:
		if sfx_click and sfx_click.stream:
			sfx_click.play()
			
	was_mouse_pressed = is_pressed

# 🎹 เช็กคีย์บอร์ดพิมพ์เฉพาะจังหวะป้อนข้อมูล (คีย์บอร์ดยังใช้ตัวเดิมได้ไม่มีปัญหา)
func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.is_echo():
			if event.keycode not in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_CAPSLOCK]:
				if sfx_type and sfx_type.stream:
					sfx_type.play()
