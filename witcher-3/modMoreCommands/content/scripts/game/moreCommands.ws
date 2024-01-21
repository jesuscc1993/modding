exec function getmaxlevel()
{	
  GetWitcherPlayer().DisplayHudMessage( "Max level is " + GetWitcherPlayer().GetMaxLevel() + "." );
}

exec function savegame()
{	
  theGame.RequestAutoSave( "", true );
}

// non-working

/*exec function removeexp( amount : int )
{
	if( amount > 0 )
	{
		GetWitcherPlayer().AddPoints(EExperiencePoint, amount * -1, false );
    GetWitcherPlayer().DisplayHudMessage( "Removed " + amount + " EXP points." );
	}
}*/

/*exec function removeskillpoints( amount : int )
{	
	if( amount > 0 )
	{
    GetWitcherPlayer().levelManager.AddPoints(ESkillPoint, amount * -1, true);
    GetWitcherPlayer().DisplayHudMessage( "Removed " + amount + " skill points." );
	}
}*/