package cry;

import java.io.*;
import java.util.*;
import javax.swing.JFileChooser;
//opens a txt file to parse the query
public class openFile {
	@SuppressWarnings("static-access")
	public openFile() throws IOException {
		
//read in txt file
		JFileChooser fileChooser = new JFileChooser();
		fileChooser.showOpenDialog(null);
		File myFile = fileChooser.getSelectedFile();
		String absolute = myFile.getAbsolutePath();
		BufferedReader buffReadIn = new BufferedReader(new FileReader(absolute));
		String readInLine;
		String hateJava = "";
		
//buffered reader to place all in one string
		while ((readInLine = buffReadIn.readLine()) != null) {
			hateJava = hateJava + readInLine + " ";
		}

		buffReadIn.close();
		
		//split the string based on ; which signifies end of query
		String[] tokems = hateJava.split(";");


		for(int i = 0; i < tokems.length ; i++ ) {
			String[] db = tokems[i].split(" ");
			for(int j = 0; j < db.length; j++) {
				if(db[j].equalsIgnoreCase("WideWorldImporters")) {
					P1.pp.add(tokems[i], db[j]);
					//System.out.println(db[j] +"ahh"+ tokems[i]);
					break;
				}
				if(db[j].equalsIgnoreCase("WideWorldImportersDW")) {
					P1.pp.add(tokems[i], db[j]);
					//System.out.println(db[j] + tokems[i]);
					break;
				}
				if(db[j].equalsIgnoreCase("AdventureWorks2017")) {
					P1.pp.add(tokems[i], db[j]);
					//System.out.println(db[j] + tokems[i]);
					break;
				}
				if(db[j].equalsIgnoreCase("AdventureWorksDW2017")) {
					P1.pp.add(tokems[i], db[j]);
					//System.out.println(db[j] + tokems[i]);
					break;
				}
				if(db[j].equalsIgnoreCase("Northwinds2020TSQLV6")) {
					P1.pp.add(tokems[i], db[j]);
					//System.out.println(db[j]+ tokems[i]);
					break;
				}
				
				
			}
			//System.out.println(i);
			//System.out.println(tokems[i]);
			//P1.pp.add(tokems[i], db[1]);
		}
		/*query x = P1.pp.head.next;
		for(int i = 0; i < P1.pp.length ; i++) {
			x.results();
			x = x.next;
		}*/
		P1.qGUI.fillGUI(P1.pp);

	}
}
