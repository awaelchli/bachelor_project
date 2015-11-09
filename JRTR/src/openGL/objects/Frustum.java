package openGL.objects;

import openGL.interfaces.SceneManager;


/**
 * Stores the specification of a viewing frustum, or a viewing volume. The
 * viewing frustum is represented by a 4x4 projection matrix.
 * <p>
 * A scene manager (see {@link SceneManager},
 * {@link SimpleSceneManager}) stores a frustum.
 */
public class Frustum {

	private Transformation projectionMatrix;
	private float near;
	private float far;
	private float aspect;
	private float vfov;

	/**
	 * Construct a default viewing frustum. The frustum is given by a default
	 * 4x4 projection matrix.
	 */
	public Frustum() {
		projectionMatrix = new Transformation();
		near = 1;
		far = 100; 
		aspect =1; vfov =(float)Math.PI/6;
		set(near, far, aspect, vfov);
	}
	
	

	/**
	 * 
	 * @param near nearplane
	 * @param far farplane
	 * @param aspect aspect ratio
	 * @param vfov vertical field of view
	 */
	public void set(float near, float far, float aspect, float vfov){
		this.near = near;
		this.far= far; 
		this.aspect =aspect; 
		this.vfov =vfov;
		
		float tan = (float) Math.tan(vfov/2);
		float f[] = {1.f/(aspect*tan), 0.f, 0.f, 0.f, 
				 0.f, 1.f/(tan), 0.f, 0.f,
			     0.f, 0.f, (0.f+far + near)/(near-far), 2.f*(0.f+far*near)/(near-far),
			     0.f, 0.f, -1.f, 0.f};
		projectionMatrix.set(f);
	}
	
	/**
	 * update the aspect ratio, this method is called for example when
	 * the window size is changed.
	 * @param aspect
	 */
	public void update(float aspect){
		set(near, far, aspect, vfov);
	}
	
	/**
	 * Return the 4x4 projection matrix, which is used for example by the
	 * renderer.
	 * 
	 * @return the 4x4 projection matrix
	 */
	public Transformation getProjectionMatrix() {
		return projectionMatrix;
	}



	/**
	 * change the position of the near plane
	 * @param d
	 */
	public void incrementNear(double d) {
		if(near + d > 0.1){
			near+=d;
		}
		set(near, far, aspect, vfov);
	}



	/**
	 * change the position of the far plane
	 * @param d
	 */
	public void incrementFar(double d) {
		if(far + d - near > 0.01){
			far+=d;
		}
		set(near, far, aspect, vfov);
	}



	/**
	 * scale the position of the far plane.
	 * @param scale
	 */
	public void scaleFar(double scale) {
		if(far * scale > near + 0.01 &&
				far*scale < 500){
			far*= scale;
		}
		set(near, far, aspect, vfov);
	}
}
