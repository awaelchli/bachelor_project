#version 150

in float frag_meanCurvature;
out vec4 out_color;

void main()
{		
	out_color = vec4(frag_meanCurvature, 0, 0, 1);		
}
