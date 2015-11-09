#version 150
// input from the vertex shader:  the positions, laid out as triangles
// output to the fragment shader: a triangle and its normal

//the projection matrix set by the main program
uniform mat4 projection; 


//In a geometry shader you have to specify how the input and output have to be interpreted
//note that the maximum number of vertices passed to the fragment shader has
//to be fixed.
layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

//the variable passed in from the vertex shader
//in geometry shaders the input is always organized as an array
in vec4 position_g[];

//the variables passed out to the fragment shader
flat out vec3 normal_g;
out vec4 color_g;

void main()
{		
	//compute the normal
	normal_g = normalize(cross(position_g[1].xyz - position_g[0].xyz,
					position_g[2].xyz - position_g[0].xyz));
	//use a constant color
	color_g = vec4(0.2f,0.2f,0.8f,1.f);
	
	for(int i=0; i<3; i++)
	{
		//special GL variables that always have to be passed to the fragment shader:
		//the final position
		gl_Position = projection * position_g[i];
		
		//and some ID which can be left untouched but has to be passed explicitely.
		gl_PrimitiveID = gl_PrimitiveIDIn;
		
		//each call to emit vertex will spawn a vertex with the
		//specified attributes, here the gl_Position, a normal_g and color_g.
		EmitVertex();
	}
	EndPrimitive();
	
	
	
}
