package test;

import java.util.Arrays;
import model.DataAccess;
import java.sql.SQLException;
import model.EmployeeInfo;
import model.DepartmentInfo;
import java.util.List;


/**
 *
 * @author Jean-Michel Busca
 */
public class Test {

    /**
     * @param args the command line arguments
     *
     * @throws java.lang.Exception
     */
    public static void main(String[] args) throws Exception {
        DataAccess data = null;
        
        // work around Netbeans bug
        if (args.length == 2) {
          args = Arrays.copyOf(args, 3);
          args[2] = "";
        }

        // create a data access object
        //data = new DataAccess(args[0], args[1], args[2]);

        // access the database using high-level Java methods
        // ...
        // close the data access object when done
        
        try {
            // create a data access object
            data = new DataAccess(args[0], args[1], args[2]);

            // access the database using high-level Java methods
            
            // Call the raiseSalary method to raise the salary of employees with a specified job
            //String jobToRaise = "CLERK"; // Replace with the job you want to target
            //float raiseAmount = 1;    // Replace with the amount by which to raise the salary

            //boolean success = data.raiseSalary(jobToRaise, raiseAmount);

            //if (success) {
            //   System.out.println("Salary raised successfully.");
            //} else {
            //    System.out.println("No employees with the specified job found.");
            //}
            
            // Retrieve a list of employees using the getEmployees method
            //List<EmployeeInfo> employees = data.getEmployees();

            // Access the database using high-level Java methods
            // Print or process the retrieved employee data
            //for (EmployeeInfo employee : employees) {
            //    System.out.println("Employee ID: " + employee.getId());
            //    System.out.println("Employee Name: " + employee.getName());
            //    System.out.println("Employee Salary: " + employee.getSalary());
            //    System.out.println("-----------------------");
            //}
            
            //List<DepartmentInfo> departments = data.getDepartments(null,"RESEARCH","DALLAS");
            
            //for (DepartmentInfo dapartment : departments) {
            //    System.out.println("D ID: " + dapartment.getId());
            //    System.out.println("D Name: " + dapartment.getName());
            //    System.out.println("D LOC: " + dapartment.getLocation());
            //    System.out.println("-----------------------");
            //}
            String query1 = "SELECT EID, ENAME, SAL FROM EMP";
            String query2 = "UPDATE EMP SET SAL = SAL + 100";
            
            System.out.println("Before");
            List<String> exQuery1 = data.executeStatement(query1);
            
            for (String line : exQuery1) {
                String[] parts = line.split("\t");
                for (String part : parts) {
                    System.out.print(part + "\t");
                }
                System.out.println(); // Move to the next line
            }
            
            System.out.println("Value updated");
            List<String> exQuery2 = data.executeStatement(query2);
            
            for (String line : exQuery2) {
                String[] parts = line.split("\t");
                for (String part : parts) {
                    System.out.print(part + "\t");
                }
                System.out.println(); // Move to the next line
            }
            
            System.out.println("After");
            List<String> exQuery3 = data.executeStatement(query1);
            
            for (String line : exQuery3) {
                String[] parts = line.split("\t");
                for (String part : parts) {
                    System.out.print(part + "\t");
                }
                System.out.println(); // Move to the next line
            }
            
        } finally {
            // close the data access object when done
            if (data != null) {
                data.closeConnection();
            }
        }
        
       
    }
}

