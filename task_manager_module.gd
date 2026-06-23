extends Control

# 🚨 ตรวจสอบ Path เหล่นี้ในหน้า Scene Editor ของคุณอีกครั้งว่าสะกดอย่างไร
@onready var label_terminal = $Panel/Label_Terminal if has_node("Panel/Label_Terminal") else null
@onready var button_ping = $Panel/Button_Ping if has_node("Panel/Button_Ping") else null

var click_count = 0
var target_clicks = 3 
var is_fixed = false

func _ready():
	is_fixed = false
	
	# ระบบความปลอดภัยดัก Null Instance ป้องกันการเด้งหลุด
	if label_terminal:
		label_terminal.text = "C:\\> ping 8.8.8.8\n\n🎯 STATUS: Pinging...\n❌ Request timed out.\n❌ Request timed out.\n\n⚠️ บอร์ดระบบแจ้งเตือน: พอร์ตเชื่อมต่อหลวม! (กรุณากดคลิกปุ่ม REPAIR NETWORK เพื่อเชื่อมต่อใหม่)"
	else:
		print("🚨 [Safety Warning]: หา Node Label_Terminal ไม่เจอ โปรดเช็กโครงสร้าง Scene")
		
	if button_ping: 
		button_ping.text = "⚡ REPAIR NETWORK"

func _on_button_ping_pressed():
	if is_fixed: return
	
	click_count += 1
	
	if label_terminal:
		label_terminal.text = "C:\\> ping 8.8.8.8\n\n🔧 กำลังเชื่อมต่อสายสัญญาณ... (" + str(click_count) + "/" + str(target_clicks) + ")"
	
	if click_count >= target_clicks:
		is_fixed = true
		if label_terminal:
			label_terminal.text = "C:\\> ping 8.8.8.8\n\n🟢 SUCCESS: Connected!\nReply from 8.8.8.8: bytes=32 time=12ms TTL=115\nReply from 8.8.8.8: bytes=32 time=10ms TTL=115\n\n✅ สัญญาณเน็ตเวิร์กกลับมาใช้งานได้ปกติแล้ว!"
		
		await get_tree().create_timer(2.0).timeout
		self.hide() # ผ่านด่าน ปิดหน้าต่างตัวเองลง
