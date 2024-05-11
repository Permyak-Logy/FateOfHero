shader_type canvas_item;
render_mode blend_mix;

uniform vec4 outline_color : source_color;
uniform vec4 modulate : source_color;
uniform float opacity = 1.;

void fragment(){
    float size_x = 1.0 / float(textureSize(TEXTURE, 0).x);
    float size_y = 1.0 / float(textureSize(TEXTURE, 0).y);
    vec4 sprite_color = texture(TEXTURE, UV);
    float alpha = -4.0 * sprite_color.a;
	sprite_color *= modulate;
    alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
    alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
    alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
    alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
	
    //For outlining corners
    //Change the -4.0 to -8.0 in alpa if adding these lines
    /*alpha += texture(TEXTURE, UV + vec2(size_x, size_y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size_x, size_y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size_x, -size_y)).a;
    alpha += texture(TEXTURE, UV + vec2(size_x, -size_y)).a;*/
	
	alpha = clamp(alpha, 0.0, 1.0);
	vec4 final_color = mix(sprite_color, outline_color, alpha);
	float final_alpha = alpha > 0. ? outline_color.a : sprite_color.a;
	COLOR = vec4(final_color.rgb, final_alpha * opacity);
}