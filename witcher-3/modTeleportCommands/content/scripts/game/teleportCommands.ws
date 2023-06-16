function _bringRoach() {
  var horse : CNewNPC;
  var playerPosition : Vector;
  var playerRotation : EulerAngles;
  var vehicle : CVehicleComponent;

  horse = thePlayer.GetHorseWithInventory();

  if( horse && !thePlayer.IsSailing() )  {
    playerPosition = thePlayer.GetWorldPosition();
    playerRotation = thePlayer.GetWorldRotation();

    horse.TeleportWithRotation( playerPosition, playerRotation );

    vehicle = (CVehicleComponent)( horse.GetHorseComponent() );
    if( vehicle ) {
      vehicle.Mount(thePlayer, VMT_ImmediateUse, EVS_driver_slot);
    }
  }
}

function _goToRoach() {
  var horse : CNewNPC;
  var horsePosition : Vector;
  var horseRotation : EulerAngles;
  var vehicle : CVehicleComponent;
    
  horse = thePlayer.GetHorseWithInventory();

  if( horse && !thePlayer.IsSailing() ) {
    __savePreviousPosition();

    horsePosition = horse.GetWorldPosition();
    horseRotation = horse.GetWorldRotation();
  
    __teleportWithRotation( horsePosition, horseRotation );

    vehicle = (CVehicleComponent)( horse.GetHorseComponent() );
    if( vehicle ) {
      vehicle.Mount(thePlayer, VMT_ImmediateUse, EVS_driver_slot);
    }
  }
}

function _savePosition() {
  var currentPosition : Vector;
  var currentRotation: EulerAngles;

  currentPosition = thePlayer.GetWorldPosition();
  currentRotation = thePlayer.GetWorldRotation();

  FactsSet( "savedPositionX", (int) currentPosition.X );
  FactsSet( "savedPositionY", (int) currentPosition.Y );
  FactsSet( "savedPositionZ", (int) currentPosition.Z );

  FactsSet( "savedRotationYaw", (int) currentRotation.Yaw );

  GetWitcherPlayer().DisplayHudMessage( "Saved current position." );
}

function _restorePosition() {
  var newPosition : Vector;
  var newRotation : EulerAngles;

  __savePreviousPosition();

  newPosition = Vector(
    FactsQuerySum( "savedPositionX" ),
    FactsQuerySum( "savedPositionY" ),
    FactsQuerySum( "savedPositionZ" )
  );

  newRotation = EulerAngles( 0.f, FactsQuerySum( "savedRotationYaw" ), 0.f );
  
  __teleportWithRotation( newPosition, newRotation );
}

function _undoTeleport() {
  var newPosition : Vector;
  var newRotation : EulerAngles;

  newPosition = Vector(
    FactsQuerySum( "previousPositionX" ),
    FactsQuerySum( "previousPositionY" ),
    FactsQuerySum( "previousPositionZ" )
  );

  newRotation = EulerAngles( 0.f, FactsQuerySum( "previousRotationYaw" ), 0.f );

  __teleportWithRotation( newPosition, newRotation );
}

function __teleportWithRotation( newPosition : Vector, newRotation : EulerAngles ) {
  var contextName : name;

  __savePreviousPosition();

  contextName =
    theGame.GetCommonMapManager().GetLocalisationNameFromAreaType(
      theGame.GetCommonMapManager().GetCurrentArea()
    );

  theGame.SetSingleShotLoadingScreen( contextName );

  thePlayer.TeleportWithRotation( newPosition, newRotation );
}

function __savePreviousPosition() {
  var previousPosition : Vector;
  var previousRotation: EulerAngles;

  previousPosition = thePlayer.GetWorldPosition();
  previousRotation = thePlayer.GetWorldRotation();

  FactsSet( "previousPositionX", (int) previousPosition.X );
  FactsSet( "previousPositionY", (int) previousPosition.Y );
  FactsSet( "previousPositionZ", (int) previousPosition.Z );

  FactsSet( "previousRotationYaw", (int) previousRotation.Yaw );
}


/* exports */

exec function bringRoach() { _bringRoach(); }
exec function goToRoach() { _goToRoach(); }
exec function savePosition() { _savePosition(); }
exec function savePos() { _savePosition(); }
exec function restorePosition() { _restorePosition(); }
exec function restorePos() { _restorePosition(); }
exec function undoTeleport() { _undoTeleport(); }
exec function undoTp() { _undoTeleport(); }
