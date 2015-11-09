package meshes;

import java.util.Collection;
import java.util.Iterator;

public class IterableHEData<He_element extends HEElement, Payload> 
extends HEData<He_element, Payload>
implements Iterable<Payload>{

	
	Collection<He_element> relatedElements;
	
	public IterableHEData(Collection<He_element> elements) {
		this.relatedElements = elements;
	}
	
	public int size(){
		return relatedElements.size();
	}

	
	@Override
	public Iterator<Payload> iterator() {
		return new inOrderIterator();
	}
	
	private final class inOrderIterator implements Iterator<Payload> {
		
		private Iterator<He_element> elementIterator;

		public inOrderIterator(){
			elementIterator = relatedElements.iterator();
		}
		@Override
		public boolean hasNext() {
			return elementIterator.hasNext();
		}

		@Override
		public Payload next() {
			return get(elementIterator.next());
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
		}
	}
}
