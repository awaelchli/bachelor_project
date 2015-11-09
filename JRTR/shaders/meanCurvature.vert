#version 150

uniform mat4 projection; 
uniform mat4 modelview;

in vec4 position;
in float meanCurvature;

out float frag_meanCurvature;

void main()
{
	gl_Position = projection * modelview * position;
	
	float C = 1;
	frag_meanCurvature = log(1 + meanCurvature / C);
}
