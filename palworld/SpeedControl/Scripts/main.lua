-- Author: MetalTxus

--------------------------------------------------------------------------------
-- Settings                                                                   --
--------------------------------------------------------------------------------

-- Base game speed
default_speed = 1.0

-- Turbo game speed
turbo_speed = 3.0

-- Speed to increment/decrement when hotkeys are pressed
speed_step = 0.25

--------------------------------------------------------------------------------
-- Keybinds                                                                   --
--------------------------------------------------------------------------------

-- Pause game
pause_key = Key.F1

-- Slow game down by the defined step
slowdown_key = Key.PAGE_DOWN

-- Speed game up by the defined step
speedup_key = Key.PAGE_UP

-- Reset speed to default
reset_key = Key.HOME

-- Set speed to turbo
turbo_key = Key.END

--------------------------------------------------------------------------------

game_paused = false
game_speed = default_speed

RegisterKeyBind(pause_key, function()
	game_paused = not game_paused
	UpdateGameSpeed()
end)

RegisterKeyBind(slowdown_key, function()
  game_paused = false
	UpdateGameSpeed(game_speed - speed_step)
end)

RegisterKeyBind(speedup_key, function()
  game_paused = false
	UpdateGameSpeed(game_speed + speed_step)
end)

RegisterKeyBind(turbo_key, function()
  game_paused = false
	UpdateGameSpeed(turbo_speed)
end)

RegisterKeyBind(reset_key, function()
  game_paused = false
	UpdateGameSpeed(default_speed)
end)

function UpdateGameSpeed(new_speed)
	GameplayStatics = StaticFindObject("/Script/Engine.Default__GameplayStatics")
	local Player = FindFirstOf("PalPlayerCharacter")

	game_speed = new_speed

	if game_paused then
		GameplayStatics:SetGlobalTimeDilation(Player, 0.0)
	else
		GameplayStatics:SetGlobalTimeDilation(Player, game_speed)
	end
end
