package openGL.gl;

import java.awt.Component;

import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GLCapabilities;
import javax.media.opengl.GLEventListener;
import javax.media.opengl.GLProfile;
import javax.media.opengl.awt.GLCanvas;

import openGL.interfaces.RenderPanel;


/**
 * An implementation of the {@link RenderPanel} interface using OpenGL. Its
 * purpose is to provide an AWT component that displays the rendered image. The
 * class {@link GLRenderer} performs the actual rendering. 
 */
public abstract class GLRenderPanel implements RenderPanel {

	/**
	 * An event listener for the GLJPanel to which this context renders. The
	 * main purpose of this event listener is to redirect display events to the
	 * renderer (the {@link GLRenderer}).
	 */
	private class GLRenderContextEventListener implements GLEventListener {
		private GLRenderPanel renderPanel;
		private GLRenderer renderContext;

		public GLRenderContextEventListener(GLRenderPanel renderPanel) {
			this.renderPanel = renderPanel;
		}

		/**
		 * Initialization call-back. Makes a render context (a renderer) using
		 * the provided <code>GLAutoDrawable</code> and calls the user provided
		 * <code>init</code> of the render panel.
		 */
		@Override
		public void init(GLAutoDrawable drawable) {
			renderContext = new GLRenderer(drawable);
			// Invoke the user-provided call back function
			renderPanel.init(renderContext);
		}

		/**
		 * Redirect the display event to the renderer.
		 */
		@Override
		public void display(GLAutoDrawable drawable) {
			renderContext.display(drawable);
		}

		@Override
		public void reshape(GLAutoDrawable drawable, int x, int y, int width,
				int height) {
			
			renderPanel.reshape( x,  y,  width,	 height);
		}

		@Override
		public void dispose(GLAutoDrawable g) {
		}
	}

	/**
	 * Because of problems with the computers in the ExWi pool, we are using
	 * <code>GLCanvas</code>, which is based on AWT, instead of
	 * <code>GLJPanel</code>, which is based on Swing.
	 */
	private GLCanvas canvas;

	public GLRenderPanel() {
		//canvas = new GLCanvas();
		canvas = new GLCanvas(new GLCapabilities(GLProfile.get(GLProfile.GL3)));

		GLEventListener eventListener = new GLRenderContextEventListener(this);
		canvas.addGLEventListener(eventListener);
	}

	/**
	 * Return the AWT component that contains the rendered image. The user
	 * application needs to call this. The returned component is usually added
	 * to an application window.
	 */
	@Override
	public final Component getCanvas() {
		return canvas;
	}

	/**
	 * Call back function to obtain the renderContext
	 */
	abstract public void init(GLRenderer renderContext);
	
	/**
	 * This callback needs to be implemented and handle window-reshape events, i.e. update
	 * Projection matrix and frustum information.
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 */
	abstract public void reshape(int x, int y, int width, int height);
}
