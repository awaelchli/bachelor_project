#version 150
// Simple fragment shader which does some diffuse shading.
// For simplicity, this shader assumes  that the eye of the viewer always lies 
// in the direction (0,0,1)

// Input variable, passed from vertex to fragment shader
// and interpolated automatically to each fragment
in vec4 color_g;
flat in vec3 normal_g;

// Output variable, will be written to the display automatically
out vec4 out_color;

void main()
{		
	out_color = color_g * (abs(dot(normal_g, vec3(0,0,1)))+0.1) //diffuse shading plus ambient (0.1)
	* (1.5 + sign(dot(normal_g, vec3(0,0,1)))/2.5); //scaled to a fifth when looking at the back of the triangle
}
