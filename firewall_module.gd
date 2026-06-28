extends Control

@onready var log_container = $Panel/VBoxContainer 
# 🗑️ ลบ @onready var blue_screen และ error_label อันเก่าออกไปแล้ว
@onready var rule_label = $Panel/Label2 

var is_game_over = false
var hackers_blocked = 0  
var win_condition = 7  # 📈 เพิ่มความยาก: ปรับเป็นต้องสกัดให้ได้ 7 ครั้งถึงจะชนะ
var danger_port = 4444 
var max_lives = 3
var current_lives = 3

func _ready():
	visibility_changed.connect(_on_window_visibility_changed)
	# 🗑️ ลบคำสั่งเชื่อมต่อปุ่ม Restart ของจอฟ้าอันเก่าออกไปแล้ว

func setup_game():
	is_game_over = false
	hackers_blocked = 0
	current_lives = 3
	
	# 😈 รีเซ็ตตัวคูณ CPU กลับมาเป็น 1 เท่าทุกครั้งที่เริ่มเกมใหม่
	Global.mix_cpu_multiplier = 1.0 
	
	for child in log_container.get_children():
		child.queue_free()
		
	# สุ่มพอร์ตอันตรายประจำรอบ
	var port_pool = [4444, 8080, 3128, 5555, 2121]
	danger_port = port_pool[randi() % port_pool.size()]
	update_rule_ui()

func update_rule_ui():
	rule_label.text = "RULE: บล็อกเฉพาะ UDP พอร์ต " + str(danger_port) + " | ❤️ พลังชีวิต: " + str(current_lives) + "/" + str(max_lives)

func _on_window_visibility_changed():
	if is_visible_in_tree():
		setup_game()
		$Timer.start()
	else:
		$Timer.stop()

# 🎲 ระบบสุ่มทราฟฟิกแบบสับขาหลอกขั้นสูง
func _on_timer_timeout():
	if is_game_over:
		return 
		
	var new_log = Button.new() 
	var traffic_type = randi() % 4 # สุ่มรูปแบบข้อมูลจาก 4 หน้าต่างความเป็นไปได้
	
	var log_ip = "192.168.1." + str(randi() % 254 + 1)
	var log_port = danger_port
	var log_proto = "UDP"
	var is_hacker = false
	
	match traffic_type:
		0: # 🟥 1. True Hacker (ตรงเงื่อนไขอันตรายทั้งหมด)
			log_ip = "10.0.0." + str(randi() % 99 + 1)
			log_port = danger_port
			log_proto = "UDP"
			is_hacker = true
			
		1: # #️⃣ 2. Fake Out: พอร์ตตรง แต่ Protocol ผิด (TCP) -> คนปกติ
			log_port = danger_port
			log_proto = "TCP"
			is_hacker = false
			
		2: # #️⃣ 3. Fake Out: Protocol ตรง (UDP) แต่พอร์ตปลอดภัย -> คนปกติ
			var safe_ports = [80, 443, 22, 3306]
			log_port = safe_ports[randi() % safe_ports.size()]
			log_proto = "UDP"
			is_hacker = false
			
		3: # 🟩 4. Pure Normal (ปลอดภัย 100%)
			var safe_ports = [80, 443, 22, 3306]
			log_port = safe_ports[randi() % safe_ports.size()]
			log_proto = "TCP"
			is_hacker = false

	# ประกอบข้อความแสดงผลบนหน้าจอ
	new_log.text = "[INBOUND] IP: " + log_ip + " | Port: " + str(log_port) + " | Protocol: " + log_proto
	new_log.set_meta("is_hacker", is_hacker) 

	new_log.pressed.connect(self._on_log_clicked.bind(new_log))
	log_container.add_child(new_log)
	
	# ระบบคิวล้นจอ (ถ้าหลุดขอบบนแล้วเป็นแฮกเกอร์ จะโดนหักเลือด)
	if log_container.get_child_count() > 8: 
		var oldest_log = log_container.get_child(0)
		if oldest_log.get_meta("is_hacker") == true:
			deduct_life("SYSTEM BREACHED: แฮกเกอร์เล็ดลอดเข้าสู่ระบบพอร์ต " + str(danger_port) + "!")
			
			# 😈 ถ้าอยู่ในโหมดผสม แล้วปล่อยแฮกเกอร์หลุด 
			# สั่งเพิ่มความเร็วหลอด CPU ฝั่ง Task Manager ขึ้นอีกตัวละ +0.5 เท่าทันที!
			if Global.is_mix_mode:
				Global.mix_cpu_multiplier += 0.5
				print("🔥 แฮกเกอร์หลุด! CPU Multiplier พุ่งเป็น: ", Global.mix_cpu_multiplier)
				
		oldest_log.queue_free()

func _on_log_clicked(clicked_log):
	if is_game_over:
		return
		
	if clicked_log.get_meta("is_hacker") == true:
		hackers_blocked += 1 
		clicked_log.queue_free() 
		update_rule_ui()
		
		if hackers_blocked >= win_condition:
			$Timer.stop() 
			
			# 🟢 ส่งแต้มไปบอกตัวแปร Global ว่าด่านนี้เคลียร์แล้วนะ
			Global.completed_modules_count += 1
			
			self.hide()   
	else:
		clicked_log.queue_free()
		deduct_life("FATAL ERROR: คุณไปบล็อกทราฟฟิกพนักงานปกติ!")

func deduct_life(reason_message):
	current_lives -= 1
	update_rule_ui()
	
	if current_lives <= 0:
		trigger_game_over(reason_message)

# 🌟 ฟังก์ชันจัดการการแพ้แบบดีดเข้าสู่หน้าจอฟ้าหลักของระบบ
func trigger_game_over(reason_message):
	is_game_over = true
	$Timer.stop() 
	
	# 1. ส่งรายละเอียดและรหัสข้อผิดพลาดของ Firewall ไปฝากไว้ที่ตัวแปรกลาง
	Global.game_over_reason = "❌ FIREWALL SECURITY COLLAPSE\n" + reason_message + "\nเครือข่ายโดนทำลายโดยสมบูรณ์!"
	
	# 2. กระโดดข้ามหน้าต่างสี่เหลี่ยม เปลี่ยนฉากใหญ่เต็มจอไปที่ฉากจอฟ้าตัวใหม่
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

# 🗑️ ลบฟังก์ชัน _on_restart_button_pressed แบบเก่าออกไปแล้ว
