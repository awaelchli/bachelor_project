package openGL.gl;

import java.nio.IntBuffer;

import javax.media.opengl.GL3;

/**
 * A vertex Array object is a OpenGL object that encapsulates all
 * the vertex data opengl needs for rendering. The vertex data is 
 * stored in vertex buffers on the gpu. Data managed with vertex array
 * objects needs to be sent to the gpu only once and can be reused in
 * multiple render passes. This is far more efficient than sending
 * Data to the gpu once for every render pass.
 * 
 */
public class GLVertexArrayObject {

	private IntBuffer vao;
	private IntBuffer vbo;

	private GL3 gl;

	public GLVertexArrayObject(GL3 gl, int numberOfVBOs) {
		this.gl = gl;

		// For all vertex attributes, make vertex buffer objects
		vbo = IntBuffer.allocate(numberOfVBOs);
		gl.glGenBuffers(numberOfVBOs, vbo);

		// Make a vertex array object for this shape
		vao = IntBuffer.allocate(1);
		gl.glGenVertexArrays(1, vao);

		// bind the new (current) vertex array object
		bind();

	}

	public int getNextVBO() {
		return vbo.get();
	}

	public void bind() {
		gl.glBindVertexArray(vao.get(0));
		
	}
	
	public void rewind(){
		vbo.rewind();
		vao.rewind();
	}

}