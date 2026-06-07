extends Control

func _ready():
	if Global.is_mix_mode:
		# 🔴 ถ้าเป็นโหมดผสม: บังคับเปิดให้เห็นไอคอน "ครบทั้ง 4 แอป"!
		$Button_TaskManager_Mod.show()
		$Button_Firewall.show()
		$Button_Router.show()
		$Button_PDPA.show()       # 🌟 เพิ่มบรรทัดนี้เปิดปุ่ม PDPA ในโหมดผสม
	else:
		# 🟢 ถ้าเลือกโหมดฝึกซ้อมแยกวิชา
		if Global.selected_topic == "network":
			$Button_Firewall.show()
			$Button_TaskManager_Mod.hide()
			$Button_Router.hide()
			$Button_PDPA.hide()    # ซ่อน PDPA
			
		elif Global.selected_topic == "task_manager":
			$Button_Firewall.hide()
			$Button_TaskManager_Mod.show()
			$Button_Router.hide()
			$Button_PDPA.hide()    # ซ่อน PDPA
			
		elif Global.selected_topic == "router":
			$Button_Firewall.hide()
			$Button_TaskManager_Mod.hide()
			$Button_Router.show()
			$Button_PDPA.hide()    # ซ่อน PDPA
			
		elif Global.selected_topic == "pdpa":
			# 🌟 โหมดซ้อมวิชากฎหมาย PDPA: เปิดเฉพาะปุ่ม PDPA เท่านั้น
			$Button_Firewall.hide()
			$Button_TaskManager_Mod.hide()
			$Button_Router.hide()
			$Button_PDPA.show()

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป Task Manager
func _on_button_pressed():
	$TaskManager_Module.show()

# 🖱️ ฟังก์ชันเมื่อคลิกปุ่มแอป Firewall
func _on_button_firewall_pressed():
	$Firewall_Module.show()


func _on_button_router_pressed():
	$Router_Module.show()  # 🌟 สั่งแสดงหน้าต่างแอปตั้งค่า Router ขึ้นมาบนหน้าจอ


func _on_button_pdpa_pressed():
	$PDPA_Module.show() # 🌟 สั่งเปิดหน้าต่างแอปกฎหมาย PDPA ขึ้นมาเล่น
