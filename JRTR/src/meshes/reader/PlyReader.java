package meshes.reader;

import glWrapper.GLPointCloud;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

import javax.vecmath.Point3f;
import javax.vecmath.Vector3f;

import openGL.MyDisplay;


import meshes.PointCloud;


/**
 * Simple Reader to read ascii .ply files containing Pointclouds (with normals)
 * @author Alf
 *
 */
public class PlyReader {
	
	HashMap<String, ArrayList<Float>[]> readData;  
	HashMap<String, HashMap<String, Integer>> property2Index;
	
	private PlyReader(){
		readData = new HashMap();
		property2Index = new HashMap<>();
	}

	private void readFile(String file) throws IOException{
		BufferedReader reader = new BufferedReader(new FileReader(file));
		
		String line = reader.readLine();
		String[] s = line.split("\\s+");
		if(!s[0].equalsIgnoreCase("ply")){
			System.out.println("Not a ply File: first line: \n" + line);
			reader.close();
			return;
		}
		
		line = reader.readLine();
		s = line.split("\\s+");
		
		if(!(s[0].equalsIgnoreCase("format")
				&&s[1].equalsIgnoreCase("ascii") 
				&& s[2].equalsIgnoreCase("1.0"))){
			System.out.println("Unknown Format: \n" + line);
			reader.close();
			return;
		}
		

		
		LinkedList<Element> elementList = new LinkedList<>();
		try{
			readHeader(reader, elementList);
			readBody(reader, elementList);
			
		}catch(NullPointerException e){
			System.out.println("Malformed ply file! no end_header tag");
			reader.close();
			return;
		}
		
		
		
		reader.close();
	}

	private void readBody(BufferedReader reader,
			LinkedList<Element> elementList) throws IOException {
		String line;
		String[] s;
		for(Element e: elementList){
			ArrayList<Float>[] data = (ArrayList<Float>[]) new ArrayList[e.numberOfElements];
			
			for(int i = 0; i < e.numberOfElements; i++){
				line = reader.readLine();
				s = line.split("\\s+");
				if(s.length != e.properties.size()){
					throw new NullPointerException();
				}
				
				data[i] = (new ArrayList<Float>());
				for(String number: s){
					data[i].add(Float.parseFloat(number));
				}
			}
			
			readData.put(e.name, data);
			property2Index.put(e.name, e.properties);
		}
	}

	private void readHeader(BufferedReader reader,
			LinkedList<Element> elementList) throws IOException {
		String line;
		String[] s;
		while(!(line = reader.readLine()).equalsIgnoreCase("end_header")) {
			s = line.split("\\s+");
			
			if(s[0].equalsIgnoreCase("comment")){
				System.out.println(line);
				continue;
			}
			
			else if(s[0].equalsIgnoreCase("element")){
				Element e = new Element();
				e.name = s[1];
				e.numberOfElements = Integer.parseInt(s[2]);
				elementList.push(e);
			}
			
			else if(s[0].equalsIgnoreCase("property") &&
					(s[1].equalsIgnoreCase("float")||
					s[1].equalsIgnoreCase("double"))){
				elementList.peek().properties.put(s[2],elementList.peek().properties.size());
			}
			else{
				System.out.println("Command not supported: This is a very basic reader.... \n" +line);
			}

		}
	}
	
	public static PointCloud readPointCloud(String file, boolean normalize) throws IOException{
		PlyReader r = new PlyReader();
		r.readFile(file);
		
		ArrayList<Float>[] data = r.readData.get("vertex");
		int x = r.property2Index.get("vertex").get("x");
		int y = r.property2Index.get("vertex").get("y");
		int z = r.property2Index.get("vertex").get("z");
		int nx = r.property2Index.get("vertex").get("nx");
		int ny = r.property2Index.get("vertex").get("ny");
		int nz = r.property2Index.get("vertex").get("nz");
		
		PointCloud pc = new PointCloud();
		for(ArrayList<Float> point : data){
			pc.points.add(
					new Point3f(point.get(x),
							point.get(y),
							point.get(z)));
			pc.normals.add(
					new Vector3f(point.get(nx),
							point.get(ny),
							point.get(nz)));
		}
		
		if(normalize){
			pc.normalize();
		}
		
		return pc;
		
	}
	
	public static void main(String[] arg) throws IOException{
		PlyReader r = new PlyReader();
		PointCloud pc = PlyReader.readPointCloud("objs/angel_points.ply", true);
		
		MyDisplay display = new MyDisplay();
		display.addToDisplay(new GLPointCloud(pc));

	}
	
	
	private class Element{
		String name = "";
		HashMap<String, Integer> properties = new HashMap<>();
		int numberOfElements = -1;
	}
}
