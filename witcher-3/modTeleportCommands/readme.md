## Description:

Adds a few teleport commands; for convenience.

## Features:

- Saved locations persist between game sessions.
- A message is shown when a player location is saved, to indicate success.
- A load screen is shown during load after teleportation.

## List of commands:

- `savePosition()` / `savePos()`  
  Saves your current player position.

- `restorePosition()` / `restorePos()`  
  Teleports you to the last saved player position.

- `teleportFrontward( distance : float )` / `tpFront( distance : float )`  
  Teleports you forward by the specified distance.

- `teleportBackward( distance : float )` / `tpBack( distance : float )`  
  Teleports you backward by the specified distance.

- `teleportUp( distance : float )` / `tpUp( distance : float )`  
  Teleports you up by the specified distance.

- `teleportDown( distance : float )` / `tpDown( distance : float )`  
  Teleports you down by the specified distance.

- `undoTeleport()` / `undoTp()`  
  Teleports you to the player position previous to the latest teleportation.

- `bringRoach()`  
  Teleports Roach wherever you are.

- `goToRoach()`  
  Teleports you to wherever Roach is.

## Installation:

Extract `modTeleportCommands` to your `"/The Witcher 3/mods"` folder (create the `mods` folder if it's missing).

## Uninstallation:

Delete the `"/The Witcher 3/mods/modTeleportCommands"` folder.

## Planned features:

- Add keyboard hotkeys for the save / restore position commands.

## Hotkeys <span style="color:red">**(not implemented yet; don't bother with this)**</span>:

In order to enable hotkeys, add the following lines to each section in file input.settings:

```
[Boat]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[BoatPassenger]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[Diving]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[Exploration]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[Exploration_Replacer_Ciri]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[Horse]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[Horse_Replacer_Ciri]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[JumpClimb]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)

[Swimming]
IK_F3=(Action=SavePosition)
IK_F4=(Action=RestorePosition)
```
