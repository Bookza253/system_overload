extends Control

# ลำดับหน้าสไลด์ปัจจุบัน (0 = มันคืออะไร, 1 = เอาไว้ทำอะไร, 2 = ขั้นตอน 1-2-3)
var current_step: int = 0

@onready var title_label = $Panelmain/Label_Title
@onready var content_label = $Panelmain/RichTextLabel_Content
@onready var next_button = $Panelmain/Button_Next
@onready var back_button = $Panelmain/Button_Back
@onready var start_button = $Panelmain/Button_Start

func _ready():
	current_step = 0
	start_button.hide() # หน้าแรกสุดให้ซ่อนปุ่มเริ่มเกมไว้ก่อน
	back_button.disabled = true # หน้าแรกสุดห้ามกดปุ่มย้อนกลับ
	_update_tutorial_ui()

func _update_tutorial_ui():
	# อ่านค่าหัวข้อด่านจากตัวแปรส่วนกลาง (Fallback เป็น VLAN ถ้าไม่มีข้อมูล)
	var topic = "VLAN"
	if "selected_topic" in Global and Global.selected_topic != "":
		topic = Global.selected_topic
	
	match current_step:
		0: # ➡️ ขั้นที่ 1: มันคืออะไร?
			title_label.text = topic + " คืออะไร?"
			back_button.disabled = true
			next_button.show()
			start_button.hide()
			
			if topic == "VLAN":
				content_label.text = "VLAN (Virtual LAN) คือการแบ่งกลุ่มเครือข่ายภายในสวิตช์ตัวเดียวกันให้แยกออกจากกันในเชิงตรรกะ ทำให้คอมพิวเตอร์ต่างแผนกไม่สามารถแอบคุยกันเองได้โดยตรง"
			elif topic == "NAT":
				content_label.text = "NAT (Network Address Translation) คือระบบแปลงฟอร์แมต IP Address ภายใน (Private IP) ให้กลายเป็น IP สาธารณะ (Public IP) เพื่อใช้ในการออกสื่อสารสู่อินเทอร์เน็ตภายนอก"
				
		1: # ➡️ ขั้นที่ 2: เอาไว้ทำอะไร?
			title_label.text = "ทำไมต้องใช้ " + topic + "?"
			back_button.disabled = false
			next_button.show()
			start_button.hide()
			
			if topic == "VLAN":
				content_label.text = "🎯 วัตถุประสงค์หลัก:\nเพื่อแยกสิทธิ์เข้าถึงข้อมูลความมั่นคงปลอดภัยระหว่างแผนก (เช่น กีดกันฝ่ายการตลาดไม่ให้แอบเข้ามาล้วงข้อมูลฝ่ายบุคคล) ช่วยเพิ่มประสิทธิภาพระบบเน็ตเวิร์ก และตอบโจทย์กฎหมายความคุ้มครองข้อมูลส่วนบุคคล (PDPA)"
			elif topic == "NAT":
				content_label.text = "🎯 วัตถุประสงค์หลัก:\nเพื่อแก้ปัญหาวิกฤตการณ์ขาดแคลนหมายเลข IPv4 บนโลก และช่วยพรางความปลอดภัยโดยซ่อนไอพีภายในคอมพิวเตอร์ของคุณ ไม่ให้แฮกเกอร์ภายนอกโจมตีเจาะระบบเข้ามาตรง ๆ"
				
		2: # ➡️ ขั้นที่ 3: ขั้นตอน 1-2-3 (ไกด์นำทางก่อนพิมพ์)
			title_label.text = "โครงสร้างและขั้นตอนคำสั่ง (Cisco CLI)"
			next_button.hide() # หน้าสุดท้ายให้ซ่อนปุ่มถัดไป
			start_button.show() # เปิดปุ่มลุยเกมจริงขึ้นมา
			
			if topic == "VLAN":
				content_label.text = "📌 ลำดับขั้นตอนการแก้ไขปัญหาระบบ:\n\n1️⃣ พิมพ์ 'en' เพื่อเข้าสู่โหมด Privileged EXEC (สิทธิ์แอดมิน)\n2️⃣ พิมพ์ 'sh vlan brief' เพื่อตรวจดูพอร์ตที่เชื่อมโยงผิดพลาด\n3️⃣ พิมพ์ 'conf t' เพื่อเข้าสู่โหมดตั้งค่าระบบส่วนกลาง\n4️⃣ พิมพ์ 'int [ชื่อพอร์ต]' (เช่น int fa0/11) เข้าสู่ตัวพอร์ตที่มีปัญหา\n5️⃣ พิมพ์ 'sw acc vlan [หมายเลข]' เพื่อย้ายสิทธิ์กลุ่มเครือข่ายให้ถูกต้อง"
			elif topic == "NAT":
				content_label.text = "📌 ลำดับขั้นตอนการแก้ไขปัญหาระบบ:\n\n1️⃣ พิมพ์ 'en' ➡️ 'conf t' เพื่อเปิดระบบเข้าสู่โหมดคอนฟิกส่วนกลาง\n2️⃣ พิมพ์ชุดคำสั่ง 'ip nat inside source list...' เพื่อผูก Access-List\n3️⃣ เจาะจงเข้าอินเตอร์เฟสขาเข้าและขาออกเพื่อพิมพ์คำสั่งเปิดท่อสัญญาณ 'ip nat inside' และ 'ip nat outside' ให้ครบถ้วนตามทฤษฎี"

	# ✅ ย้ายโค้ดมาอยู่ท้ายสุดของฟังก์ชันนี้ และจัดย่อหน้าให้ถูกต้องเรียบร้อยแล้วครับ
	if has_node("Panelmain/TextureRect_Visual"):
		$Panelmain/TextureRect_Visual.queue_redraw()

# ==============================================================================
# 🎮 SIGNAL BINDING HANDLERS (เชื่อมโยงปุ่มกดอินเตอร์เฟซ)
# ==============================================================================
func _on_button_next_pressed():
	if current_step < 2:
		current_step += 1
		_update_tutorial_ui()

func _on_button_back_pressed():
	if current_step > 0:
		current_step -= 1
		_update_tutorial_ui()

func _on_button_start_pressed():
	get_tree().change_scene_to_file("res://main_desktop.tscn")
