extends Control

var info_label: Label = null

func _ready():
	update_cheat_sheet_info()
	visibility_changed.connect(update_cheat_sheet_info)

func _process(_delta):
	if is_visible_in_tree():
		update_cheat_sheet_info()

func update_cheat_sheet_info():
	if not info_label:
		info_label = get_node_or_null("Label_Info") as Label
		
	if not info_label:
		return

	var text_display = "=== 📋 NETWORK INFO CHEAT SHEET ===\n\n"
	
	# --------------------------------------------------------------------------
	# 📶 1. ด่าน ROUTING (เปิดจาก SystemButton)
	# --------------------------------------------------------------------------
	if Global.selected_topic == "routing" or Global.selected_topic == "system":
		text_display += "📍 [รายชื่อแผนกและข้อมูล IP ในด่าน ROUTING]\n\n"
		text_display += "▪️ แผนก: Marketing\n"
		text_display += "  VLAN: 10 | Port: fa0/1 | IP: 192.168.1.99\n\n"
		
		text_display += "▪️ แผนก: Engineering\n"
		text_display += "  VLAN: 20 | Port: fa0/2 | IP: 192.168.2.99\n\n"
		
		text_display += "▪️ แผนก: Guest_WiFi\n"
		text_display += "  VLAN: 30 | Port: fa0/5 | IP: 192.168.3.77\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ใช้ข้อมูล Network Path เหล่านี้ในการเขียนคำสั่ง "

	# --------------------------------------------------------------------------
	# 🛡️ 2. ด่าน FIREWALL (เปิดจาก NetworkButton)
	# --------------------------------------------------------------------------
	elif Global.selected_topic == "firewall" or Global.selected_topic == "network":
		text_display += "📍 [รายชื่อแผนกและ IP ทั้งหมดในด่าน FIREWALL]\n\n"
		text_display += "▪️ แผนก: Accounting\n  IP Address: 192.168.1.50\n\n"
		text_display += "▪️ แผนก: HR\n  IP Address: 192.168.2.10\n\n"
		text_display += "▪️ แผนก: Marketing\n  IP Address: 192.168.3.99\n\n"
		text_display += "▪️ แผนก: R&D\n  IP Address: 192.168.4.25\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบหน้าจอแจ้งเตือนแอปหลักว่าแผนกใดถูกโจมตี "

	# --------------------------------------------------------------------------
	# 🌟 3. ด่าน CHANGE VLAN (เปิดจาก Button_Router_Topic)
	# --------------------------------------------------------------------------
	elif Global.selected_topic == "vlan" or Global.selected_topic == "router":
		text_display += "📍 [รายชื่อแผนกและ VLAN ID ในด่าน SWITCH VLAN]\n\n"
		text_display += "▪️ แผนก: Management  | VLAN ID: 10\n\n"
		text_display += "▪️ แผนก: Finance     | VLAN ID: 20\n\n"
		text_display += "▪️ แผนก: Engineering | VLAN ID: 30\n\n"
		text_display += "▪️ แผนก: Guest       | VLAN ID: 99\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบพอร์ตเชื่อมต่อจากด่านหลัก "

	# --------------------------------------------------------------------------
	# 🌐 4. ด่าน NAT (เปิดจาก Button_PDPA_Topic)
	# --------------------------------------------------------------------------
	elif Global.selected_topic == "nat" or Global.selected_topic == "pdpa":
		text_display += "📍 [โครงสร้าง IP สำหรับการแปลงที่อยู่ด่าน NAT]\n\n"
		text_display += "▪️  port: Gi0/1 | ACL: 1 | IP: 192.168.1.50 \n\n"
		text_display += "▪️  port: Gi0/2 | ACL: 5 | IP: 192.168.2.10 \n\n"
		text_display += "▪️  port: fa0/1 | ACL: 10 | IP: 192.168.3.99 \n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ใช้ข้อมูลชุดนี้ร่วมกับหมายเลข Access List "

	# 🔒 โหมดสำรอง
	else:
		text_display += "📍 [ฐานข้อมูลเครือข่ายของระบบ (กำลังตรวจจับด่าน)]\n\n"
		text_display += "▪️ Accounting : 192.168.1.50\n"
		text_display += "▪️ HR         : 192.168.2.10\n"
		text_display += "▪️ Marketing  : 192.168.3.99\n"
		text_display += "▪️ R&D        : 192.168.4.25\n\n"
		text_display += "ℹ️ (ระบบกำลังทำงานในโหมด: \"" + str(Global.selected_topic) + "\")"

	info_label.text = text_display
