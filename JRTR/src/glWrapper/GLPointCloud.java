package glWrapper;

import java.util.ArrayList;

import javax.media.opengl.GL;
import javax.vecmath.Tuple3f;

import openGL.gl.GLDisplayable;
import openGL.gl.GLRenderer;
import openGL.gl.GLDisplayable.Semantic;
import openGL.objects.Transformation;

import meshes.PointCloud;

/**
 * Wrapper for Pointclouds
 * @author Alf
 *
 */
public class GLPointCloud extends GLDisplayable {

	private PointCloud myCloud;


	public GLPointCloud(PointCloud cloud) {
		super(cloud.points.size());
		myCloud = cloud;
		
		//Add Vertices
		float[] verts = new float[myCloud.points.size()*3];
		float[] normals = new float[myCloud.normals.size()*3];
		int[] ind = new int[myCloud.points.size()];
		copyToArray(myCloud.points, verts);
			
		for(int i = 0; i < ind.length; i++)	{
			ind[i]=i;
		}
		this.addElement(verts, Semantic.POSITION , 3);
		
		if(myCloud.normals.size() > 0){
		copyToArray(myCloud.normals, normals);
		this.addElement(normals, Semantic.USERSPECIFIED , 3, "normal");
		}
		this.addIndices(ind);
	}

	
	private void copyToArray(ArrayList<? extends Tuple3f> points, float[] arr) {
		
		int i = 0;
		for(Tuple3f t: points){
			arr[i++] =t.x;
			arr[i++] =t.y;
			arr[i++] =t.z;
		}
	}


	@Override
	public int glRenderFlag() {
		return GL.GL_POINTS;
	}


	@Override
	public void loadAdditionalUniforms(GLRenderer glRenderContext,
			Transformation mvMat) {
		// TODO Auto-generated method stub
		
	}
	
	
}
