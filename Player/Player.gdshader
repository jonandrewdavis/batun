shader_type canvas_item;

uniform vec4 OLDCOLOR1 : source_color;

uniform vec4 NEWCOLOR1 : source_color;

void fragment() {
	// Place fragment code here.
	vec4 curr_color = texture(TEXTURE, UV);
	
	if (curr_color == OLDCOLOR1)
	{
		COLOR = NEWCOLOR1;
	} 
}
