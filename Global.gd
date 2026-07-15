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
