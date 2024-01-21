//====================================================================//
// Alerts                                                             //
//                                                                    //
//   Show the user messages and errors                                //
//                                                                    //
//--------------------------------------------------------------------//
//                          2014 - MetalTxus                          //
//====================================================================//

package utilities;

import javax.swing.JOptionPane;

public class Alert {
	/**
	 * Shows a message to the user
	 * 
	 * @param title Message title
	 * @param msg Message text
	 */
	public static void alertMessage(String title, String str) {
		JOptionPane.showMessageDialog(null, str, title, JOptionPane.PLAIN_MESSAGE);
	}

	/**
	 * Alerts an exception to the user
	 * 
	 * @param ev Exception event
	 */
	public static void alertException(Exception ev) {
		JOptionPane.showMessageDialog(null, ev.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
	}
}
