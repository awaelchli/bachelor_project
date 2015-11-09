package openGL.picking;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

import javax.swing.ButtonGroup;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;

import openGL.picking.PickingProcessor.PickOperation;
import openGL.picking.PickingProcessor.PickTarget;


/**
 * Panel for Picking-Mode Selection
 * @author bertholet
 *
 */
public class PickingPanel extends JPanel implements ActionListener {

	private JRadioButton set1;
	private JRadioButton set2;
	private JRadioButton addOp;
	private JRadioButton remOp;
	private JRadioButton moveOp;
	
	ArrayList<PickingListener> listeners;
	private JRadioButton rotOp;

	public PickingPanel(){
		
		//setup radio buttons
		ButtonGroup g = new ButtonGroup();
		set1 = new JRadioButton("Set 1");
		set1.setSelected(true);
		set2 = new JRadioButton("Set 2");
		g.add(set1); g.add(set2);
		
		addOp = new JRadioButton("add");
		addOp.setSelected(true);
		remOp = new JRadioButton("remove");
		moveOp = new JRadioButton("move");
		rotOp = new JRadioButton("rotate");
		g = new ButtonGroup();
		g.add(addOp); g.add(remOp); g.add(moveOp);g.add(rotOp);
		
		//add action
		set1.addActionListener(this);
		set2.addActionListener(this);
		remOp.addActionListener(this);
		addOp.addActionListener(this);
		moveOp.addActionListener(this);
		rotOp.addActionListener(this);
		listeners = new ArrayList<>();
		
		//do layout.
		this.add(new JLabel("Picking Target: "));
		this.add(set1);
		this.add(set2);
		this.add(new JLabel("Picking Operation: "));
		this.add(addOp);
		this.add(remOp);
		this.add(moveOp);
		this.add(rotOp);
	}

	@Override
	public void actionPerformed(ActionEvent arg0) {
		PickOperation op;
		PickTarget t;
		if(set1.isSelected()){
			t = PickTarget.SET1;
		}
		else{
			t = PickTarget.SET2;
		}
		
		if(addOp.isSelected()){
			op =PickOperation.ADD; 
		}
		else if( remOp.isSelected()){
			op = PickOperation.REMOVE;
		}
		else if (moveOp.isSelected()){
			op = PickOperation.MOVE;
		}
		else{
			op = PickOperation.ROTATE;
		}
		for(PickingListener p : listeners){
			p.setMode(op,t);
		}
	}
	
	public void addPickingListener(PickingListener p){
		this.listeners.add(p);
	}
	

}
