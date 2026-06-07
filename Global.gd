extends Node

# ตัวแปรกลางเอาไว้เช็กโหมด: false = แยกเล่น (Training), true = โหมดผสม (Mix)
var is_mix_mode = false

# ตัวแปรเก็บเรื่องที่เลือก: "network", "task_manager" หรือ "mix"
var selected_topic = ""

var mix_cpu_multiplier = 1.0  # 😈 ตัวคูณความเร็ว CPU (เริ่มต้นที่ 1 เท่าปกติ)
