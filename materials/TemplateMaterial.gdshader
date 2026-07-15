shader_type spatial; // Use standard as a base
render_mode unshaded;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D lightmap_atlas : source_color, filter_linear; // Your Lump 8 Atlas

void fragment() {
    vec4 albedo = texture(albedo_texture, UV);
    vec4 lightmap = texture(lightmap_atlas, UV2);
    
    // DEBUG: If lightmap is pure black, use 0.5 grey so we can still see the wall
    //vec3 lm_debug = max(lightmap.rgb, vec3(0.5)); 
    
    // Switch to this to see ONLY the lightmap shadows on the walls:
    
	//ALBEDO = vec3(UV2.x, UV2.y, 0.0);
	//ALBEDO = lightmap.rgb; 
    
    // The final Source-style composite
    ALBEDO = albedo.rgb * lightmap.rgb;
    
    // If the texture is still invisible, try:
    //ALBEDO = albedo.rgb; 
}