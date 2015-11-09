package meshes.exception;

public class DanglingTriangleException extends MeshMalformedException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 779959109207696059L;

	public DanglingTriangleException() {
		super("Dangling Triangles where detected, Datastructure may be disfunctional");
	}

}
