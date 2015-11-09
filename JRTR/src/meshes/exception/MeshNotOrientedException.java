package meshes.exception;

public class MeshNotOrientedException extends MeshMalformedException {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -4742450705220062317L;

	public MeshNotOrientedException(){
		super("Mesh is not oriented consistently!");
	}

}
