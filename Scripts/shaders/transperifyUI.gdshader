shader_type canvas_item;

uniform float howTransparent : hint_range(0, 1) = 0.0f;
uniform float threshold : hint_range(0.0, 1.0, 0.05) = 0.0f;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = COLOR;
	if (COLOR.r <= threshold && COLOR.g <= threshold && COLOR.b <= threshold) COLOR.a *= howTransparent;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
