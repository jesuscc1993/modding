package fileWritters;

import java.io.FileWriter;
import java.io.PrintWriter;

import javax.swing.JOptionPane;

public class ChatUIWriter {
	private int windowHeight;
	private int chatWidth;

	public int getChatWidth() {
		return chatWidth;
	}
	public void setChatWidth(int chatWidth) {
		this.chatWidth = chatWidth;
	}
	public void setWindowHeight(int height) {
		this.windowHeight = height;
	}	
	public int getWindowHeight() {
		return windowHeight;
	}

	public boolean write() {
		boolean success = false;
		
		try {
			// Write file
			FileWriter fileWriter = new FileWriter("data/UI_nori/ChatUI.ucf");
			PrintWriter printWriter = new PrintWriter(fileWriter);
			printWriter.println("iViewDimX	= " + (chatWidth));
			printWriter.println("iViewDimY	= 22");
			printWriter.println("");
			printWriter.println("iEditBoxDimX	= " + (chatWidth - 76));
			printWriter.println("iEditBoxDimY	= 18");
			printWriter.println("iEditBoxCoordX	= 58");
			printWriter.println("iEditBoxCoordY	= 3");
			printWriter.println("iEditBoxMinDimX	= " + (chatWidth - 194));
			printWriter.println("iEditBoxMinDimY	= 18");
			printWriter.println("iEditBoxMinCoordX	= 176");
			printWriter.println("iEditBoxMinCoordY	= 3");
			printWriter.println("");
			printWriter.println("iComboBoxDimX	= 116");
			printWriter.println("iComboBoxDimY	= 18");
			printWriter.println("iComboBoxCoordX	= 58");
			printWriter.println("iComboBoxCoordY	= 3");
			printWriter.println("");
			printWriter.println("iEmoticonBtnCoordX	= 5");
			printWriter.println("iEmoticonBtnCoordY	= 5");
			printWriter.println("iMemoBtnCoordX		= 22");
			printWriter.println("iMemoBtnCoordY		= 5");
			printWriter.println("iWhisperBtnCoordX	= 40");
			printWriter.println("iWhisperBtnCoordY	= 5");
			printWriter.println("iCloseBtnCoordX		= " + (chatWidth - 17));
			printWriter.println("iCloseBtnCoordY		= 6");
			printWriter.println("");
			printWriter.println("iStatViewDimX	= " + (chatWidth - 2));
			printWriter.println("iStatViewDimY	= 78");
			printWriter.println("");
			printWriter.println("iStatViewMaxDimX	= " + (chatWidth - 2));
			printWriter.println("iStatViewMaxDimY	= " + windowHeight);
			printWriter.println("");
			printWriter.println("iModeButtonDimX	= 65");
			printWriter.println("iModeButtonDimY	= 18");
			printWriter.println("");
			printWriter.println("iDummyModeButtonDimX	= 64");
			printWriter.print("iDummyModeButtonDimY	= 18");
			fileWriter.close();
			
			success = true;
			
		} catch (Exception exception) {
			JOptionPane.showMessageDialog(null, exception.getMessage() + "\nAre you running the launcher from the game's root folder?",
					"Could not save changes", JOptionPane.ERROR_MESSAGE);
		}
		
		return success;
	}
}
