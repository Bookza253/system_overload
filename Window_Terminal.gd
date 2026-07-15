extends Control

# ==============================================================================
# 🚨 1. NODE REFERENCES & STATE VARIABLES
# - info_label: อ้างอิงโหนด Label สำหรับเรนเดอร์ข้อความคู่มือ (Cheat Sheet)
# ==============================================================================
var info_label: Label = null

# ==============================================================================
# ⚙️ 2. LIFE CYCLE & SIGNAL BINDING
# - _ready: ทำงานครั้งแรกเมื่อโหลดซีน และดักจับ Event การเปลี่ยนสถานะการมองเห็น
# - _process: อัปเดตข้อมูลแบบ Real-time เมื่อหน้าต่างถูกเปิดใช้งาน (UI Polling)
# ==============================================================================
func _ready():
	update_cheat_sheet_info()
	visibility_changed.connect(update_cheat_sheet_info)

func _process(_delta):
	# Optimization: สั่งอัปเดตข้อมูลเฉพาะตอนที่หน้าต่างนี้ถูกแสดงผลอยู่เท่านั้นเพื่อประหยัด CPU
	if is_visible_in_tree():
		update_cheat_sheet_info()

# ==============================================================================
# 🧠 3. CONTEXT-AWARE DATA RENDERING (Dynamic Topic Detection)
# - ดึง State จาก Global Singleton เพื่อตรวจสอบโหมดปัจจุบันที่ผู้เล่นกำลังรันอยู่
# - สลับชุดข้อมูลคู่มือ (Data Mapping) ให้ตรงกับมินิเกมโดยอัตโนมัติ
# ==============================================================================
func update_cheat_sheet_info():
	# Lazy Initialization: ดึงโหนดเป้าหมายเฉพาะเมื่อยังไม่เคยดึง (Memory Optimization)
	if not info_label:
		info_label = get_node_or_null("Label_Info") as Label
		
	if not info_label:
		return

	var text_display = "=== 📋 NETWORK INFO CHEAT SHEET ===\n\n"
	
	# State Extraction: ดึงค่า Topic จาก Global และ Normalization ให้อยู่ในรูปตัวพิมพ์เล็กทั้งหมด
	var current_topic = ""
	if "selected_topic" in Global and Global.selected_topic != null:
		current_topic = str(Global.selected_topic).to_lower()

	# --------------------------------------------------------------------------
	# 🌐 1. NAT OVERLOAD MODULE (โหมด Task Manager / System)
	# --------------------------------------------------------------------------
	if current_topic == "task_manager" or current_topic == "system":
		text_display += "📍 [ข้อมูลการตั้งค่าโครงสร้างด่าน NAT OVERLOAD]\n\n"
		text_display += "▪️ Port: Gi0/1 | ACL: 1 | IP: 192.168.1.50\n\n"
		text_display += "▪️ Port: Gi0/2 | ACL: 5 | IP: 192.168.2.10\n\n"
		text_display += "▪️ Port: fa0/1 | ACL: 10 | IP: 192.168.3.99\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบพอร์ตเชื่อมต่อจากหน้าจอแจ้งเตือนหลัก\n"
		text_display += "ℹ️ อย่าลืมพิมพ์ save ทุกครั้งหลังตั้งค่าสำเร็จ"

	# --------------------------------------------------------------------------
	# 🛡️ 2. FIREWALL ACCESS-LIST MODULE (โหมด Network / Firewall)
	# --------------------------------------------------------------------------
	elif current_topic == "network" or current_topic == "firewall":
		text_display += "📍 [รายชื่อแผนกและ IP เป้าหมายในด่าน FIREWALL]\n\n"
		text_display += "▪️ แผนก: Accounting\n  IP Address: 192.168.1.50\n\n"
		text_display += "▪️ แผนก: HR\n  IP Address: 192.168.2.10\n\n"
		text_display += "▪️ แผนก: Marketing\n  IP Address: 192.168.3.99\n\n"
		text_display += "▪️ แผนก: R&D\n  IP Address: 192.168.4.25\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบหน้าจอแจ้งเตือนแอปหลักว่าแผนกใดถูกโจมตี\n"
		text_display += "ℹ️ อย่าลืมพิมพ์ save ทุกครั้งหลังตั้งค่าสำเร็จ"

	# --------------------------------------------------------------------------
	# 📶 3. STATIC ROUTE MODULE (โหมด Router)
	# --------------------------------------------------------------------------
	elif current_topic == "router":
		text_display += "📍 [ตารางเส้นทางเครือข่ายด่าน STATIC ROUTE]\n\n"
		text_display += "▪️ ปลายทาง: HQ_Server\n"
		text_display += "  Network: 192.168.55.0 | Mask: 255.255.255.0 | Next-Hop: 192.168.1.1\n\n"
		text_display += "▪️ ปลายทาง: Branch_Office\n"
		text_display += "  Network: 192.168.50.0 | Mask: 255.255.255.0 | Next-Hop: 192.168.2.55\n\n"
		text_display += "▪️ ปลายทาง: Cloud_Storage\n"
		text_display += "  Network: 192.168.71.0 | Mask: 255.255.255.0 | Next-Hop: 192.168.10.254\n\n"
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบชื่อปลายทางเครือข่ายที่ล่มจากหน้าจอหลัก\n"
		text_display += "ℹ️ อย่าลืมพิมพ์ save ทุกครั้งหลังตั้งค่าสำเร็จ"

	# --------------------------------------------------------------------------
	# 🌟 4. VLAN SEGMENTATION MODULE (โหมด VLAN / PDPA)
	# --------------------------------------------------------------------------
	elif current_topic == "vlan" or current_topic == "pdpa":
		text_display += "📍 [ข้อมูลพอร์ตและหมายเลข VLAN ในด่าน SWITCH]\n\n"
		text_display += "▪️ แผนก: Marketing\n"
		text_display += "  VLAN: 10 | Port: fa0/11 | IP: 192.168.1.99\n\n"
		text_display += "▪️ แผนก: Engineering\n"
		text_display += "  VLAN: 20 | Port: fa0/25 | IP: 192.168.2.99\n\n"
		text_display += "▪️ แผนก: Guest_WiFi\n"
		text_display += "  VLAN: 30 | Port: fa0/17 | IP: 192.168.3.77\n\n" 
		text_display += "━━━━━━━━━━━━━━━━━━━━━━━━\n"
		text_display += "💡 ตรวจสอบชื่อแผนกที่มีปัญหา VLAN Mismatch จากหน้าจอหลัก\n"
		text_display += "ℹ️ อย่าลืมพิมพ์ save ทุกครั้งหลังทดสอบ Ping สำเร็จ"

	# --------------------------------------------------------------------------
	# 🔒 5. FALLBACK / ERROR STATE (โหมดสำรองกันข้อผิดพลาด)
	# --------------------------------------------------------------------------
	else:
		text_display += "📍 [System Error: ไม่พบการเชื่อมโยงข้อมูล Data Mapping]\n\n"
		text_display += "🔎 ค่าสถานะ Global.selected_topic ล่าสุด: \"" + str(current_topic) + "\"\n\n"
		text_display += "💡 ข้อมูลไม่ตรงกับเงื่อนไข Configuration ใด ๆ กรุณาตรวจสอบการตั้งค่า Scene Transition"

	# UI Update Render
	info_label.text = text_display
