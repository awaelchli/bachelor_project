#version 150

uniform mat4 projection;
uniform mat4 modelview;

layout(triangles) in;
layout(line_strip, max_vertices = 6) out;

in Vertex 
{
	vec4 position;
	vec4 normal;
	vec4 color;
	
} vertex[];

out vec4 color_f;

void main()
{

	float normalLength = 0.5;
	
	for(int i = 0; i < 3; i++)
	{
		vec4 position = vertex[i].position;
		vec4 normal = vertex[i].normal;
		
		gl_PrimitiveID = gl_PrimitiveIDIn;
		
		gl_Position = projection * modelview * position;
		color_f = vertex[i].color;
		
		EmitVertex();
		
		
		gl_Position = projection * modelview * (position + normal * normalLength);
		color_f = vertex[i].color;
		EmitVertex();
		
		EndPrimitive();
	}
	
	
	
}
