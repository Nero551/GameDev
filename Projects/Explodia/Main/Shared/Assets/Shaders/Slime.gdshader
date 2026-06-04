shader_type spatial;
uniform vec3 color;
uniform float alpha;

void vertex() {
		// Called for every vertex the material is visible on.
    VERTEX.xz += sin(TIME + VERTEX.y) * 0.01;
}

void fragment() {
	// Called for every pixel the material is visible
	ALBEDO = color;
	ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
