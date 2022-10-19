package cry;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import javax.swing.JFrame;

class FileMenuHandler implements ActionListener {
	JFrame jframe;

	public FileMenuHandler(JFrame jf) {
		jframe = jf;
	}

	public void actionPerformed(ActionEvent event) { // override
		String menuName = event.getActionCommand();
		if (menuName.equals("Open")) {
			try {
				new openFile();
			} catch (IOException e) {
				System.out.println("File not found");
			}
		} else if (menuName.equals("Quit"))
			System.exit(0);
	}
}