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
public class Exercise3_3 {

	public static void main(String[] args) throws IOException {
		// Load a wireframe mesh
		WireframeMesh m = ObjReader.read("./objs/cat.obj", true);
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

		GLHalfedgeStructure valenceObj = new GLHalfedgeStructure(hs);
		valenceObj.configurePreferredShader("shaders/valence.vert", "shaders/valence.frag", null);
		display.addToDisplay(valenceObj);

		hs.averageSmoothing(4);

		GLHalfedgeStructure smoothObject = new GLHalfedgeStructure(hs);
		smoothObject.configurePreferredShader("shaders/valence.vert", "shaders/valence.frag", null);
		display.addToDisplay(smoothObject);

	}

}
