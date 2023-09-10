## Description:

Adds a few teleport commands; for convenience.
Do **NOT** use between regions, as teleporting to the same coordinates on different regions will likely end up badly.

## Features:

- Locations are stored in the game save, so they persist between game sessions.
- **(NEW)** Named locations can be saved, allowing for several to be saved.
- **(NEW)** Allows teleportation frontward / backward / upward / downward; useful when stuck.
- A message is shown when a player location is saved, to indicate success.
- A load screen is shown during load after teleportation.

## List of commands:

- `savePosition()`  
  `savePos()`  
   Saves your current position.

  > Usage: `savePosition`

- `saveNamedPosition( positionName: String )`  
  `saveNamedPos( positionName: String )`  
   Saves a position with a given name.

  > Usage: `saveNamedPosition("market")`

- `restorePosition()` / `restorePos()`  
   Teleports you to the last saved unnamed position.

  > Usage: `restorePosition`

- `restoreNamedPosition( positionName: String )`  
  `restoreNamedPos( positionName: String )`  
   Teleports you to the saved position with the given name.

  > Usage: `restoreNamedPosition("market")`

- `teleportFrontward( distance : float )`  
  `tpFront( distance : float )`  
   Teleports you forward by the specified distance.

  > Usage: `teleportFrontward` / `teleportFrontward(5)`

- `teleportBackward( distance : float )`  
  `tpBack( distance : float )`  
   Teleports you backward by the specified distance.

  > Usage: `teleportBackward` / `teleportBackward(5)`

- `teleportUp( distance : float )`  
  `tpUp( distance : float )`  
   Teleports you up by the specified distance.

  > Usage: `teleportUp` / `teleportUp(10)`

- `teleportDown( distance : float )`  
  `tpDown( distance : float )`  
   Teleports you down by the specified distance.

  > Usage: `teleportDown` / `teleportDown(10)`

- `undoTeleport()`  
  `undoTp()`  
   Teleports you to the player position previous to the latest teleportation.

  > Usage: `undoTeleport`

- `bringRoach()`  
   Teleports Roach wherever you are.

  > Usage: `bringRoach`

- `goToRoach()`  
   Teleports you to wherever Roach is.

  > Usage: `goToRoach`

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
