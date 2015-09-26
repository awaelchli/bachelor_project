package meshes;

import java.util.Iterator;
import java.util.NoSuchElementException;

import javax.vecmath.Vector3f;

public class Face extends HEElement {

	private HalfEdge anEdge;

	public Face() {
		anEdge = null;
	}

	public void setHalfEdge(HalfEdge he) {
		this.anEdge = he;
	}

	public HalfEdge getHalfEdge() {
		return anEdge;
	}

	public Iterator<Vertex> iteratorFV() {
		return new IteratorFV(anEdge);
	}

	public Iterator<HalfEdge> iteratorFE() {
		return new IteratorFE(this.anEdge);
	}

	public Vector3f normal() {
		Vector3f v1 = getHalfEdge().vector();
		Vector3f v2 = getHalfEdge().getNext().vector();

		Vector3f normal = new Vector3f();
		normal.cross(v1, v2);
		normal.normalize();

		return normal;
	}

	public float area() {
		Vector3f v1 = getHalfEdge().vector();
		Vector3f v2 = getHalfEdge().getNext().vector();

		v1.cross(v1, v2);
		return v1.length() / 2;
	}

	public boolean isObtuse() {
		return getObtuseVertex() != null;
	}
	
	public Vertex getObtuseVertex(){
		Iterator<HalfEdge> iterator = iteratorFE();
		while (iterator.hasNext()) {
			HalfEdge current = iterator.next();
			HalfEdge prev = current.getPrev();

			if (current.angle(prev.getOpposite()) > Math.PI / 2) {
				return current.start();
			}
		}
		return null;
	}

	public String toString() {
		if (anEdge == null) {
			return "f: not initialized";
		}
		String s = "f: [";
		Iterator<Vertex> it = this.iteratorFV();
		while (it.hasNext()) {
			s += it.next().toString();
			if (it.hasNext()) {
				s += ", ";
			}
		}

		s += "]";
		return s;

	}

	public final class IteratorFV implements Iterator<Vertex> {

		private HalfEdge first, actual;

		public IteratorFV(HalfEdge anEdge) {
			first = anEdge;
			actual = null;
		}

		@Override
		public boolean hasNext() {
			return actual == null || actual.next != first;
		}

		@Override
		public Vertex next() {
			if (!hasNext()) {
				throw new NoSuchElementException();
			}
			actual = (actual == null ? first : actual.next);
			return actual.incident_v;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}

		public Face face() {
			return first.incident_f;
		}
	}

	public final class IteratorFE implements Iterator<HalfEdge> {

		private HalfEdge current, first;

		public IteratorFE(HalfEdge anEdge) {
			this.first = anEdge;
			this.current = null;
		}

		@Override
		public boolean hasNext() {
			return current == null || current.next != first;
		}

		@Override
		public HalfEdge next() {
			current = current == null ? first : current.next;
			return current;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();

		}

		public Face face() {
			return first.incident_f;
		}

	}

}
