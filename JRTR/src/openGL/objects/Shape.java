package openGL.objects;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import openGL.gl.GLDisplayable;
import openGL.gl.GLRenderer;



/**
 * Represents a 3D shape for opengl. Manages its Object-to-world transformation
 */
public class Shape implements ActionListener {

	private GLDisplayable vertexData;
	private Transformation t;
	private boolean show;

	/**
	 * Make a shape from {@link GLDisplayable}.
	 * 
	 * @param vertexData
	 *            the vertices of the shape.
	 */
	public Shape(GLDisplayable vertexData) {
		this.vertexData = vertexData;
		t = new Transformation();
		t.setIdentity();
		show = true;
	}

	public GLDisplayable getVertexData() {
		return vertexData;
	}

	public void setTransformation(Transformation t) {
		this.t = t;
	}

	public Transformation getTransformation() {
		return t;
	}


	public void loadPreferredShader(GLRenderer context) {
		((GLDisplayable) vertexData).loadPreferredShader(context);
	}

	public void setAdditionalUniforms(GLRenderer glRenderContext,
			Transformation mvMat) {
		((GLDisplayable) vertexData).loadAdditionalUniforms( glRenderContext,
				 mvMat);
		
	}
	
	
	public boolean isVisible(){
		 return show;
	}
	
	public void setVisible(boolean show){
		this.show = show;
	}

	@Override
	public void actionPerformed(ActionEvent arg0) {
		show = !show;
	}
}
