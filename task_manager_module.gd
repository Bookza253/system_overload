extends Control

@onready var cpu_bar = $Panel/ProgressBar

var is_game_over = false  
var viruses_left = 5  

func _ready():
	cpu_bar.value = 15 # สตาร์ทโหลดพื้นฐานของเซิร์ฟเวอร์ไว้ก่อน
	# 🌟 เอา shuffle_buttons() ออกเพื่อให้แถวของระบบนิ่งเป็นระเบียบเหมือนหน้าจอเซิร์ฟเวอร์จริง

func _process(delta):
	if is_game_over == false:
		
		if viruses_left == 0:
			print("✅ [INCIDENT RESPONSE]: ภัยคุกคามเน็ตเวิร์กถูกระงับสำเร็จ!")
			Global.completed_modules_count += 1
			self.hide()
			return      
		
		# 📈 หลอดความร้อน/อัตราภาระงานระบบจะพุ่งขึ้นตามเวลาและตัวคูณความเสียหายหลังบ้าน
		cpu_bar.value += 12 * delta * Global.mix_cpu_multiplier
		
		# ระบบแจ้งเตือนระดับวิกฤต (หลอดสีขาวเปลี่ยนเป็นแดง)
		if cpu_bar.value >= 70:
			cpu_bar.modulate = Color(1, 0, 0) 
		else:
			cpu_bar.modulate = Color(1, 1, 1)
		
		if cpu_bar.value >= 100:
			trigger_game_over("หลอดการทำงานของ CPU ทะลุ 100% (Server Overheated) เนื่องจากกระบวนการโจมตีไม่ถูกยุติในเวลาที่กำหนด!")

# 🌟 ฟังก์ชันส่งสัญญาณเมื่อระบบล่ม
func trigger_game_over(reason_text):
	is_game_over = true
	print("SERVER COLLAPSED!")
	Global.game_over_reason = "❌ SYSTEM CORE OVERHEAT\n" + reason_text
	get_tree().change_scene_to_file("res://blue_screen_scene.tscn")

# =========================================================
# 💀 SECTION: COMMAND CENTER - TERMINATE PROCESS ACTIONS
# =========================================================

# 🟢 ยุติการทำงาน Backdoor Listener
func _on_button_1_pressed():
	if is_game_over: return
	cpu_bar.value -= 20
	viruses_left -= 1   
	$Panel/VBoxContainer/Button1.disabled = true # เปลี่ยนจากลบปุ่มเป็นการ "ปิดการทำงาน" เพื่อให้แถวอยู่ครบไม่กระตุก
	$Panel/VBoxContainer/Button1.text = "[ TERMINATED ]"

# 🟢 ยุติการทำงาน Ping Flood Attack
func _on_button_2_pressed():
	if is_game_over: return
	cpu_bar.value -= 20
	viruses_left -= 1  
	$Panel/VBoxContainer/Button2.disabled = true
	$Panel/VBoxContainer/Button2.text = "[ TERMINATED ]"

# 🟢 ยุติการทำงาน Ransomware Spreading
func _on_button_5_pressed():
	if is_game_over: return
	cpu_bar.value -= 20
	viruses_left -= 1   
	$Panel/VBoxContainer/Button5.disabled = true
	$Panel/VBoxContainer/Button5.text = "[ TERMINATED ]"

# 🟢 ยุติการทำงาน Cryptominer Network
func _on_button_6_pressed():
	if is_game_over: return
	cpu_bar.value -= 20
	viruses_left -= 1   
	$Panel/VBoxContainer/Button6.disabled = true
	$Panel/VBoxContainer/Button6.text = "[ TERMINATED ]"

# 🟢 ยุติการทำงาน Sniffing Tool
func _on_button_7_pressed():
	if is_game_over: return
	cpu_bar.value -= 20
	viruses_left -= 1   
	$Panel/VBoxContainer/Button7.disabled = true
	$Panel/VBoxContainer/Button7.text = "[ TERMINATED ]"

# =========================================================
# ⚠️ SECTION: CRITICAL SYSTEM FILES (กับดักวิกฤต)
# =========================================================

# ❌ เผลอไปกดตัดสัญญาณเร้าเตอร์แกนหลัก (core_router_gateway.sys)
func _on_button_3_pressed():
	print("FATAL: เผลอปิดเกตเวย์เร้าเตอร์หลัก!")
	trigger_game_over("CRITICAL ERROR: คุณเผลอสั่งยุติบริการ 'core_router_gateway.sys' (Default Gateway) ส่งผลให้เส้นทางเน็ตเวิร์กขาดจากกันทันที!") 

# ❌ เผลอไปสั่งปิดบริการ DHCP (dhcp_server_daemon.pid)
func _on_button_4_pressed() -> void:
	if is_game_over: return
	print("FATAL: บริการจ่ายไอพีแอดเดรสหยุดทำงาน!")
	trigger_game_over("DHCP FAILURE: คุณเผลอสั่งยุติบริการ 'dhcp_server_daemon.pid' เครื่องคอมพิวเตอร์ในเครือข่ายสูญเสียหมายเลข IP ทั้งระบบ!")
