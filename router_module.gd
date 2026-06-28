extends Control

@onready var manual_panel = $Panel/ManualPanel  # 📖 ตัวแปรชี้ไปที่แผงคู่มือ
@onready var status_label = $Panel/Label_Status
@onready var instruction_label = $Panel/Label_Instruction
@onready var ip_input = $Panel/LineEdit_IP
@onready var port_button = $Panel/Button_TogglePort
# 🗑️ ลบ @onready var blue_screen และ error_label อันเก่าออกไปแล้ว

var target_ip = ""
var target_port = 0
var is_port_open = false
var is_game_over = false

# 🌟 เพิ่มตัวแปรสำหรับเก็บค่าสถานะจำลองในการพิมพ์คำสั่ง
var current_configured_ip = ""

func _ready():
	# 🔒 🌟 ปลุกให้ระวังตัวแปรลูปเกม (ถ้ามีการเช็ก process ให้เริ่มทำงานที่นี่ได้)
	port_button.text = "PORT: CLOSED"
	setup_router_challenge()

# 🎲 ฟังก์ชันสุ่มโจทย์ระบบล่มตามแผนกต่างๆ
func setup_router_challenge():
	is_game_over = false
	ip_input.text = ""
	is_port_open = false
	current_configured_ip = "" # รีเซ็ตค่า IP ที่คอนฟิกไว้
	port_button.text = "PORT: CLOSED"
	
	manual_panel.hide() # 🌟 สั่งให้คู่มือปิดลงก่อนทุกครั้งที่ขึ้นโจทย์ใหม่
	
	var departments = ["Accounting", "HR", "Marketing", "R&D"]
	var selected_dept = departments[randi() % departments.size()]
	
	# สุ่มชุดข้อมูล IP และพอร์ตที่ถูกต้อง
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
	# 🌟 ปรับปรุงคำอธิบายวิธีใช้คำสั่งบนหน้าจอให้เสมือนจริงขึ้น
	instruction_label.text = "พิมพ์คำสั่ง: 'route add [IP]' -> 'open port [Port]' -> พิมพ์ 'apply' หรือกดปุ่ม APPLY"

# ❌ 🔘 เอาลอจิกคลิกปุ่มสลับพอร์ตแบบเก่าออก เพื่อบังคับให้พิมพ์แทน
func _on_button_toggle_port_pressed():
	pass

# 🚀 กดปุ่ม Apply เพื่อตรวจสอบความถูกต้องและการรันชุดคำสั่งทั้งหมด
func _on_button_apply_pressed():
	# 🌟 เพิ่มเงื่อนไขเช็ก: ถ้าแพ้แล้ว หรือหน้าต่างถูกซ่อนไปแล้ว ให้ดีดคำสั่งทิ้งทันที ป้องกัน Input ซ้ำซ้อน
	if is_game_over or not is_visible_in_tree(): return
	
	var raw_input = ip_input.text.strip_edges()
	
	# 🌟 [ระบบ Simulator แกะคำสั่ง] 
	# 1. จัดการคำสั่งเพิ่มเส้นทาง IP: route add
	if raw_input.begins_with("route add "):
		var user_ip = raw_input.replace("route add ", "").strip_edges()
		current_configured_ip = user_ip
		status_label.text = "⚙️ SIMULATOR: Static route configured -> " + user_ip
		ip_input.text = "" # ล้างช่องเพื่อให้พิมพ์คำสั่งต่อไปง่ายขึ้น
		return
		
	# 2. จัดการคำสั่งเปิดเกตเวย์พอร์ต: open port
	elif raw_input.begins_with("open port "):
		var user_port_str = raw_input.replace("open port ", "").strip_edges()
		if user_port_str == str(target_port):
			is_port_open = true
			port_button.text = "PORT: OPEN (Listening)"
			status_label.text = "⚙️ SIMULATOR: Target Gateway Port Opened Successfully."
		else:
			# ถ้าตั้งพอร์ตผิดจากคู่มือ ถือว่าบุกรุกและระบบตัดทันที
			trigger_game_over("SECURITY ERROR:\nเกิดสภาวะบุกรุก พอร์ตหมายเลข " + user_port_str + " ไม่อนุญาตให้เปิดใช้งานบนแผนกนี้!")
		ip_input.text = ""
		return

	# 3. ตรวจสอบเงื่อนไขหลังสั่งรันระบบแบบของจริง
	# เช็กว่าผู้เล่นกรอก IP ได้ตรงกับแผนก และเปิดใช้งานพอร์ตตรงล็อกแล้วหรือไม่
	if current_configured_ip == target_ip and is_port_open:
		print("✅ เชื่อมต่อเน็ตเวิร์กสำเร็จ!")
		status_label.text = "🟢 STATUS: NETWORK ONLINE"
		
		# สะสมคะแนนตัวนับด่านที่เคลียร์เข้าสคริปต์กลาง
		Global.completed_modules_count += 1
		
		await get_tree().create_timer(1.5).timeout
		self.hide() # ผ่านด่านแล้ว ปิดหน้าต่างตัวเองลง
	else:
		# ❌ ถ้าคีย์คำสั่งผิดพลาด หรือไม่ทำตามลำดับเน็ตเวิร์ก จะโดนบอมบ์จอฟ้าทันที
		var error_msg = "ROUTER DETONATED:\nการตั้งค่าล้มเหลว! "
		if current_configured_ip != target_ip:
			error_msg += "ไม่พบเส้นทางเครือข่ายปลายทาง (Network Unreachable) "
		if not is_port_open:
			error_msg += "หรือ พอร์ตการสื่อสารยังไม่ได้เปิดสัญญาณ (Gateway Closed)!"
		trigger_game_over(error_msg)

# 🌟 ฟังก์ชันจัดการการแพ้แบบเปลี่ยนฉากไปหน้าจอฟ้าหลัก
func trigger_game_over(reason_text):
	is_game_over = true
	
	# 1. ฝากสาเหตุความผิดพลาดเข้าตัวแปรกลาง Global
	Global.game_over_reason = reason_text
	
	# 2. สั่งระบบกระโดดข้ามฉากหลักเต็มจอไปที่ฉากจอฟ้าใหม่ทันที!
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

# 🗑️ ลบฟังก์ชัน _on_restart_button_pressed แบบเก่าออกไปแล้ว

# 🖱️ ปุ่มกดเพื่อ เปิด หรือ ปิด หน้าต่างคู่มือสลับกันไปมา
func _on_button_manual_pressed():
	if is_game_over: return
	manual_panel.visible = !manual_panel.visible

# 🖱️ แก้ไขฟังก์ชันตอนกด Enter ในช่องพิมพ์
func _on_line_edit_ip_text_submitted(_new_text: String) -> void:
	if is_game_over or not is_visible_in_tree(): return # 🌟 ใส่ดักไว้ตรงนี้ด้วยเช่นกันครับ
	_on_button_apply_pressed()
