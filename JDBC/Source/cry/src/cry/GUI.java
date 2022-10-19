package cry;

import javax.swing.*;




class GUI extends JFrame {

	public JTextArea queryres;

	private static final long serialVersionUID = 1L;

	public GUI() {

		createFileMenu();
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setVisible(true);



		queryres = new JTextArea();

		queryres.setEditable(false);

		JScrollPane unsortedScroll = new JScrollPane(queryres);


		add(unsortedScroll);

		
		setSize(700, 600);
		setLocation(100, 100);
		setTitle("Query results");
		setVisible(true);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

	}
	//open file
	private void createFileMenu() {
		JMenuItem item;
		JMenuBar menuBar = new JMenuBar();
		JMenu fileMenu = new JMenu("File");


		FileMenuHandler fmh = new FileMenuHandler(this);


		item = new JMenuItem("Open"); 
		item.addActionListener(fmh);
		fileMenu.add(item);

		fileMenu.addSeparator(); 

		item = new JMenuItem("Quit"); 
		item.addActionListener(fmh);
		fileMenu.add(item);



		setJMenuBar(menuBar);
		menuBar.add(fileMenu);


	}
	//filing the gui up from the results
	public void fillGUI(qlist pp) {
		query x = P1.pp.head.next;
		for(int i = 0; i < P1.pp.length ; i++) {
			x.results();
			x = x.next;
		}
		
	}

}
