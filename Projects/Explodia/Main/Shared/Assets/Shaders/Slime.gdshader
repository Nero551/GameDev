shader_type spatial;
render_mode unshaded;
//uniform vec3 color;
uniform float alpha;

void vertex() {
		// Called for every vertex the material is visible on.
	float wave = sin(TIME * 3.0 + VERTEX.y);
	VERTEX.xz += wave * 0.01;
	
	float squash = 1.0 + 0.05 * sin(TIME * 2.0);
	VERTEX.y *= squash;
}

void fragment() {
	// Called for every pixel the material is visible

	EMISSION = vec3(0,0.5,0.9) * 0.5;
	ALBEDO = vec3(0,0.5,0.9);
	ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
