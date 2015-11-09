#version 150

uniform mat4 projection; 
uniform mat4 modelview;

in vec3 position;
in vec3 normal;

out Vertex 
{
	vec4 position;
	vec4 normal;
	vec4 color;
	
} vertex;

void main()
{
	vertex.position = vec4(position, 1.0);
	vertex.normal = vec4(normal, 0.0);
	vertex.color = vec4(1.0, 0.0, 0.0, 1.0);
}
