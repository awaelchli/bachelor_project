package meshes;

import java.util.ArrayList;

import javax.vecmath.Point3f;

/**
 * A Wireframe Mesh represents a mesh as a list of vertices and a list of faces.
 * Very lightweight representation.
 * @author bertholet
 *
 */
public class WireframeMesh {

	public ArrayList<Point3f> vertices;
	public ArrayList<int[]> faces;
	
	public WireframeMesh(){
		vertices = new ArrayList<Point3f>();
		faces = new ArrayList<>();
	}

}
