package openGL.gl.interactive;

import java.util.HashSet;
import java.util.LinkedList;

import openGL.gl.GLDisplayable;
import openGL.gl.GLRenderer;
import openGL.gl.GLDisplayable.VertexElement;
import openGL.objects.Transformation;


/**
 * Extension of GLDisplayables that allows the update of data buffers on the gpu. 
 * @author bertholet
 *
 */
public abstract class GLUpdateable extends GLDisplayable {

	HashSet<String> scheduledUpdates;
	
	public GLUpdateable(int n) {
		super(n);
		scheduledUpdates = new HashSet<>();
	}

	
	public float[] getDataBuffer(String glName) {
		VertexElement e = get(glName, this.getElements());
		float[] data = e.getData();
		return data;
	}



	private VertexElement get(String string, LinkedList<VertexElement> elements) {
		for (VertexElement e : elements){
			if(e.getGLName().equalsIgnoreCase(string)){
				return e;
			}
		}
		return null;
	}

	
	public void scheduleUpdate(String name){
		scheduledUpdates.add(name);
	}
	
	public boolean wantUpdate(String name){
		return scheduledUpdates.contains(name);
	}


	public void didUpdate(String glName) {
		this.scheduledUpdates.remove(glName);
	}

}
