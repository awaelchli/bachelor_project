package glWrapper;

import java.util.HashMap;
import java.util.Iterator;

import javax.media.opengl.GL;
import javax.vecmath.Point3f;

import meshes.Face;
import meshes.HalfEdgeStructure;
import meshes.Vertex;
import openGL.gl.GLDisplayable;
import openGL.gl.GLRenderer;
import openGL.objects.Transformation;

/**
 * 
 * @author Adrian Waelchli
 *
 */
public class GLHalfedgeStructure extends GLDisplayable {

	public GLHalfedgeStructure(HalfEdgeStructure structure) {
		super(structure.getVertices().size());

		/*
		 * Add vertices
		 */
		Iterator<Vertex> vertexIterator = structure.iteratorV();
		float[] glVertices = new float[3 * this.getNumberOfVertices()];

		HashMap<Vertex, Integer> vertexIndexMap = new HashMap<Vertex, Integer>();

		int c = 0;
		int vertexIndex = 0;
		while (vertexIterator.hasNext()) {

			Vertex vertex = vertexIterator.next();
			Point3f point = vertex.getPos();

			glVertices[c++] = point.x;
			glVertices[c++] = point.y;
			glVertices[c++] = point.z;

			vertexIndexMap.put(vertex, vertexIndex++);
		}

		this.addElement(glVertices, Semantic.POSITION, 3);
		this.addElement(glVertices, Semantic.USERSPECIFIED , 3, "color");

		/*
		 * Create indices
		 */
		int[] glIndices = new int[3 * structure.getFaces().size()];

		Iterator<Face> faceIterator = structure.iteratorF();
		c = 0;
		while (faceIterator.hasNext()) {

			Iterator<Vertex> faceVertexIterator = faceIterator.next().iteratorFV();
			while (faceVertexIterator.hasNext()) {
				Vertex vertex = faceVertexIterator.next();
				int index = vertexIndexMap.get(vertex);
				glIndices[c++] = index;
			}

		}
		this.addIndices(glIndices);
	}

	@Override
	public int glRenderFlag() {
		return GL.GL_TRIANGLES;
	}

	@Override
	public void loadAdditionalUniforms(GLRenderer glRenderContext, Transformation mvMat) {
		// To be implemented
	}

}
