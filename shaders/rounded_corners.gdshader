shader_type canvas_item;

uniform float corner_radius : hint_range(0.0, 0.5, 0.01) = 0.05;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	vec2 corner = min(UV, vec2(1.0) - UV);
	float distance_from_corner = min(corner.x, corner.y);

	float alpha_mask = smoothstep(
		0.0,
		corner_radius,
		distance_from_corner
	);

	COLOR = vec4(color.rgb, color.a * alpha_mask);
}