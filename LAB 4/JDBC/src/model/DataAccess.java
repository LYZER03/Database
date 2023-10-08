package model;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.sql.ResultSetMetaData;

public class DataAccess {

    private Connection connection;

    public DataAccess(String url, String login, String password) throws
        SQLException {
      connection = DriverManager.getConnection(url, login, password);
      System.out.println("connected to " + url);
    }
    
    // Method to get a list of EmployeeInfo objects
    public List<EmployeeInfo> getEmployees() throws SQLException {
        List<EmployeeInfo> employees = new ArrayList<>();

        // SQL query without a prepared statement (be cautious of SQL injection here)
        String sql = "SELECT EID, ENAME, SAL FROM EMP";

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(sql)) {
            while (resultSet.next()) {
                int id = resultSet.getInt("EID");
                String name = resultSet.getString("ENAME");
                float salary = resultSet.getFloat("SAL");

                // Create an EmployeeInfo object and add it to the list
                EmployeeInfo employee = new EmployeeInfo(id, name, salary);
                employees.add(employee);
            }
        }

        return employees;
    }
    
    // Method to raise the salary of employees with a specified job
    public boolean raiseSalary(String job, float amount) throws SQLException {
        // SQL query without a prepared statement (be cautious of SQL injection here)
        String sql = "UPDATE EMP SET SAL = SAL + " + amount + " WHERE JOB = '" + job + "'";

        try (Statement statement = connection.createStatement()) {
            // Execute the SQL update
            int rowsAffected = statement.executeUpdate(sql);

            // Check if any rows were affected (salary updated)
            return rowsAffected > 0;
        }
    }
    
    // Method to get a list of EmployeeInfo objects using a prepared statement
    public List<EmployeeInfo> getEmployeesPS() throws SQLException {
        List<EmployeeInfo> employees = new ArrayList<>();

        // SQL query with a prepared statement
        String sql = "SELECT EID, ENAME, SAL FROM EMP WHERE JOB = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            // Set the job parameter for the prepared statement
            statement.setString(1, "CLERK"); // Replace with the job you want to target

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    int id = resultSet.getInt("EID");
                    String name = resultSet.getString("ENAME");
                    float salary = resultSet.getFloat("SAL");

                    // Create an EmployeeInfo object and add it to the list
                    EmployeeInfo employee = new EmployeeInfo(id, name, salary);
                    employees.add(employee);
                }
            }
        }

        return employees;
    }
    
    // Method to raise the salary of employees with a specified job using a prepared statement
    public boolean raiseSalaryPS(String job, float amount) throws SQLException {
        // SQL query with a prepared statement to update salary
        String sql = "UPDATE EMP SET SAL = SAL + ? WHERE JOB = ?";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            // Set parameters for the prepared statement
            statement.setFloat(1, amount);
            statement.setString(2, job);

            // Execute the SQL update
            int rowsAffected = statement.executeUpdate();

            // Check if any rows were affected (salary updated)
            return rowsAffected > 0;
        }
    }

    // Method to retrieve departments matching the specified criteria using statements
    public List<DepartmentInfo> getDepartments(Integer id, String name, String location) throws SQLException {
        List<DepartmentInfo> departments = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM DEPT WHERE 1=1");

        if (id != null) {
            sql.append(" AND DID = ").append(id);
        }

        if (name != null) {
            sql.append(" AND DNAME = '").append(name).append("'");
        }

        if (location != null) {
            sql.append(" AND DLOC = '").append(location).append("'");
        }

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(sql.toString())) {

            while (resultSet.next()) {
                int departmentId = resultSet.getInt("DID");
                String departmentName = resultSet.getString("DNAME");
                String departmentLocation = resultSet.getString("DLOC");

                DepartmentInfo department = new DepartmentInfo(departmentId, departmentName, departmentLocation);
                departments.add(department);
            }
        }

        return departments;
    }
    
    // Method to execute a SELECT query and return the result as a list of strings
    public List<String> executeQuery(String query) throws SQLException {
        List<String> resultList = new ArrayList<>();

        try (Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(query)) {

            ResultSetMetaData metaData = resultSet.getMetaData();
            int columnCount = metaData.getColumnCount();

            // Append the header row to the result
            StringBuilder header = new StringBuilder();
            for (int i = 1; i <= columnCount; i++) {
                header.append(metaData.getColumnName(i));
                if (i < columnCount) {
                    header.append(", ");
                }
            }
            resultList.add(header.toString());

            // Append each tuple to the result
            while (resultSet.next()) {
                StringBuilder tuple = new StringBuilder();
                for (int i = 1; i <= columnCount; i++) {
                    tuple.append(resultSet.getString(i));
                    if (i < columnCount) {
                        tuple.append(", ");
                    }
                }
                resultList.add(tuple.toString());
            }
        }

        return resultList;
        
    }
    
    // Method to execute any SQL statement and return the result or the update count
    public List<String> executeStatement(String statement) throws SQLException {
        List<String> resultList = new ArrayList<>();

        // Check if the statement is a query or an update
        boolean isQuery = statement.trim().toLowerCase().startsWith("select");

        try {
            if (isQuery) {
                // Execute a query using a prepared statement
                try (PreparedStatement preparedStatement = connection.prepareStatement(statement);
                    ResultSet resultSet = preparedStatement.executeQuery()) {
                    
                    ResultSetMetaData metaData = resultSet.getMetaData();
                    int columnCount = metaData.getColumnCount();

                    // Append the header row to the result
                    StringBuilder header = new StringBuilder();
                    for (int i = 1; i <= columnCount; i++) {
                        header.append(metaData.getColumnName(i));
                        if (i < columnCount) {
                            header.append("\t");
                        }
                    }
                    resultList.add(header.toString());
                    
                    // Process the result set and add rows to the result list
                    while (resultSet.next()) {
                        StringBuilder row = new StringBuilder();
                        for (int i = 1; i <= resultSet.getMetaData().getColumnCount(); i++) {
                            row.append(resultSet.getString(i));
                            if (i < resultSet.getMetaData().getColumnCount()) {
                                row.append("\t");
                            }
                        }
                        resultList.add(row.toString());
                    }
                }
            } else {
                // Execute an update statement using a prepared statement
                try (PreparedStatement preparedStatement = connection.prepareStatement(statement)) {
                    int updateCount = preparedStatement.executeUpdate();
                    resultList.add(String.valueOf(updateCount)); // Add update count to the result list
                }
            }
        } catch (SQLException e) {
            // Handle any SQL exception and add the error message to the result list
            resultList.add("Error: " + e.getMessage());
        }

        return resultList;
    }
    
    // Method to close the database connection
    public void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Database connection closed.");
            } catch (SQLException e) {
                // Handle any potential exceptions here
                e.printStackTrace();
            }
        }
    }
  
}
