extends Control

# ==============================================================================
# 🚨 1. ONREADY VARIABLES (ตรวจสอบชื่อ Node ใน Scene Tree ให้สะกดตรงกัน)
# ==============================================================================
@onready var label_terminal = $Panel/Label_Terminal if has_node("Panel/Label_Terminal") else null
@onready var button_ping = $Panel/Button_Ping if has_node("Panel/Button_Ping") else null
@onready var button_ok = $Panel/Button_OK if has_node("Panel/Button_OK") else null

# กลุ่มปุ่มสายไฟฝั่งซ้าย (คลิกเลือก)
@onready var left_nodes = {
	"red": $Panel/WireGame/Left_Red if has_node("Panel/WireGame/Left_Red") else null,
	"blue": $Panel/WireGame/Left_Blue if has_node("Panel/WireGame/Left_Blue") else null,
	"yellow": $Panel/WireGame/Left_Yellow if has_node("Panel/WireGame/Left_Yellow") else null,
	"green": $Panel/WireGame/Left_Green if has_node("Panel/WireGame/Left_Green") else null,
	"orange": $Panel/WireGame/Left_Orange if has_node("Panel/WireGame/Left_Orange") else null
}

# กลุ่มปุ่มสายไฟฝั่งขวา (เป้าหมายที่จะถูกสุ่มตำแหน่ง)
@onready var right_nodes = {
	"red": $Panel/WireGame/Right_Red if has_node("Panel/WireGame/Right_Red") else null,
	"blue": $Panel/WireGame/Right_Blue if has_node("Panel/WireGame/Right_Blue") else null,
	"yellow": $Panel/WireGame/Right_Yellow if has_node("Panel/WireGame/Right_Yellow") else null,
	"green": $Panel/WireGame/Right_Green if has_node("Panel/WireGame/Right_Green") else null,
	"orange": $Panel/WireGame/Right_Orange if has_node("Panel/WireGame/Right_Orange") else null
}

# มินิเกมตัวครอบสายไฟ และหน้าจอเคลียร์ด่าน
@onready var wire_game = $Panel/WireGame if has_node("Panel/WireGame") else null
@onready var color_rect = $ColorRect if has_node("ColorRect") else null
@onready var error_text = $ColorRect/ErrorText if has_node("ColorRect/ErrorText") else null
@onready var restart_button = $ColorRect/RestartButton if has_node("ColorRect/RestartButton") else null

# ==============================================================================
# ⚙️ 2. GAME VARIABLES (ตัวแปรควบคุมระบบ)
# ==============================================================================
var active_color = ""        # สีของสายไฟที่กำลังคลิกเลือกค้างไว้รอต่อ
var connected_wires = {}     # บันทึกสายไฟที่ต่อสำเร็จแล้ว เช่น {"red": true, "blue": true}
var is_fixed = false         # สถานะด่านว่าซ่อมเสร็จสิ้นหรือยัง

# ตารางรหัสสี RGB สำเนาไว้ใช้วาดเส้นสายไฟให้ตรงกับปุ่ม
var color_map = {
	"red": Color(1, 0.2, 0.2),
	"blue": Color(0.2, 0.5, 1),
	"yellow": Color(1, 0.9, 0.2),
	"green": Color(0.2, 0.8, 0.3),
	"orange": Color(1, 0.5, 0.1)
}

# ==============================================================================
# 🎮 3. MAIN FUNCTIONS (ฟังก์ชันหลักของระบบ)
# ==============================================================================
func _ready():
	is_fixed = false
	connected_wires.clear()
	active_color = ""
	
	if color_rect: color_rect.hide()
	if button_ok: button_ok.hide()
	if wire_game: wire_game.hide()
	
	# แจ้งเตือนเน็ตเวิร์กหลุดตอนเริ่มเกม
	if label_terminal:
		label_terminal.text = "C:\\> ping 8.8.8.8\n\n🎯 STATUS: Pinging...\n❌ Request timed out.\n❌ Request timed out.\n\n⚠️ บอร์ดระบบแจ้งเตือน: สายแลนภายในขาดชำรุด!\n(กรุณากดปุ่ม ⚡ REPAIR NETWORK เพื่อเข้าสู่ระบบต่อสายไฟ)"
	if button_ping: 
		button_ping.show()
		button_ping.text = "⚡ REPAIR NETWORK"

	# ผูกสัญญาณปุ่มแบบอัตโนมัติ
	_setup_wire_signals()

# ⚡ เมื่อกดปุ่ม Repair
func _on_button_ping_pressed():
	if button_ping: button_ping.hide()
	if label_terminal: label_terminal.text = "" 
	
	# 🎲 สุ่มสลับตำแหน่ง Y ของปุ่มขวาทันที
	_shuffle_right_nodes_position()
	
	if wire_game:
		wire_game.show()

# 🔀 ระบบสุ่มสลับตำแหน่งแนวตั้ง (แกน Y) ของขั้วสายไฟฝั่งขวา
func _shuffle_right_nodes_position():
	var y_positions = []
	
	# เก็บค่าพิกัด Y ดั้งเดิมทั้งหมดไว้ใน Array
	for color in right_nodes:
		var node = right_nodes[color]
		if node:
			y_positions.append(node.position.y)
	
	# ทำการสุ่มเขย่าลำดับใน Array มั่วๆ
	randomize()
	y_positions.shuffle()
	
	# จ่ายค่าพิกัด Y คืนให้ปุ่มแต่ละตัวเพื่อสลับที่กัน
	var index = 0
	for color in right_nodes:
		var node = right_nodes[color]
		if node and index < y_positions.size():
			node.position.y = y_positions[index]
			index += 1
	print("🎲 สุ่มตำแหน่งปุ่มฝั่งขวาเรียบร้อย!")

# 🛠️ ระบบจัดการ Mouse Filter และผูกสัญญาณปุ่ม
func _setup_wire_signals():
	if label_terminal: label_terminal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if wire_game: wire_game.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# ปุ่มฝั่งซ้าย: คลิกเลือกสี
	for color in left_nodes:
		var node = left_nodes[color]
		if node:
			node.mouse_filter = Control.MOUSE_FILTER_STOP
			node.connect("pressed", func(): _on_left_wire_pressed(color))
			
	# ปุ่มฝั่งขวา: คลิกวางสี
	for color in right_nodes:
		var node = right_nodes[color]
		if node:
			node.mouse_filter = Control.MOUSE_FILTER_STOP
			node.connect("pressed", func(): _on_right_wire_pressed(color))

# ==============================================================================
# 🖱️ 4. WIRE GAME LOGIC (ระบบเชื่อมต่อสายไฟแบบคลิกจับคู่)
# ==============================================================================
func _on_left_wire_pressed(color):
	if connected_wires.has(color): return # เชื่อมสำเร็จแล้วห้ามแก้ซ้ำ
	active_color = color
	print("🖱️ เลือกสายฝั่งซ้ายสี: " + color)

func _on_right_wire_pressed(color):
	if active_color == "": return
	
	# เช็กว่าปุ่มขวาที่กด สีตรงกับซ้ายที่เลือกไว้ไหม
	if color == active_color:
		connected_wires[active_color] = true
		print("🟢 จับคู่สี " + active_color + " สำเร็จ!")
		active_color = "" # ล้างค่ารอเลือกคู่ถัดไป
		queue_redraw()     # สั่งวาดเส้นใหม่ค้างไว้
		_check_game_victory()
	else:
		print("❌ สีไม่ตรงกัน! กรุณาเลือกปุ่มฝั่งซ้ายใหม่อีกครั้ง")
		active_color = ""
		queue_redraw()

func _process(_delta):
	if active_color != "":
		queue_redraw() # อัปเดตเส้นลากตามเมาส์ตลอดเวลาเมื่อมีการเลือกสาย

# 🎨 ฟังก์ชันวาดเส้นสายไฟลงบน Canvas ของตัวเกม
func _draw():
	if not wire_game or not wire_game.visible: return
	
	# 1. วาดเส้นที่จับคู่สำเร็จแล้วให้ค้างอยู่บนหน้าจอ
	for color in connected_wires:
		var left_btn = left_nodes[color]
		var right_btn = right_nodes[color]
		if left_btn and right_btn:
			var start_pos = left_btn.global_position + (left_btn.size / 2) - global_position
			var end_pos = right_btn.global_position + (right_btn.size / 2) - global_position
			draw_line(start_pos, end_pos, color_map[color], 10.0, true)
		
	# 2. วาดเส้นที่กำลังงอกตามเมาส์จากปุ่มฝั่งซ้าย
	if active_color != "":
		var left_btn = left_nodes[active_color]
		if left_btn:
			var start_pos = left_btn.global_position + (left_btn.size / 2) - global_position
			var end_pos = get_local_mouse_position()
			draw_line(start_pos, end_pos, color_map[active_color], 10.0, true)

# ==============================================================================
# 🏆 5. END GAME FLOW (ระบบประมวลผลผ่านด่านและสลับฉาก)
# ==============================================================================
func _check_game_victory():
	# ตรวจว่าต่อครบทั้ง 5 เส้นแล้วหรือยัง
	if connected_wires.size() >= 5 and not is_fixed: 
		is_fixed = true
		if wire_game: wire_game.hide()
		
		if label_terminal:
			label_terminal.text = "C:\\> ping 8.8.8.8\n\n🔧 [SYSTEM]: สายไฟเชื่อมต่อสนิทครบ 5 เส้น... กำลังส่งคำสั่งพิงค์ทดสอบสัญญาณ...\n⏳ Please wait..."
		
		# ดึงเวลารอโหลดระบบ 3 วินาที
		await get_tree().create_timer(3.0).timeout
		
		if label_terminal:
			label_terminal.text = "C:\\> ping 8.8.8.8\n\n🟢 SUCCESS: Connected!\nReply from 8.8.8.8: bytes=32 time=10ms TTL=115\n\n✅ กระแสไฟเดินเต็มระบบ เน็ตเวิร์กออนไลน์เสถียร 100%!"
		
		if button_ok: button_ok.show()

# เมื่อกดปุ่ม OK (หน้าจอผ่านด่านเขียวสะใจ ➡️ กลับหน้าเลือกโหมด)
func _on_button_ok_pressed():
	if has_node("Panel"): $Panel.hide()
	
	# แสดงหน้าจอเขียวผ่านด่านสำเร็จ
	if color_rect:
		color_rect.show()
		color_rect.color = Color(0.1, 0.6, 0.2, 0.9)
	if error_text:
		error_text.text = "🎉 MISSION PASSED! 🎉\n\nคุณเชื่อมต่อสายไฟทั้ง 5 สีและซ่อมเน็ตเวิร์กสำเร็จ!\nระบบกำลังพากลับสู่หน้าเลือกโหมด..."
	if restart_button: restart_button.hide()
	
	# ดีใจ 3 วินาทีแล้วย้ายฉากกลับ
	await get_tree().create_timer(3.0).timeout
	print("🚀 ย้ายฉากกลับสู่หน้าเลือกโหมด")
	get_tree().change_scene_to_file("res://mode_selection.tscn")
