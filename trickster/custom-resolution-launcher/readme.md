# Custom Resolution Trickster Launcher

![launcher](_meta/screenshots/launcher.png)

## Description

Some time ago I took a look at Cait's Guide to Custom Screen Resolutions and Chat Bars and since I thought it would be annoying to have to repeat all the steps every time I developed this small app. It lets you manually setting any resolution for the game, automating the process of modifying the registry values. After the new resolution is set you can either launch the game from this launcher or use the default one (recommended).

⚠️ From time to time, for no apparent reason, the game crashes with the message "Access Violation" when run from this launcher. I never could find why nor how to fix it.

## Instructions

1. Make sure you have Java installed.
1. Copy `custom-resolution-launcher` to your Trickster installation
1. Execute `custom-resolution-launcher` as administrator (requires Java to run).

⚠️ Remember; if you experience any "Access Violation" crash, just switch to the default launcher after saving your changes with this one.

## Notes

- ❌ The guardian skills window will soft-lock your game on save on resolutions higher than natively supported (1024x768).
- ⚠️ Many UI elements will overlap on resolutions lower than native (1024x768).
- ⚠️ A few interfaces will look weird, given they weren't thought to be used for different resolutions and/or aspect ratios (e.g. card reading).

## Screenshots:

<details>
  <summary>Default fullscreen 1024x768 resolution on a 1280x768 screen (image just stretches)</summary>
  
  ![1024x768](_meta/screenshots/1024x768.png)
  
</details>

<details>
  <summary>Custom fullscreen 1280x768 resolution</summary>
  
  ![1280x768](_meta/screenshots/1280x768.png)
  
</details>

<details>
  <summary>Custom fullscreen 1920x1080 resolution + custom chat width of 544px</summary>
  
  ![1920x1080](_meta/screenshots/1920x1080.png)
</details>

<details>
  <summary>Custom windowed 640x480 resolution</summary>
  
  ![640x480](_meta/screenshots/640x480.png)
  
</details>

## Download

- [Download](https://github.com/jesuscc1993/modding/raw/master/trickster/custom-resolution-launcher/out/artifacts/custom_resolution_launcher_jar/custom-resolution-launcher.jar)

## Changelog

v2.1

- Added support for Trickster_NT registry keys (previously only supported Trickster_WAN)

v2.0

- ???

v1.0.1

- Changed "Play" button to only save to registry when settings are changed, instead of every time.

v1.0.0

- Initial release.
