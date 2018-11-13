import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;

public class CSVWriter {

	public static void main(String[] args) throws FileNotFoundException {
		CSVWriter writer = new CSVWriter();
	}
	
	public CSVWriter() throws FileNotFoundException {
		// CSV files to parse
		HashMap<String, String> csvFiles = new HashMap<String, String>();
		
		// Working directory
		String wd = "/Users/zacharysnoek/Programming/java/course-schedule-parser/csv/";
		
		CSVParser p = new CSVParser(wd);

		// Put CSV files to parse
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
		
		// Create new file -- won't take absolute/relative path... oh well
        PrintWriter pw = new PrintWriter(new File("FA10-SP19.csv"));
        StringBuilder sb = new StringBuilder();
        
        // Write headers
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
        
        // Loop through all CSV files
		for (String f : csvFiles.keySet()) {
			ArrayList<Class> c = p.parse(f, csvFiles.get(f));
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
}
