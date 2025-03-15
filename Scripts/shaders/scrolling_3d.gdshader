shader_type spatial;

uniform sampler2D texturey;
uniform vec2 direction = vec2(0.0, 0.06);
uniform vec2 direction2 = vec2(-0.01, -0.07);
uniform vec2 direction3 = vec2(0.03, -0.02);
uniform vec4 transparency = vec4(1.0, 1.0, 1.0, 0.3);
uniform float skewAmt = 0.0;

void fragment() {
	vec2 skewed = vec2(skewAmt * UV.y + skewAmt * -0.5, 0.0);
	ALBEDO = texture(texturey, UV+TIME*direction + skewed).rgb * texture(texturey, (UV*0.8)+TIME*direction2 + skewed).rgb * texture(texturey, (UV*0.3)+TIME*direction3 + skewed).rgb;
	ALPHA = ALBEDO.r * 0.4;
}