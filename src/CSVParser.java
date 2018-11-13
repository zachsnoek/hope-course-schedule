import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;

public class CSVParser {
	// The working directory for CSV files
    String wd;
    
	public CSVParser(String wd) throws FileNotFoundException {
		this.wd = wd;
    }
    
	public ArrayList<Class> parse(String file, String year) {
		ArrayList<Class> classes = new ArrayList<Class>();
		
		String workingDir = wd;
	    String l = "";
	    
	    String csvFile = workingDir + file + ".csv";
	    
	    try (BufferedReader br = new BufferedReader(new FileReader(csvFile))) {
	
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
	
	/*
	 * Use this function to properly handle commas in course titles and names
	 */
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