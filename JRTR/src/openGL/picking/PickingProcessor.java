package openGL.picking;

import javax.vecmath.Matrix3f;
import javax.vecmath.Matrix4f;
import javax.vecmath.Vector3f;

import openGL.picking.PickingProcessor.PickTarget;


/**
 * Interface to receive and process Picking operations.
 * @author bertholet
 *
 */
public interface PickingProcessor {

	public enum PickOperation {ADD, REMOVE, MOVE, ROTATE};
	public enum PickTarget {SET1, SET2};
	public void prepareMove();
	public void move(Vector3f delta, PickTarget selected_target);
	public void pick(TransformedBBox t, PickOperation op, PickTarget target);
	
	public void rotate(Matrix3f rot, PickTarget selected_target);

}
