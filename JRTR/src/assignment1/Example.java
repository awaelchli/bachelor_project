package assignment1;

import glWrapper.GLWireframeMesh;

import java.io.IOException;

import openGL.MyDisplay;

import meshes.WireframeMesh;
import meshes.reader.ObjReader;

public class Example {
	
	
	public static void main(String[] args) throws IOException{
		//load a mesh
		WireframeMesh bunny = ObjReader.read("./objs/bunny5k.obj", true);
		
		
		//..and display it.
		MyDisplay disp = new MyDisplay();
		//create wrapper which lays out the bunny data in a opengl conform
		//manner 
		GLWireframeMesh glbunny = new GLWireframeMesh(bunny);
		//choose the shader for the data
		glbunny.configurePreferredShader("shaders/default.vert", 
				"shaders/default.frag", 
				null);
		//add the data to the display
		disp.addToDisplay(glbunny);
		
		//do the same but choose a different shader
		GLWireframeMesh glbunny2 = new GLWireframeMesh(bunny);
		glbunny2.configurePreferredShader("shaders/trimesh_flat.vert", 
				"shaders/trimesh_flat.frag", 
				"shaders/trimesh_flat.geom");
		disp.addToDisplay(glbunny2);
	}

}
