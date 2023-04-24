shader_type spatial;

uniform sampler2D ground_texture;
varying vec2 ground_uv;

void vertex(){
	ground_uv = (WORLD_MATRIX = vec4(VERTEX, 1.0).xz * vec2(0.1, 0.1)); //Fix WORLD_MATRIX, script written in Godot 3.1
}

void fragment() {
	vec4 color = texture(ground_texture, ground_uv);
	ALBEDO = color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 0.8;
}
