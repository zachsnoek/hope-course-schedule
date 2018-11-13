import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;

public class Parser {
	static HashMap<String, String> csvFiles = new HashMap<String, String>();
	
	public static void main(String[] args) throws FileNotFoundException {
		csvFiles.put("sp19", "19SP");
		csvFiles.put("fa18", "18FA");
		csvFiles.put("sp18", "18SP");
		csvFiles.put("fa17", "17FA");
		csvFiles.put("sp17", "17SP");
		csvFiles.put("fa16", "16FA");
		csvFiles.put("sp16", "16SP");
		csvFiles.put("fa15", "15FA");
		csvFiles.put("sp15", "15SP");
		csvFiles.put("fa14", "14FA");
		csvFiles.put("sp14", "14SP");
		csvFiles.put("fa13", "13FA");
		csvFiles.put("sp13", "13SP");
		csvFiles.put("fa12", "12FA");
		csvFiles.put("sp12", "12SP");
		csvFiles.put("fa11", "11FA");
		csvFiles.put("sp11", "11SP");
		csvFiles.put("fa10", "10FA");
		csvFiles.put("sp10", "10SP");
		Parser p = new Parser();
	}
    
	public Parser() throws FileNotFoundException {
        PrintWriter pw = new PrintWriter(new File("main.csv"));
        StringBuilder sb = new StringBuilder();
        sb.append("Year");
        sb.append(',');
        sb.append("Title");
        sb.append(',');
        sb.append("Instructor");
        sb.append(',');
        sb.append("Credits");
        sb.append(',');
        sb.append("Actual");
        sb.append(',');
        sb.append("Capacity");
        sb.append('\n');
        pw.write(sb.toString());
        
		for (String f : csvFiles.keySet()) {
			ArrayList<Class> c = parse(f, csvFiles.get(f));
			sb = new StringBuilder();
			for (Class cl : c) {
				sb.append(cl.getYear());
				sb.append(',');			
				sb.append(cl.getTitle());
				sb.append(',');
				sb.append(cl.getInstructor());
				sb.append(',');
				sb.append(cl.getCredits());
				sb.append(',');
				sb.append(cl.getActual());
				sb.append(',');
				sb.append(cl.getCapacity());
				sb.append('\n');
			}
			pw.write(sb.toString());
		}
        
		pw.close();
        System.out.println("Done!");
    }
    
	public ArrayList<Class> parse(String file, String year) {
		ArrayList<Class> classes = new ArrayList<Class>();
		
		String workingDir = "/Users/zacharysnoek/Programming/java/course-schedule-parser/csv/";
	    String l = "";
	    
	    String fa18 = workingDir + file + ".csv";
	    
	    try (BufferedReader br = new BufferedReader(new FileReader(fa18))) {
	
	    		while ((l = br.readLine()) != null) {
	            ArrayList<String> line = parseLine(l);
	            
	            try {
	            		String stat = line.get(0).trim();
	        	   		if (stat.equals("IN PROGRESS") || stat.equals("CANCELLED") || stat.equals("CLOSED") || stat.equals("COMPLETED") || stat.equals("PERMISSION")) {
	        	   			
	        	   			String title = line.get(1);
	        	   			String status = line.get(0);
	        	   			String creditAmount = line.get(6);
	        	   			String capacity = line.get(17);
	        	   			String actual = line.get(18);
	        	   			String instructor = line.get(21);
	        	   			
	        	   			Class c = new Class(title, status, creditAmount, capacity, actual, instructor, year);
	        	   			
	        	   			classes.add(c);
	        	   		}
	            } catch (IndexOutOfBoundsException e) {
	            		//e.printStackTrace();
	            }
	        }
	    } catch (IOException e) {
	    		//e.printStackTrace();
	    }
	    return classes;
	}
	
    public ArrayList<String> parseLine(String line) {
		char[] input = line.toCharArray();
		StringBuilder sb = new StringBuilder();
		ArrayList<String> output = new ArrayList<String>();
		
		boolean inQuotes = false;
		
		for (char c : input) {
			if (c == '"' && inQuotes == false) {
				inQuotes = true;
			} else {
				if (inQuotes == true) {
					if (c == '"') {
						inQuotes = false;
					} else {
						sb.append(c);
					}
				} 
				else if (c == ',') {
					output.add(sb.toString());
					sb = new StringBuilder();
				} else {
					sb.append(c);
				}
			}
		}
		
		return output;
    }
}