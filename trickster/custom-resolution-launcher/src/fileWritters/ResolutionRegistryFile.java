package fileWritters;

import static utilities.Alert.alertException;

import java.io.FileWriter;
import java.io.PrintWriter;

public class ResolutionRegistryFile {
	private int windowWidth;
	private int windowHeight;
	private int chatWidth;
	private boolean fullscreen;
	
	public void setWindowWidth(int width) {
		this.windowWidth = width;
	}	
	public int getWindowWidth() {
		return windowWidth;
	}
	public void setWindowHeight(int height) {
		this.windowHeight = height;
	}	
	public int getWindowHeight() {
		return windowHeight;
	}
	public void setChatWidth(int width) {
		this.chatWidth = width;
	}	
	public int getChatWidth() {
		return chatWidth;
	}
	public void setFullscreen(boolean fullscreen) {
		this.fullscreen = fullscreen;
	}
	public boolean isFullscreen() {
		return fullscreen;
	}
	
	private String integerToEigthDigitHex(int number) {
		return String.format("%08x", number);
	}
	
	public boolean write() {
		boolean success = false;
		
		try {
			// Write file
			FileWriter fileWriter = new FileWriter("custom-resolution-launcher.reg");
			PrintWriter printWriter = new PrintWriter(fileWriter);
			printWriter.println("Windows Registry Editor Version 5.00");
			printWriter.println("");
			printWriter.println("[HKEY_CURRENT_USER\\Software\\Ntreev\\Trickster_NT\\Setup]");
			printWriter.println("\"widthPixel\"=dword:" + integerToEigthDigitHex(windowWidth));
			printWriter.println("\"heightPixel\"=dword:" + integerToEigthDigitHex(windowHeight));
			printWriter.println("\"Chat Width\"=dword:" + integerToEigthDigitHex(chatWidth));
			printWriter.println("\"Full Screen\"=dword:" + integerToEigthDigitHex(fullscreen ? 1 : 0));
			printWriter.println("");
			printWriter.println("[HKEY_CURRENT_USER\\Software\\Ntreev\\Trickster_WAN\\Setup]");
			printWriter.println("\"widthPixel\"=dword:" + integerToEigthDigitHex(windowWidth));
			printWriter.println("\"heightPixel\"=dword:" + integerToEigthDigitHex(windowHeight));
			printWriter.println("\"Chat Width\"=dword:" + integerToEigthDigitHex(chatWidth));
			printWriter.println("\"Full Screen\"=dword:" + integerToEigthDigitHex(fullscreen ? 1 : 0));
			fileWriter.close();
			
			success = true;
			
		} catch (Exception e) {
			alertException(e);
		}
		
		return success;
	}
	
	public boolean execute () {
		boolean success = false;
		
		try {
			String[] cmd = { "cmd.exe", "/C", "start /wait " + "custom-resolution-launcher.reg" };
			Process registryProcess = Runtime.getRuntime().exec(cmd);
			registryProcess.waitFor();
			
			success = true;
		} catch (Exception e) {
			alertException(e);
		}
		
		return success;
	}
}
