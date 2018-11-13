import java.util.HashMap;

public class Class {
	String title;
	String status;
	String creditAmount;
	String capacity;
	String actual;
	String instructor;
	String year;
	
	public Class(String title, String status, String creditAmount,
			String capacity, String actual, String instructor, String year) {
		this.title = title;
		this.status = status;
		this.creditAmount = creditAmount;
		this.capacity = capacity;
		this.actual = actual;
		this.instructor = instructor;
		this.year = year;
	}
	
	public String getTitle() {
		return title.replace(",", "");
	}
	
	public String getStatus() {
		return status;
	}
	
	public String getCredits() {
		return creditAmount;
	}
	
	public String getCapacity() {
		return capacity;
	}
	
	public String getActual() {
		return actual;
	}
	
	public String getInstructor() {
		return instructor.replace(",", "");
	}
	
	public String getYear() {
		return year;
	}
	
	public String toString() {
		String str = "Title: " + title.toUpperCase() + "\n";
		str += "Status: " + status + "\n";
		str += "Credits: " + creditAmount + "\n";
		str += "Capacity: " + capacity + "\n";
		str += "Actual: " + actual + "\n";
		str += "Instructor: " + instructor + "\n";
		str += "Year: " + year + "\n";
		return str;
	}
}