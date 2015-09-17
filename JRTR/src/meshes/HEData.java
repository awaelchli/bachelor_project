package meshes;

import java.util.HashMap;


/**
 * 
 * This datastructure allows you to associate additional data to 
 * half edge structures, for example normals to vertices or faces.
 * See {@link HEData1d}, {@link HEData3d}
 *
 * @param <He_element>
 * @param <Payload>
 */
public class HEData<He_element extends HEElement, Payload>{
	
	

	HashMap<He_element, Payload> myData;
		
	public HEData(){
		myData = new HashMap<He_element, Payload>();
	}

	public void put(He_element v, Payload data) {
		myData.put(v, data);
	}

	public Payload get(He_element v) {
		return myData.get(v);
	}
	
	public int size(){
		return myData.size();
	}

	public void remove(He_element v) {
		myData.remove(v);
	}

}
