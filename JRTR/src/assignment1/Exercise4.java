package assignment1;

import glWrapper.GLHalfedgeStructure;

import java.io.IOException;

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
public class Exercise4 {

	public static void main(String[] args) throws IOException {
		
		WireframeMesh m1 = ObjReader.read("./objs/teapot.obj", true);
		HalfEdgeStructure hs1 = new HalfEdgeStructure();

		try {
			hs1.init(m1);
		} catch (MeshNotOrientedException | DanglingTriangleException e) {
			e.printStackTrace();
			return;
		}
		
		WireframeMesh m2 = ObjReader.read("./objs/sphere.obj", true);
		HalfEdgeStructure hs2 = new HalfEdgeStructure();

		try {
			hs2.init(m2);
		} catch (MeshNotOrientedException | DanglingTriangleException e) {
			e.printStackTrace();
			return;
		}

		MyDisplay display = new MyDisplay();

		GLHalfedgeStructure object1 = new GLHalfedgeStructure(hs1);
		object1.configurePreferredShader("shaders/meanCurvature.vert", "shaders/meanCurvature.frag", null);
		display.addToDisplay(object1);
		
		GLHalfedgeStructure object2 = new GLHalfedgeStructure(hs2);
		object2.configurePreferredShader("shaders/meanCurvature.vert", "shaders/meanCurvature.frag", null);
		display.addToDisplay(object2);
	}

}
