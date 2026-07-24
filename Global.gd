extends Node

# ==============================================================================
# 🎮 GLOBAL GAME STATE SINGLETON (AUTOLOAD)
# - สคริปต์นี้ทำหน้าที่เป็นตัวควบคุมสเตทส่วนกลาง (Centralized State Controller) 
# - ใช้สำหรับแชร์และส่งผ่านข้อมูลข้าม Scene Tree (Cross-Scene Data Persistence)
# ==============================================================================

# 🌐 Gameplay Mode Flag: ควบคุมโหมดการเล่น (False: แยกหัวข้อฝึกฝน, True: โหมดผสมผสาน)
var is_mix_mode: bool = false

# 📑 Selected Scenario Topic: เก็บค่าคีย์เวิร์ดด่านปัจจุบัน ("network", "task_manager", "router", "vlan")
var selected_topic: String = ""

# 🛡️ Completion Tracker: จำนวนโมดูลภารกิจที่ผู้เล่นเคลียร์ได้สำเร็จในรอบการเล่นนั้น ๆ
var completed_modules_count: int = 0

# ❌ Exception & Failure Logger: ใช้จัดเก็บสายอักขระ (String) แสดงสาเหตุความล้มเหลว
# เพื่อส่งต่อข้อมูลเชิงลึกไปเรนเดอร์บนหน้าจอระบบปฏิบัติการล่ม (Blue Screen Crash Dump)
var game_over_reason: String = ""

# ==============================================================================
# 📊 NEW: DASHBOARD & METRICS TRACKER (ระบบคะแนนและความก้าวหน้า)
# ==============================================================================
# 🏆 Total Score: คะแนนสะสมรวมทั้งหมด
var total_score: int = 0

# 🎯 Level Data Dataset: จัดเก็บสถิติรายด่านเพื่อนำไปเรนเดอร์ลง UI Dashboard
var level_data = {
	"VLAN": {
		"cleared": false,
		"score": 0,
		"stars": 0,
		"time_spent": 0
	},
	"NAT": {
		"cleared": false,
		"score": 0,
		"stars": 0,
		"time_spent": 0
	},
	"Routing": {
		"cleared": false,
		"score": 0,
		"stars": 0,
		"time_spent": 0
	},
	"Firewall": {
		"cleared": false,
		"score": 0,
		"stars": 0,
		"time_spent": 0
	}
}

# 🔄 Helper Function: สำหรับ Reset ค่าทั้งหมดเมื่อเริ่มเล่นเกมใหม่อีกรอบ
func reset_all_progress():
	completed_modules_count = 0
	total_score = 0
	game_over_reason = ""
	for key in level_data.keys():
		level_data[key]["cleared"] = false
		level_data[key]["score"] = 0
		level_data[key]["stars"] = 0
		level_data[key]["time_spent"] = 0
