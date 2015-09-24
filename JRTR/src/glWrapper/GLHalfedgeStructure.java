package glWrapper;

import java.util.HashMap;
import java.util.Iterator;

import javax.media.opengl.GL;
import javax.vecmath.Point3f;
import javax.vecmath.Vector3f;

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
		 * Add vertex positions
		 */
		Iterator<Vertex> vertexIterator = structure.iteratorV();
		float[] glVertices = new float[3 * getNumberOfVertices()];
		float[] glValenceData = new float[getNumberOfVertices()];

		HashMap<Vertex, Integer> vertexIndexMap = new HashMap<Vertex, Integer>();

		int c = 0;
		int vertexIndex = 0;
		while (vertexIterator.hasNext()) {

			Vertex vertex = vertexIterator.next();
			Point3f point = vertex.getPos();

			glVertices[c++] = point.x;
			glVertices[c++] = point.y;
			glVertices[c++] = point.z;

			glValenceData[vertexIndex] = vertex.valence();

			vertexIndexMap.put(vertex, vertexIndex++);
		}

		this.addElement(glVertices, Semantic.POSITION, 3);

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

		/*
		 * Add vertex colors
		 */
		this.addElement(glVertices, Semantic.USERSPECIFIED, 3, "color");

		/*
		 * Add valence data
		 */
		this.addElement(glValenceData, Semantic.USERSPECIFIED, 1, "valence");

		addVertexNormals(structure);
	}

	@Override
	public int glRenderFlag() {
		return GL.GL_TRIANGLES;
	}

	@Override
	public void loadAdditionalUniforms(GLRenderer glRenderContext, Transformation mvMat) {
		Transformation normalMatrix = new Transformation(mvMat);
		normalMatrix.invert();
		normalMatrix.transpose();
		glRenderContext.setUniform("normalMatrix", normalMatrix);
	}

	private void addVertexNormals(HalfEdgeStructure structure) {

		float[] glNormals = new float[3 * getNumberOfVertices()];

		Iterator<Vertex> vertexIterator = structure.iteratorV();
		int c = 0;
		while (vertexIterator.hasNext()) {

			Vertex vertex = vertexIterator.next();
			Vector3f normal = vertex.normal();

			glNormals[c++] = normal.x;
			glNormals[c++] = normal.y;
			glNormals[c++] = normal.z;
		}

		this.addElement(glNormals, Semantic.USERSPECIFIED, 3, "normal");
	}

}
