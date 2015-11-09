package openGL.objects;

import javax.vecmath.Matrix4f;
import javax.vecmath.Point3f;
import javax.vecmath.Point4f;

/**
 * Extends the Matrix4f with some useful methods.
 * 
 * @author Marius Schwalbe
 * 
 */
public class Transformation extends Matrix4f {

	private static final long serialVersionUID = 0;

	public Transformation() {
		super();
	}

	public Transformation(Matrix4f matrix) {
		super(matrix);
	}

	public Transformation(float arg0, float arg1, float arg2, float arg3,
			float arg4, float arg5, float arg6, float arg7, float arg8,
			float arg9, float arg10, float arg11, float arg12, float arg13,
			float arg14, float arg15) {
		super(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9,
				arg10, arg11, arg12, arg13, arg14, arg15);
	}

	public void addToElement(int arg0, int arg1, float arg2) {
		setElement(arg0, arg1, getElement(arg0, arg1) + arg2);
	}

	public void shift(float xShift, float yShift, float zShift) {
		shiftX(xShift);
		shiftY(yShift);
		shiftZ(zShift);
	}

	public void shiftX(float xShift) {
		addToElement(0, 3, xShift);
	}

	public void shiftY(float yShift) {
		addToElement(1, 3, yShift);
	}

	public void shiftZ(float zShift) {
		addToElement(2, 3, zShift);
	}

	public Point4f mul(Point4f arg0) {
		return new Point4f(m00 * arg0.x + m01 * arg0.y + m02 * arg0.z + m03
				* arg0.w, m10 * arg0.x + m11 * arg0.y + m12 * arg0.z + m13
				* arg0.w, m20 * arg0.x + m21 * arg0.y + m22 * arg0.z + m23
				* arg0.w, m30 * arg0.x + m31 * arg0.y + m32 * arg0.z + m33
				* arg0.w);
	}
	
	
}
