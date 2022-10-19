package cry;

public class qlist {
	
	static	query head;
	static query tail;
	public static int length;
	
	qlist () {
		query dq = new query();
		head = dq;
		tail = dq;
		length = 0;
	}

	  static void add (String q, String d) {
		query nq = new query(q, d);
		tail.next = nq;
		tail = nq;
		length++;
		}
		void clear () {
			query dq = new query();
			head = dq;
			tail = dq;
			length = 0;
		}

}
