package meshes;

import java.util.Iterator;
import java.util.NoSuchElementException;

import javax.vecmath.Point3f;
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
		Point3f p1 = anEdge.start().getPos();
		Point3f p2 = anEdge.end().getPos();
		Point3f p3 = anEdge.getNext().end().getPos();
		
		Vector3f v1 = new Vector3f(p2);
		v1.sub(p1);
		
		Vector3f v2 = new Vector3f(p3);
		v2.sub(p2);
		
		Vector3f normal = new Vector3f();
		normal.cross(v1, v2);
		normal.normalize();
		return normal;
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
