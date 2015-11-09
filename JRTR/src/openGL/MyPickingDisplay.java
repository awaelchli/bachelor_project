package openGL;

import java.awt.BorderLayout;
import java.awt.event.ActionListener;

import javax.swing.ButtonGroup;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;

import openGL.gl.GLDisplayable;
import openGL.gl.interactive.GLUpdateable;
import openGL.interfaces.RenderPanel;
import openGL.objects.Shape;
import openGL.picking.PickingListener;
import openGL.picking.PickingPanel;
import openGL.picking.PickingProcessor;

/**
 * A simple  displayer that extends {@link MyDisplay} with 
 * picking capabilities for anything that is  {@link GLUpdateable}.
 * 
 * By default it provides zoom (mouse scrolling, hold shift for fast mode),
 * a trackball, near and far plane control 
 * (ctrl-scroll, alt-scroll), and an interface to switch on/off everything
 * on display.
 * And Picking (ctrl + mouse click/drag)
 * @author bertholet
 *
 */
public class MyPickingDisplay extends MyDisplay implements ActionListener {

	PickingListener l;
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public MyPickingDisplay(){
		super();
		
		l = new PickingListener(this, sceneManager);
		renderPanel.getCanvas().addMouseListener(l);
		renderPanel.getCanvas().addMouseMotionListener(l);
		renderPanel.getCanvas().addKeyListener(l);
		
		renderPanel.getCanvas().setFocusable(true);
		
		Shape s = new Shape(l);
		sceneManager.addShape(s);
		
		PickingPanel pickpan = new PickingPanel();
		pickpan.addPickingListener(l);
		
		this.getContentPane().add(
				pickpan, BorderLayout.NORTH);
		
	}
	
	
	public void addAsPickable(GLDisplayable glupd, PickingProcessor proc){
		Shape s = new Shape(glupd);
		sceneManager.addShape(s);
		trackball.register(s);
		l.register(s, proc);
		this.updateWhatsOnDisplay();
		this.updateDisplay();
		this.invalidate();
	}


	public float glWidth() {
		return renderPanel.getCanvas().getWidth();
	}


	public float glHeight() {
		return renderPanel.getCanvas().getHeight();		
	}


	public RenderPanel getRenderPanel() {
		return renderPanel;
	}


	
}
