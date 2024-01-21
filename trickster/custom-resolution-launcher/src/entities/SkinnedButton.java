package entities;

import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JLabel;
import javax.swing.SwingConstants;

@SuppressWarnings("serial")
public class SkinnedButton extends JLabel {
	boolean beingHovered;
	boolean beingPressed;
	
	public SkinnedButton() {
		this.setVerticalAlignment(SwingConstants.TOP);
		this.addMouseListener(new MouseAdapter() {
			public void mouseEntered(MouseEvent ev) {
				beingHovered = true;
				((JLabel) ev.getSource()).setVerticalAlignment(SwingConstants.CENTER);
			}

			public void mouseExited(MouseEvent ev) {
				beingHovered = false;
				if (!beingPressed) ((JLabel) ev.getSource()).setVerticalAlignment(SwingConstants.TOP);
			}

			public void mousePressed(MouseEvent ev) {
				beingPressed = true;
				((JLabel) ev.getSource()).requestFocusInWindow();
				((JLabel) ev.getSource()).setVerticalAlignment(SwingConstants.BOTTOM);
			}

			public void mouseReleased(MouseEvent ev) {
				beingPressed = false;
				if (!beingHovered) ((JLabel) ev.getSource()).setVerticalAlignment(SwingConstants.TOP);
				else ((JLabel) ev.getSource()).setVerticalAlignment(SwingConstants.CENTER);
			}
		});
	}
}
