package meshes;

import javax.vecmath.Tuple3f;

/**
 * Simple data structure, which lets you associate 3d data to the vertices of a half-edge structure 
 * @author bertholet
 *
 */
public class HEData3d extends IterableHEData<Vertex, Tuple3f> {
	
	
	public HEData3d(HalfEdgeStructure hs) {
		super(hs.getVertices());
	}
}
