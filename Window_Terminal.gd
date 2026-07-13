extends Control

@onready var info_label = $Panel/Label_Info if has_node("Panel/Label_Info") else null

func _ready():
	update_cheat_sheet_info()

# ฟังก์ชันสำหรับดึงข้อมูลการตั้งค่าจากโมดูลต่าง ๆ มาแสดงเป็นคำใบ้
func update_cheat_sheet_info():
	if not info_label: return
	
	var desktop = get_tree().current_scene
	var text_display = "=== 📋 NETWORK INFO CHEAT SHEET ===\n\n"
	
	# 📶 กรณีที่ 1: กำลังเล่นด่าน Router (NAT)
	if desktop.has_node("Window_Router/Router_Module") and desktop.get_node("Window_Router/Router_Module").is_visible_in_tree():
		var router_mod = desktop.get_node("Window_Router/Router_Module")
		if "target_acl" in router_mod:
			text_display += "📍 [ด่านตั้งค่า NAT ROUTER]\n"
			text_display += "▪️ แผนกที่อนุญาต: Internal Office Local Users\n"
			text_display += "▪️ หมายเลข Access List (ACL): " + str(router_mod.target_acl) + "\n"
			text_display += "▪️ Interface ขาออก (ISP Link): " + str(router_mod.target_interface) + "\n"
			text_display += "▪️ ไอพีภายนอก (Public IP): " + str(router_mod.public_ip) + "\n\n"
			text_display += "💡 คำสั่งแนะนำ:\n'ip nat inside source list " + str(router_mod.target_acl) + " interface " + str(router_mod.target_interface) + " overload'"
	
	# 🌟 กรณีที่ 2: กำลังเล่นด่าน VLAN (หากคุณมีตัวแปรด่าน VLAN ในโปรเจกต์)
	elif desktop.has_node("Window_VLAN/PDPA_Module") and desktop.get_node("Window_VLAN/PDPA_Module").is_visible_in_tree():
		var vlan_mod = desktop.get_node("Window_VLAN/PDPA_Module")
		text_display += "📍 [ด่านตั้งค่า SWITCH VLAN]\n"
		# ตรวจสอบว่าในด่าน VLAN มีตัวแปรเหล่านี้ไหม (ปรับให้ตรงกับชื่อตัวแปรในด่าน VLAN ของคุณได้เลยครับ)
		var dept = vlan_mod.target_department if "target_department" in vlan_mod else "IT / Finance"
		var vlan_id = vlan_mod.target_vlan if "target_vlan" in vlan_mod else "10"
		var port_id = vlan_mod.target_port if "target_port" in vlan_mod else "fa0/5"
		
		text_display += "▪️ แผนกที่ต้องจัดระบบ: " + str(dept) + "\n"
		text_display += "▪️ หมายเลข VLAN ID: " + str(vlan_id) + "\n"
		text_display += "▪️ พอร์ตเชื่อมต่อ (Interface Port): " + str(port_id) + "\n\n"
		text_display += "💡 คำสั่งแนะนำ:\n'switchport access vlan " + str(vlan_id) + "'"

	# 🛡️ กรณีด่านอื่น ๆ (Firewall หรือ Task Manager)
	else:
		text_display += "📍 [สถานะระบบปัจจุบัน]\n"
		text_display += "▪️ หัวข้อการเรียนรู้: " + String(Global.selected_topic).to_upper() + "\n"
		text_display += "▪️ ระบบพร้อมทำงาน ร่วมกับการตรวจสอบความปลอดภัยเครือข่าย\n\n"
		text_display += "💡 กรุณาเปิดหน้าต่างแอปพลิเคชันหลักของด่านนี้เพื่อดูรายละเอียดโจทย์เพิ่มเติม"

	info_label.text = text_display
