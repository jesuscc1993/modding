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
      vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
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
      vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
    }
  }
}

function _saveNamedPosition( positionName: String ) {
  var currentPosition : Vector;
  var currentRotation: EulerAngles;

  currentPosition = thePlayer.GetWorldPosition();
  currentRotation = thePlayer.GetWorldRotation();

  FactsSet( "savedPosition_" + positionName + "_X", (int) currentPosition.X );
  FactsSet( "savedPosition_" + positionName + "_Y", (int) currentPosition.Y );
  FactsSet( "savedPosition_" + positionName + "_Z", (int) currentPosition.Z );

  FactsSet( "savedRotation_" + positionName + "_Yaw", (int) currentRotation.Yaw );

  GetWitcherPlayer().DisplayHudMessage( "Saved " + positionName + " position." );
}

function _savePosition() {
  _saveNamedPosition( "current" );
}

function _restoreNamedPosition( positionName: String ) {
  var newPosition : Vector;
  var newRotation : EulerAngles;

  __savePreviousPosition();

  newPosition = Vector( 
    FactsQuerySum( "savedPosition_" + positionName + "_X" ),
    FactsQuerySum( "savedPosition_" + positionName + "_Y" ),
    FactsQuerySum( "savedPosition_" + positionName + "_Z" ) + 1 // +1 to avoid "kneeling" bug
 );

  newRotation = EulerAngles( 0.f, FactsQuerySum( "savedRotation_" + positionName + "_Yaw" ), 0.f );

  __teleportWithRotation( newPosition, newRotation );
}

function _restorePosition() {
  _restoreNamedPosition( "current" );
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

function _teleportFrontward( distance : float ) {
  var heading : Vector = VecFromHeading( thePlayer.GetHeading() );
  var position : Vector = thePlayer.GetWorldPosition();

  __teleport( position + heading * distance );
}

function _teleportBackward( distance : float ) {
  _teleportFrontward( distance * -1 );
}

function _teleportUp( distance : float ) {
  var position : Vector = thePlayer.GetWorldPosition();

  __teleport( Vector( position.X, position.Y, position.Z + distance, 1 ) );
}

function _teleportDown( distance : float ) {
  _teleportUp( distance * -1 );
}

function __teleport( newPosition : Vector ) {
  var contextName : name;

  __savePreviousPosition();

  contextName =
    theGame.GetCommonMapManager().GetLocalisationNameFromAreaType( 
      theGame.GetCommonMapManager().GetCurrentArea()
  );

  theGame.SetSingleShotLoadingScreen( contextName );

  thePlayer.Teleport( newPosition );
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
exec function saveNamedPosition( positionName: String ) { _saveNamedPosition( positionName ); }
exec function saveNamedPos( positionName: String ) { _saveNamedPosition( positionName ); }
exec function savePosition() { _savePosition(); }
exec function savePos() { _savePosition(); }
exec function restoreNamedPosition( positionName: String ) { _restoreNamedPosition( positionName ); }
exec function restoreNamedPos( positionName: String ) { _restoreNamedPosition( positionName ); }
exec function restorePosition() { _restorePosition(); }
exec function restorePos() { _restorePosition(); }
exec function undoTeleport() { _undoTeleport(); }
exec function undoTp() { _undoTeleport(); }

exec function teleportBackward( distance : float ) { _teleportBackward( distance ); }
exec function teleportDown( distance : float ) { _teleportDown( distance ); }
exec function teleportFrontward( distance : float ) { _teleportFrontward( distance ); }
exec function teleportUp( distance : float ) { _teleportUp( distance ); }
exec function tpBack( distance : float ) { _teleportBackward( distance ); }
exec function tpDown( distance : float ) { _teleportDown( distance ); }
exec function tpFront( distance : float ) { _teleportFrontward( distance ); }
exec function tpUp( distance : float ) { _teleportUp( distance ); }
