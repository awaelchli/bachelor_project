#version 150
// Default fragment shader

// Input variable, passed from vertex to fragment shader
// it is interpolated automatically on each fragment
in vec4 frag_color;

// The output variable, will be written to the display automatically
out vec4 out_color;

void main()
{		
	out_color = frag_color;		
}
