extends Node

# ตัวแปรกลางเอาไว้เช็กโหมด: false = แยกเล่น (Training), true = โหมดผสม (Mix)
var is_mix_mode = true

# ตัวแปรเก็บเรื่องที่เลือก: "network", "task_manager" หรือ "mix"
var selected_topic = ""

var mix_cpu_multiplier = 1.0  # 😈 ตัวคูณความเร็ว CPU (เริ่มต้นที่ 1 เท่าปกติ)

var completed_modules_count : int = 0
var game_over_reason : String = "" # 🌟 เพิ่มตัวแปรนี้ไว้เก็บสาเหตุการแพ้จากแต่ละด่าน
