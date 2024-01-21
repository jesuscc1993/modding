//====================================================================//
// Copy                                                               //
//                                                                    //
//   Copy files and folders.                                          //
//                                                                    //
//--------------------------------------------------------------------//
//                          2014 - MetalTxus                          //
//====================================================================//

package utilities;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

public class FileDealer {
	public static void copyFile(String orgFile, String newFile) {
		Path source = Paths.get(orgFile);
		Path target = Paths.get(newFile);
		try {
			Files.copy(source, target);
		} catch (IOException e) {
			System.out.println("File " + target + " already exists.");
		}
	}
	
	public static ArrayList<String> readFile(String fileName) {
		ArrayList<String> content = new ArrayList<String>();
		try {
			File file = new File(fileName);
			if (!file.exists()) {
				return null;
			} else {
				FileReader fileReader = new FileReader(file);
				BufferedReader bufferedReader = new BufferedReader(fileReader);

				String contentLine;
				while ((contentLine = bufferedReader.readLine()) != null) {
					content.add(contentLine);
				}
				fileReader.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return content;
	}
}
