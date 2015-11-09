package openGL.picking;

import javax.vecmath.Point3f;

import openGL.objects.Transformation;


/**
 * Provides a test to test if some points x,y coordinates lie in a  frame  described by two points,
 * given some coordinate system
 * @author bertholet
 *
 */
public class TransformedBBox {
	
	private Transformation t;
	private Point3f max;
	private Point3f min;
	Point3f transf;

	public TransformedBBox(Transformation t, Point3f p0, Point3f p1){
		this.t = t;
		this.min = new Point3f();
		min.x = p0.x <p1.x? p0.x:p1.x;
		min.y = p0.y <p1.y? p0.y:p1.y;
		min.z = p0.z <p1.z? p0.z:p1.z;
		this.max = new Point3f();
		max.x = p0.x >p1.x? p0.x:p1.x;
		max.y = p0.y >p1.y? p0.y:p1.y;
		max.z = p0.z >p1.z? p0.z:p1.z;
		
		transf = new Point3f();
	}

	public boolean contains(Point3f pos) {
		t.transform(pos, transf);
		
		return min.x < transf.x &&
				min.y < transf.y &&
				max.x > transf.x &&
				max.y > transf.y;
		
	}
	
	

}
