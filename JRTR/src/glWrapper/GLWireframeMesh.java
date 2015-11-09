package glWrapper;

import java.util.ArrayList;

import javax.media.opengl.GL;
import javax.vecmath.Point3f;

import openGL.gl.GLDisplayable;
import openGL.gl.GLRenderer;
import openGL.gl.GLDisplayable.Semantic;
import openGL.objects.Transformation;

import meshes.WireframeMesh;


/**
 * This class describes how OpenGL should inteprete a wire frame mesh.
 * @author bertholet
 *
 */
public class GLWireframeMesh extends GLDisplayable {

	WireframeMesh myMesh;
	public GLWireframeMesh(WireframeMesh m) {
		super(m.vertices.size());
		myMesh = m;
		
		//Add Vertices
		float[] verts = new float[m.vertices.size()*3];
		int[] ind = new int[m.faces.size()*3];
		
		//copy the data to the allocated arrays
		copyToArrayP3f(m.vertices, verts);
		copyToArray(m.faces, ind);
		
		
		//The class GLVertexData provides the methods addElement(...), which will
		//cause the passed array to be sent to the graphic card
		//The array passed with the semantic POSITION will always be associated
		//to the position variable in the GL shaders, while arrays passed with the
		//USERSPECIFIED semantic will be associated to the name passed in the last argument
		//
		this.addElement(verts, Semantic.POSITION , 3);
		//Here the position coordinates are passed a second time to the shader as color
		this.addElement(verts, Semantic.USERSPECIFIED , 3, "color");
		
		//pass the index array which has to be conformal to the glRenderflag returned, here GL_Triangles
		this.addIndices(ind);
		
	}
	
	
	/**
	 * Helper method that copies the face information to the ind array
	 * @param faces
	 * @param ind
	 */
	private void copyToArray(ArrayList<int[]> faces, int[] ind) {
		int i = 0, j;
		for(int[] f : faces){
			//only triangle meshes covered for now.
			assert(f.length == 3);
			for(j=0; j < 3; j++){
				ind[i*3 + j] =f[j];
			}
			i++;
		}
	}
	
	/**
	 * Helper method that copies the vertices arraylist to the verts array
	 * @param vertices
	 * @param verts
	 */
	private void copyToArrayP3f(ArrayList<Point3f> vertices, float[] verts) {
		int i = 0;
		for(Point3f v: vertices){
			verts[i++] = v.x;
			verts[i++] = v.y;
			verts[i++] = v.z;
		}
	}

	
	/**
	 * Return the gl render flag to inform opengl that the indices/positions describe
	 * triangles
	 */
	@Override
	public int glRenderFlag() {
		return GL.GL_TRIANGLES;
	}


	/**
	 * No additional uniform variabes are passed to the shader.
	 */
	@Override
	public void loadAdditionalUniforms(GLRenderer glRenderContext,
			Transformation mvMat) {
		
		//additional uniforms can be loaded using the function
		//glRenderContext.setUniform(name, val);
		
		//Such uniforms can be accessed in the shader by declaring them as
		// uniform <type> name;
		//where type is the appropriate type, e.g. float / vec3 / mat4 etc.
		//this method is called at every rendering pass.
	}

}
