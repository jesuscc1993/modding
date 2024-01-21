package gui;

import entities.DraggableFrame;
import entities.SkinnedButton;
import fileWritters.ChatUIWriter;
import fileWritters.ResolutionRegistryFile;

import javax.swing.ImageIcon;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.UIManager;
import javax.swing.border.EmptyBorder;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import java.awt.Color;
import java.awt.EventQueue;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.util.List;

import static java.lang.Integer.parseInt;
import static utilities.Alert.alertException;
import static utilities.Alert.alertMessage;
import static utilities.FileDealer.copyFile;
import static utilities.FileDealer.readFile;


/**
 * @author MetalTxus
 * 
 */
public class Launcher extends DraggableFrame {
    private static final int MEDIUM_HEIGHT = 1024;
    private static final int SMALL_HEIGHT = 800;

    private JTextField windowWidthField, windowHeightField, chatWidthField;
	private JCheckBox fullscreenCheckbox;
    private boolean changesPending = false;

	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable () {
			public void run () {
				new Launcher().setVisible(true);
			}
		});
	}

	private void copyResolutionFiles () {
		String ROOT_PATH = "data/UI_nori/";
		String FOLDER_PATH = ROOT_PATH + "LoadingImg_1024";
		String[] FILE_NAMES = {
            "CharCreateUI_1024.ucf",
            "InstructionUI_1024.ucf",
            "LoginUI_1024.ucf",

            "CharCreateUI_1024.nri",
            "FortuneBg_1024.nri",
            "InstructionUI_1024.nri",
            "intro_img/intro_base1024.nri",
            "intro_img/intro_Load1024.nri",

            "map_loading_1024.jpg"
		};

		String width = windowWidthField.getText();
		if (parseInt(width) != SMALL_HEIGHT && parseInt(width) != MEDIUM_HEIGHT) {
			// Copy loading images folder
			File originalFolder = new File(parseInt(width) > SMALL_HEIGHT ? FOLDER_PATH : FOLDER_PATH.replaceAll(Integer.toString(MEDIUM_HEIGHT), Integer.toString(SMALL_HEIGHT)));
			File newFolder = new File(FOLDER_PATH.replaceAll(Integer.toString(MEDIUM_HEIGHT), width));
			if (!newFolder.exists()) {
				newFolder.mkdir();

				// Copy loading images
				String[] images = originalFolder.list();
                if (images != null) {
                    for (String image : images) {
                        copyFile(originalFolder + "\\" + image, newFolder + "\\" + image);
                    }
                }
            }

			// Copy UI setting files
            for (String file : FILE_NAMES) {
                String orgFile = parseInt(width) > SMALL_HEIGHT ? file : file.replaceAll(Integer.toString(MEDIUM_HEIGHT), Integer.toString(SMALL_HEIGHT));
                String newFile = file.replaceAll(Integer.toString(MEDIUM_HEIGHT), width);
                if (!new File(ROOT_PATH + newFile).exists()) {
                    copyFile(ROOT_PATH + orgFile, ROOT_PATH + newFile);
                }
            }
		}
	}

	private boolean saveChanges () {
		int windowWidth = parseInt(windowWidthField.getText());
		int windowHeight = parseInt(windowHeightField.getText());
		int chatWidth = parseInt(chatWidthField.getText());
		boolean fullscreenEnabled = fullscreenCheckbox.isSelected();
		
		ResolutionRegistryFile resolutionRegistryFile = new ResolutionRegistryFile();
		resolutionRegistryFile.setWindowWidth(windowWidth);
		resolutionRegistryFile.setWindowHeight(windowHeight);
		resolutionRegistryFile.setChatWidth(chatWidth);
		resolutionRegistryFile.setFullscreen(fullscreenEnabled);
		
		ChatUIWriter chatUIWriter = new ChatUIWriter();
		chatUIWriter.setWindowHeight(windowHeight);
		chatUIWriter.setChatWidth(chatWidth);
		
		boolean success = chatUIWriter.write();
		if (!success) return false;

		success = resolutionRegistryFile.write();
		if (!success) return false;
		
		success = resolutionRegistryFile.execute();		
		
		return success;
	}
	
	private void loadChanges () {
		List<String> content = readFile("custom-resolution-launcher.reg");
		if (content != null) {
            for (String contentLine : content) {
                if (contentLine.contains("\"widthPixel\"")) {
                    windowWidthField.setText("" + getValueFromRegFile(contentLine));
                }
                if (contentLine.contains("\"heightPixel\"")) {
                    windowHeightField.setText("" + getValueFromRegFile(contentLine));
                }
                if (contentLine.contains("\"Chat Width\"")) {
                    chatWidthField.setText("" + getValueFromRegFile(contentLine));
                }
                if (contentLine.contains("\"Full Screen\"")) {
                    fullscreenCheckbox.setSelected(getValueFromRegFile(contentLine) == 1);
                }
            }
        }
	}

	private Long getValueFromRegFile (String line) {
		int length = line.length();
		return Long.parseLong((line.substring(length - 8, length)), 16);
	}

	private void saveSettings () {
		try {
			if (windowWidthField.getText().length() > 0
			&& windowHeightField.getText().length() > 0
			&& chatWidthField.getText().length() > 0) {
				copyResolutionFiles();				
				
				changesPending = !saveChanges();
			} else {
				alertMessage("Error", "Required values are missing.");
			}
		} catch (Exception e) {
			alertException(e);
		}
	}

	private void setupTextField(JTextField textField) {
		textField.setHorizontalAlignment(SwingConstants.RIGHT);
		textField.setForeground(Color.WHITE);
		textField.setOpaque(false);
		textField.setBorder(null);
		textField.addMouseListener(new MouseAdapter () {
			@Override
			public void mousePressed(MouseEvent ev) {
				((JTextField) ev.getSource()).selectAll();
			}
		});
		textField.addKeyListener(new KeyAdapter () {
			@Override
			public void keyTyped(KeyEvent keyEvent) {
				try {
					JTextField source = ((JTextField) keyEvent.getSource());
					
					if (source.getText().length() > 3 && source.getSelectedText() == null) {
						keyEvent.consume();
					} else {
						changesPending = true;
					}
				} catch (NumberFormatException e) {
					keyEvent.consume();
				}
			}
		});
	}

	/**
	 * Actual UI
	 */
	public Launcher () {
        final int LAUNCHER_WIDTH = 346;
        final int LAUNCHER_HEIGHT = 324;
        final int LAUNCHER_BORDER_WIDTH = 3;

		/* FRAME INITIALIZATION */
		setTitle("Trickster Launcher");
		setIconImage(new ImageIcon(Launcher.class.getResource("/res/icon.png")).getImage());
		setBounds(100, 100, LAUNCHER_WIDTH + LAUNCHER_BORDER_WIDTH*2, LAUNCHER_HEIGHT + LAUNCHER_BORDER_WIDTH*2);
		setResizable(false);
		setUndecorated(true);
		setLocationRelativeTo(null);
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch (Exception e) {
			alertException(e);
		}
		
		/* CONTENT PANE INITIALIZATION */
        JPanel contentPane = new JPanel();
		contentPane.setBackground(new Color(69, 131, 242));
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		contentPane.setLayout(null);
		setContentPane(contentPane);

		/* SETTINGS */
		JPanel settingsPanel = new JPanel();
		settingsPanel.setBorder(null);
		settingsPanel.setOpaque(false);
		settingsPanel.setBounds(4, 137, 344, 56);
		contentPane.add(settingsPanel);
		settingsPanel.setLayout(null);

		// Width text field
		windowWidthField = new JTextField();
		setupTextField(windowWidthField);
		windowWidthField.setToolTipText("Game window width");
		windowWidthField.setBounds(108, 8, 48, 18);
		windowWidthField.setText(Integer.toString(MEDIUM_HEIGHT));
		settingsPanel.add(windowWidthField);

		// Height text field
		windowHeightField = new JTextField();
		setupTextField(windowHeightField);
		windowHeightField.setToolTipText("Game window height");
		windowHeightField.setBounds(284, 8, 48, 18);
		windowHeightField.setText("768");
		settingsPanel.add(windowHeightField);

		// Fullscreen checkbox
		fullscreenCheckbox = new JCheckBox("");
		fullscreenCheckbox.setSelected(true);
		fullscreenCheckbox.setOpaque(false);
		fullscreenCheckbox.setIcon(new ImageIcon(Launcher.class.getResource("/res/chkUnselected.png")));
		fullscreenCheckbox.setSelectedIcon(new ImageIcon(Launcher.class.getResource("/res/chkSelected.png")));
		fullscreenCheckbox.setToolTipText("Play in fullscreen mode");
		fullscreenCheckbox.setBounds(316, 31, 21, 21);
		fullscreenCheckbox.addChangeListener(new ChangeListener() {
			@Override
			public void stateChanged(ChangeEvent e) {
				changesPending = true;
			}
		});
		settingsPanel.add(fullscreenCheckbox);

		// Chat width text field
		chatWidthField = new JTextField();
		setupTextField(chatWidthField);
		chatWidthField.setToolTipText("Game chatbox width");
		chatWidthField.setBounds(108, 32, 48, 18);
		chatWidthField.setText("327");
		settingsPanel.add(chatWidthField);

		/* BUTTONS */
		JPanel pnlButtons = new JPanel();
		pnlButtons.setOpaque(false);
		pnlButtons.setBorder(null);
		pnlButtons.setBounds(6, 199, 340, 64);
		contentPane.add(pnlButtons);
		pnlButtons.setLayout(null);

		// Save and play
		SkinnedButton btnSavePlay = new SkinnedButton();
		btnSavePlay.setToolTipText("Save settings and launch game");
		btnSavePlay.setBounds(106, 0, 128, 64);
		btnSavePlay.setIcon(new ImageIcon(Launcher.class.getResource("/res/btnStart.png")));
		btnSavePlay.addMouseListener(new MouseAdapter () {
			@Override
			public void mouseReleased(MouseEvent ev) {
				if (changesPending && JOptionPane.showConfirmDialog(
						null, "Save changes?", "Save changes",
						JOptionPane.YES_NO_OPTION) == JOptionPane.OK_OPTION) {
					
					saveSettings();
				}
				
				try {
					new ProcessBuilder("Trickster.bin").start();
					System.exit(0);
				} catch (Exception exception) {
					JOptionPane.showMessageDialog(null, exception.getMessage() + "\nAre you running the launcher from the game's root folder?",
							"Could not launch the game", JOptionPane.ERROR_MESSAGE);
				}
			}
		});
		pnlButtons.add(btnSavePlay);

		// Save
		SkinnedButton btnSave = new SkinnedButton();
		btnSave.setToolTipText("Save settings");
		btnSave.setBounds(6, 18, 96, 28);
		btnSave.setIcon(new ImageIcon(Launcher.class.getResource("/res/btnSave.png")));
		btnSave.addMouseListener(new MouseAdapter () {
			@Override
			public void mouseReleased(MouseEvent ev) {
				saveSettings();
			}
		});
		pnlButtons.add(btnSave);

		// Exit
		SkinnedButton btnExit = new SkinnedButton();
		btnExit.setToolTipText("Exit without saving changes");
		btnExit.setBounds(238, 18, 96, 28);
		btnExit.setIcon(new ImageIcon(Launcher.class.getResource("/res/btnExit.png")));
		btnExit.addMouseListener(new MouseAdapter () {
			@Override
			public void mouseReleased(MouseEvent ev) {
				System.exit(0);
			}
		});
		pnlButtons.add(btnExit);

		/* FRAME BACKGROUND */
		JLabel lblBackground = new JLabel("");
		lblBackground.setBounds(0, 0, LAUNCHER_WIDTH + LAUNCHER_BORDER_WIDTH *2, LAUNCHER_HEIGHT + LAUNCHER_BORDER_WIDTH*2);
		lblBackground.setIcon(new ImageIcon(Launcher.class.getResource("/res/background.png")));
		contentPane.add(lblBackground);
		
		/* ON FRAME LOAD */
		loadChanges();
	}
}
