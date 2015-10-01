#version 150

in float frag_meanCurvature;
out vec4 out_color;

void main()
{		

	float r = max(1 - frag_meanCurvature, 0);
	float g = max(min(2 - frag_meanCurvature, frag_meanCurvature), 0);
	float b = max(min(1, frag_meanCurvature - 1), 0);
	out_color = vec4(r, g, b, 1);
	//out_color = vec4(frag_meanCurvature, 0, 0, 1);		
}
