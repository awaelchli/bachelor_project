package meshes;

import java.util.ArrayList;

import javax.vecmath.Point3f;
import javax.vecmath.Vector3f;

/**
 * 
 * A Pointcloud with normals.
 * @author Alf
 *
 */
public class PointCloud {

	public ArrayList<Point3f> points;
	public ArrayList<Vector3f> normals;
	
	
	public PointCloud(){
		this.points = new ArrayList<>();
		this.normals = new ArrayList<>();
	}

	/**
	 * Will rescale and distort the pointcloud such that its bounding box becomes
	 *  a unit cube.
	 * @return
	 */
	public Vector3f scaleToCube() {
		Vector3f max = new Vector3f(Float.MIN_VALUE,Float.MIN_VALUE,Float.MIN_VALUE);
		Vector3f min = new Vector3f(Float.MAX_VALUE,Float.MAX_VALUE,Float.MAX_VALUE);
		
		for(Point3f p : points){
			max.x = (p.x>max.x? p.x: max.x);
			max.y = (p.y>max.y? p.y: max.y);
			max.z = (p.z>max.z? p.z: max.z);
			
			min.x = (p.x < min.x? p.x: min.x);
			min.y = (p.y < min.y? p.y: min.y);
			min.z = (p.z < min.z? p.z: min.z);
			
		}
		
		Vector3f scale = new Vector3f(1.f/(max.x - min.x), 1.f/(max.y - min.y),1.f/(max.z - min.z));
		
		for(Point3f p : points){
			p.x*=scale.x;
			p.y*=scale.y;
			p.z*=scale.z;
		}
		for(Vector3f n: normals){
			n.x/=scale.x;
			n.y/=scale.y;
			n.z/=scale.z;
			n.normalize();
		}
		
		return scale;
	}
	
	
	/**
	 * Will rescale the pointcloud and translate it to the
	 * origin.
	 */
	public void normalize() {
		Vector3f max = new Vector3f(Float.MIN_VALUE,Float.MIN_VALUE,Float.MIN_VALUE);
		Vector3f min = new Vector3f(Float.MAX_VALUE,Float.MAX_VALUE,Float.MAX_VALUE);
		
		for(Point3f p : points){
			max.x = (p.x>max.x? p.x: max.x);
			max.y = (p.y>max.y? p.y: max.y);
			max.z = (p.z>max.z? p.z: max.z);
			
			min.x = (p.x < min.x? p.x: min.x);
			min.y = (p.y < min.y? p.y: min.y);
			min.z = (p.z < min.z? p.z: min.z);
			
		}
		
		float scale = Math.max(
				Math.min(1.f/(max.x - min.x), 1.f/(max.y - min.y)),
				Math.min(1.f/(max.z - min.z), 1.f/(max.y - min.y)))*2;
		
		Vector3f translate = new Vector3f((-min.x - max.x)/2,
				(-min.y - max.y)/2,
				(-min.z - max.z)/2);
		
		for(Point3f p : points){
			p.add(translate);
			
			p.x*=scale;
			p.y*=scale;
			p.z*=scale;
		}

	}
	

	/**
	 * Normalize all normals.
	 */
	public void normalizeNormals() {
		for(Vector3f v : normals){
			v.normalize();
		}
	}
	

}
