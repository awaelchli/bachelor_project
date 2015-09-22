package assignment1;

import java.io.IOException;
import java.util.Iterator;

import glWrapper.GLHalfedgeStructure;
import meshes.HalfEdgeStructure;
import meshes.Vertex;
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
public class Exercise3_4 {

	public static void main(String[] args) throws IOException {
		// Load a wireframe mesh
		WireframeMesh m = ObjReader.read("./objs/oneNeighborhood.obj", true);
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
		
		Iterator<Vertex> it = hs.iteratorV();
		while(it.hasNext()){
			Vertex v = it.next();
			System.out.println(v.normal());
		}

		GLHalfedgeStructure object = new GLHalfedgeStructure(hs);
		object.configurePreferredShader("shaders/normal.vert", "shaders/normal.frag", "shaders/normal.geom");
		display.addToDisplay(object);

	}

}
