package openGL.objects;

import openGL.interfaces.SceneManagerIterator;

/**
 * A data structure that contains a shape and its transformation. Its purpose is
 * to pass data from the scene manager to the renderer via the
 * {@link SceneManagerIterator}.
 */
public class RenderItem {

	private Shape shape;
	private Transformation t;

	public RenderItem(Shape shape, Transformation t) {
		this.shape = shape;
		this.t = t;
	}

	public Shape getShape() {
		return shape;
	}

	public Transformation getTransformation() {
		return t;
	}
	
	
}
