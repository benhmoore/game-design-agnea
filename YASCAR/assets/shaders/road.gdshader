shader_type spatial;

uniform sampler2D road_texture;

void fragment() {
	vec2 road_uv = vec2(UV.y, UV.x);
	vec4 color = texture(road_texture, road_uv);
	ALBEDO = color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = 0.8;
}
