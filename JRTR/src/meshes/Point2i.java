package meshes;

public class Point2i {
	public int x,y;

	public Point2i(int i, int j) {
		x = i;
		y = j;
		
	}
	
	public int hashCode(){
		return (x ^ ~y << 16) | (x ^ y) ;
	}
	
	public boolean equals(Object o){
		return o instanceof Point2i && 
				((Point2i) o).x == this.x &&
				((Point2i) o).y == this.y;
	}

}
