package openGL.objects;

import javax.vecmath.Matrix4f;
import javax.vecmath.Point3f;
import javax.vecmath.Vector3f;


/**
 * Stores the specification of a virtual camera. 
 * 
 * A scene manager (see {@link SceneManagerInterface}, {@link SimpleSceneManager}) 
 * stores a camera.
 */
public class Camera {

	private Matrix4f cameraMatrix;
	Point3f pos,lookAt;
	Vector3f up;
	
	/**
	 * Construct a camera with a default camera matrix. The camera
	 * matrix corresponds to the world-to-camera transform. This default
	 * matrix places the camera at (0,0,10) in world space, facing towards
	 * the origin (0,0,0) of world space, i.e., towards the negative z-axis.
	 */
	public Camera()
	{
		cameraMatrix = new Matrix4f();
		pos = new Point3f(0,0,10);
		lookAt = new Point3f(0,0,0);
		up = new Vector3f(0,1,0);

		
		set(pos, up,lookAt);
	}
	
	public void set(Point3f position, Vector3f up, Point3f lookAt){ 
		this.pos = position;
		this.up = up;
		this.lookAt = lookAt;
		
		computeMatrix();
			
	}

	private void computeMatrix() {
		Vector3f z = new Vector3f(pos.x-lookAt.x,
								 pos.y -lookAt.y,
								 pos.z -lookAt.z);
		z.normalize();
	
		Vector3f x = new Vector3f();		
		x.cross(up, z);
		x.normalize();
		Vector3f y = new Vector3f();
		y.cross(z, x);

		float[] f = { x.x, y.x, z.x,pos.x,
				x.y, y.y, z.y, pos.y,
				x.z, y.z, z.z, pos.z,
				0.f, 0.f, 0.f, 1.f};
		cameraMatrix.set(f);
		cameraMatrix.invert();
	}
	
	public Point3f getPosition(){
		return this.pos;
	}
	
	public void setPosition(Point3f p){
		this.pos = p;
		this.computeMatrix();
	}
	/**
	 * Return the camera matrix, i.e., the world-to-camera transform. For example, 
	 * this is used by the renderer.
	 * 
	 * @return the 4x4 world-to-camera transform matrix
	 */
	public Matrix4f getCameraMatrix()
	{
		return cameraMatrix;
	}
}
