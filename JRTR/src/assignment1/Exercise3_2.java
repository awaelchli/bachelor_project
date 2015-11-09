package assignment1;

import java.io.IOException;

import glWrapper.GLHalfedgeStructure;
import meshes.HalfEdgeStructure;
import meshes.WireframeMesh;
import meshes.exception.DanglingTriangleException;
import meshes.exception.MeshNotOrientedException;
import meshes.reader.ObjReader;
import openGL.MyDisplay;

/**
 * 
 * @author Adrian Waelchli
 *
 */
public class Exercise3_2 {

	public static void main(String[] args) throws IOException {
		// Load a wireframe mesh
		WireframeMesh m = ObjReader.read("./objs/teapot.obj", true);
		HalfEdgeStructure hs = new HalfEdgeStructure();

		/*
		 * Create a half-edge structure out of the wireframe description. As not
		 * every mesh can be represented as a half-edge structure exceptions
		 * could occur.
		 */
		try {
			hs.init(m);
		} catch (MeshNotOrientedException | DanglingTriangleException e) {
			e.printStackTrace();
			return;
		}

		MyDisplay display = new MyDisplay();

		GLHalfedgeStructure object = new GLHalfedgeStructure(hs);
		object.configurePreferredShader("shaders/trimesh_flat.vert", "shaders/trimesh_flat.frag", null);
		display.addToDisplay(object);

		// Do the same but choose a different shader
		GLHalfedgeStructure object2 = new GLHalfedgeStructure(hs);
		object2.configurePreferredShader("shaders/valence.vert", "shaders/valence.frag", null);
		display.addToDisplay(object2);
	}

}
