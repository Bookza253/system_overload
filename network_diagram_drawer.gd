extends Control

func _ready():
	queue_redraw()

func _draw():
	var topic = "VLAN"
	if "selected_topic" in Global and Global.selected_topic != "":
		topic = Global.selected_topic
		
	if topic == "VLAN":
		_draw_vlan_diagram()
	else:
		_draw_nat_diagram()

func _draw_vlan_diagram():
	var color_switch = Color("#00ffff")
	var color_vlan10 = Color("#ff5555")
	var color_vlan20 = Color("#55ff55")
	
	# 📐 หาจุดกึ่งกลางของกรอบสีส้มโดยอัตโนมัติ
	var area_center_x = size.x / 2
	
	# ปรับตำแหน่งพิกเซลการวาดให้อยู่ตรงกลางของกรอบพอดี
	var center_switch = Vector2(area_center_x, 60)
	var pc_a1 = Vector2(area_center_x - 90, 180)
	var pc_a2 = Vector2(area_center_x - 30, 180)
	var pc_b1 = Vector2(area_center_x + 30, 180)
	var pc_b2 = Vector2(area_center_x + 90, 180)
	
	# 1️⃣ วาดสายสัญญาณ
	draw_line(center_switch, pc_a1, color_vlan10, 3.0, true)
	draw_line(center_switch, pc_a2, color_vlan10, 3.0, true)
	draw_line(center_switch, pc_b1, color_vlan20, 3.0, true)
	draw_line(center_switch, pc_b2, color_vlan20, 3.0, true)
	
	# 2️⃣ วาดสัญลักษณ์อุปกรณ์
	draw_circle(center_switch, 20, color_switch)
	draw_circle(pc_a1, 10, color_vlan10)
	draw_circle(pc_a2, 10, color_vlan10)
	draw_circle(pc_b1, 10, color_vlan20)
	draw_circle(pc_b2, 10, color_vlan20)
	
	var default_font = get_theme_font("font")
	
	# 3️⃣ วาดข้อความกำกับตำแหน่ง
	draw_string(default_font, center_switch + Vector2(-35, -28), "MAIN SWITCH", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color.WHITE)
	draw_string(default_font, Vector2(area_center_x - 60, 210), "VLAN 10\n(Marketing)", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, color_vlan10)
	draw_string(default_font, Vector2(area_center_x + 60, 210), "VLAN 20\n(Engineering)", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, color_vlan20)
	
	# วาดเส้นประแสดงการแบ่งส่วนตรรกะ
	draw_line(Vector2(area_center_x, 100), Vector2(area_center_x, 220), Color("#ffffff", 0.2), 2.0, true)

func _draw_nat_diagram():
	var color_inside = Color("#55ff55")
	var color_router = Color("#00ffff")
	var color_outside = Color("#ffaa00")
	
	# 📐 หาจุดกึ่งกลางของกรอบสีส้มโดยอัตโนมัติสำหรับ NAT
	var area_center_x = size.x / 2
	var center_y = 130
	
	var pc_inside = Vector2(area_center_x - 90, center_y)
	var center_router = Vector2(area_center_x, center_y)
	var cloud_internet = Vector2(area_center_x + 90, center_y)
	
	draw_line(pc_inside, center_router, color_inside, 4.0)
	draw_line(center_router, cloud_internet, color_outside, 4.0)
	
	draw_circle(pc_inside, 14, color_inside)
	draw_circle(center_router, 20, color_router)
	draw_circle(cloud_internet, 16, color_outside)
	
	var default_font = get_theme_font("font")
	
	draw_string(default_font, pc_inside + Vector2(-40, -25), "Private IP\n(192.168.1.X)", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, color_inside)
	draw_string(default_font, center_router + Vector2(-45, -30), "[ NAT GATEWAY ]", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, color_router)
	draw_string(default_font, cloud_internet + Vector2(-40, -25), "Public IP\n(203.0.113.1)", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, color_outside)
