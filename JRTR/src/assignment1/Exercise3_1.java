package assignment1;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import meshes.Face;
import meshes.HalfEdge;
import meshes.HalfEdgeStructure;
import meshes.Vertex;
import meshes.WireframeMesh;
import meshes.exception.DanglingTriangleException;
import meshes.exception.MeshNotOrientedException;
import meshes.reader.ObjReader;

/**
 * 
 * @author Adrian Waelchli
 *
 */
public class Exercise3_1 {

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

		/*
		 * Display adjacent vertices, half-edges and faces of selected vertex
		 */
		ArrayList<Vertex> vertices = hs.getVertices();
		Vertex vertex = vertices.get(4);

		Iterator<Vertex> vertexIterator = vertex.iteratorVV();
		System.out.printf("Adjacent vertices of vertex %s: ", vertex);
		while (vertexIterator.hasNext()) {
			Vertex v = vertexIterator.next();
			System.out.printf("%s ", v);
		}
		System.out.println();

		Iterator<HalfEdge> edgeIterator = vertex.iteratorVE();
		System.out.printf("Adjacent half-edges of vertex %s:\n", vertex);
		while (edgeIterator.hasNext()) {
			HalfEdge halfedge = edgeIterator.next();
			System.out.printf("%s\n", halfedge);
		}

		Iterator<Face> faceIterator = vertex.iteratorVF();
		System.out.printf("Adjacent faces of vertex %s:\n", vertex);
		while (faceIterator.hasNext()) {
			Face face = faceIterator.next();
			System.out.printf("%s\n", face);
		}

		/*
		 * Display adjacent half-edges of selected face
		 */
		ArrayList<Face> faces = hs.getFaces();
		Face face = faces.get(3);

		edgeIterator = face.iteratorFE();
		System.out.printf("Adjacent half-edges of face %s:\n", face);
		while (edgeIterator.hasNext()) {
			HalfEdge edge = edgeIterator.next();
			System.out.printf("%s\n", edge);
		}
	}

}
