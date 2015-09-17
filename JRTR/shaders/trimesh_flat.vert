#version 150
// This shader expects position input laid out as triangles
// and diffusely shades the surface.
// 
// No further vertex attributes besides the position are needed,
// the per face normals needed for the shading are computed on the fly in the
// geometry shader.

// Uniform variables, set in main program
uniform mat4 projection; 
uniform mat4 modelview;

// Input vertex attributes; passed from main program to the shader 
// via glDisplayable.addElement(float[],Semantic.POSITION, 3).
in vec4 position;

//the positions passed to the geometry shader
out vec4 position_g;

void main()
{
	//the position coordinates are transformed into view coordinates but are
	//not yet projected
	position_g = modelview *position;
}
