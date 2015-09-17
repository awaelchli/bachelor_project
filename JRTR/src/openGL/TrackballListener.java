package openGL;

import java.awt.Dimension;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.ArrayList;

import javax.vecmath.AxisAngle4f;
import javax.vecmath.Matrix4f;
import javax.vecmath.Vector3f;

import openGL.objects.Shape;
import openGL.objects.Transformation;



public class TrackballListener implements MouseListener, MouseMotionListener{

	private Point last = null;
	private ArrayList<Shape> shapes;
	MyDisplay display;

	public TrackballListener(MyDisplay myDisplay) {
		display = myDisplay;
		this.shapes = new ArrayList<Shape>();
	}

	public void register(Shape s){
		this.shapes.add(s);
	}
	
	@Override
	public void mouseClicked(MouseEvent e) {
		System.out.println("click");
	}

	@Override
	public void mouseEntered(MouseEvent e) {
	}

	@Override
	public void mouseExited(MouseEvent e) {
	}

	@Override
	public void mousePressed(MouseEvent e) {
		this.last = e.getPoint();
		Dimension winSize = e.getComponent().getSize();
		last.translate(-winSize.width/2, -winSize.height/2);
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		last = null;
	}

	private AxisAngle4f resolve(Point start2, Point end, Dimension e) {
		Vector3f a, b, axis = new Vector3f();
		a = resolve(start2, e);
		a.normalize();
		b = resolve(end, e);
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

	private Vector3f resolve(Point p, Dimension e) {
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

	@Override
	public void mouseDragged(MouseEvent e) {
		if(last == null){
			return;
		}

		
		Dimension winSize = e.getComponent().getSize();
		Point next = e.getPoint();
		next.translate(-winSize.width/2, -winSize.height/2);
	
		if(!e.isControlDown()){
			Matrix4f rot = new Matrix4f();
			AxisAngle4f temp = resolve(last, next, winSize);
			rot.set(temp);
			
			for(Shape s: shapes){
				Transformation t = new Transformation();
				t.mul(rot,s.getTransformation());
				s.setTransformation(t);
			}
		}
		display.updateDisplay();
		last = next;
	}

	@Override
	public void mouseMoved(MouseEvent arg0) {

	}

}
