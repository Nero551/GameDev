shader_type spatial;
uniform float color_r : hint_range(0.0, 1.0, 0.05);
uniform float color_g : hint_range(0.0, 1.0, 0.05);
uniform float color_b : hint_range(0.0, 1.0, 0.05);
uniform float alpha;

void vertex() {
	//COLOR = vec4(color_r,color_g,color_b, 1.0);
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible
	ALBEDO.r = color_r + UV.x;
	ALBEDO.g = color_g + UV.x;
	ALBEDO.b = color_b + UV.x;
	ALPHA = alpha;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
