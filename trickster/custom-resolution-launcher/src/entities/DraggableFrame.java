package entities;

import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.JFrame;

@SuppressWarnings("serial")
public class DraggableFrame extends JFrame {
	private static final int LMB = 1;
	private int[] frameLocation;
	
	public DraggableFrame() {
		addMouseListener(new MouseListener() {
			public void mousePressed(MouseEvent mouseEvent) {
				if (mouseEvent.getButton() == LMB) {
					frameLocation = new int[] { mouseEvent.getX(), mouseEvent.getY() };
				}
			}
			
			public void mouseReleased(MouseEvent mouseEvent) {
				if (mouseEvent.getButton() == LMB) {
					frameLocation = null;
				}
			}
			
			// Unused interface methods
			@Override public void mouseClicked(MouseEvent arg0) {}
			@Override public void mouseEntered(MouseEvent arg0) {}
			@Override public void mouseExited(MouseEvent arg0) {}
		});
		
		addMouseMotionListener(new MouseAdapter() {
			public void mouseDragged(MouseEvent mouseEvent) {
				if (mouseEvent.getModifiersEx() == MouseEvent.BUTTON1_DOWN_MASK) {
					int pos_x = mouseEvent.getXOnScreen() - frameLocation[0];
					int pos_y = mouseEvent.getYOnScreen() - frameLocation[1];
					setLocation(pos_x, pos_y);
				}
			}
		});		
	}
}
