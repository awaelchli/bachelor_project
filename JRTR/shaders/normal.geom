#version 150

uniform mat4 projection;
uniform mat4 modelview;

layout(triangles) in;
layout(line_strip, max_vertices = 2) out;

in Vertex 
{
	vec4 position;
	vec4 normal;
	vec4 color;
	
} vertex[];

out vec4 color_f;

void main()
{
	
	for(int i = 0; i < 3; i++)
	{
		vec4 position = vertex[i].position;
		vec4 normal = vertex[i].normal;
		
		gl_PrimitiveID = gl_PrimitiveIDIn;
		
		gl_Position = projection * modelview * position;
		color_f = vertex[i].color;
		
		EmitVertex();
		
		gl_Position = projection * modelview * (position + normal);
		color_f = vertex[i].color;
		EmitVertex();
	}
	
	EndPrimitive();
	
}
