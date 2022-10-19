package cry;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
/* class for the query, returns results and appends to the gui*/

public class query {
	String qu;
	String db;
	//this will be connected to my personal server
	String URL = "jdbc:sqlserver://mommymilkers.asuscomm.com:12001;databaseName=";
	String login = ";user=sa;password=PH@123456789";
	String connectionURL;
	query next;
	
	query(){
		qu = null;
		db = null;
	}
	//storing the query input into nodes so its easier to run as a batch 
	query(String q, String d){
		qu = q;
		db = d;
		next = null;
		
	}
	//this gets columns
	void getColumn(ResultSetMetaData rsmd) throws SQLException{
		for ( int i=1; i <= rsmd.getColumnCount(); i++){
			System.out.print(rsmd.getColumnName(i) + "\t\t|");
			P1.qGUI.queryres.append(rsmd.getColumnName(i) + "\t\t|");
		}

		System.out.println("");
		P1.qGUI.queryres.append("\n");
	}
	//returns the results and appends to gui
	void results(){
		connectionURL = URL + db + login;
    	try (Connection con = DriverManager.getConnection(connectionURL); Statement stmt = con.createStatement();){
    		System.out.println("Connected to " + db);
    		P1.qGUI.queryres.append("\n" + "Connected to " + db + "\n");
    		ResultSet rs = stmt.executeQuery(qu);
    		ResultSetMetaData rsmd = rs.getMetaData();
    		
    		getColumn(rsmd);
    		
    		// Getting the Results
    		while (rs.next()){
    			for (int i = 1; i <= rsmd.getColumnCount(); i++){;
    				System.out.print(rs.getString(i) + "\t\t");
    				P1.qGUI.queryres.append(rs.getString(i) + "\t\t");
    			}
    			System.out.println();
    			P1.qGUI.queryres.append("\n");
    		}
    	}
        catch (SQLException e) {
        	e.printStackTrace();
        }
	}

}
