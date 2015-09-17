package openGL.picking;

import java.awt.Dimension;
import java.awt.Point;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.HashMap;

import javax.media.opengl.GL;
import javax.vecmath.AxisAngle4f;
import javax.vecmath.Matrix3f;
import javax.vecmath.Matrix4f;
import javax.vecmath.Point3f;
import javax.vecmath.Tuple4f;
import javax.vecmath.Vector3f;
import javax.vecmath.Vector4f;

import openGL.MyPickingDisplay;
import openGL.gl.GLRenderer;
import openGL.gl.interactive.GLUpdateable;
import openGL.interfaces.SceneManager;
import openGL.objects.Shape;
import openGL.objects.Transformation;
import openGL.picking.PickingProcessor.PickOperation;
import openGL.picking.PickingProcessor.PickTarget;


/**
 * Preprocesses the Actions from the Pickingdisplay and forwards them to
 * the registered PickingProcessors, and handles the display of the selection 
 * frame that appears in the Add and Remove modes of the PickingWindow.
 * 
 * Preprocessing tasks include the mapping of window coordinates to 3d world-coordinates,
 * and the mapping of mouse movements to rotations and translations.
 * @author bertholet
 *
 */
public class PickingListener extends GLUpdateable
implements MouseListener, MouseMotionListener, KeyListener {

	//Provides access to camera frustum etc settings.
	SceneManager s;
	
	//Provides access to the shapes transformation
	HashMap<Shape, PickingProcessor> pickables;
	
	//provides access to the display dimensions.
	private MyPickingDisplay display;
	
	//defines the picking frame.
	Point3f point0,point1;

	//for rotations
	private Point last = null;
	
	//track the selected operation.
	PickOperation selected_op = PickOperation.ADD;
	PickTarget selected_target = PickTarget.SET1;
	
	
	public PickingListener(MyPickingDisplay d, SceneManager manager){
		super(4);
		pickables = new HashMap();
		s = manager;
		
		this.display = d;
		
		//track picking frame
		point0 = new Point3f(-1,-1,0);
		point1 = new Point3f(-1,-1,0);
		

		// display picking frame
		float[] f = new float[12];
		int[] indices = { 0,1,3,2};
		copyPositions(f);
		this.addElement(f, Semantic.POSITION, 3, "position");
		this.addIndices(indices);
	}
	
	/**
	 * map the points point0, point1 to a gl-compatible float array
	 * @param f
	 */
	private void copyPositions(float[] f) {
		f[0] = point0.x; f[1] = point0.y; f[2] = point0.z;
		f[3] = point0.x; f[4] = point1.y; f[5] = point0.z;
		f[6] = point1.x; f[7] = point0.y; f[8] = point1.z;
		f[9] = point1.x; f[10] = point1.y; f[11] = point1.z;
	}
	
	
	/**
	 * Register a PickingProcessor as an Observer
	 * @param s
	 * @param proc
	 */
	public void register(Shape s, PickingProcessor proc) {
		this.pickables.put(s, proc);
	}
	
	
	/**
	 * Callback when the Pickoperation or Picktarget is changed in the
	 * PickingDisplay.
	 * @param op
	 * @param t
	 */
	public void setMode(PickOperation op, PickTarget t) {
		
		if((op == PickOperation.MOVE || op == PickOperation.ROTATE) && 
				!(this.selected_op == PickOperation.MOVE || this.selected_op == PickOperation.ROTATE)
				){
			prepareMove();
		}
		this.selected_op = op;
		this.selected_target = t;


	}
	
	
	/**
	 * on click- remove selection frame
	 */
	@Override
	public void mouseClicked(MouseEvent e) {
		
		display.getRenderPanel().getCanvas().requestFocus();
		this.point0.set(0,0,0);
		this.point1.set(0,0,0);
		
		updateSelector();
		display.updateDisplay();
	}

	/**
	 * dragging starts
	 */
	@Override
	public void mousePressed(MouseEvent e) {
		if(e.isControlDown() && selected_op != PickOperation.MOVE && selected_op != PickOperation.ROTATE){
			unproject(e, point0);
			updateSelector();
		}
		else if (e.isControlDown() &&selected_op == PickOperation.MOVE){
			unproject(e, point0);
		}
		else if(e.isControlDown() && selected_op == PickOperation.ROTATE){
			last = null;
			this.last = e.getPoint();
			Dimension winSize = e.getComponent().getSize();
			last.translate(-winSize.width/2, -winSize.height/2);
		}
	}

	
	/**
	 * Map draggin operation to selection update, movement update or rotation update 
	 */
	@Override
	public void mouseDragged(MouseEvent e) {
		if(e.isControlDown() && selected_op != PickOperation.MOVE&&selected_op != PickOperation.ROTATE){
			unproject(e, point1);
			updateSelector();
		}
		else if (e.isControlDown() &&selected_op == PickOperation.MOVE){
			unproject(e, point1);
			updateMove();
			point0.set(point1);
			display.updateDisplay();
			Thread.yield();
			
		}
		else if (e.isControlDown() &&selected_op == PickOperation.ROTATE){
			if(last == null){
				return;
			}
			
			Dimension winSize = e.getComponent().getSize();
			Point next = e.getPoint();
			next.translate(-winSize.width/2, -winSize.height/2);
		
			Matrix4f rot = new Matrix4f();
			AxisAngle4f temp = resolveRotation(last, next, winSize);
			rot.set(temp);
			
			updateRotate(rot);
			
			last = next;
			
			display.updateDisplay();
			Thread.yield();
		}
		
	}

	
	/**
	 * Dragging ends
	 */
	@Override
	public void mouseReleased(MouseEvent e) {
		if(e.isControlDown() && !(selected_op == PickOperation.MOVE ||
				selected_op == PickOperation.ROTATE)){
			updatePicks();
			display.updateDisplay();
		}
		else if (e.isControlDown() &&
				(selected_op == PickOperation.MOVE )){
			updateMove();
			display.updateDisplay();
		}
	}
	

	

	/**
	 * triggers pick(..) operation to update the selection in all observing
	 * PickingProcessors
	 */
	private void updatePicks() {
		for(Shape s: pickables.keySet()){
			Transformation t = new Transformation(s.getTransformation());
			pickables.get(s).pick(new TransformedBBox(t, point0, point1),
				selected_op, selected_target);
				
		}
	}

	
	/**
	 * called when the operation is changed
	 * from a selection operation to a movement operation. Trigger prepareMove in the
	 * PickingProcessors
	 */
	private void prepareMove(){
		for(PickingProcessor p : pickables.values()){
			p.prepareMove();
		}
	}
	
	/**
	 * Triggers move operation in all the PickingProcessors
	 */
	private void updateMove() {
		Vector3f delta = new Vector3f();
		for(Shape s: pickables.keySet()){
			Transformation t = new Transformation(s.getTransformation());
			t.invert();
			delta.sub(point1, point0);
			t.transform(delta);
			pickables.get(s).move(delta, selected_target);
		}
	}
	
	/**
	 * Triggers rotate operation in all the PickingProcessors
	 */
	private void updateRotate(Matrix4f rot) {
		Matrix3f world2shape = new Matrix3f();
		Matrix3f shape2world = new Matrix3f();
		Matrix3f shapeRot = new Matrix3f();
		for(Shape s: pickables.keySet()){
			Transformation t = new Transformation(s.getTransformation());
			t.get(shape2world);
			t.invert();
			t.get(world2shape);
			
			rot.get(shapeRot);
			shapeRot.mul(shapeRot, shape2world);
			shapeRot.mul(world2shape, shapeRot);
			pickables.get(s).rotate(shapeRot, selected_target);
				
		}
	}

	
	
	////////////////////
	//Geometric operations to resolve window positions and mouse movements
	///////////////////
	
	/**
	 * map the window position stored in e to a 3d point p
	 * @param e
	 * @param p
	 */
	private void unproject(MouseEvent e, Point3f p) {
		Transformation t = new Transformation(s.getFrustum().getProjectionMatrix());
		t.mul(s.getCamera().getCameraMatrix());
		
		float depth = 0f;
		Vector4f targetDepth = new Vector4f();
		targetDepth.z = depth;
		targetDepth.w = 1;
		
		t.transform(targetDepth);
		t.invert();
		
		Tuple4f pnt1 = new Vector4f(2*(0.f + e.getX())/display.glWidth() -1,
				-2*(0.f+e.getY())/display.glHeight() +1, targetDepth.z/targetDepth.w, 1);
		t.transform(pnt1);
		p.set(pnt1.x/pnt1.w, pnt1.y/pnt1.w, pnt1.z/pnt1.w);
	}
	
	
	/**
	 * map the mouse movement to a rotation, as it is done for trackballs.
	 * 
	 * @param start2
	 * @param end
	 * @param e
	 * @return
	 */
	private AxisAngle4f resolveRotation(Point start2, Point end, Dimension e) {
		Vector3f a, b, axis = new Vector3f();
		a = mapToSphere(start2, e);
		a.normalize();
		b = mapToSphere(end, e);
		b.normalize();
		axis.cross(a, b);
		
		float angle;
		float aDotB = a.dot(b);
		aDotB = (aDotB > 1 ? 1 : (aDotB < -1 ? -1:aDotB));
		angle = (float) Math.acos(aDotB);
		if(axis.lengthSquared()< 0.0000001f){
			axis.set(1, 0, 0);
		}
		axis.normalize();
		return new AxisAngle4f(axis,angle);
	}

	/**
	 * trackball subroutine
	 * @param p
	 * @param e
	 * @return
	 */
	private Vector3f mapToSphere(Point p, Dimension e) {
		Vector3f resolved = new Vector3f();
		resolved.x = (0.f+p.x) /(Math.min(e.height, e.width)/2);
		resolved.y = -(0.f+p.y) /(Math.min(e.height, e.width)/2);
		if(resolved.lengthSquared() > 0.999f){
			resolved.normalize();
		}
		else{
			resolved.z = (float) Math.sqrt(1-resolved.x* resolved.x - resolved.y*resolved.y);
		}
		return resolved;
	}

	
	
	//display the selection frame
	private void updateSelector() {
		float[] buff = getDataBuffer("position");
		copyPositions(buff);
		scheduleUpdate("position");
	}

	@Override
	public int glRenderFlag() {
		return GL.GL_LINE_LOOP;
	}

	@Override
	public void loadAdditionalUniforms(GLRenderer glRenderContext,
			Transformation mvMat) {
	}

	
	
	@Override
	public void mouseEntered(MouseEvent e) {
	}

	@Override
	public void mouseExited(MouseEvent e) {
	}

	@Override
	public void mouseMoved(MouseEvent e) {
	}

	
	@Override
	public void keyPressed(KeyEvent e) {
	}

	@Override
	public void keyReleased(KeyEvent e) {
	}

	@Override
	public void keyTyped(KeyEvent e) {
	}

	

}
