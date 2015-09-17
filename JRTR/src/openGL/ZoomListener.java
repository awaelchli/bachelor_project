package openGL;

import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;

import javax.vecmath.Point3f;

import openGL.objects.SimpleSceneManager;


public class ZoomListener implements MouseWheelListener{
	
	private SimpleSceneManager myManager;
	private MyDisplay myDisplay;



	public ZoomListener(SimpleSceneManager sceneManager, MyDisplay display){
		myManager = sceneManager;
		myDisplay = display;
	}



	@Override
	public void mouseWheelMoved(MouseWheelEvent e) {
		double delta = e.isShiftDown()? 
				e.getPreciseWheelRotation()/4:
				e.getPreciseWheelRotation()/20;

		if(e.isControlDown()){
			myManager.getFrustum().incrementNear(delta);
			myManager.getFrustum().incrementFar(delta);
			myDisplay.updateDisplay();
		}
		else if(e.isAltDown()){
			myManager.getFrustum().scaleFar(1 + (e.isShiftDown()? 2*delta: delta/3));
			myDisplay.updateDisplay();
		}
		else{
			Point3f pos = myManager.getCamera().getPosition();
			pos.z-=delta;
			myManager.getCamera().setPosition(pos);
			myDisplay.updateDisplay();
		}
	}

}
