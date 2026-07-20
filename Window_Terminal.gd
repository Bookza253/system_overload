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
	
	# ดึงค่าจาก Global มาเช็ก (แปลงเป็นตัวพิมพ์เล็กทั้งหมด)
	var current_topic = ""
	if "selected_topic" in Global and Global.selected_topic != null:
		current_topic = str(Global.selected_topic).to_lower()

	# --------------------------------------------------------------------------
	# 🖥️ 1. ด่าน TASK MANAGER (SYSTEM)
	# --------------------------------------------------------------------------
	if current_topic == "task_manager" or current_topic == "system":
		text_display += "📍 [ตารางเส้นทางเครือข่ายด่าน ROUTING]\n\n"
		text_display += "▪️ ปลายทาง: HQ_Server\n"
		text_display += "  Network: 192.168.55.0 | Mask: 255.255.255.0 | Next-Hop: 192.168.1.1\n\n"
		text_display += "▪️ ปลายทาง: Branch_Office\n"
		text_display += "  Network: 192.168.50.0 | Mask: 255.255.255.0 | Next-Hop: 192.168.2.55\n\n"
		text_display += "▪️ ปลายทาง: Cloud_Storage\n"
		text_display += "  Network: 192.168.71.0 | Mask: 255.255.255.0 | Next-Hop: 192.168.10.254\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบชื่อแผนกหจากด่านหลัก \n"
		text_display += "💡 ip route [Network] [Subnet_Mask] [Next_Hop] \n"
		text_display += "ℹ️ อย่าลืม Save ทุกครั้งหลังแก้ไขเสร็จ \n"


	# --------------------------------------------------------------------------
	# 🛡️ 2. ด่าน FIREWALL (NETWORK)
	# --------------------------------------------------------------------------
	elif current_topic == "network" or current_topic == "firewall":
		text_display += "📍 [รายชื่อแผนกและ IP ทั้งหมดในด่าน FIREWALL]\n\n"
		text_display += "▪️ แผนก: Accounting\n  IP Address: 192.168.1.50\n\n"
		text_display += "▪️ แผนก: HR\n  IP Address: 192.168.2.10\n\n"
		text_display += "▪️ แผนก: Marketing\n  IP Address: 192.168.3.99\n\n"
		text_display += "▪️ แผนก: R&D\n  IP Address: 192.168.4.25\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบหน้าจอแจ้งเตือนแอปหลักว่าแผนกใดถูกโจมตี \n"
		text_display += "💡 access-list 1 deny host [IP] \n"
		text_display += "ℹ️ อย่าลืม Save ทุกครั้งหลังแก้ไขเสร็จ \n"

	# --------------------------------------------------------------------------
	# 📶 3. ด่าน ROUTER
	# --------------------------------------------------------------------------
	elif current_topic == "router":
		text_display += "📍 [รายชื่อแผนกและ VLAN ID ในด่าน SWITCH VLAN]\n\n"
		text_display += "▪️ แผนก: Marketing\n"
		text_display += "  VLAN: 10 | Port: fa0/11 | IP: 192.168.1.99\n\n"
		text_display += "▪️ แผนก: Engineering\n"
		text_display += "  VLAN: 20 | Port: fa0/25 | IP: 192.168.2.99\n\n"
		text_display += "▪️ แผนก: Guest_WiFi\n"
		text_display += "  VLAN: 30 | Port: fa0/17 | IP: 192.168.3.77\n\n" 
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบพอร์ตเชื่อมต่อจากด่านหลัก \n"
		text_display += "💡 interface [ชื่อพอร์ต] \n"
		text_display += "💡 switchport access vlan [เลข vlan]\n"
		text_display += "💡 ping [ip] \n"
		text_display += "ℹ️ อย่าลืม Save ทุกครั้งหลังแก้ไขเสร็จ"

	# --------------------------------------------------------------------------
	# 🌐 4. ด่าน NAT (เชื่อมโยงจากค่า "vlan" หรือโมดูล "pdpa")
	# --------------------------------------------------------------------------
	elif current_topic == "vlan" or current_topic == "pdpa" or current_topic == "nat":
		text_display += "📍 [ข้อมูลการตั้งค่าโครงสร้างด่าน NAT]\n\n"
		text_display += "▪️ port: Gi0/1 | ACL: 1 | IP: 192.168.1.50\n\n"
		text_display += "▪️ port: Gi0/2 | ACL: 5 | IP: 192.168.2.10\n\n"
		text_display += "▪️ port: fa0/1 | ACL: 10 | IP: 192.168.3.99\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบพอร์ตเชื่อมต่อจากด่านหลัก \n"
		text_display += "💡 ip nat inside source list [acl] interface [ip] overload \n"
		text_display += "ℹ️ อย่าลืม Save ทุกครั้งหลังแก้ไขเสร็จ \n"

	# 🔒 โหมดสำรอง
	else:
		text_display += "📍 [ระบบกำลังค้นหาข้อมูลด่าน...]\n\n"
		text_display += "🔎 ตอนนี้ระบบอ่านค่าด่านได้เป็นคำว่า: \"" + str(Global.selected_topic) + "\"\n\n"
		text_display += "💡 ข้อมูลไม่ตรงกับเงื่อนไขด่านใดๆ กรุณาเช็กการส่งค่าอีกครั้ง"

	info_label.text = text_display
