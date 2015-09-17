package openGL.interfaces;

import java.awt.Component;

import openGL.gl.GLRenderPanel;
import openGL.gl.GLRenderer;


/**
 * An interface to display images that are rendered by a render context (a
 * "renderer").
 */
public interface RenderPanel {

	/**
	 * This is a call-back that needs to be implemented to
	 * initialize the renderContext.
	 */
	void init(GLRenderer renderContext);

	/**
	 * Obtain a <code>Component</code> that contains the rendered image.
	 */
	Component getCanvas();
}
