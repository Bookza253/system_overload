extends Control

# ดึงโหนดตามโครงสร้าง Node Tree ล่าสุด
@onready var label_title = $Panel/Label_Title
@onready var label_stars = $Panel/Label_Stars

@onready var label_header = $Panel/Panel_ScoreDetails/VBoxContainer/Label_Header if has_node("Panel/Panel_ScoreDetails/VBoxContainer/Label_Header") else $Panel/Panel_ScoreDetails/Label_Header
@onready var label_base = $Panel/Panel_ScoreDetails/VBoxContainer/Label_BaseScore if has_node("Panel/Panel_ScoreDetails/VBoxContainer/Label_BaseScore") else $Panel/Panel_ScoreDetails/Label_BaseScore
@onready var label_time = $Panel/Panel_ScoreDetails/VBoxContainer/Label_TimePenalty if has_node("Panel/Panel_ScoreDetails/VBoxContainer/Label_TimePenalty") else $Panel/Panel_ScoreDetails/Label_TimePenalty
@onready var label_error = $Panel/Panel_ScoreDetails/VBoxContainer/Label_ErrorPenalty if has_node("Panel/Panel_ScoreDetails/VBoxContainer/Label_ErrorPenalty") else $Panel/Panel_ScoreDetails/Label_ErrorPenalty
@onready var label_total = $Panel/Panel_ScoreDetails/VBoxContainer/Label_TotalScore if has_node("Panel/Panel_ScoreDetails/VBoxContainer/Label_TotalScore") else $Panel/Panel_ScoreDetails/Label_TotalScore

func _ready():
	hide()
	
	# 🔴 ใส่บรรทัดนี้เพื่อลองเทสหน้าตาตอนรัน F6 (เทสเสร็จค่อยลบออก):
	setup_data("VLAN", 950, 3, 20, 1)

# ฟังก์ชันรับค่าจากด่านต่างๆ มาแสดงผล
func setup_data(stage_name: String, total_score: int, stars: int, time_spent: int, errors: int):
	label_title.text = "MISSION ACCOMPLISHED! - [" + stage_name.to_upper() + " CLEAR]"
	
	match stars:
		1: label_stars.text = "⭐️ ☆ ☆   (1 / 3 STARS)"
		2: label_stars.text = "⭐️ ⭐️ ☆   (2 / 3 STARS)"
		3: label_stars.text = "⭐️ ⭐️ ⭐️   (3 / 3 STARS)"
	
	# อัปเดตข้อความตามที่อาจารย์สั่งคอมเมนต์
	if label_header:
		label_header.text = "📊 SCORE BREAKDOWN:"
	
	var time_penalty = time_spent * 2
	var error_penalty = errors * 50
	
	if label_base: label_base.text = "- BASE SCORE: 1,000 PTS"
	if label_time: label_time.text = "- TIME SPENT: " + str(time_spent) + " SEC (-" + str(time_penalty) + " PTS)"
	if label_error: label_error.text = "- COMMAND ERRORS: " + str(errors) + " TIMES (-" + str(error_penalty) + " PTS)"
	if label_total: label_total.text = "TOTAL STAGE SCORE: " + str(total_score) + " PTS"
	
	show()

# --- สัญญาณปุ่มกด 3 ปุ่ม ---
func _on_button_retry_pressed():
	hide()
	get_tree().reload_current_scene()

func _on_button_dashboard_pressed():
	hide()
	get_tree().change_scene_to_file("res://main_desktop.tscn")

func _on_button_next_pressed():
	hide()
