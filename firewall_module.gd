extends Control

@onready var packet_info = $Panel/Label_Packet # 👈 แก้ไข Path ตรงนี้ให้ตรงตามด่านจริงของคุณ
@onready var rule_info = $Panel/Label_Rule     # 👈 แก้ไข Path ตรงนี้ให้ตรงตามด่านจริงของคุณ

var current_ip = ""
var current_port = 0
var is_dangerous = false

func _ready():
	# 🔒 เช็กความปลอดภัยก่อนว่าลาก Node มาแปะถูกตัวไหม เกมจะได้ไม่ค้าง
	if packet_info and rule_info:
		generate_packet()
	else:
		print("🚨 Error: หา Node Label_Packet หรือ Label_Rule ไม่เจอ! ตรวจสอบชื่อ Node ใน Scene Tree อีกครั้ง")

func generate_packet():
	# ตรวจสอบอีกครั้งก่อนกำหนดค่าข้อความ (.text)
	if not rule_info or not packet_info:
		return
		
	rule_info.text = "🛡️ SECURITY RULE: BLOCK all traffic from IP: 192.168.1.66 OR Port: 666"
	
	var ips = ["192.168.1.10", "192.168.1.66", "10.0.0.5"]
	var ports = [80, 443, 666, 22]
	
	current_ip = ips[randi() % ips.size()]
	current_port = ports[randi() % ports.size()]
	
	if current_ip == "192.168.1.66" or current_port == 666:
		is_dangerous = true
	else:
		is_dangerous = false
		
	packet_info.text = "INCOMING PACKET:\nIP: " + current_ip + "\nPORT: " + str(current_port)


func _on_button_allow_pressed():
	if not is_dangerous:
		# ✅ ตอบถูก (เป็น Packet ปลอดภัยและปล่อยผ่าน) -> ชนะทันที
		win_stage()
	else:
		# ❌ ตอบผิด -> จอฟ้า/กลับหน้าเลือกโหมด
		trigger_game_over("SECURITY BREACH: คุณปล่อยให้มัลแวร์เข้าสู่ระบบ!")

func _on_button_deny_pressed():
	if is_dangerous:
		# ✅ ตอบถูก (เป็น Packet อันตรายแล้วกดบล็อก) -> ชนะทันที
		win_stage()
	else:
		# ❌ ตอบผิด -> จอฟ้า/กลับหน้าเลือกโหมด
		trigger_game_over("NETWORK DISRUPTION: คุณบล็อกผู้ใช้ทั่วไปจนใช้งานไม่ได้!")

func trigger_game_over(reason):
	print(reason)
	get_tree().change_scene_to_file("res://mode_selection.tscn")

func win_stage():
	print("Firewall Configured Successfully!")
	self.hide() # ปิดหน้าต่าง Popup ด่านนี้ลง
