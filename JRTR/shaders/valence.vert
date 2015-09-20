#version 150

uniform mat4 projection; 
uniform mat4 modelview;

in vec4 position;
in float valence;

out vec4 color_f;

void main()
{
	float max = 7;
	float r = valence;
	if(r > max){
		r = max;
	}
	color_f = vec4(r / max, 0, 0, 1);
	
	gl_Position = projection * modelview * position;
}
