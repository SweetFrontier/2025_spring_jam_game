shader_type canvas_item;

uniform sampler2D texture : repeat_enable;
uniform int num_directions = 0;
uniform vec3[10] directions;
uniform vec4 transparency = vec4(1.0, 1.0, 1.0, 0.3);
uniform bool lightAsTransparency = false;
uniform float skewAmt = 0.0;

void fragment() {
	vec2 skewed = vec2(skewAmt * UV.y + skewAmt * -0.5, 0.0);
	vec4 myColor = vec4(1);
	
	float numdirecreciprocal = 1.0/float(num_directions);
	
	for (int i=0;i<num_directions;i++)
		myColor *= numdirecreciprocal+texture(texture, UV*directions[i].z+TIME*directions[i].xy + skewed);
	
	if (lightAsTransparency)
		COLOR.a = 0.5 + 0.5*(1.0-myColor.x);
	else
		COLOR = myColor;
}