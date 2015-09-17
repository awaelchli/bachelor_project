package openGL.objects;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.ListIterator;

import openGL.interfaces.SceneManager;
import openGL.interfaces.SceneManagerIterator;


/**
 * This class stores the shapes on display, the camera and the frustum
 * setting
 */
public class SimpleSceneManager implements SceneManager {

	private ArrayList<Shape> shapes;
	private Camera camera;
	private Frustum frustum;

	public SimpleSceneManager() {
		shapes = new ArrayList<Shape>();
		camera = new Camera();
		frustum = new Frustum();
	}

	@Override
	public Camera getCamera() {
		return camera;
	}

	@Override
	public Frustum getFrustum() {
		return frustum;
	}

	public void addShape(Shape shape) {
		shapes.add(shape);
	}

	@Override
	public SceneManagerIterator iterator() {
		return new SimpleSceneManagerItr(this);
	}


	private class SimpleSceneManagerItr implements SceneManagerIterator {

		public SimpleSceneManagerItr(SimpleSceneManager sceneManager) {
			itr = sceneManager.shapes.listIterator(0);
		}

		@Override
		public boolean hasNext() {
			return itr.hasNext();
		}

		@Override
		public RenderItem next() {
			Shape shape = itr.next();
			// Here the transformation in the RenderItem is simply the
			// transformation matrix of the shape. 
			return new RenderItem(shape, shape.getTransformation());
		}

		ListIterator<Shape> itr;
	}
}
