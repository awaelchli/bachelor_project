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
			HalfEdge edge = edgeIterator.next();
			if (edge.hasFace()) {
				faces.add(edge.getFace());
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
	}

	/**
	 * Test if vertex w is adjacent to this vertex.
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

	public Vector3f normal() {
		Iterator<HalfEdge> edgeIterator = iteratorVE();

		Vector3f averageNormal = new Vector3f();

		while (edgeIterator.hasNext()) {
			HalfEdge halfEdge = edgeIterator.next();

			if (!halfEdge.hasFace())
				continue;

			float angle = halfEdge.angle(halfEdge.getPrev().getOpposite());
			Vector3f faceNormal = halfEdge.getFace().normal();
			faceNormal.scale(angle);
			averageNormal.add(faceNormal);
		}

		averageNormal.normalize();
		return averageNormal;
	}

	public float meanCurvature() {
		return laplaceBeltrami().length() / 2;
	}

	public Vector3f laplaceBeltrami() {

		Vector3f sum = new Vector3f();

		Iterator<HalfEdge> iterator = iteratorVE();
		while (iterator.hasNext()) {
			HalfEdge edge = iterator.next();

			float alpha = edge.alpha();
			float beta = edge.beta();

			Vector3f vector = edge.vector();
			vector.negate();
			vector.scale((float) (1 / Math.tan(alpha) + 1 / Math.tan(beta)));

			sum.add(vector);
		}

		sum.scale(1 / (2 * mixedArea()));
		return sum;
	}

	public float mixedArea() {
		float mixedArea = 0;

		Iterator<HalfEdge> iterator = iteratorVE();
		while (iterator.hasNext()) {

			HalfEdge edge = iterator.next();
			if (!edge.hasFace())
				continue;

			Face face = edge.getFace();
			Vertex obtuseV = face.getObtuseVertex();

			if (obtuseV == null) {
				HalfEdge pq = edge;
				HalfEdge qr = edge.getNext();
				HalfEdge rp = edge.getNext().getNext();
				
				float angleQ = qr.angle(pq.getOpposite());
				float angleR = rp.angle(qr.getOpposite());
				
				mixedArea += 1 / 8 * (rp.length() * rp.length() / Math.tan(angleQ));
				mixedArea += 1 / 8 * (pq.length() * pq.length() / Math.tan(angleR));
			} else if (obtuseV == this) {
				mixedArea += face.area() / 2;
			} else {
				mixedArea += face.area() / 4;
			}
		}
		return mixedArea;
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
