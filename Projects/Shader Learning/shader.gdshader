shader_type canvas_item;
//uniform sampler2D tex;

void vertex() { 
	//VERTEX.xy += sin(VERTEX.x + TIME) * 10.0;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 finalCol = vec3(0);

	for (float i = 1.0; i <= 3.0; i++)
	{
		float dist = length(UV * i -1.0) * exp(length(UV));
		dist = sin(dist * 4.0 - TIME) / 4.0;
		dist = abs(dist);
		dist = pow(dist, i);
		dist = 0.005/dist;
		
		vec3 col = vec3(i/5.0,0.5,1.0);
		col *= dist;
		col = fract(col);
		finalCol += col;
	}	
	COLOR = vec4(finalCol,1.0);
	
	//vec4 col = vec4(UV.x,UV.y,0,1.0);
	//float avg = (col.r + col.g + col.b) / 3.0;
	//COLOR = vec4(col.rg,0,1.0);
	//vec4 c1 = vec4(0.5,1.0,0.3,1);
	//vec4 c2 = vec4(0.1,0.2,0.75,0.9);
	//vec4 c = mix(c1,c2,fract(UV.x * 10.0));
	//c = mix(c, c2, fract(UV.y * 10.0));
	//float num = COLOR.b * UV.x;
	//COLOR = vec4(c.rg, num,num);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
