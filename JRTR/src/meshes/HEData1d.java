package meshes;

/**
 * Simple class that allows to associate one dimensional data to half-edge structure vertices
 * @author bertholet
 *
 */
public class HEData1d 
extends IterableHEData<Vertex, Number> {

	public HEData1d(HalfEdgeStructure hs) {
		super(hs.getVertices());
	}
}
