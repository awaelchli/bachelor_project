package meshes;

import java.util.Iterator;

import javax.vecmath.Point3f;

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
	 * Get an iterator which iterates over the 1-neighbouhood
	 * 
	 * @return
	 */
	public Iterator<Vertex> iteratorVV() {
		return new IteratorVV(this.anEdge);
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
		// Implement this...
		return null;

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
			return current == null || current.getOpposite() != first;
		}

		@Override
		public HalfEdge next() {
			if (current == null) {
				current = first;
			} else if (current.incident_v != first.incident_v) {
				/*
				 * Go to opposite half-edge if current half-edge does not point
				 * to the center vertex.
				 */
				current = current.getOpposite();
			} else {
				current = current.getNext();
			}

			return current;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}
	}
	
	public final class IteratorVV implements Iterator<Vertex> {

		private final Iterator<HalfEdge> edgeIterator;

		public IteratorVV(HalfEdge anEdge) {
			this.edgeIterator = iteratorVE();
		}

		@Override
		public boolean hasNext() {
			return edgeIterator.hasNext();
		}

		@Override
		public Vertex next() {
			// Skip the half-edge pointing to the center vertex
			edgeIterator.next();
			HalfEdge edge = edgeIterator.next();
			return edge.incident_v;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}
	}
	
	public final class IteratorVF implements Iterator<Face> {

		private Iterator<HalfEdge> edgeIterator;

		public IteratorVF(HalfEdge anEdge) {
			edgeIterator = iteratorVE();
		}

		@Override
		public boolean hasNext() {
			return edgeIterator.hasNext();
		}

		@Override
		public Face next() {
			// Skip the half-edge pointing to the center vertex
			edgeIterator.next();
			HalfEdge edge = edgeIterator.next();
			return edge.incident_f;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}
	}

}
