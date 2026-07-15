shader_type canvas_item;

uniform vec4 alert_color : source_color = vec4(1.0, 0.0, 0.0, 0.5); // สีแดงโปร่งแสงเริ่มต้น
uniform float frequency = 1.0; // ความถี่ในการกระพริบ
uniform float min_alpha = 0.0; // ความโปร่งแสงต่ำสุด
uniform float max_alpha = 0.4; // ความโปร่งแสงสูงสุด
uniform float border_size = 0.1; // ความหนาของขอบสี่เหลี่ยม (ค่าระหว่าง 0.0 - 0.5)

void fragment() {
    // คำนวณค่าคลื่น sin ให้กระพริบเป็นจังหวะ
    float time = TIME * frequency * 4.28318;
    float wave = (sin(time) + 1.0) * 0.5;
    
    // คำนวณระยะห่างจากขอบจอทั้ง 4 ด้าน (ขอบสี่เหลี่ยม)
    vec2 border = smoothstep(vec2(0.0), vec2(border_size), UV) * smoothstep(vec2(0.0), vec2(border_size), 1.0 - UV);
    
    // หาค่าความเข้มขอบสี่เหลี่ยม (1.0 คือตรงขอบจอสุด, 0.0 คือตรงกลางจอ)
    float vignette_box = 1.0 - (border.x * border.y);
    
    // ผสมสีแดงกับการกระพริบเข้ากับขอบสี่เหลี่ยม
    vec4 final_color = alert_color;
    final_color.a *= mix(min_alpha, max_alpha, wave * vignette_box);
    
    COLOR = final_color;
}