shader_type canvas_item;

uniform bool flash = false;

void fragment() {
	if (flash) {
		vec4 tex = texture(TEXTURE, UV);
		COLOR = vec4(vec3(1.0), tex.a);
	}
}
