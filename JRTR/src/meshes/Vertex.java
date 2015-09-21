package meshes;

import java.util.ArrayList;
import java.util.Iterator;

import javax.vecmath.Point3f;
import javax.vecmath.Vector3f;

/**
 * Implementation of a vertex for the {@link HalfEdgeStructure}
 */
public class Vertex extends HEElement {

	/** position */
	Point3f pos;
	/** adjacent edge: this vertex is startVertex of anEdge */
	HalfEdge anEdge;

	/** The index of the vertex, mainly used for toString() */
	public int index;

	public Vertex(Point3f v) {
		pos = v;
		anEdge = null;
	}

	public Point3f getPos() {
		return pos;
	}

	public void setHalfEdge(HalfEdge he) {
		anEdge = he;
	}

	public HalfEdge getHalfEdge() {
		return anEdge;
	}

	/**
	 * Get an iterator which iterates over the 1-neighborhood
	 * 
	 * @return
	 */
	public Iterator<Vertex> iteratorVV() {
		return new IteratorVV();
	}

	/**
	 * Iterate over the outgoing edges
	 * 
	 * @return
	 */
	public Iterator<HalfEdge> iteratorVE() {
		return new IteratorVE(this.anEdge);

	}

	/**
	 * Iterate over the neighboring faces
	 * 
	 * @return
	 */
	public Iterator<Face> iteratorVF() {

		ArrayList<Face> faces = new ArrayList<Face>();

		Iterator<HalfEdge> edgeIterator = iteratorVE();
		while (edgeIterator.hasNext()) {
			// Skip the half-edge pointing to the center vertex
			edgeIterator.next();
			HalfEdge edge = edgeIterator.next();
			if (edge.incident_f != null) {
				faces.add(edge.incident_f);
			}
		}

		return faces.iterator();
	}

	public int valence() {
		int valence = 0;
		Iterator<Vertex> iterator = iteratorVV();
		while (iterator.hasNext()) {
			iterator.next();
			valence++;
		}

		return valence;
	}

	public String toString() {
		return "" + index;
		// return pos.toString();
	}

	/**
	 * Test if vertex w is adjacent to this vertex. Will work once the iterators
	 * over neigbors are implemented
	 * 
	 * @param w
	 * @return
	 */
	public boolean isAdjascent(Vertex w) {
		boolean isAdj = false;
		Vertex v = null;
		Iterator<Vertex> it = iteratorVV();
		while (it.hasNext()) {
			v = it.next();
			if (v == w) {
				isAdj = true;
			}
		}
		return isAdj;
	}
	
	public Vector3f normal(){
		Iterator<Face> faceIterator = iteratorVF();
		
		Vector3f averageNormal = new Vector3f();
		
		while(faceIterator.hasNext()){
			Face face = faceIterator.next();
			Vector3f faceNormal = face.normal();
			averageNormal.add(faceNormal);
		}

		averageNormal.normalize();
		return averageNormal;
	}

	/**
	 * Test if vertex w is adjacent to this vertex. Will work once the iterators
	 * over neigbors are implemented
	 * 
	 * @param w
	 * @return
	 */
	public boolean isOnBoundary() {
		Iterator<HalfEdge> it = iteratorVE();
		while (it.hasNext()) {
			if (it.next().isOnBorder()) {
				return true;
			}
		}
		return false;
	}

	public final class IteratorVE implements Iterator<HalfEdge> {

		private final HalfEdge first;
		private HalfEdge current;

		public IteratorVE(HalfEdge anEdge) {
			this.first = anEdge;
			this.current = null;
		}

		@Override
		public boolean hasNext() {
			return current == null || current.getOpposite().getNext() != first;
		}

		@Override
		public HalfEdge next() {
			current = current == null ? first : current.getOpposite().getNext();
			return current;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}
	}

	public final class IteratorVV implements Iterator<Vertex> {

		private final Iterator<HalfEdge> edgeIterator;

		public IteratorVV() {
			this.edgeIterator = iteratorVE();
		}

		@Override
		public boolean hasNext() {
			return edgeIterator.hasNext();
		}

		@Override
		public Vertex next() {
			return edgeIterator.next().end();
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}
	}
}
