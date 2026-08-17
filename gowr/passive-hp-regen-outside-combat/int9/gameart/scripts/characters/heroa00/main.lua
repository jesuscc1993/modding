local mpicon = require("ui.mpicon")
local DL = require("design.DesignerLibrary")
local uiCalls = require("ui.uicalls")
local timer = require("creature.timer")
local color = require("core.color")
engine.SetIncrementalGCTime(250)
local components = require("design.components")
local scriptComponents = {
  components.Debuff_HeroFrostComponent.New(),
  components.Debuff_HeroBurnComponent.New(),
  components.Debuff_HeroPoisonComponent.New(),
  components.Debuff_HeroBlindComponent.New(),
  components.Debuff_HeroDazeComponent.New(),
  components.RageModeComponent.New(),
  components.Debuff_HeroBifrostComponent.New()
}
local lValue, rValue, lRelValue, rRelValue
local weaponsLoaded = false
local sprintingLastFrame = false
local sprintTimer = 0
local inSynchMovePrevFrame, inSynchCurrentFrame, currentCarry, currentBase
local initializedLookAtValues = false
_G.thisLookAtEntry = nil
_G.lookAtPriorityOverrides = {}
local playerVelocity, giveLootChance
local giveLootType = "commonLoot"
local rumbles = {}
rumbles.conRumbleMedium = {EffectName = "FFB_MEDIUM", Duration = 3}
rumbles.ffbRumbleThrowHeavy = {
  EffectName = "FFB_THROW_HEAVY",
  Duration = 1.5
}
rumbles.ffbRumbleThrow = {
  EffectName = "FFB_LIGHT_ATTACK_03",
  Duration = 0.5
}
rumbles.ffbWeaponEmbedTraversal = {
  EffectName = "FFB_WEAPON_TRAVERSAL_EMBED",
  Duration = 1
}
local kratos
local inRageMode = false
local lastUpdateCombatState = false
local warpLoc, warpRot
local megaBusterGracePeriod = 1
local megaBusterGracePeriodMinAfterEvade = 1
local megaBusterGracePeriodGuardPoint = 2
local megaBusterBuildRateHalf = 66.666664
local megaBusterBuildRateFull = 40
local megaBusterDecayRate = 20
local defProtoCooldown = 0
function LuaHook_ResetMegaBusterGracePeriodOnGuardPoint()
  defProtoCooldown = megaBusterGracePeriodGuardPoint
end
local VFS = {}
VFS.UnlockHeaderHack = engine.VFSBool.New("--------------------- UNLOCKS ------------------------------------------------------------")
VFS.CheatsAndDebugHeaderHack = engine.VFSBool.New("--------------------- CHEATS AND DEBUG ---------------------------------------------------")
VFS.InfiniteRage = engine.VFSBool.New("Infinite Rage")
VFS.InfiniteRage.value = false
VFS.InfiniteMomentum = engine.VFSBool.New("Infinite Momentum")
VFS.InfiniteMomentum.value = false
VFS.InfiniteRunic = engine.VFSBool.New("Infinite Runic")
VFS.InfiniteRunic.value = false
VFS.EnableEasyStun = engine.VFSBool.New("Enable Easy Stun")
VFS.EnableEasyStun.value = false
VFS.EnableEasyStunCurrentState = false
VFS.DisableStun = engine.VFSBool.New("Disable Stun Reactions")
VFS.DisableStun.value = false
VFS.DisableStunCurrentState = false
VFS.DisableEnemyDefense = engine.VFSBool.New("Disable Enemy Defense")
VFS.DisableEnemyDefense.value = false
VFS.DisableEnemyDefenseCurrentState = false
VFS.PositionDistanceDebug = engine.VFSBool.New("Position Distance Debug -- Press Triangle")
VFS.HideSpeedControlInfo = engine.VFSBool.New("Hide Speed Control Info")
VFS.EnableMomentumSystem = engine.VFSBool.New("Enable Momentum System")
VFS.EnableMomentumSystem.value = false
VFS.SetMomentumAmount = engine.VFSFloat.New("Set Momentum Meter Amount", -1, 100, 0.5)
VFS.SetMomentumAmount.value = -1
VFS.PlaytestToggle = engine.VFSBool.New("Playtest Toggle")
VFS.PlaytestToggle.value = false
VFS.CSMoveIndex = engine.VFSInt.New("CS Move Index", -1, 13)
VFS.CSMoveIndex.value = -1
VFS.CSMoveIndexStrings = {
  "CSMove_0",
  "CSMove_1",
  "CSMove_2",
  "CSMove_3",
  "CSMove_4",
  "CSMove_5",
  "CSMove_6",
  "CSMove_7",
  "CSMove_8",
  "CSMove_9",
  "CSMove_10",
  "CSMove_11",
  "CSMove_12",
  "CSMove_13"
}
VFS.ForceDamagePlayer = engine.VFSBool.New("Force Damage Player")
VFS.ForceDamagePlayer.value = false
VFS.PrototypeHeaderHack = engine.VFSBool.New("--------------------- PROTOTYPES ---------------------------------------------------------")
gVFSCadenceType = engine.VFSInt.New("Spear Cadence 1 = Orig | 2 = 2 frame decrease | 3 = Timed then mash", 1, 3)
gVFSCadenceType.value = 1
gVFSSpecialType = engine.VFSInt.New("Types 1=Cooldown|2=Metered|3=Overheat|4=Slots|5=MajorRune|6=Connected|7=CdSlot", 1, 7)
gVFSSpecialType.value = 6
gVFSSprintR1Type = engine.VFSInt.New("Sprint Spear R1 Types 1=SpearFlick|2=StabStop|3=StabStumble|4=SingleStabStop|5=SingleStabStumble", 1, 5)
gVFSSprintR1Type.value = 1
gVFSHeavyComboType = engine.VFSInt.New("Heavy Combo 1 = No Stab | 2 = Stab", 1, 2)
gVFSHeavyComboType.value = 1
gVFSLightComboType = engine.VFSInt.New("Light Combo 1 = Version 1 | 2 = Version 2 | 3 = Version 3", 1, 3)
gVFSLightComboType.value = 1
gVFSCSEnterType = engine.VFSInt.New("CS enter types  = 1 Run in | 2 = Variable distance", 1, 2)
gVFSCSEnterType.value = 1
gVFSCatchThrowType = engine.VFSInt.New("CatchThrow Type", 1, 4)
gVFSCatchThrowType.value = 1
VFS.megaBusterType = engine.VFSInt.New("Mega Buster - 0: Double tap | 1: Clear on hit | 2: Auto release | 3: Auto release and clear", 0, 3)
VFS.megaBusterType.value = 0
VFS.showShieldMaterialAnimForEquippedShield = engine.VFSBool.New("Play Material Anim on Equipped Shield")
VFS.showShieldMaterialAnimForEquippedShield.value = false
VFS.AccessibilityHeaderHack = engine.VFSBool.New("--------------------- ACCESSIBILITY ---------------------------------------------------------")
VFS.Accessibility_AutoTraverseFromSprint = engine.VFSBool.New("Accessibility - Auto traverse from sprint")
VFS.Accessibility_AutoTraverseFromSprint.value = true
VFS.SprintAccessibilityTimeHeld = 0
gVFSBifrostHeaderHack = engine.VFSBool.New("--------------------- BIFROST ------------------------------------------------------------")
gVFSBifrostShowStatusEffectIcon = engine.VFSBool.New("Bifrost: Show Status Effect Icon")
gVFSBifrostShowStatusEffectIcon.value = false
gVFSBifrostAllowDebugDrawToBypassShowInfo = engine.VFSBool.New("Bifrost: Allow DebugDraw Thru ShowInfo")
gVFSBifrostAllowDebugDrawToBypassShowInfo.value = false
gVFSBifrostOnlyShowInDangerMode = engine.VFSBool.New("Bifrost: Only Show In Danger Mode")
gVFSBifrostOnlyShowInDangerMode.value = false
gRunicTable = {}
gRunicTable.pipCount = 2
vfsMeterValues = {}
vfsMeterValues.MeterUIHeaderHack = engine.VFSBool.New("--------------------- RUNIC UI -----------------------------------------------------------")
vfsMeterValues.pipCount = engine.VFSInt.New("Pip Count ", 1, 30)
vfsMeterValues.pipCount.value = 2
vfsMeterValues.majorRuneSize = engine.VFSInt.New("MajorRune Size", 0, 100)
vfsMeterValues.majorRuneSize.value = 1
vfsMeterValues.regenRate = engine.VFSFloat.New("Pip per second = ", 1, 300)
vfsMeterValues.regenRate.value = 30
vfsMeterValues.scale = engine.VFSFloat.New("UI Scale ", 0.1, 20)
vfsMeterValues.scale.value = 2.5
vfsMeterValues.xLoc = engine.VFSInt.New("X Pos ", 0, 1920)
vfsMeterValues.xLoc.value = 200
vfsMeterValues.yLoc = engine.VFSInt.New("Y Pos ", 0, 1080)
vfsMeterValues.yLoc.value = 864
vfsMeterValues.height = engine.VFSFloat.New("Height ", 0.1, 100)
vfsMeterValues.height.value = 7
vfsMeterValues.pipSize = {}
vfsMeterValues.pipSize.value = 50
vfsMeterValues.borderSize = engine.VFSFloat.New("Border Thickness ", 0.1, 100)
vfsMeterValues.borderSize.value = 1.5
vfsMeterValues.showMeteredBar = engine.VFSBool.New("Show meter lines")
vfsMeterValues.showMeteredBar.value = false
vfsMeterValues.queueType = engine.VFSInt.New("Overheat bar stack type: 1 = ordered | 2 = queue", 1, 2)
vfsMeterValues.queueType.value = 1
vfsMeterValues.goPastBar = engine.VFSBool.New("Go past overheat bar")
vfsMeterValues.goPastBar.value = true
vfsMeterValues.meterGainMultiplier = engine.VFSFloat.New("Meter Gain Multiplier", 0.01, 100)
vfsMeterValues.meterGainMultiplier.value = 0.05
vfsMeterValues.minimumMeterAmount = engine.VFSInt.New("Minimum Meter Use", 1, 6)
vfsMeterValues.minimumMeterAmount.value = 1
vfsMeterValues.scaledRegenRate_0 = engine.VFSFloat.New("Scale rate at 0% ", 0.01, 100)
vfsMeterValues.scaledRegenRate_0.value = 1
vfsMeterValues.scaledRegenRate_25 = engine.VFSFloat.New("Scale rate at 25% ", 0.01, 100)
vfsMeterValues.scaledRegenRate_25.value = 1
vfsMeterValues.scaledRegenRate_50 = engine.VFSFloat.New("Scale rate at 50% ", 0.01, 100)
vfsMeterValues.scaledRegenRate_50.value = 1
vfsMeterValues.scaledRegenRate_75 = engine.VFSFloat.New("Scale rate at 75% ", 0.01, 100)
vfsMeterValues.scaledRegenRate_75.value = 1
vfsMeterValues.weaponTypePipAxe = {}
vfsMeterValues.weaponTypePipAxe.value = 1
vfsMeterValues.weaponTypePipAxe = {}
vfsMeterValues.weaponTypePipAxe.value = 1
vfsMeterValues.invertSlotColor = engine.VFSBool.New("Invert Fill")
vfsMeterValues.invertSlotColor.value = true
vfsMeterValues.spilloverPercentage = engine.VFSFloat.New("Spillover Percentage", 0.2, 1)
vfsMeterValues.spilloverPercentage.value = 0.9
vfsMeterValues.spilloverHeight = engine.VFSFloat.New("Spillover Height", 0.1, 0.5)
vfsMeterValues.spilloverHeight.value = 0.2
VFS.DeprecatedHeaderHack = engine.VFSBool.New("--------------------- DEPRECATED -----------------------------------------------------")
VFS.RuneDebugStat = engine.VFSInt.New("Rune debug: Select Stat 1 = Strength - 2 = Runic ...", 1, 6)
VFS.RuneDebugStat.value = 1
VFS.RuneDebugPerk = engine.VFSInt.New("Rune debug: Select Perk", 1, 18)
VFS.RuneDebugPerk.value = 1
VFS.RuneDebugTier = engine.VFSInt.New("Rune debug: Select Tier", 2, 6)
VFS.RuneDebugTier.value = 2
VFS.RuneDebugCreate = engine.VFSInt.New("Rune debug: Create Rune (move to 6 then back to 0)", 0, 6)
local hitCounterDrain = false
local tetherArrow_lastKnownPosition
local tetherArrowExists = false
local healthCurrent = 100
local healthMaxPrevFrame = 100
local healthMax = 100
local healthPercent = 100
local healthPrevFrame = 100
local playerHealthLowThreshold = 20
local playerHealthCriticalThreshold = 10
local healthDifference = 0
local playerEffectiveHealthPercentForLowHealthFeedback = 100
local showLowHealthWarningTimer = 0
local showLowHealthWarningTimerMax = 10
local shieldSoundEmitter, chainSoundEmitterR, chainSoundEmitterL
local lowHealthSFXCall = false
function LuaHook_CheckTraverseLink(crt, data)
  if crt:GetTraverseLink() == nil then
    return data:FindOutcomeBranchesEntry("BranchNav")
  end
end
function LuaHook_PyreFire()
  local level = game.FindLevel("For200_House")
  level:CallScript("LuaHook_PyreFire_For200")
end
local encounterMusic = {}
encounterMusic.combatMusicStart = nil
encounterMusic.combatMusicEnd = nil
encounterMusic.activeEnemies = 0
encounterMusic.lastEnemyCount = 0
function CombatEncounterStarted(ai, startMusic, endMusic)
  EvaluateCombatMusicStart(ai, startMusic, endMusic)
end
function EvaluateCombatMusicStart(ai, startMusic, endMusic)
  if startMusic and endMusic and encounterMusic.combatMusicStart == nil and encounterMusic.combatMusicEnd == nil then
    encounterMusic.combatMusicStart = startMusic
    encounterMusic.combatMusicEnd = endMusic
    game.Audio.StartMusic(encounterMusic.combatMusicStart)
  end
end
function CombatEncounterEnded(ai, endMusicOverride)
  if bboard:GetNumber("ActiveCombatEncounters") <= 0 and encounterMusic.combatMusicStart ~= nil then
    EvaluateCombatMusicEnd(ai, endMusicOverride)
  end
end
function EvaluateCombatMusicEnd(ai, endMusicOverride)
  if encounterMusic.combatMusicEnd ~= nil or endMusicOverride ~= nil then
    local endMusic = endMusicOverride or encounterMusic.combatMusicEnd
    game.Audio.StartMusic(endMusic)
    encounterMusic.combatMusicStart = nil
    encounterMusic.combatMusicEnd = nil
  end
end
function DisableNextDockingCheckpoint()
end
function LuaHook_CheckpointOnExit()
end
local debugPosStart, debugPosEnd, debugPosDistanceXZ, debugPosDistanceY
local debugPosSwitch = true
local debugPosResult
local UI = game.UI
VFS.ShowWorldOffscreenIndicator = engine.VFSBool.New("World Offscreen Indicator")
VFS.ShowWorldOffscreenIndicator.value = false
stats = {
  Strength = 10,
  Endurance = 10,
  Power = 15,
  Focus = 6,
  Luck = 7,
  Recovery = 25
}
armor = {
  ItemName = "null",
  ItemStats = stats,
  Level = 0
}
local fseVignetteTakeDmg = {
  EffectName = "FSE_ColorCorrection_TakeDamage",
  Duration = 0.2,
  TweenInTime = 0.1,
  TweenInEaseIn = 0.1,
  TweenOutEaseOut = 0.5,
  TweenOutTime = 0.45
}
local fseVignetteTakeDmgCritical = {
  EffectName = "FSE_ColorCorrection_TakeDamageCritical",
  Duration = 0.25,
  TweenInTime = 0.5,
  TweenInEaseIn = 0.4,
  TweenOutEaseOut = 0.65,
  TweenOutTime = 0.5
}
local fseVignetteTakeDmgCriticalDelayed = {
  EffectName = "FSE_ColorCorrection_TakeDamageCritical_Delayed",
  Duration = 0.75,
  TweenInTime = 0.5,
  TweenInEaseIn = 0.4,
  TweenOutEaseOut = 0.65,
  TweenOutTime = 0.5
}
local fseVignetteMoveArmor = {
  EffectName = "FSE_ColorCorrection_MoveArmor",
  Duration = 0.65,
  TweenInTime = 0.1,
  TweenInEaseIn = 0.1,
  TweenOutEaseOut = 0.5,
  TweenOutTime = 0.45
}
local padColorReset = false
local reviveDisabled = false
function _G.OnGOCreateLuaState(go)
  go:SetBlackboardSize(16)
  bboard = go:GetPrivateBlackboard()
  go:SetInfluenceConeAngle(95)
  go:SetInfluenceConeLength(4)
  go:SetInfluenceConeIntensity(0.3)
  go:SetInfluenceConeDecay(game.Creature.InfluenceConeDecay.kLinearDecay)
  go:SetInfluenceConeIsEnabled(true)
  go:SetInfluenceCircleRadius(3.25)
  go:SetInfluenceCircleIntensity(0.3)
  go:SetInfluenceCircleDecay(game.Creature.InfluenceConeDecay.kLinearDecay)
  go:SetInfluenceCircleIsEnabled(true)
  reviveDisabled = false
  mpicon.level.Create(go, "KRATOS_HEALTH_BAR", "zerojoint")
  if go.SetOverrideStatusEffectIconParent ~= nil then
    go:SetOverrideStatusEffectIconParent("KRATOS_HEALTH_BAR")
  end
end
global = {}
global.inventory = {}
rageLevel = 0
gVFSInfiniteMeter = engine.VFSBool.New("Ironsight Son Commands")
translationDriver = nil
rotationDriver = nil
bboard = nil
local statusEffectIconsOn = {}
statusEffectIconsOn.BURN = false
statusEffectIconsOn.FROST = false
statusEffectIconsOn.POISON = false
statusEffectIconsOn.WEAKEN = false
statusEffectIconsOn.BLIND = false
statusEffectIconsOn.DAZE = false
statusEffectIconsOn.BIFROST = false
wasAimCapable = false
wasAiming = false
wasAttacking = false
wasBlocking = false
wasBlockFull = false
wasPerformingGroundSmash = false
wasAxeFrostPowerUp = false
reticleTargetCreatureChangeTimer = 0
reticleTargetCreatureTimeThreshold = 1
reticleTargetCreatureTimeThresholdFast = 0.25
reticleTargetCreaturePrevious = nil
global.DebugLoadout = {}
global.DebugLoadout.initialized = false
global.DebugLoadout.pickups = {"Bifrost", "Blades"}
local DebugGiveHeroLoadout = function(C)
  if game.Resources.SetDebugAddMode then
    game.Resources.SetDebugAddMode(true)
  end
  if global.DebugLoadout.initialized == false then
    local levelName = C.GroundLevel
    if levelName then
      global.DebugLoadout.initialized = true
      levelName = string.upper(levelName.Name)
      if string.find(levelName, "WAD_TB") == 1 then
        for _, pickups in ipairs(global.DebugLoadout.pickups) do
          if C:PickupIsAcquired(pickups) == false then
            C:PickupAcquire(pickups)
          end
        end
      end
    end
  end
  if game.Resources.SetDebugAddMode then
    game.Resources.SetDebugAddMode(false)
  end
end
local IsValidRuneID = function(runeID)
  return runeID ~= nil and runeID ~= 1
end
local HasFlag = function(runeID, flag)
  local hasFlag = false
  if IsValidRuneID(runeID) then
    hasFlag = game.Wallets.RuneHasFlag("HERO", runeID, {flag})
  end
  return hasFlag
end
function LuaHook_PlaytestRoomIsSpecialOnCooldown()
  local thisLevel = kratos.GroundLevel
  if thisLevel == "WAD_PlaytestTraining" or game.FindLevel("PlaytestTraining") then
    thisLevel:CallScript("LuaHook_PlaytestRoomIsSpecialOnCooldown")
  end
end
function LuaHook_CombatEvent_CooldownActivated(C, pickupName)
  local pickupNameString = tostring(pickupName)
  local specialLight = kratos.PickupGetPickupNameInSlot(kratos, "WeaponSpecial_Light")
  local specialHeavy = kratos.PickupGetPickupNameInSlot(kratos, "WeaponSpecial_Heavy")
  local specialBladesLight = kratos.PickupGetPickupNameInSlot(kratos, "WeaponSpecial_Blades_Light")
  local specialBladesHeavy = kratos.PickupGetPickupNameInSlot(kratos, "WeaponSpecial_Blades_Heavy")
  if pickupNameString == specialBladesHeavy and kratos:PickupIsAcquired(pickupNameString) then
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_HealthBurst") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_HealthBurst")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_RunicBuff")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnRefresh_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnRefresh_RunicBuff")
    end
  end
  if pickupNameString == specialBladesLight and kratos:PickupIsAcquired(pickupNameString) then
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_HealthBurst") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_HealthBurst")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_RunicBuff")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnRefresh_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnRefresh_RunicBuff")
    end
  end
  if pickupNameString == specialLight and kratos:PickupIsAcquired(pickupNameString) then
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_HealthBurst") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_HealthBurst")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_RunicBuff")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnRefresh_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnRefresh_RunicBuff")
    end
  end
  if pickupNameString == specialHeavy and kratos:PickupIsAcquired(pickupNameString) then
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_HealthBurst") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_HealthBurst")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnActivation_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnActivation_RunicBuff")
    end
    if kratos:PickupIsAcquired("Perk_WeaponSpecial_OnRefresh_RunicBuff") then
      kratos:CallScript("LuaHook_Perk_WeaponSpecial_OnRefresh_RunicBuff")
    end
  end
end
local HipSelectionValue
function GrabHipSelection(C)
  if HipSelectionValue == nil then
    HipSelectionValue = C:GetAnimDriver("HipSelectionDriver")
  end
end
function LuaHook_DisableRevive(ai, toggleValue)
  reviveDisabled = toggleValue
end
function IsDeathAllowed(C)
  if C:CheckDynamicFlag("DisallowDeath") then
    return false
  end
  if reviveDisabled then
    return true
  end
  local son = game.AI.FindSon()
  if son == nil then
    return true
  end
  local sonBB = son:GetBlackboard()
  local sonEnraged = false
  if sonBB and sonBB:Exists("Enraged") then
    sonEnraged = sonBB:GetBoolean("Enraged")
  end
  local canRevive = son ~= nil and (son.OwnedPOI == nil or son.OwnedPOI ~= nil and son.OwnedPOI:FindLuaTableAttribute("AllowRevive") ~= nil and son.OwnedPOI:FindLuaTableAttribute("AllowRevive") == true) and son.IsAvailableInLevel and son:IsAvailableInLevel() and son:HasMarker("Son_KnockedDown") == false and sonEnraged == false and not DL.CheckCreatureContext(son:GetContext(), "INCAPACITATED") and C:IsPlayingMove("MOV_DeathSave") == false and C:IsPlayingMove("MOV_DeathSaveEnter") == false
  local hasRune = game.Wallets.GetResourceValue("HERO_SAVEONLY", "ResurrectionRuneStoneA") > 0 or 0 < game.Wallets.GetResourceValue("HERO_SAVEONLY", "ResurrectionRuneStoneB") or 0 < game.Wallets.GetResourceValue("HERO_SAVEONLY", "ResurrectionRuneStoneC")
  if canRevive and hasRune then
    son:TriggerMoveEvent("kLE_ExitGrabToRevive")
    return false
  else
    return true
  end
end
local breathEffect
local fakePad = {}
local tempDebuffBurnTimer = 0
local debugFastLeakTable
function DoMemoryDebugHelpers()
  if game.GetLeakMemory() then
    if debugFastLeakTable == nil then
      debugFastLeakTable = {}
    end
    local rate = game.GetLeakMemoryRate()
    for _ = 1, rate do
      debugFastLeakTable[#debugFastLeakTable + 1] = #debugFastLeakTable
    end
  end
  if game.GetCreateGarbage() then
    local rate = game.GetCreateGarbageRate()
    for _ = 1, rate do
      local garbageTable = {}
    end
  end
end
function LuaHook_DeathFadeoutQuick()
  game.Combat.KillPlayer(1)
end
function EnableColdIdle(C)
  C:SetMood("MOOD_DEEP_SNOW")
end
function DisableColdIdle(C)
  C:ClearMood("MOOD_DEEP_SNOW")
end
function EnablePanicIdle(C)
  C:SetMood("MOOD_FRENZYRUN")
end
function DisablePanicIdle(C)
  C:ClearMood("MOOD_FRENZYRUN")
end
function SetupMarkerLogic(C, typeValue, VFS_OptionStrings)
  for k, v in ipairs(VFS_OptionStrings) do
    if k ~= typeValue and C:HasMarker(v) then
      C:RemoveMarker(v)
    end
  end
  if not C:HasMarker(VFS_OptionStrings[typeValue]) then
    C:AddMarker(VFS_OptionStrings[typeValue])
  end
end
function RunMarkerLogic(C)
  SetupMarkerLogic(C, gVFSSpecialType.value, {
    "VFS_Old",
    "VFS_Metered",
    "VFS_Metered_Overheat",
    "VFS_Metered_CooldownSlot",
    "VFS_Metered_MajorRune",
    "VFS_Metered_Connected",
    "VFS_OldButLimited"
  })
  SetupMarkerLogic(C, gVFSCadenceType.value, {
    "VFS_OldCadence",
    "VFS_2Frame",
    "VFS_TimedThenMash"
  })
  SetupMarkerLogic(C, gVFSSprintR1Type.value, {
    "VFS_SpearFlick",
    "VFS_StabStop",
    "VFS_StabStumble",
    "VFS_SingleStabStop",
    "VFS_SingleStabStumble"
  })
  SetupMarkerLogic(C, gVFSHeavyComboType.value, {
    "VFS_HeavyCombo_NoStab",
    "VFS_HeavyCombo_Stab"
  })
  SetupMarkerLogic(C, gVFSLightComboType.value, {
    "VFS_LightCombo_Version1",
    "VFS_LightCombo_Version2",
    "VFS_LightCombo_Version3"
  })
  SetupMarkerLogic(C, gVFSCSEnterType.value, {
    "VFS_CS_RunIn",
    "VFS_CS_VariableDistance"
  })
  SetupMarkerLogic(C, gVFSCatchThrowType.value, {
    "VFS_360",
    "VFS_Impact360",
    "VFS_PullShotPutt",
    "VFS_PullSideArm"
  })
end
defProtoX = 440
defProtoY = 840
defProtoWidth = 200
defProtoHeight = 30
defProtoBorderThickness = 4
regenRate = 5
pipValue = 25
tempMeter = {}
tempMeter.currentType = "default"
tempMeter.borderColor = 0
tempMeter.time = 0
tempMeter.fullColor = 5709677
tempMeter.types = {}
tempMeter.types.default = {}
tempMeter.types.default.value = 0
tempMeter.types.default.color = 3243769
tempMeter.types.default.notFullColor = 4802629
tempMeter.types.default.prevCount = 0
tempMeter.types.overheat = {}
tempMeter.types.overheat.value = 0
tempMeter.types.overheat.displayType = "queue"
tempMeter.types.overheat.meters = {}
tempMeter.types.overheat.meters.AxeLight = {
  value = 0,
  color = 1289174,
  cost = 25
}
tempMeter.types.overheat.meters.AxeHeavy = {
  value = 0,
  color = 14765,
  cost = 75
}
tempMeter.types.overheat.meters.BladeLight = {
  value = 0,
  color = 16766038,
  cost = 50
}
tempMeter.types.overheat.meters.BladeHeavy = {
  value = 0,
  color = 16740864,
  cost = 100
}
tempMeter.types.overheat.displayMeters = {}
tempMeter.types.overheat.prevCount = 0
tempMeter.types.overheat.notFullColor = 3158064
tempMeter.types.weaponType = {}
tempMeter.types.weaponType.meters = {}
tempMeter.types.weaponType.meters.Axe = {value = 0, color = 1289174}
tempMeter.types.weaponType.meters.Blade = {value = 0, color = 16766038}
tempMeter.types.weaponType.sharedMeter = {value = 0, color = 6329902}
tempMeter.types.cooldownSlots = {}
tempMeter.types.cooldownSlots.meters = {}
tempMeter.types.cooldownSlots.meters.AxeLight = {color = 1289174, cooldown = 30}
tempMeter.types.cooldownSlots.meters.AxeHeavy = {color = 14765, cooldown = 90}
tempMeter.types.cooldownSlots.meters.BladeLight = {color = 16766038, cooldown = 60}
tempMeter.types.cooldownSlots.meters.BladeHeavy = {color = 16740864, cooldown = 120}
tempMeter.types.cooldownSlots.visuals = {}
tempMeter.types.cooldownSlots.prevCount = 0
tempMeter.types.majorRune = {}
tempMeter.types.majorRune.meters = {}
tempMeter.types.majorRune.meters.AxeLight = {color = 1289174, cooldown = 30}
tempMeter.types.majorRune.meters.AxeHeavy = {color = 14765, cooldown = 90}
tempMeter.types.majorRune.meters.BladeLight = {color = 16766038, cooldown = 60}
tempMeter.types.majorRune.meters.BladeHeavy = {color = 16740864, cooldown = 120}
tempMeter.types.majorRune.visuals = {}
tempMeter.types.majorRune.majorvisuals = {}
tempMeter.types.connected = {}
tempMeter.types.connected.meterCount = 0
tempMeter.types.connected.meters = {}
tempMeter.types.connected.meters.AxeLight = {color = 1289174, cooldown = 30}
tempMeter.types.connected.meters.AxeHeavy = {color = 14765, cooldown = 90}
tempMeter.types.connected.meters.BladeLight = {color = 16766038, cooldown = 60}
tempMeter.types.connected.meters.BladeHeavy = {color = 16740864, cooldown = 120}
tempMeter.types.connected.meters.SpearLight = {color = 16766038, cooldown = 30}
tempMeter.types.connected.meters.SpearHeavy = {color = 16740864, cooldown = 90}
tempMeter.types.connected.visuals = {}
meterVisuals = {}
meterVisuals.time = 0.5
meterVisuals.scaleRate = 1.15
meterVisuals.filledList = {}
function DrawCenteredRectangle(C, vis)
  local xloc = vfsMeterValues.xLoc.value + vfsMeterValues.pipSize.value * vis.location * vfsMeterValues.scale.value - vfsMeterValues.pipSize.value * 0.5 - vfsMeterValues.pipSize.value * vis.currentScale * vfsMeterValues.scale.value * 0.6
  local yloc = vfsMeterValues.yLoc.value - vfsMeterValues.height.value * 0.5 * vfsMeterValues.scale.value * vis.currentScale
  local red = vis.colorChange * 65536
  local green = vis.colorChange * 256
  local finalColor = bit32.bor(bit32.bor(vis.color, red), green)
  engine.DrawRect2D(xloc, yloc, vfsMeterValues.pipSize.value * vis.currentScale * vfsMeterValues.scale.value, vfsMeterValues.height.value * vis.currentScale * vfsMeterValues.scale.value, finalColor, vis.time * 200)
end
function DrawCenteredSquare(C, vis)
  local xloc = vis.location - vfsMeterValues.pipSize.value * 0.5 * vfsMeterValues.scale.value * vis.currentScale
  local yloc = vfsMeterValues.yLoc.value - vfsMeterValues.pipSize.value * 0.5 * vfsMeterValues.scale.value * vis.currentScale
  local red = vis.colorChange * 65536
  local green = vis.colorChange * 256
  local finalColor = bit32.bor(bit32.bor(vis.color, red), green)
  engine.DrawRect2D(xloc, yloc, vfsMeterValues.pipSize.value * vis.currentScale * vfsMeterValues.scale.value, vfsMeterValues.pipSize.value * vis.currentScale * vfsMeterValues.scale.value, finalColor, vis.time * 200)
end
function AddMeterVisualFX(C, location, color, fxType)
  local popup = {}
  popup.time = meterVisuals.time
  popup.currentScale = 1
  popup.location = location
  popup.color = color
  popup.colorChange = 0
  popup.colorChangeRate = 750
  popup.fxType = fxType
  table.insert(meterVisuals.filledList, popup)
end
function UpdateMeterVisualFX(C)
  local dt = C:GetUnitTime()
  for i = #meterVisuals.filledList, 1, -1 do
    local thispop = meterVisuals.filledList[i]
    thispop.time = thispop.time - dt
    if thispop.time <= 0 then
      table.remove(meterVisuals.filledList, i)
    else
      thispop.currentScale = thispop.currentScale * meterVisuals.scaleRate
      thispop.colorChange = thispop.colorChange + thispop.colorChangeRate * dt
      if thispop.colorChange >= 255 then
        thispop.colorChange = 255
      end
      if thispop.fxType == "bar" then
        DrawCenteredRectangle(C, thispop)
      else
        DrawCenteredSquare(C, thispop)
      end
    end
  end
end
function DrawBorder(C)
  if tempMeter.currentType == "connected" then
    local xOffset = 0
    local height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
    for i = 1, gRunicTable.pipCount do
      local thisColor = tempMeter.borderColor
      if vfsMeterValues.invertSlotColor.value and i > #tempMeter.types.cooldownSlots.visuals then
        thisColor = 34622
      end
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      if i < gRunicTable.pipCount and i + 1 <= #tempMeter.types.connected.visuals and tempMeter.types.connected.visuals[i].name == tempMeter.types.connected.visuals[i + 1].name then
        local prevOffset = xOffset
        local offsetDiff = (vfsMeterValues.borderSize.value + (vfsMeterValues.pipSize.value * 1.2 - vfsMeterValues.pipSize.value)) * vfsMeterValues.scale.value
        engine.DrawRect2D(vfsMeterValues.xLoc.value + (prevOffset + vfsMeterValues.pipSize.value) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + height - 2 * height * vfsMeterValues.spilloverPercentage.value, offsetDiff, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
        engine.DrawRect2D(vfsMeterValues.xLoc.value + (prevOffset + vfsMeterValues.pipSize.value) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + height - 2 * height * (vfsMeterValues.spilloverPercentage.value - vfsMeterValues.spilloverHeight.value), offsetDiff, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      end
      xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
    end
  end
  if tempMeter.currentType == "majorRune" then
    local xOffset = 0
    local height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
    for _ = 1, gRunicTable.pipCount do
      local thisColor = tempMeter.borderColor
      if vfsMeterValues.invertSlotColor.value and _ > #tempMeter.types.majorRune.visuals then
        thisColor = 34622
      end
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
    end
    height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5 * 1.25
    local pipsize = vfsMeterValues.pipSize.value * 1.25
    for _ = 1, vfsMeterValues.majorRuneSize.value do
      local thisColor = tempMeter.borderColor
      if vfsMeterValues.invertSlotColor.value and _ > #tempMeter.types.majorRune.majorvisuals then
        thisColor = 34622
      end
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + height, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + (xOffset + pipsize) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      xOffset = xOffset + pipsize * 1.2
    end
  end
  if tempMeter.currentType == "cooldownSlot" then
    local xOffset = 0
    local height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
    for _ = 1, gRunicTable.pipCount do
      local thisColor = tempMeter.borderColor
      if vfsMeterValues.invertSlotColor.value and _ > #tempMeter.types.cooldownSlots.visuals then
        thisColor = 34622
      end
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      engine.DrawRect2D(vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisColor, 100)
      xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
    end
  end
  if tempMeter.currentType == "default" then
    local height = vfsMeterValues.height.value * 0.5 * vfsMeterValues.scale.value
    local maxWidth = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    if vfsMeterValues.showMeteredBar.value == true then
      local weaponequipped = C:GetCurrentWeapon()
      local tableOfWeapons = {}
      if weaponequipped == "Axe" then
        tableOfWeapons = {"AxeLight", "AxeHeavy"}
      elseif weaponequipped == "Blades" then
        tableOfWeapons = {"BladeLight", "BladeHeavy"}
      elseif weaponequipped == "Spear" then
        tableOfWeapons = {"SpearLight", "SpearHeavy"}
      end
      for _, v in pairs(tableOfWeapons) do
        local thisMeter = tempMeter.types.overheat.meters[v]
        engine.DrawRect2D(vfsMeterValues.xLoc.value + (vfsMeterValues.borderSize.value * 0.35 + thisMeter.cost) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height * 2, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value * 0.5, (vfsMeterValues.height.value * 2 + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, thisMeter.color, 100)
      end
    end
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value + height, (maxWidth + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, (maxWidth + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    for i = 1, gRunicTable.pipCount + 1 do
      local offset = vfsMeterValues.pipSize.value * (i - 1) * vfsMeterValues.scale.value
      engine.DrawRect2D(vfsMeterValues.xLoc.value + offset, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.height.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    end
  end
  if tempMeter.currentType == "overheat" then
    local height = vfsMeterValues.height.value * 0.5 * vfsMeterValues.scale.value
    local maxWidth = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    tempMeter.time = tempMeter.time + C:GetUnitTime()
    local shiftcolor = tempMeter.borderColor
    local color = tempMeter.borderColor
    if C:HasMarker("Overheat") then
      shiftcolor = math.floor((math.sin(tempMeter.time * 10) + 1) * 127.5)
      color = shiftcolor * 65536
    end
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value + height, (maxWidth + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, color, 100)
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, (maxWidth + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, color, 100)
    local offset = vfsMeterValues.pipSize.value * gRunicTable.pipCount * vfsMeterValues.scale.value
    engine.DrawRect2D(vfsMeterValues.xLoc.value + 0, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.height.value + vfsMeterValues.borderSize.value * 0.5) * vfsMeterValues.scale.value, color, 100)
    engine.DrawRect2D(vfsMeterValues.xLoc.value + offset, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.height.value + vfsMeterValues.borderSize.value * 0.5) * vfsMeterValues.scale.value, color, 100)
    for i = 2, gRunicTable.pipCount do
      local offset = vfsMeterValues.pipSize.value * (i - 1) * vfsMeterValues.scale.value
      engine.DrawRect2D(vfsMeterValues.xLoc.value + offset, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.height.value + vfsMeterValues.borderSize.value * 0.5) * vfsMeterValues.scale.value, color, 50)
    end
  end
  if tempMeter.currentType == "weaponType" then
    local height = vfsMeterValues.height.value * 0.5 * vfsMeterValues.scale.value
    local maxWidth = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value + height, (maxWidth + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, (maxWidth + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    for i = 1, gRunicTable.pipCount + 1 do
      local offset = vfsMeterValues.pipSize.value * (i - 1) * vfsMeterValues.scale.value
      engine.DrawRect2D(vfsMeterValues.xLoc.value + offset, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.height.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    end
    local weaponequipped = C:GetCurrentWeapon()
    local pipCount = 0
    if weaponequipped == "Axe" then
      pipCount = vfsMeterValues.weaponTypePipAxe.value
    elseif weaponequipped == "Blade" then
      pipCount = vfsMeterValues.weaponTypePipBlade.value
    end
    local newLocx = vfsMeterValues.xLoc.value + (maxWidth + vfsMeterValues.pipSize.value * 0.25 + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value
    engine.DrawRect2D(newLocx, vfsMeterValues.yLoc.value + height, (pipCount * vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    engine.DrawRect2D(newLocx, vfsMeterValues.yLoc.value - height, (pipCount * vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    for i = 1, pipCount + 1 do
      local offset = vfsMeterValues.pipSize.value * (i - 1) * vfsMeterValues.scale.value
      engine.DrawRect2D(newLocx + offset, vfsMeterValues.yLoc.value - height, vfsMeterValues.borderSize.value * vfsMeterValues.scale.value, (vfsMeterValues.height.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.borderColor, 100)
    end
  end
end
function OverheatMeterLogic(C)
  if tempMeter.types.overheat.displayType == "inOrder" then
    tempMeter.types.overheat.displayMeters[1] = "AxeLight"
    tempMeter.types.overheat.displayMeters[2] = "AxeHeavy"
    tempMeter.types.overheat.displayMeters[3] = "BladeLight"
    tempMeter.types.overheat.displayMeters[4] = "BladeHeavy"
  else
    for i = #tempMeter.types.overheat.displayMeters, 1, -1 do
      local theType = tempMeter.types.overheat.displayMeters[i]
      if tempMeter.types.overheat.meters[theType].value <= 0 then
        table.remove(tempMeter.types.overheat.displayMeters, i)
      end
    end
  end
end
function DrawMeter(C)
  ResetMeters(C)
  if tempMeter.currentType == "default" then
    local currentValue = tempMeter.types.default.value
    local height = vfsMeterValues.height.value * 0.5 * vfsMeterValues.scale.value
    local pipCount = math.floor(currentValue / vfsMeterValues.pipSize.value)
    local offsetPoint = 0
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, currentValue * vfsMeterValues.scale.value, vfsMeterValues.height.value * vfsMeterValues.scale.value, tempMeter.types.default.notFullColor, 75)
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, pipCount * vfsMeterValues.pipSize.value * vfsMeterValues.scale.value, vfsMeterValues.height.value * vfsMeterValues.scale.value, tempMeter.types.default.color, 100)
  elseif tempMeter.currentType == "overheat" then
    OverheatMeterLogic(C)
    local height = vfsMeterValues.height.value * 0.5 * vfsMeterValues.scale.value
    local offset = 0
    local prevcount = tempMeter.types.overheat.prevCount
    local currentcount = 0
    local totalvalue = 0
    for _, t in pairs(tempMeter.types.overheat.meters) do
      totalvalue = totalvalue + t.value
    end
    local actualValue = totalvalue / vfsMeterValues.pipSize.value
    currentcount = math.ceil(actualValue)
    if currentcount ~= prevcount then
      if prevcount > currentcount and currentcount < gRunicTable.pipCount then
        AddMeterVisualFX(C, prevcount, 16777215, "bar")
      end
      tempMeter.types.overheat.prevCount = currentcount
    end
    local greyBar = math.ceil(actualValue)
    local shiftcolor = tempMeter.borderColor
    local color = tempMeter.types.overheat.notFullColor
    if C:HasMarker("Overheat") then
      shiftcolor = math.floor((math.sin(tempMeter.time * 10) + 1) * 127.5)
      color = shiftcolor * 65536
    end
    local maxSize = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    if vfsMeterValues.goPastBar.value == false and greyBar > gRunicTable.pipCount then
      greyBar = gRunicTable.pipCount
    end
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, greyBar * vfsMeterValues.pipSize.value * vfsMeterValues.scale.value, vfsMeterValues.height.value * vfsMeterValues.scale.value, color, 75)
    for _, t in ipairs(tempMeter.types.overheat.displayMeters) do
      local v = tempMeter.types.overheat.meters[t]
      local showValue = v.value
      if vfsMeterValues.goPastBar.value == false and maxSize < showValue then
        showValue = maxSize
      end
      if 0 < showValue then
        engine.DrawRect2D(vfsMeterValues.xLoc.value + offset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, showValue * vfsMeterValues.scale.value, vfsMeterValues.height.value * vfsMeterValues.scale.value, v.color, 100)
      end
      offset = offset + v.value
      maxSize = maxSize - v.value
    end
  elseif tempMeter.currentType == "weaponType" then
    local currentValue = tempMeter.types.weaponType.sharedMeter.value
    local height = vfsMeterValues.height.value * 0.5 * vfsMeterValues.scale.value
    local pipCount = math.floor(currentValue / vfsMeterValues.pipSize.value)
    local offsetPoint = 0
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, currentValue * vfsMeterValues.scale.value, vfsMeterValues.height.value * vfsMeterValues.scale.value, tempMeter.types.default.notFullColor, 75)
    engine.DrawRect2D(vfsMeterValues.xLoc.value, vfsMeterValues.yLoc.value - height, pipCount * vfsMeterValues.pipSize.value * vfsMeterValues.scale.value, vfsMeterValues.height.value * vfsMeterValues.scale.value, tempMeter.types.weaponType.sharedMeter.color, 100)
    local weaponequipped = C:GetCurrentWeapon()
    local pipValue = 0
    local color = 1118481
    if weaponequipped == "Axe" then
      pipValue = tempMeter.types.weaponType.meters.Axe.value
      color = tempMeter.types.weaponType.meters.Axe.color
    elseif weaponequipped == "Blade" then
      pipValue = tempMeter.types.weaponType.meters.Blade.value
      color = tempMeter.types.weaponType.meters.Blade.color
    end
    local maxWidth = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    local newLocx = vfsMeterValues.xLoc.value + (maxWidth + vfsMeterValues.pipSize.value * 0.25 + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value
    engine.DrawRect2D(newLocx, vfsMeterValues.yLoc.value - height, (pipValue + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, vfsMeterValues.height.value * vfsMeterValues.scale.value, color, 100)
  elseif tempMeter.currentType == "cooldownSlot" then
    local xOffset = 0
    local height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
    for i = 1, #tempMeter.types.cooldownSlots.visuals do
      if vfsMeterValues.invertSlotColor.value == false then
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.borderColor, 50)
      end
      local visuals = tempMeter.types.cooldownSlots.visuals[i]
      local percentage = visuals.currentCooldown / visuals.cooldown
      if vfsMeterValues.invertSlotColor.value then
        percentage = 1 - percentage
      end
      local startHeight = vfsMeterValues.pipSize.value * 0.5 * vfsMeterValues.scale.value - percentage * vfsMeterValues.pipSize.value * vfsMeterValues.scale.value
      local value = (percentage * vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + startHeight, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, value, visuals.color, 50)
      engine.DrawText2D(visuals.text, vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value * 0.4) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
      xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
    end
    if vfsMeterValues.invertSlotColor.value then
      xOffset = vfsMeterValues.pipSize.value * 1.2 * #tempMeter.types.cooldownSlots.visuals
      local fullCount = gRunicTable.pipCount - #tempMeter.types.cooldownSlots.visuals
      for _ = 1, fullCount do
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.fullColor, 50)
        engine.DrawText2D("ready", vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value * 0.175) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
        xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
      end
    end
  elseif tempMeter.currentType == "connected" then
    local xOffset = 0
    local height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
    for i = 1, #tempMeter.types.connected.visuals do
      if vfsMeterValues.invertSlotColor.value == false then
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.borderColor, 50)
      end
      local visuals = tempMeter.types.connected.visuals[i]
      local percentage = visuals.currentCooldown / visuals.cooldown
      if vfsMeterValues.invertSlotColor.value then
        percentage = 1 - percentage
      end
      local startHeight = vfsMeterValues.pipSize.value * 0.5 * vfsMeterValues.scale.value - percentage * vfsMeterValues.pipSize.value * vfsMeterValues.scale.value
      local value = (percentage * vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + startHeight, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, value, visuals.color, 50)
      engine.DrawText2D(visuals.text, vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value * 0.4) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
      local prevOffset = xOffset
      xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
      local offsetDiff = (vfsMeterValues.borderSize.value + (vfsMeterValues.pipSize.value * 1.2 - vfsMeterValues.pipSize.value)) * vfsMeterValues.scale.value
      local nextType
      if i + 1 <= #tempMeter.types.connected.visuals then
        nextType = tempMeter.types.connected.visuals[i + 1]
        if visuals.name == nextType.name and nextType.currentCooldown / nextType.cooldown < 1 - vfsMeterValues.spilloverPercentage.value then
          engine.DrawRect2D(vfsMeterValues.xLoc.value + (prevOffset + vfsMeterValues.pipSize.value) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + height - 2 * height * vfsMeterValues.spilloverPercentage.value, offsetDiff, 2 * height * vfsMeterValues.spilloverHeight.value * 1.1, visuals.color, 50)
        end
      end
    end
    if vfsMeterValues.invertSlotColor.value then
      xOffset = vfsMeterValues.pipSize.value * 1.2 * #tempMeter.types.connected.visuals
      local fullCount = gRunicTable.pipCount - #tempMeter.types.connected.visuals
      for _ = 1, fullCount do
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.fullColor, 50)
        engine.DrawText2D("ready", vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value * 0.175) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
        xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
      end
    end
  elseif tempMeter.currentType == "majorRune" then
    local xOffset = 0
    local height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
    for i = 1, #tempMeter.types.majorRune.visuals do
      if vfsMeterValues.invertSlotColor.value == false then
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.borderColor, 50)
      end
      local visuals = tempMeter.types.majorRune.visuals[i]
      local percentage = visuals.currentCooldown / visuals.cooldown
      if vfsMeterValues.invertSlotColor.value then
        percentage = 1 - percentage
      end
      local startHeight = vfsMeterValues.pipSize.value * 0.5 * vfsMeterValues.scale.value - percentage * vfsMeterValues.pipSize.value * vfsMeterValues.scale.value
      local value = (percentage * vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + startHeight, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, value, visuals.color, 50)
      engine.DrawText2D(visuals.text, vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value * 0.4) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
      xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
    end
    if vfsMeterValues.invertSlotColor.value then
      xOffset = vfsMeterValues.pipSize.value * 1.2 * #tempMeter.types.majorRune.visuals
      local fullCount = gRunicTable.pipCount - #tempMeter.types.majorRune.visuals
      for _ = 1, fullCount do
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (vfsMeterValues.pipSize.value + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.fullColor, 85)
        engine.DrawText2D("ready", vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value * 0.175) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
        xOffset = xOffset + vfsMeterValues.pipSize.value * 1.2
      end
    end
    xOffset = vfsMeterValues.pipSize.value * 1.2 * gRunicTable.pipCount
    height = vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5 * 1.25
    local pipsize = vfsMeterValues.pipSize.value * 1.25
    for i = 1, #tempMeter.types.majorRune.majorvisuals do
      if vfsMeterValues.invertSlotColor.value == false then
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.borderColor, 50)
      end
      local visuals = tempMeter.types.majorRune.majorvisuals[i]
      local percentage = visuals.currentCooldown / visuals.cooldown
      if vfsMeterValues.invertSlotColor.value then
        percentage = 1 - percentage
      end
      local startHeight = pipsize * 0.5 * vfsMeterValues.scale.value - percentage * pipsize * vfsMeterValues.scale.value
      local value = (percentage * pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value
      engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value + startHeight, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, value, visuals.color, 50)
      engine.DrawText2D(visuals.text, vfsMeterValues.xLoc.value + (xOffset + pipsize * 0.4) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
      xOffset = xOffset + pipsize * 1.2
    end
    if vfsMeterValues.invertSlotColor.value then
      xOffset = vfsMeterValues.pipSize.value * 1.2 * gRunicTable.pipCount + pipsize * 1.2 * #tempMeter.types.majorRune.majorvisuals
      local fullCount = vfsMeterValues.majorRuneSize.value - #tempMeter.types.majorRune.majorvisuals
      for _ = 1, fullCount do
        engine.DrawRect2D(vfsMeterValues.xLoc.value + xOffset * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value - height, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, (pipsize + vfsMeterValues.borderSize.value) * vfsMeterValues.scale.value, tempMeter.fullColor, 85)
        engine.DrawText2D("ready", vfsMeterValues.xLoc.value + (xOffset + vfsMeterValues.pipSize.value * 0.3) * vfsMeterValues.scale.value, vfsMeterValues.yLoc.value, 16777215, 100, 2 * (0.25 * vfsMeterValues.scale.value))
        xOffset = xOffset + pipsize * 1.2
      end
    end
  end
end
function SetMeter(C)
  local reduction = C:MeterGetValue("SpecialMeterReduction") * vfsMeterValues.meterGainMultiplier.value
  C:MeterSetValue("SpecialMeterReduction", 0)
  local pipCount = (game.Wallets.GetResourceValue("HERO", "MaxRunicUpgrade") == -1 and 0 or game.Wallets.GetResourceValue("HERO", "MaxRunicUpgrade")) + 1
  if pipCount ~= gRunicTable.pipCount then
    uiCalls.UI_Refresh_HUD()
    gRunicTable.pipCount = pipCount
  end
  local total = gRunicTable.pipCount * vfsMeterValues.pipSize.value
  local percentage = C:MeterGetValue("SpecialMeter") / total
  if tempMeter.currentType == "default" then
    if percentage < 0.25 then
      reduction = reduction * vfsMeterValues.scaledRegenRate_0.value
    elseif percentage < 0.5 then
      reduction = reduction * vfsMeterValues.scaledRegenRate_25.value
    elseif percentage < 0.75 then
      reduction = reduction * vfsMeterValues.scaledRegenRate_50.value
    else
      reduction = reduction * vfsMeterValues.scaledRegenRate_75.value
    end
  elseif percentage < 0.25 then
    reduction = reduction * vfsMeterValues.scaledRegenRate_0.value
  elseif percentage < 0.5 then
    reduction = reduction * vfsMeterValues.scaledRegenRate_25.value
  elseif percentage < 0.75 then
    reduction = reduction * vfsMeterValues.scaledRegenRate_50.value
  else
    reduction = reduction * vfsMeterValues.scaledRegenRate_75.value
  end
  local regenAmount = C:GetUnitTime() * pipValue / vfsMeterValues.regenRate.value
  if tempMeter.currentType == "default" then
    local currentValue = C:MeterGetValue("SpecialMeter") + reduction + regenAmount
    local maxValue = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    if currentValue > maxValue then
      currentValue = maxValue
    end
    if currentValue < 0 then
      currentValue = 0
    end
    local prevCount = tempMeter.types.default.prevCount
    local currentCount = math.floor(currentValue / vfsMeterValues.pipSize.value)
    if currentCount ~= prevCount then
      if prevCount < currentCount then
        AddMeterVisualFX(C, currentCount, 16777215, "bar")
      end
      tempMeter.types.default.prevCount = currentCount
    end
    tempMeter.types.default.value = currentValue
    C:MeterSetValue("SpecialMeter", currentValue)
  end
  if tempMeter.currentType == "overheat" then
    local totalValue = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    local addedValues = 0
    for _, v in pairs(tempMeter.types.overheat.meters) do
      v.value = v.value - (regenAmount + reduction)
      if v.value < 0 then
        v.value = 0
      end
      totalValue = totalValue - v.value
      addedValues = addedValues + v.value
    end
    if totalValue < 0 then
      totalValue = 0
    end
    if addedValues > gRunicTable.pipCount * vfsMeterValues.pipSize.value then
      if C:HasMarker("Overheat") == false then
        C:AddMarker("Overheat")
      end
    elseif addedValues <= (gRunicTable.pipCount - 1) * vfsMeterValues.pipSize.value and C:HasMarker("Overheat") then
      AddMeterVisualFX(C, gRunicTable.pipCount, 16777215, "bar")
      C:RemoveMarker("Overheat")
    end
    tempMeter.types.overheat.value = totalValue
    C:MeterSetValue("SpecialMeter", totalValue)
  end
  if tempMeter.currentType == "cooldownSlot" then
    local removalIndices = {}
    for i = #tempMeter.types.cooldownSlots.visuals, 1, -1 do
      local theType = tempMeter.types.cooldownSlots.visuals[i]
      theType.currentCooldown = theType.currentCooldown - (reduction + regenAmount)
      if 0 >= theType.currentCooldown then
        table.insert(removalIndices, i - 1)
        table.remove(tempMeter.types.cooldownSlots.visuals, i)
      end
    end
    for _, v in ipairs(removalIndices) do
      local theoffset = vfsMeterValues.xLoc.value + (vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * v + vfsMeterValues.pipSize.value * 1.2 * v) + vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
      AddMeterVisualFX(C, theoffset, 16777215, "square")
    end
    local totalValue = (gRunicTable.pipCount - #tempMeter.types.cooldownSlots.visuals) * vfsMeterValues.pipSize.value
    C:MeterSetValue("SpecialMeter", totalValue)
  end
  if tempMeter.currentType == "connected" then
    local removalIndices = {}
    local disabledIndices = {}
    for i = #tempMeter.types.connected.visuals, 1, -1 do
      local theType = tempMeter.types.connected.visuals[i]
      local nextType
      local canReduce = true
      if i + 1 <= #tempMeter.types.connected.visuals then
        nextType = tempMeter.types.connected.visuals[i + 1]
        if theType.name == nextType.name and nextType.currentCooldown / nextType.cooldown > 1 - vfsMeterValues.spilloverPercentage.value then
          canReduce = false
          disabledIndices[i] = true
        end
      end
      if canReduce then
        theType.currentCooldown = theType.currentCooldown - (reduction + regenAmount)
        if 0 >= theType.currentCooldown then
          uiCalls.UI_Event_Weapon_Special_Cooldown_End(tempMeter.types.connected.visuals[i])
          table.insert(removalIndices, i - 1)
          table.remove(tempMeter.types.connected.visuals, i)
        end
      end
    end
    uiCalls.UI_Event_Weapon_Special_Cooldown_Change(tempMeter.types.connected.visuals, disabledIndices)
    for _, v in ipairs(removalIndices) do
      local theoffset = vfsMeterValues.xLoc.value + (vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * v + vfsMeterValues.pipSize.value * 1.2 * v) + vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
      AddMeterVisualFX(C, theoffset, 16777215, "square")
    end
    local totalValue = (gRunicTable.pipCount - #tempMeter.types.connected.visuals) * vfsMeterValues.pipSize.value
    C:MeterSetValue("SpecialMeter", totalValue)
  end
  if tempMeter.currentType == "majorRune" then
    local removalIndices = {}
    for i = #tempMeter.types.majorRune.visuals, 1, -1 do
      local theType = tempMeter.types.majorRune.visuals[i]
      theType.currentCooldown = theType.currentCooldown - (reduction + regenAmount)
      if 0 >= theType.currentCooldown then
        table.insert(removalIndices, i - 1)
        table.remove(tempMeter.types.majorRune.visuals, i)
      end
    end
    for _, v in ipairs(removalIndices) do
      local theoffset = vfsMeterValues.xLoc.value + (vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * v + vfsMeterValues.pipSize.value * 1.2 * v) + vfsMeterValues.pipSize.value * vfsMeterValues.scale.value * 0.5
      AddMeterVisualFX(C, theoffset, 16777215, "square")
    end
    removalIndices = {}
    for i = #tempMeter.types.majorRune.majorvisuals, 1, -1 do
      local theType = tempMeter.types.majorRune.majorvisuals[i]
      theType.currentCooldown = theType.currentCooldown - (reduction + regenAmount)
      if 0 >= theType.currentCooldown then
        table.insert(removalIndices, i - 1)
        table.remove(tempMeter.types.majorRune.majorvisuals, i)
      end
    end
    local xOffset = vfsMeterValues.pipSize.value * 1.2 * gRunicTable.pipCount
    local pipsize = vfsMeterValues.pipSize.value * 1.25
    for _, v in ipairs(removalIndices) do
      local theoffset = vfsMeterValues.xLoc.value + xOffset + (pipsize * vfsMeterValues.scale.value * v + pipsize * 1.2 * v) + pipsize * vfsMeterValues.scale.value * 0.5
      AddMeterVisualFX(C, theoffset, 16777215, "square")
    end
    local minorValue = (gRunicTable.pipCount - #tempMeter.types.majorRune.visuals) * vfsMeterValues.pipSize.value
    local majorValue = (vfsMeterValues.majorRuneSize.value - #tempMeter.types.majorRune.majorvisuals) * vfsMeterValues.pipSize.value
    C:MeterSetValue("SpecialMeter", minorValue)
    C:MeterSetValue("MajorRuneMeter", majorValue)
  end
end
function ValidType(C)
  if vfsMeterValues.queueType.value == 1 then
    tempMeter.types.overheat.displayType = "queue"
  elseif vfsMeterValues.queueType.value == 2 then
    tempMeter.types.overheat.displayType = "inOrder"
  end
  if gVFSSpecialType.value == 1 then
    tempMeter.currentType = "cooldown"
    return false
  elseif gVFSSpecialType.value == 2 then
    tempMeter.currentType = "default"
    return true
  elseif gVFSSpecialType.value == 3 then
    tempMeter.currentType = "overheat"
    return true
  elseif gVFSSpecialType.value == 4 then
    tempMeter.currentType = "cooldownSlot"
    return true
  elseif gVFSSpecialType.value == 5 then
    tempMeter.currentType = "majorRune"
    return true
  elseif gVFSSpecialType.value == 6 then
    tempMeter.currentType = "connected"
    return true
  elseif gVFSSpecialType.value == 7 then
    tempMeter.currentType = "cooldownslot"
    return true
  end
  return false
end
function MeterReductionLogic(C)
  local reduction = C:MeterGetValue("SpecialMeterReduction")
  C:MeterSetValue("SpecialMeterReduction", 0)
  local currentValue = C:MeterGetValue("SpecialMeter") + reduction
  C:MeterSetValue("SpecialMeter", currentValue)
  tempMeter.types.default.value = currentValue
end
function DrawSpecialMeter(C)
  if ValidType(C) then
    ResetMeters(C)
  end
end
function ForceResetMeter(C)
  if C ~= nil then
    tempMeter.types.default.value = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    C:MeterSetValue("SpecialMeter", tempMeter.types.default.value)
    tempMeter.types.default.prevCount = gRunicTable.pipCount
    tempMeter.types.overheat.value = 0
    tempMeter.types.overheat.meters = {}
    tempMeter.types.overheat.meters.AxeLight = {
      value = 0,
      color = 1289174,
      cost = 25
    }
    tempMeter.types.overheat.meters.AxeHeavy = {
      value = 0,
      color = 14765,
      cost = 75
    }
    tempMeter.types.overheat.meters.BladeLight = {
      value = 0,
      color = 16766038,
      cost = 50
    }
    tempMeter.types.overheat.meters.BladeHeavy = {
      value = 0,
      color = 16740864,
      cost = 100
    }
    tempMeter.types.overheat.displayMeters = {}
    C:RemoveMarker("Overheat")
    tempMeter.types.weaponType = {}
    tempMeter.types.weaponType.meters = {}
    tempMeter.types.cooldownSlots.visuals = {}
    tempMeter.types.majorRune.visuals = {}
    tempMeter.types.majorRune.majorvisuals = {}
    tempMeter.types.connected.visuals = {}
    tempMeter.types.connected.meterCount = 0
  else
    tempMeter.types.default.value = tempMeter.types.default.value
  end
end
function LuaHook_ForceResetSpecialMeters(C)
  ResetMeters(C, true)
end
function ResetMeters(C, force)
  if force == nil then
    force = false
  end
  if game.Player.IsPlayer(C) and C:IsInDebugMovementMode() or force == true then
    tempMeter.types.default.value = gRunicTable.pipCount * vfsMeterValues.pipSize.value
    C:MeterSetValue("SpecialMeter", tempMeter.types.default.value)
    tempMeter.types.default.prevCount = gRunicTable.pipCount
    tempMeter.types.overheat.value = 0
    tempMeter.types.overheat.meters = {}
    tempMeter.types.overheat.meters.AxeLight = {
      value = 0,
      color = 1289174,
      cost = 25
    }
    tempMeter.types.overheat.meters.AxeHeavy = {
      value = 0,
      color = 14765,
      cost = 75
    }
    tempMeter.types.overheat.meters.BladeLight = {
      value = 0,
      color = 16766038,
      cost = 50
    }
    tempMeter.types.overheat.meters.BladeHeavy = {
      value = 0,
      color = 16740864,
      cost = 100
    }
    tempMeter.types.overheat.displayMeters = {}
    C:RemoveMarker("Overheat")
    tempMeter.types.weaponType = {}
    tempMeter.types.weaponType.meters = {}
    tempMeter.types.cooldownSlots.visuals = {}
    tempMeter.types.majorRune.visuals = {}
    tempMeter.types.majorRune.majorvisuals = {}
    tempMeter.types.connected.visuals = {}
    tempMeter.types.connected.meterCount = 0
  else
    tempMeter.types.default.value = tempMeter.types.default.value
  end
end
function OverheatMeterAddLogic(C, meterType, value)
  if tempMeter.types.overheat.displayType == "queue" and tempMeter.types.overheat.meters[meterType].value <= 0 then
    table.insert(tempMeter.types.overheat.displayMeters, #tempMeter.types.overheat.displayMeters + 1, meterType)
  end
  tempMeter.types.overheat.meters[meterType].value = tempMeter.types.overheat.meters[meterType].value + value
end
function SpecialMeterAdd(C, meterType, value)
  print("I'm in special meter add")
  if value == 25 then
    value = value * vfsMeterValues.minimumMeterAmount.value
  end
  if tempMeter.currentType == "default" then
    local currentValue = C:MeterGetValue("SpecialMeter") - value
    C:MeterSetValue("SpecialMeter", currentValue)
  elseif tempMeter.currentType == "overheat" then
    OverheatMeterAddLogic(C, meterType, value)
  elseif tempMeter.currentType == "cooldownSlot" then
    local meterptr = tempMeter.types.cooldownSlots.meters[meterType]
    local txt = "AL"
    if meterType == "AxeHeavy" then
      txt = "AH"
    elseif meterType == "BladeLight" then
      txt = "BL"
    elseif meterType == "BladeHeavy" then
      txt = "BH"
    end
    tempMeter.types.cooldownSlots.visuals[#tempMeter.types.cooldownSlots.visuals + 1] = {
      text = txt,
      meterType = meterType,
      currentCooldown = meterptr.cooldown,
      cooldown = meterptr.cooldown,
      color = meterptr.color
    }
  elseif tempMeter.currentType == "majorRune" then
    local meterptr = tempMeter.types.majorRune.meters[meterType]
    local txt = "AL"
    if meterType == "AxeHeavy" then
      txt = "AH"
    elseif meterType == "BladeLight" then
      txt = "BL"
    elseif meterType == "BladeHeavy" then
      txt = "BH"
    end
    local thisVisual
    local minorMeterVal = C:MeterGetValue("SpecialMeter")
    if 25 <= minorMeterVal then
      thisVisual = tempMeter.types.majorRune.visuals
    else
      local majorMeterVal = C:MeterGetValue("MajorRuneMeter")
      if 25 <= majorMeterVal then
        thisVisual = tempMeter.types.majorRune.majorvisuals
      end
    end
    if thisVisual == nil then
      return
    end
    thisVisual[#thisVisual + 1] = {
      text = txt,
      meterType = meterType,
      currentCooldown = meterptr.cooldown,
      cooldown = meterptr.cooldown,
      color = meterptr.color
    }
  elseif tempMeter.currentType == "connected" then
    local txt = "AL"
    if meterType == "AxeHeavy" then
      txt = "AH"
    elseif meterType == "BladeLight" then
      txt = "BL"
    elseif meterType == "BladeHeavy" then
      txt = "BH"
    end
    local insertIndex = 1
    local found = false
    for i, v in ipairs(tempMeter.types.connected.visuals) do
      if meterType == v.name then
        found = true
        insertIndex = i
        break
      end
    end
    local thisMeter = tempMeter.types.connected.meters[meterType]
    if found == false then
      insertIndex = #tempMeter.types.connected.visuals + 1
    end
    tempMeter.types.connected.meterCount = tempMeter.types.connected.meterCount + 1
    print("num fired off:" .. tempMeter.types.connected.meterCount)
    table.insert(tempMeter.types.connected.visuals, insertIndex, {
      text = txt,
      name = meterType,
      currentCooldown = thisMeter.cooldown,
      cooldown = thisMeter.cooldown,
      color = thisMeter.color,
      id = tempMeter.types.connected.meterCount
    })
    uiCalls.UI_Event_Weapon_Special_Cooldown_Start(tempMeter.types.connected.visuals[insertIndex])
    uiCalls.UI_Event_Weapon_Special_Activated(tempMeter.types.connected.visuals[insertIndex])
  end
end
function AddMajorRune(C, meterType)
  if tempMeter.currentType == "majorRune" then
    local meterptr = tempMeter.types.majorRune.meters[meterType]
    local txt = "AL"
    if meterType == "AxeHeavy" then
      txt = "AH"
    elseif meterType == "BladeLight" then
      txt = "BL"
    elseif meterType == "BladeHeavy" then
      txt = "BH"
    end
    tempMeter.types.majorRune.majorvisuals[#tempMeter.types.majorRune.majorvisuals + 1] = {
      text = txt,
      meterType = meterType,
      currentCooldown = meterptr.cooldown,
      cooldown = meterptr.cooldown,
      color = meterptr.color
    }
  end
end
function EmptyShellSound()
  if tempMeter.types.connected.meterCount == 0 then
    print("fire off empty sound")
  end
end
function LuaHook_MajorAXE_L(C)
  AddMajorRune(C, "AxeLight")
end
function LuaHook_MajorAXE_H(C)
  AddMajorRune(C, "AxeHeavy")
end
function LuaHook_MajorBLADE_L(C)
  AddMajorRune(C, "BladeLight")
end
function LuaHook_MajorBLADE_H(C)
  AddMajorRune(C, "BladeHeavy")
end
function LuaHook_SpecialMeter_1AXE_L(C)
  SpecialMeterAdd(C, "AxeLight", 25)
  print("fire off special attack")
end
function LuaHook_SpecialMeter_2AXE_L(C)
  SpecialMeterAdd(C, "AxeLight", 50)
  print("fire off special attack")
end
function LuaHook_SpecialMeter_3AXE_L(C)
  SpecialMeterAdd(C, "AxeLight", 75)
  print("fire off special attack")
end
function LuaHook_SpecialMeter_4AXE_L(C)
  SpecialMeterAdd(C, "AxeLight", 100)
  print("fire off special attack")
end
function LuaHook_SpecialMeter_1AXE_H(C)
  SpecialMeterAdd(C, "AxeHeavy", 25)
  print("fire off special attack")
end
function LuaHook_SpecialMeter_2AXE_H(C)
  SpecialMeterAdd(C, "AxeHeavy", 50)
  print("fire off special attack")
end
function LuaHook_SpecialMeter_3AXE_H(C)
  SpecialMeterAdd(C, "AxeHeavy", 75)
  print("fire off special attack")
end
function LuaHook_SpecialMeter_4AXE_H(C)
  SpecialMeterAdd(C, "AxeHeavy", 100)
end
function LuaHook_SpecialMeter_1BLADE_L(C)
  SpecialMeterAdd(C, "BladeLight", 25)
end
function LuaHook_SpecialMeter_2BLADE_L(C)
  SpecialMeterAdd(C, "BladeLight", 50)
end
function LuaHook_SpecialMeter_3BLADE_L(C)
  SpecialMeterAdd(C, "BladeLight", 75)
end
function LuaHook_SpecialMeter_4BLADE_L(C)
  SpecialMeterAdd(C, "BladeLight", 100)
end
function LuaHook_SpecialMeter_1BLADE_H(C)
  SpecialMeterAdd(C, "BladeHeavy", 25)
end
function LuaHook_SpecialMeter_2BLADE_H(C)
  SpecialMeterAdd(C, "BladeHeavy", 50)
end
function LuaHook_SpecialMeter_3BLADE_H(C)
  SpecialMeterAdd(C, "BladeHeavy", 75)
end
function LuaHook_SpecialMeter_4BLADE_H(C)
  SpecialMeterAdd(C, "BladeHeavy", 100)
end
function LuaHook_SpecialMeter_1SPEAR_L(C)
  SpecialMeterAdd(C, "SpearLight", 25)
end
function LuaHook_SpecialMeter_2SPEAR_L(C)
  SpecialMeterAdd(C, "SpearLight", 50)
end
function LuaHook_SpecialMeter_3SPEAR_L(C)
  SpecialMeterAdd(C, "SpearLight", 75)
end
function LuaHook_SpecialMeter_4SPEAR_L(C)
  SpecialMeterAdd(C, "SpearLight", 100)
end
function LuaHook_SpecialMeter_1SPEAR_H(C)
  SpecialMeterAdd(C, "SpearHeavy", 25)
end
function LuaHook_SpecialMeter_2SPEAR_H(C)
  SpecialMeterAdd(C, "SpearHeavy", 50)
end
function LuaHook_SpecialMeter_3SPEAR_H(C)
  SpecialMeterAdd(C, "SpearHeavy", 75)
end
function LuaHook_SpecialMeter_4SPEAR_H(C)
  SpecialMeterAdd(C, "SpearHeavy", 100)
end
local previousTarget
function MarkCurrentTarget(C)
  local currentTarget = C:GetTargetCreature()
  if currentTarget ~= previousTarget then
    if previousTarget ~= nil then
      previousTarget:RemoveMarker("CurrentTarget")
    end
    previousTarget = currentTarget
    currentTarget:AddMarker("CurrentTarget")
  end
end
function IsPlayer()
  return kratos ~= nil and kratos:GetPlayer() ~= nil
end
local DynamicFlagLargeIntegerOptimization = false
local isAttacking = false
local isBlocking = false
local isPlayer = false
local isAiming = false
local BOOToggle1 = false
function OnCreatureUpdate(C)
  if kratos == nil then
    kratos = C
  end
  DynamicFlagLargeIntegerOptimization = C.CheckDynamicFlagLargeInteger ~= nil
  isAttacking = C:HasMarker("Attacking")
  isBlocking = C:CheckDynamicFlag("Blocking")
  isAiming = C:HasMarker("Aiming")
  isPlayer = IsPlayer()
  local player = game.Player.FindPlayer()
  UpdateSprintMaintainHelper(C)
  InvalidateWeaponSwitchRequests(C)
  UpdateMomentum(C)
  UpdateWhiplash(C)
  local shieldChangedThisFrame = UpdateShieldChargeMaterialAnims(C, player)
  UpdateScriptedMaterialAnims(C, player)
  CheckForCompanionContextualR3(C)
  local hasPlayerMarker = C:HasMarker("PlayerCharacter")
  if isPlayer and not hasPlayerMarker then
    C:AddMarker("PlayerCharacter")
  elseif not isPlayer and hasPlayerMarker then
    C:RemoveMarker("PlayerCharacter")
  end
  if shieldSoundEmitter == nil then
    shieldSoundEmitter = C:FindSingleSoundEmitterByName("SNDLeftHand")
  end
  if game.Combat.GetCombatStatus then
    if not game.Combat.GetCombatStatus() then
      game.Interact.EnableTags("NotInCombat")

      if isPlayer and player:MeterGetValue("Health") < player:MeterGetMax("Health") then
        player:MeterSetValue("Health", math.min(player:MeterGetValue("Health") + 0.05, player:MeterGetMax("Health")))
      end
    else
      game.Interact.DisableTags("NotInCombat")
    end
  end
  inSynchCurrentFrame = C:IsDoingSyncMove()
  if inSynchMovePrevFrame ~= nil and inSynchMovePrevFrame == true and inSynchCurrentFrame == false then
    C:PickupAcquire("PostCSMoveInvulnerability")
  end
  inSynchMovePrevFrame = inSynchCurrentFrame
  DoMemoryDebugHelpers()
  if engine.SetInCombat then
    engine.SetInCombat(game.Combat.GetCombatStatus())
  end
  local BOO = GetBOOWeapon()
  local currentWeapon = C.GetCurrentWeapon and C:GetCurrentWeapon() or nil
  if BOO ~= nil then
    if currentWeapon == "BOO" and BOOToggle1 == false then
      BOO:PlayAnimationToPercent(1, {
        Animation = "olympusBlade_matOn",
        Rate = 1
      })
      BOOToggle1 = true
    elseif BOOToggle1 == true and (currentWeapon ~= "BOO" or C:PickupIsAcquired("RageModeOlympus") and C:PickupGetStage("RageModeOlympus") == 0) then
      BOO:PlayAnimationToPercent(0, {
        Animation = "olympusBlade_matOn",
        Rate = -4.5
      })
      BOOToggle1 = false
    end
  end
  if C.GroundLevel then
    if string.find(C.GroundLevel.Name, "Msp") or string.find(C.GroundLevel.Name, "Nif_Spark") or string.find(C.GroundLevel.Name, "Asg_Rag970") or string.find(C.GroundLevel.Name, "Asg_Fort500") then
      C:SetDynamicFlag("BOO_USE_MILD_LUT")
    else
      C:RemoveDynamicFlag("BOO_USE_MILD_LUT")
    end
  end
  encounterMusic.activeEnemies = game.Encounters.GetEnemiesInCombatCount()
  if encounterMusic.activeEnemies ~= encounterMusic.lastEnemyCount then
    game.Audio.SetBusLevelRTPCValue("MX_Intensity_Meter", game.Audio.GetMusicIntensity() + encounterMusic.activeEnemies)
    print(tostring(game.Audio.GetMusicIntensity() + encounterMusic.activeEnemies) .. " music meter")
  end
  encounterMusic.lastEnemyCount = encounterMusic.activeEnemies
  if C.SetOverrideStatusEffectIconParent == nil then
    for statusEffect, value in pairs(statusEffectIconsOn) do
      if 0 < C:MeterGetValue(tostring(statusEffect)) and value == false then
        mpicon.level.Create(C, tostring(statusEffect) .. "_DEBUFF")
        mpicon.level.Parent(C, tostring(statusEffect) .. "_DEBUFF", "KRATOS_HEALTH_BAR")
        statusEffectIconsOn[tostring(statusEffect)] = true
      elseif 0 >= C:MeterGetValue(tostring(statusEffect)) and value == true then
        mpicon.level.Off(C, tostring(statusEffect) .. "_DEBUFF")
        statusEffectIconsOn[tostring(statusEffect)] = false
      end
    end
  end
  if 0 < C:MeterGetValue("Bifrost") and gVFSBifrostShowStatusEffectIcon.value == false then
    mpicon.level.Off(C, "BIFROST_DEBUFF")
  end
  if C:PickupIsAcquired("Debuff_Hero_Burn") then
    if tempDebuffBurnTimer <= 0 then
      tempDebuffBurnTimer = 8
    end
    if 0 < tempDebuffBurnTimer then
      tempDebuffBurnTimer = tempDebuffBurnTimer - C:GetUnitTime()
    end
  end
  if C:PickupIsAcquired("ForceRageModeDisabled") then
    C:MeterSetValue("Blood", 0)
  end
  if game.Resources.SetDebugAddMode then
    game.Resources.SetDebugAddMode(true)
  end
  if game.build.GOLD_VERSION ~= 1 then
    if VFS.EnableMomentumSystem.value == true and C:PickupIsAcquired("MomentumBaseShared") == false then
      C:PickupAcquire("MomentumBaseShared")
      C:PickupAcquire("MomentumAxeMeter")
      C:PickupAcquire("MomentumBladesMeter")
      C:PickupAcquire("MomentumSpearMeter")
    end
    if 0 <= VFS.SetMomentumAmount.value then
      C:MeterSetValue("Momentum", VFS.SetMomentumAmount.value)
    end
    if VFS.ForceDamagePlayer.value == true then
      VFS.ForceDamagePlayer.value = false
      Debug_PlayConcussionOnPlayer(C)
    end
    if VFS.EnableEasyStun.value == true and VFS.EnableEasyStunCurrentState == false then
      if C:PickupIsAcquired("Buff_EasyStun") == false then
        C:PickupAcquire("Buff_EasyStun")
      end
      VFS.EnableEasyStunCurrentState = true
    elseif VFS.EnableEasyStun.value == false and VFS.EnableEasyStunCurrentState == true then
      if C:PickupIsAcquired("Buff_EasyStun") == true then
        C:PickupRelinquish("Buff_EasyStun")
      end
      VFS.EnableEasyStunCurrentState = false
    end
    if VFS.DisableStun.value == true and VFS.DisableStunCurrentState == false then
      game.Level.SetVariable("DEBUG_CBT_Disable_Stun", true)
      VFS.DisableStunCurrentState = true
    elseif VFS.DisableStun.value == false and VFS.DisableStunCurrentState == true then
      game.Level.SetVariable("DEBUG_CBT_Disable_Stun", false)
      VFS.DisableStunCurrentState = false
    end
    if VFS.DisableEnemyDefense.value == true and VFS.DisableEnemyDefenseCurrentState == false then
      C:SetDynamicFlag("DEBUG_CBT_Disable_Enemy_Defense")
      VFS.DisableEnemyDefenseCurrentState = true
    elseif VFS.DisableEnemyDefense.value == false and VFS.DisableEnemyDefenseCurrentState == true then
      C:RemoveDynamicFlag("DEBUG_CBT_Disable_Enemy_Defense")
      VFS.DisableEnemyDefenseCurrentState = false
    end
    if VFS.InfiniteRunic.value == true then
      ResetMeters(C, true)
      engine.VFSSetInt("/Combat/Cheats/Disable Cooldown", 1)
    end
    if VFS.InfiniteRage.value == true then
      C:MeterSetValue("Blood", 100)
    end
    if VFS.InfiniteMomentum.value == true then
      C:MeterSetValue("MomentumBaseShared", 100)
      if not C:PickupIsAcquired("MomentumAxeMeter") then
        C:PickupAcquire("MomentumAxeMeter")
      end
      if not C:PickupIsAcquired("MomentumBladesMeter") then
        C:PickupAcquire("MomentumBladesMeter")
      end
      if not C:PickupIsAcquired("MomentumSpearMeter") then
        C:PickupAcquire("MomentumSpearMeter")
      end
    end
    if VFS.ShowWorldOffscreenIndicator.value then
      OffScreenRingUpate(C)
    end
    if VFS.CSMoveIndex.value ~= -1 then
      for _, mrkr in pairs(VFS.CSMoveIndexStrings) do
        if mrkr ~= VFS.CSMoveIndexStrings[VFS.CSMoveIndex.value + 1] and C:HasMarker(mrkr) then
          C:RemoveMarker(mrkr)
        end
      end
      if not C:HasMarker(VFS.CSMoveIndexStrings[VFS.CSMoveIndex.value + 1]) then
        C:AddMarker(VFS.CSMoveIndexStrings[VFS.CSMoveIndex.value + 1])
      end
    else
      for _, mrkr in pairs(VFS.CSMoveIndexStrings) do
        if C:HasMarker(mrkr) then
          C:RemoveMarker(mrkr)
        end
      end
    end
    if VFS.showShieldMaterialAnimForEquippedShield.value == true then
      if GuardianShieldEquipped() then
        local shieldObj = GetShieldWeapon()
        if shieldObj ~= nil then
          shieldObj:PlayAnimationToPercent(1, {
            Animation = "kratosShield00_guardian_chargeUp",
            Rate = 1
          })
        end
        return
      end
      if SiegeGuardShieldEquipped() then
        local shieldObj = GetShieldWeapon()
        if shieldObj ~= nil then
          shieldObj:PlayAnimationToPercent(1, {
            Animation = "kratosShield00_siege_chargeUp",
            Rate = 1
          })
        end
        return
      end
      if MegaBusterShieldEquipped() then
        local shieldObj = GetShieldWeapon()
        if shieldObj ~= nil then
          shieldObj:PlayAnimationToPercent(1, {
            Animation = "kratosShield00_megaBuster_chargeUp",
            Rate = 1
          })
        end
        return
      end
      if BlitzRushShieldEquipped() then
        local shieldObj = GetShieldWeapon()
        if shieldObj ~= nil then
          shieldObj:PlayAnimationToPercent(1, {
            Animation = "kratosShield00_blitz_chargeUp",
            Rate = 1
          })
        end
        return
      end
      if PerfectParryShieldEquipped() then
        local shieldObj = GetShieldWeapon()
        if shieldObj ~= nil then
          shieldObj:PlayAnimationToPercent(1, {
            Animation = "kratosShield00_parry_chargeUp",
            Rate = 1
          })
        end
        return
      end
    end
  end
  if game.Resources.SetDebugAddMode then
    game.Resources.SetDebugAddMode(false)
  end
  if isPlayer and player.UpdateTargetedState then
    player:UpdateTargetedState()
  end
  playerVelocity = C:GetVelocity()
  SendInputDataToCompanion()
  SetInfluenceToTheaterOfOperation(C)
  MimirHeadIdleSetup()
  if wasBlocking == false and isBlocking == true and C:PickupGetStage("BlockingSwitch") ~= 2 then
    wasBlocking = true
    local shieldObj = GetShieldWeapon()
    if shieldObj ~= nil then
      C:PickupAcquire("BlockingSwitch", 1)
    end
  elseif wasBlocking == true and isBlocking == false then
    wasBlocking = false
    local shieldObj = GetShieldWeapon()
    if shieldObj ~= nil then
      C:PickupAcquire("BlockingSwitch", 0)
    end
  end
  if engine.IsDebug() then
    bboard:Set("DEBUG_TurnOnPositionDistanceDebug", VFS.PositionDistanceDebug.value)
    if C:DebugIsSelectedCreature() then
      Update_PositionDistanceDebugTable()
    end
  end
  GrabHipSelection(C)
  local myHeading = C:GetWorldForward()
  local dot = playerVelocity:Dot(myHeading)
  if dot < 0 and HipSelectionValue.Value == 0 then
    HipSelectionValue.Value = 1
  elseif 0 < dot and HipSelectionValue.Value == 1 then
    HipSelectionValue.Value = 0
  end
  if wasAiming == false and isAiming == true then
    uiCalls.UI_Event_Aim_Start()
  elseif wasAiming == true and isAiming == false then
    uiCalls.UI_Event_Aim_End()
  end
  wasAiming = isAiming
  local isCurrentlyAimCapable = true
  if C.CanAim ~= nil then
    isCurrentlyAimCapable = C:CanAim() or C:HasMarker("Cranking")
    if isPlayer and not isCurrentlyAimCapable then
      local blades = player.Blades
      if blades ~= nil then
        isCurrentlyAimCapable = blades.ThrowOutStatus == tweaks.tThrowOutStatus.eThrownWeaponStatus.kTOSInFlightOut
      end
    end
  end
  if not wasAimCapable and isCurrentlyAimCapable then
    uiCalls.UI_Event_Aim_Capable()
  elseif wasAimCapable and not isCurrentlyAimCapable then
    uiCalls.UI_Event_Aim_Incapable()
  end
  wasAimCapable = isCurrentlyAimCapable
  if wasAttacking == false and isAttacking == true then
    uiCalls.UI_Event_Attack_Start()
  elseif wasAttacking == true and isAttacking == false then
    uiCalls.UI_Event_Attack_End()
  end
  wasAttacking = isAttacking
  if inRageMode == true and C:PickupGetStage("RageMode") == 0 and C:PickupGetStage("RageModeWrath") == 0 and C:PickupGetStage("RageModeValor") == 0 and C:PickupGetStage("RageModeOlympus") == 0 then
    LuaHook_RageModeExit()
  end
  healthCurrent = C:MeterGetValue("Health")
  healthMax = C:MeterGetMax("Health")
  if healthCurrent > healthMax then
    healthCurrent = healthMax
  end
  healthPercent = math.abs(healthCurrent / healthMax) * 100
  if C:PickupIsAcquired("MuspelheimPreventPlayerDeath") then
    playerEffectiveHealthPercentForLowHealthFeedback = 100
  elseif C:PickupIsAcquired("Perk_LowHealth_RageRedirect") then
    local bonusHealthFromRage = C:MeterGetValue("Blood") / C:LookupFloatConstant("PERK_CHEST_TO_RAGE_REDIRECT_SCALAR")
    local playerEffectiveHealthCurrent = healthCurrent + bonusHealthFromRage
    playerEffectiveHealthPercentForLowHealthFeedback = math.abs(playerEffectiveHealthCurrent / healthMax) * 100
    if 100 < playerEffectiveHealthPercentForLowHealthFeedback then
      playerEffectiveHealthPercentForLowHealthFeedback = 100
    end
  else
    playerEffectiveHealthPercentForLowHealthFeedback = healthPercent
  end
  if healthPrevFrame > healthCurrent and healthMaxPrevFrame == healthMax then
    if C:HasMarker("MoveArmor") then
      game.FX.SubmitEffect(fseVignetteMoveArmor)
    else
      game.FX.SubmitEffect(fseVignetteTakeDmg)
    end
    if C:PickupIsAcquired("MuspelheimSingleHitChallenge") then
      C:PickupRelinquish("MuspelheimSingleHitChallenge")
    end
    showLowHealthWarningTimer = showLowHealthWarningTimerMax
  end
  healthPrevFrame = healthCurrent
  healthMaxPrevFrame = healthMax
  if lowHealthSFXCall == true and (game.Cinematics.IsInCinematicMode() or not isPlayer) then
    game.Audio.StopSound("SND_UX_Health_Kratos_Low_Health_LP")
    lowHealthSFXCall = false
  end
  if isPlayer then
    if playerEffectiveHealthPercentForLowHealthFeedback > playerHealthLowThreshold then
      if player.Pad ~= nil and not padColorReset then
        player.Pad:ResetLightColor()
        padColorReset = true
      end
      if lowHealthSFXCall == true then
        game.Audio.StopSound("SND_UX_Health_Kratos_Low_Health_LP")
        lowHealthSFXCall = false
      end
      showLowHealthWarningTimer = showLowHealthWarningTimerMax
    elseif playerEffectiveHealthPercentForLowHealthFeedback <= playerHealthLowThreshold and 0 < healthPercent then
      if 0 < showLowHealthWarningTimer then
        if not game.Cinematics.IsInCinematicMode() then
          game.FX.SubmitEffect(rumbles.conRumbleMedium)
          game.FX.SubmitEffect(fseVignetteTakeDmgCritical)
        end
        showLowHealthWarningTimer = showLowHealthWarningTimer - C:GetUnitTime()
      elseif not game.Cinematics.IsInCinematicMode() then
        game.FX.SubmitEffect(fseVignetteTakeDmgCriticalDelayed)
      end
      if player.Pad ~= nil then
        if playerEffectiveHealthPercentForLowHealthFeedback <= playerHealthCriticalThreshold then
          player.Pad:SetLightColor(16711680)
        else
          player.Pad:SetLightColor(16733184)
        end
        padColorReset = false
      end
      if lowHealthSFXCall == false and not game.Cinematics.IsInCinematicMode() then
        game.Audio.PlaySound("SND_UX_Health_Kratos_Low_Health_LP")
        game.Audio.PlaySound("SND_UX_Health_Kratos_Low_Health_STNG")
        game.Audio.PlayBanterNonCritical("cbt_son_KratosCriticallyWeak")
        lowHealthSFXCall = true
      end
    end
    if player.ReticleTargetCreature ~= nil then
      if player.ReticleTargetCreature == reticleTargetCreaturePrevious and isAiming then
        reticleTargetCreatureChangeTimer = reticleTargetCreatureChangeTimer + C:GetUnitTime()
      else
        reticleTargetCreatureChangeTimer = 0
      end
      reticleTargetCreaturePrevious = player.ReticleTargetCreature
    else
      reticleTargetCreatureChangeTimer = 0
    end
    if bboard then
      if player.ReticleTargetCreature then
        bboard:Set("ReticleTargetCreature", player.ReticleTargetCreature, player)
      else
        bboard:Set("ReticleTargetCreature", player, player)
      end
      if reticleTargetCreatureChangeTimer > reticleTargetCreatureTimeThresholdFast then
        bboard:Set("ReticleTargetCreatureTimeThresholdFast", true, player)
      else
        bboard:Set("ReticleTargetCreatureTimeThresholdFast", false, player)
      end
      if reticleTargetCreatureChangeTimer > reticleTargetCreatureTimeThreshold then
        bboard:Set("ReticleTargetCreatureTimeThreshold", true, player)
      else
        bboard:Set("ReticleTargetCreatureTimeThreshold", false, player)
      end
    end
  end
  if C:PickupIsAcquired("DefensePrototype_TypeBuster") and shieldChangedThisFrame == false then
    local curMetVal = C:MeterGetValue("DefenseMeter")
    local pad = game.Pad.GetPad(0)
    if player:CheckDynamicFlag("MegaBusterCharging") and pad:IsControlDown(tweaks.eControls.kC_Defend) then
      if C:MeterGetValue("DefenseMeter") > 50 then
        C:MeterSetValue("DefenseMeter", curMetVal - C:GetUnitTime() * megaBusterBuildRateHalf)
      else
        C:MeterSetValue("DefenseMeter", curMetVal - C:GetUnitTime() * megaBusterBuildRateFull)
      end
      defProtoCooldown = megaBusterGracePeriod
    else
      if C:IsPlayingMove("MOV_DefensiveSideStepEvade") == false and player:CheckDynamicFlag("EVADING") == false and player:CheckDynamicFlag("Parry") == false and player:CheckDynamicFlag("MegaBusterRelease") == false and player:CheckDynamicFlag("Attacking") == false then
        if defProtoCooldown <= 0 then
          if VFS.megaBusterType.value == 3 then
            C:MeterSetValue("DefenseMeter", 100)
          else
            local meterCap = 100
            if 0 >= C:MeterGetValue("DefenseMeter") then
              meterCap = 0
            elseif C:MeterGetValue("DefenseMeter") <= 50 then
              meterCap = 50
            end
            local newVal = curMetVal + C:GetUnitTime() * megaBusterDecayRate
            if meterCap < newVal then
              newVal = meterCap
            end
            C:MeterSetValue("DefenseMeter", newVal)
          end
        elseif defProtoCooldown < 1000 then
          defProtoCooldown = defProtoCooldown - C:GetUnitTime()
        end
      elseif VFS.megaBusterType.value == 3 then
        if 100 > C:MeterGetValue("DefenseMeter") then
          defProtoCooldown = megaBusterGracePeriod
        end
      elseif defProtoCooldown < megaBusterGracePeriodMinAfterEvade then
        defProtoCooldown = megaBusterGracePeriodMinAfterEvade
      end
      if 2 <= VFS.megaBusterType.value then
        if C:CheckDynamicFlag("MegaBusterAutoRelease") == false then
          C:SetDynamicFlag("MegaBusterAutoRelease")
        end
      elseif C:CheckDynamicFlag("MegaBusterAutoRelease") == true then
        C:RemoveDynamicFlag("MegaBusterAutoRelease")
      end
      if VFS.megaBusterType.value >= 3 then
        if C:CheckDynamicFlag("MegaBusterClearOnParry") == false then
          C:SetDynamicFlag("MegaBusterClearOnParry")
        end
      elseif C:CheckDynamicFlag("MegaBusterClearOnParry") == true then
        C:RemoveDynamicFlag("MegaBusterClearOnParry")
      end
    end
    if C:MeterGetValue("DefenseMeter") > 50 then
      C:PickupSetStage("DefensePrototype_TypeBuster", 0)
    elseif 0 < C:MeterGetValue("DefenseMeter") then
      C:PickupSetStage("DefensePrototype_TypeBuster", 1)
    else
      C:PickupSetStage("DefensePrototype_TypeBuster", 2)
    end
    local metVal = C:MeterGetValue("DefenseMeter") / 100
    uiCalls.UI_Event_Shield_Meter_Change(metVal * 5)
  end
  components.UpdateComponents(C, scriptComponents)
  if not weaponsLoaded then
    PlayBladeAudioOnLoad()
  end
  if game.Cinematics.IsInCinematicMode() then
    LuaHook_ForceClearStatusEffects()
  end
  local slotSet = game.Equipment.GetEquipmentCharacterSlotSet("Kratos")
  local slotEquipment = slotSet:QuerySlot("Spear")
  if slotEquipment ~= nil then
    local spearTransmog = slotEquipment:GetCurrentTransmogGenerator()
    if spearTransmog ~= nil and spearTransmog.Name == engine.Hash("Spear_DO") then
      if not C:CheckDynamicFlag("SpearDO_Active") then
        C:SetDynamicFlag("SpearDO_Active")
      end
    else
      C:ClearDynamicFlag("SpearDO_Active")
    end
  end
end
local RemovePlayerPickupIfAcquired = function(pickupName)
  if kratos:PickupIsAcquired(pickupName) then
    if game.Pickup.NGP_RelinquishPickupAndClearProfile then
      game.Pickup.NGP_RelinquishPickupAndClearProfile(pickupName)
    else
      kratos:PickupRelinquish(pickupName)
    end
  end
end
local ResetResourceForNGP = function(resourceName)
  if game.Wallets.NGP_ResetResource then
    game.Wallets.NGP_ResetResource("HERO", resourceName)
  else
    local value = game.Wallets.GetResourceValue("HERO", resourceName)
    if 1 <= value then
      game.Wallets.RemoveResource("HERO", resourceName, value)
    end
  end
end
function LuaHook_RageModePerkActivation()
  local HealthMeterCurrent = kratos.MeterGetValue(kratos, "Health")
  local RageMeterCurrent = kratos.MeterGetValue(kratos, "Blood")
  local newValue = HealthMeterCurrent * 0.25
  kratos:MeterSetValue("Health", HealthMeterCurrent - newValue)
  local newRageValue = RageMeterCurrent + 25
  if kratos:PickupIsAcquired("Buff_RageBurst") ~= true then
    kratos:PickupAcquire("Buff_RageBurst")
  end
end
function LuaHook_HasReticleTarget(c, data)
  if kratos.ReticleTargetCreature ~= nil then
    return data:FindOutcomeBranchesEntry("HasTarget")
  end
  return data:FindOutcomeBranchesEntry("NoTarget")
end
function LuaHook_DropThrowable()
  for weaponInfo in kratos:IterateActiveWeapons() do
    local throwObj = weaponInfo.Weapon
    if throwObj ~= nil and (throwObj:GetName() == "throwablevibrate" or throwObj:HasMarker("CombatThrowable")) then
      throwObj:CallScript("LuaHookDrop")
      game.Interact.EnableTags("ThrowableCrystal")
    end
  end
end
function LuaHook_ThrowAttached()
  game.Interact.EnableTags("ThrowableCrystal")
  for weaponInfo in kratos:IterateActiveWeapons() do
    local throwObj = weaponInfo.Weapon
    if throwObj ~= nil then
      if throwObj:GetName() == "throwablevibrate" or throwObj:HasMarker("CombatThrowable") then
        throwObj:CallScript("LuaHookOnThrowRelease")
      elseif throwObj:HasMarker("throwBomb") then
        local bombObj = throwObj:FindSingleGOByName("settings").Child
        bombObj:CallScript("LuaHookOnThrowRelease")
      end
    end
  end
end
function GetAxeWeapon()
  return kratos:GetWeapon("kWeaponAxe")
end
function GetSpearWeapon()
  return kratos:GetWeapon("kWeaponSpear")
end
function GetLeftBladeWeapon()
  return kratos:GetWeapon("kWeaponBladeLeft")
end
function GetRightBladeWeapon()
  return kratos:GetWeapon("kWeaponBladeRight")
end
function GetBOOWeapon()
  if kratos ~= nil then
    return kratos:GetWeapon("kWeaponRageModeOlympus")
  else
    return nil
  end
end
function GetBOOEquipped()
  local currentWeapon = kratos.GetCurrentWeapon and kratos:GetCurrentWeapon() or nil
  if currentWeapon ~= nil then
    return currentWeapon == "BOO"
  else
    return nil
  end
end
function GetShieldWeapon()
  return kratos:GetWeapon("kWeaponShield")
end
function GuardianShieldEquipped()
  return kratos:PickupIsAcquired("DefensePrototype_TypeDefault")
end
function SiegeGuardShieldEquipped()
  return kratos:PickupIsAcquired("DefensePrototype_TypeGuard")
end
function SiegeGuardShieldEquipped_NoDoingGroundSmash()
  return kratos:PickupIsAcquired("DefensePrototype_TypeGuard") and not kratos:CheckDynamicFlag("SiegeGuard_GroundSmash")
end
function PerfectParryShieldEquipped()
  return kratos:PickupIsAcquired("DefensePrototype_TypeParry")
end
function BlitzRushShieldEquipped()
  return kratos:PickupIsAcquired("DefensePrototype_TypeBlitz")
end
function MegaBusterShieldEquipped()
  return kratos:PickupIsAcquired("DefensePrototype_TypeBuster")
end
function TrinketArmorParryEquipped()
  return kratos:PickupIsAcquired("KratosArmorTrinket_Parry")
end
function LuaHook_AxeFrostOnSlow()
end
function LuaHook_AxeFrostOn()
  local axe = GetAxeWeapon()
  if axe ~= nil then
    axe:PauseAnimation({
      Animation = "Axe_Momentum_OFF"
    })
    axe:JumpAnimationToPercent(0, {
      Animation = "Axe_Momentum_ON"
    })
    axe:StartAnimation({
      Animation = "Axe_Momentum_ON"
    })
  end
end
function LuaHook_AxeFrostOff()
  local axe = GetAxeWeapon()
  if axe ~= nil then
    axe:PauseAnimation({
      Animation = "Axe_Momentum_ON"
    })
    axe:JumpAnimationToPercent(0.05, {
      Animation = "Axe_Momentum_OFF"
    })
    axe:StartAnimation({
      Animation = "Axe_Momentum_OFF"
    })
  end
end
function LuaHook_BladeLightUp()
  for weaponInfo in kratos:IterateActiveWeapons() do
    local gameobj = weaponInfo.Weapon
    if gameobj ~= nil and gameobj:GetName() == "explosive00" then
      gameobj:StartMaterialAnim("blade_ONOFF")
    end
  end
end
function LuaHook_DrainBladesOn()
  for weaponInfo in kratos:IterateActiveWeapons() do
    local gameobj = weaponInfo.Weapon
    if gameobj:GetName() == "explosive00" then
      print("Not yet!")
    end
  end
end
function LuaHook_DrainBladesOff()
  for weaponInfo in kratos:IterateActiveWeapons() do
    local gameobj = weaponInfo.Weapon
    if gameobj:GetName() == "explosive00" then
      print("Not yet!")
    end
  end
end
function LuaHook_ApplySpearBlackCloth()
  for weaponInfo in kratos:IterateActiveWeapons() do
    local gameobj = weaponInfo.Weapon
    if gameobj:GetName() == "kratosspear00_thrown" and kratos:CheckDynamicFlag("SpearDO_Active") then
      gameobj:SetMaterialSwap("spear_anniversary")
    end
  end
end
function Update_PositionDistanceDebugTable()
  if VFS.PositionDistanceDebug.value == true then
    local positionDistanceDebugTable = {}
    if engine.IsDebug() then
      debugPosResult = DL.PositionDistanceDebug(kratos, debugPosStart, debugPosEnd, debugPosSwitch)
      debugPosStart = debugPosResult.debugPosStart
      debugPosEnd = debugPosResult.debugPosEnd
      debugPosDistanceXZ = debugPosResult.debugPosDistanceXZ
      debugPosDistanceY = debugPosResult.debugPosDistanceY
      debugPosSwitch = debugPosResult.debugPosSwitch
      if debugPosStart ~= nil then
        table.insert(positionDistanceDebugTable, {"Start: ", debugPosStart})
      end
      if debugPosEnd ~= nil then
        table.insert(positionDistanceDebugTable, {"End: ", debugPosEnd})
      end
      if debugPosDistanceXZ ~= nil then
        table.insert(positionDistanceDebugTable, {
          "Result - XZ: ",
          debugPosDistanceXZ
        })
      end
      if debugPosDistanceY ~= nil then
        table.insert(positionDistanceDebugTable, {
          "Result - Y: ",
          debugPosDistanceY
        })
      end
      if 0 < #positionDistanceDebugTable then
        positionDistanceDebugTable.TitleColor = engine.Vector.New(0, 100, 0)
        positionDistanceDebugTable.TitleAlpha = 225
        positionDistanceDebugTable.Title = "Position Distance Debug table"
        positionDistanceDebugTable.X, positionDistanceDebugTable.Y = 150, 18
        engine.DrawDebugTable(positionDistanceDebugTable)
      end
    end
  end
end
function LuaHookScript_SpecialReticleOn()
  uiCalls.UI_Event_Minigame_Start()
end
function LuaHookScript_SpecialReticleOff()
  uiCalls.UI_Event_Minigame_End()
end
function LuaHook_FrostMeterState()
end
function LuaHook_UI_PouchOn()
  local uiKratos = game.UI.FindCreatureByGOName("goHeroA00")
  if uiKratos then
    uiKratos:ShowJoint(uiKratos:GetJointIndex("ashPouch1"))
  end
end
function LuaHook_UI_PouchOff()
  local uiKratos = game.UI.FindCreatureByGOName("goHeroA00")
  if uiKratos then
    uiKratos:HideJoint(uiKratos:GetJointIndex("ashPouch1"))
  end
end
function LuaHook_UI_ShieldOn()
  local uiKratos = game.UI.FindCreatureByGOName("goHeroA00")
  if uiKratos then
    uiKratos:ShowJoint(uiKratos:GetJointIndex("JOshieldHolster1_LeftLowerArm1Twist2_0"))
  end
end
function LuaHook_UI_ShieldOff()
  local uiKratos = game.UI.FindCreatureByGOName("goHeroA00")
  if uiKratos then
    uiKratos:HideJoint(uiKratos:GetJointIndex("JOshieldHolster1_LeftLowerArm1Twist2_0"))
  end
end
function LuaHook_TurnRageModeOn()
  uiCalls.UI_Event_Turn_Rage_Meter_On()
end
function LuaHook_TurnRageModeOff()
  uiCalls.UI_Event_Turn_Rage_Meter_Off()
end
function LuaHook_RageModeEnter()
  game.Interact.DisableTags("NotInRageMode")
  uiCalls.UI_Event_Rage_Start()
end
function LuaHook_RageBool()
  inRageMode = true
end
function LuaHook_RageModeExit()
  uiCalls.UI_Event_Rage_End()
  game.Interact.EnableTags("NotInRageMode")
  inRageMode = false
end
function LuaHook_ForceCineRageModeExit()
  local player = game.Player.FindPlayer()
  if kratos:PickupIsAcquired("RageMode") and kratos:PickupGetStage("RageMode") ~= 0 and IsPlayer() and player.ClearMarkedWeapon ~= nil then
    kratos:PickupSetStage("RageMode", 0)
    player:ClearMarkedWeapon()
  elseif kratos:PickupIsAcquired("RageModeWrath") and kratos:PickupGetStage("RageModeWrath") ~= 0 and IsPlayer() and player.ClearMarkedWeapon ~= nil then
    kratos:PickupSetStage("RageModeWrath", 0)
  elseif kratos:PickupIsAcquired("RageModeOlympus") and kratos:PickupGetStage("RageModeOlympus") ~= 0 and IsPlayer() and player.ClearMarkedWeapon ~= nil then
    kratos:PickupSetStage("RageModeOlympus", 0)
    player:ClearMarkedWeapon()
  end
  uiCalls.UI_Event_Rage_End()
  game.Interact.EnableTags("NotInRageMode")
  inRageMode = false
  LuaHook_ForceClearStatusEffects()
end
function LuaHook_ForceClearStatusEffects()
  if kratos:PickupIsAcquired("Debuff_Hero_Frost") then
    kratos:PickupRelinquish("Debuff_Hero_Frost")
  end
  if kratos:PickupIsAcquired("Debuff_Hero_Burn") then
    kratos:PickupRelinquish("Debuff_Hero_Burn")
  end
  if kratos:PickupIsAcquired("Debuff_Hero_Poison") then
    kratos:PickupRelinquish("Debuff_Hero_Poison")
  end
  if kratos:PickupIsAcquired("Debuff_Hero_Blind") then
    kratos:PickupRelinquish("Debuff_Hero_Blind")
  end
  if kratos:PickupIsAcquired("Debuff_Hero_Daze") then
    kratos:PickupRelinquish("Debuff_Hero_Daze")
  end
  if kratos:PickupIsAcquired("Debuff_Hero_Lightning") then
    kratos:PickupRelinquish("Debuff_Hero_Lightning")
  end
  if kratos:MeterGetValue("BifrostGreyDmg") > 0 then
    kratos:MeterSetValue("BifrostGreyDmg", 0)
  end
  kratos:MeterSetValue("Frost", 0)
  kratos:MeterSetValue("Burn", 0)
  kratos:MeterSetValue("Poison", 0)
  kratos:MeterSetValue("Blind", 0)
  kratos:MeterSetValue("Daze", 0)
  kratos:MeterSetValueOverride("Lightning", 0)
  kratos:MeterSetValue("Bifrost", 0)
end
function LuaHook_RageGrabActivated()
  uiCalls.UI_Event_Rage_Grab()
end
local SprintCount = 0
function LuaHook_SprintCounter(C)
  if SprintCount < 5 then
    SprintCount = SprintCount + 1
    print("Sprintcount =", SprintCount)
  elseif SprintCount == 5 then
    C:TriggerMoveEvent("kSprintCountReached")
    SprintCount = 0
  end
end
function LuaHook_SprintCounterReset(C)
  SprintCount = 0
end
function LuaHook_RequestTagTeam()
  _G.global.tagTeamPossible = false
  engine.SendHook("OnRequestTagTeamHook", game.AI.FindSon())
end
function LuaHook_SetQuestGiverMarker(crt, setMark)
  if setMark then
    crt:AddMarker("QuestGiverInteract")
    crt:SetDynamicFlag("QuestGiverInteract")
  else
    crt:RemoveMarker("QuestGiverInteract")
    crt:RemoveDynamicFlag("QuestGiverInteract")
  end
end
function OnResponseTagTeamHook(go, result)
  _G.global.tagTeamPossible = result
end
function LuaHook_GetLoot()
  if game.AI.FindSon() ~= nil then
    engine.SendHook("OnGetRuneAmmo", game.AI.FindSon())
  end
end
function OnFollowUpPromptCreate()
  mpicon.Create("WORLD_INTERACT")
end
function OnFollowUpPromptOff()
  mpicon.Off("WORLD_INTERACT")
end
function OnRecLootTableHook(go, result)
  _G.global.recLootTable = result
  if _G.global.inventory[result] == nil then
    _G.global.inventory[result] = 1
  else
    _G.global.inventory[result] = _G.global.inventory[result] + 1
  end
end
function OnSonRevive()
  kratos:TriggerMoveEvent("SonRevive")
end
function OnSonCoopJumpAttack()
  kratos:TriggerMoveEvent("SonCoop")
end
function LuaHookDecision_CanSonPerformSpecial()
  local sonAI = game.AI.FindSon()
  if sonAI == nil then
    return false
  end
  if sonAI.OwnedPOI ~= nil or sonAI:IsDoingSyncMove() or sonAI:HasMarker("TweakPOIResOnly") or sonAI:HasMarker("TweakLogicOnly") or sonAI:HasMarker("DisableCommandShot") or DL.CheckCreatureContext(sonAI:GetContext(), "SON_COOLDOWN") then
    return false
  end
  return true
end
function LuaHookDecision_CanShieldBash()
  local target = kratos:GetTargetCreature()
  if target ~= nil and (kratos.WorldPosition - target.WorldPosition):Length() <= 4 and target:PickupIsAcquired("Son_HoldMark") then
    return true
  end
  return false
end
local charging = false
local enumToggleLockOn = tweaks.eControls.kC_ToggleLockOn
function SendInputDataToCompanion()
  if not isPlayer then
    return
  end
  local ToggleLockOn_IsDown = false
  if DynamicFlagLargeIntegerOptimization then
    ToggleLockOn_IsDown = game.Pad.IsControlDown(0, enumToggleLockOn)
  else
    local pad = game.Pad.GetPad(0) or fakePad
    ToggleLockOn_IsDown = pad:IsControlDown(enumToggleLockOn)
  end
  if ToggleLockOn_IsDown then
    game.AI.SubmitStim("R3ButtonStim", engine.Vector.New(0, 0, 0), kratos)
  end
end
function SetInfluenceToTheaterOfOperation(go)
  local son = game.AI.FindSon()
  if son == nil then
    return
  end
  local sonBB = son:GetBlackboard()
  if sonBB ~= nil then
    local activateInfluence = true
    if sonBB:Exists("IsInGoToTarget") and sonBB:GetBoolean("IsInGoToTarget") then
      activateInfluence = false
    end
    go:SetInfluenceConeIsEnabled(activateInfluence)
  end
end
function LuaHookDecision_IsLastEnemy(playerCreature)
  if #DL.FindLivingEnemies(playerCreature, 35) < 1 then
    return true
  end
  return false
end
function LuaHook_ForceSonFail(ai, data)
  local companion = game.AI.GetCompanion()
  if companion ~= nil then
    engine.SendHook("OnCommandCompanionStart", companion, "Knife")
  end
end
function LuaHook_FlyerSteal(playerCreature)
  local healthStoneCount = playerCreature:GetPlayerCounter("ShardHealth")
  local rageStoneCount = playerCreature:GetPlayerCounter("ShardRage")
  if 0 < healthStoneCount then
    playerCreature:SetPlayerCounter("ShardHealth", healthStoneCount - 1)
    uiCalls.UI_Event_SendDesignerMessage("Lost Health Stone -1", 1)
    playerCreature:SpawnProp("consumableHealthRune", playerCreature:GetWorldPosition() + engine.Vector.New(0, 0.3, -0.5))
  elseif 0 < rageStoneCount then
    playerCreature:SetPlayerCounter("ShardRage", rageStoneCount - 1)
    uiCalls.UI_Event_SendDesignerMessage("Lost Rage Stone -1", 1)
    playerCreature:SpawnProp("consumableRageRune", playerCreature:GetWorldPosition() + engine.Vector.New(0, 0.3, -0.5))
  else
    print("No Inventory")
  end
end
function UpdateStunGrabDecisionTimer(C)
end
function LuaHook_TraverseLink_Vault1m(C)
  local traverseLink = C:GetTraverseLink()
  if translationDriver and rotationDriver and traverseLink then
    translationDriver.ValueVec = traverseLink.WarpLocation
    rotationDriver.ValueVec = traverseLink.WarpDirection
  end
end
function LuaHook_SetTrackingObjectOnSon(playerCreature)
  for attachmentInfo in playerCreature:IterateActiveWeapons() do
    print("tracking info is...", attachmentInfo.Weapon:GetName())
    if attachmentInfo.Weapon:GetName() == "throwablevibrate" then
      engine.SendHook("LuaHook_SetTrackingObject", game.AI.FindSon(), attachmentInfo.Weapon)
    end
  end
end
function LuaHook_ReflectProjectile(playerCreature)
  local arrowData = {}
  arrowData.Tweak = "ARR_DRAUGR_PROJECTILE_PARRY"
  arrowData.Creator = playerCreature
  arrowData.CreatorEmitJoint = "JOLeftWrist1"
  arrowData.EmitOffset = nil
  if playerCreature:GetLastAttacker() ~= nil then
    arrowData.Target = playerCreature:GetLastAttacker()
  else
    arrowData.TargetLocation = playerCreature:GetWorldPosition() + 10 * playerCreature:GetWorldFacing() + engine.Vector.New(0, 1.25, 0)
  end
  game.Combat.EmitArrow(arrowData)
end
global.beam_deflecting = false
function LuaHookScript_DeflectBeam(ai, data)
  print("Golem Deflect!")
  global.beam_deflecting = true
end
function LuaHookScript_DeflectBeam_Trigger(ai, data)
  if global.beam_deflecting then
    local attacker = ai:GetLastAttacker()
    attacker:TriggerMoveEvent("StunNow")
  end
end
function LuaHook_DeflectMissile(ai, data)
  print("deflecting missile")
  local target = ai:GetLastAttacker()
  local arrowData = {}
  arrowData.Tweak = "ARR_DEFLECTED_GOLEM_HEAT_MISSILE_V2"
  arrowData.Creator = ai
  arrowData.CreatorEmitJoint = "zeroJoint"
  arrowData.TargetLocation = ai:GetWorldPosition() + ai:GetWorldForward() * 35
  arrowData.Target = nil
  arrowData.EmitOffset = engine.Vector.New(0, 0.85, 0)
  game.Combat.EmitArrow(arrowData)
end
local IncreaseMomentum = function(C, amount)
  if C:HasMeter("MomentumBaseShared") then
    C:MeterSetValue("MomentumBaseShared", C:MeterGetValue("MomentumBaseShared") + amount)
    LuaHook_MomentumAxeIncrease()
    LuaHook_MomentumBladesIncrease()
  end
end
function OnWeaponHitGameObject(Creature, Weapon, HitGameObject, HitInfo)
  local isCreature = HitInfo.HitCreature
  local precisionHit = HitInfo.IsPrecision
  local isHeadshotTrue = HitInfo.IsHeadShot
  local isBlockedTrue = HitInfo.IsBlocked
  local partFlagsHit = HitInfo.PartFlags
  local throwModeName = HitInfo.ThrowName
  local concussionParams, currentRageMeter, currentComboMeter
  local weaponPosition = Weapon:GetWorldPosition()
  if throwModeName == "Axe_Toss_Rail" then
    if kratos:PickupGetStage("FrostSpecialAxeTossRail") <= 1 then
      concussionParams = {
        Tweak = "CNC_AXE_SPECIAL_RAIL_TOSS_HIT_REPLACE",
        EnemyId = kratos:GetID(),
        GameObject = kratos
      }
      game.Combat.PlayConcussion(concussionParams)
      game.FX.SubmitEffect(rumbles.ffbRumbleThrowHeavy)
    end
    if kratos:PickupGetStage("FrostSpecialAxeTossRail") == 2 then
      concussionParams = {
        Tweak = "CNC_AXE_SPECIAL_RAIL_TOSS_HIT_REPLACE_LVL02",
        EnemyId = kratos:GetID(),
        GameObject = kratos
      }
      game.Combat.PlayConcussion(concussionParams)
      game.FX.SubmitEffect(rumbles.ffbRumbleThrowHeavy)
    end
  end
  if throwModeName == "Axe_Toss_Rail_Triangle" then
    concussionParams = {
      Tweak = "CNC_AXE_SPECIAL_TOSS_PROC_RAIL_TRIANGLE",
      EnemyId = kratos:GetID(),
      GameObject = kratos
    }
    game.Combat.PlayConcussion(concussionParams)
    game.FX.SubmitEffect(rumbles.ffbRumbleThrowHeavy)
  end
  if throwModeName == "Axe_Toss_Horizontal_Critical" then
    concussionParams = {
      Tweak = "CNC_AXE_SPECIAL_TOSS_PROC_HORIZONTAL",
      EnemyId = kratos:GetID(),
      GameObject = kratos
    }
    game.Combat.PlayConcussion(concussionParams)
    game.FX.SubmitEffect(rumbles.ffbRumbleThrowHeavy)
  end
  if throwModeName == "Axe_Toss_Horizontal_Critical_02" or throwModeName == "Axe_Toss_Rail_Triangle_02" then
    concussionParams = {
      Tweak = "CNC_AXE_SPECIAL_DOUBLE_TOSS_PROC",
      EnemyId = kratos:GetID(),
      GameObject = kratos
    }
    game.Combat.PlayConcussion(concussionParams)
    game.FX.SubmitEffect(rumbles.ffbRumbleThrowHeavy)
  end
  if throwModeName == "Axe_Toss_Vertical_Charged" then
    concussionParams = {
      Tweak = "CNC_AXE_VERTICAL_TOSS_IMPACT",
      EnemyId = kratos:GetID(),
      GameObject = kratos
    }
    game.Combat.PlayConcussion(concussionParams)
  end
  if throwModeName == "Axe_Toss_Vertical" and kratos:PickupIsAcquired("Effect_AxeCharged") then
    concussionParams = {
      Tweak = "CNC_AXE_SPECIAL_TOSS_PROC",
      EnemyId = kratos:GetID(),
      GameObject = kratos
    }
    game.Combat.PlayConcussion(concussionParams)
  end
  if isBlockedTrue == 0 and isCreature == 1 then
    IncreaseMomentum(Creature, 0.1)
    if throwModeName ~= nil and string.find(throwModeName, "Spear_Toss") ~= nil then
      currentRageMeter = kratos.MeterGetValue(kratos, "Blood")
      kratos:MeterSetValue("Blood", currentRageMeter + 1.5)
    end
    if throwModeName ~= nil and string.find(throwModeName, "Axe_Toss") ~= nil then
      if kratos:PickupIsAcquired("Buff_LightningAxe") == true then
        concussionParams = {
          Tweak = "CNC_AXE_MELEE_DAMAGE_PROC_LIGHTNING",
          EnemyId = kratos:GetID(),
          GameObject = kratos
        }
        game.Combat.PlayConcussion(concussionParams)
        kratos:PickupRelinquish("Buff_LightningAxe")
      end
      if kratos:PickupIsAcquired("Buff_ValkyrieAxe") == true then
        concussionParams = {
          Tweak = "CNC_AXE_MELEE_DAMAGE_PROC_MASSIVE_EXPLOSION",
          EnemyId = kratos:GetID(),
          GameObject = kratos
        }
        game.Combat.PlayConcussion(concussionParams)
        kratos:PickupRelinquish("Buff_ValkyrieAxe")
      end
      currentRageMeter = kratos.MeterGetValue(kratos, "Blood")
      kratos:MeterSetValue("Blood", currentRageMeter + 2)
      if kratos:PickupIsAcquired("Buff_MomentumAxeFull") then
        if kratos:PickupGetStage("Buff_MomentumAxeFull") == 3 and kratos:AttributeGetValue("Difficulty") == 4 then
          concussionParams = {
            Tweak = "CNC_AXE_FROST_MOMENTUM_FULL_IMPOSSIBLE",
            EnemyId = kratos:GetID(),
            GameObject = kratos
          }
          game.Combat.PlayConcussion(concussionParams)
        elseif kratos:PickupGetStage("Buff_MomentumAxeFull") == 3 and kratos:AttributeGetValue("Difficulty") < 4 then
          concussionParams = {
            Tweak = "CNC_AXE_FROST_MOMENTUM_FULL",
            EnemyId = kratos:GetID(),
            GameObject = kratos
          }
          game.Combat.PlayConcussion(concussionParams)
        end
      end
    end
    if isHeadshotTrue == 1 or partFlagsHit == "PART_HEAD" then
      if throwModeName ~= "Axe_Toss_Horizontal" then
      end
      if kratos:PickupIsAcquired("Perk_Throw_OnHeadshot_Cooldown") == true then
        kratos:CallScript("LuaHook_Perk_Throw_OnHeadshot_Cooldown")
      end
      if kratos:PickupIsAcquired("Perk_Throw_OnHeadshot_OffenseBuff") == true then
        kratos:CallScript("LuaHook_Perk_Throw_OnHeadshot_OffenseBuff")
      end
      if kratos:PickupIsAcquired("Perk_Throw_OnHeadshot_Runic") == true then
        kratos:CallScript("LuaHook_Perk_Throw_OnHeadshot_Runic")
      end
      if kratos:PickupIsAcquired("Perk_Throw_OnHeadshot_Rage") == true then
        kratos:CallScript("LuaHook_Perk_Throw_OnHeadshot_Rage")
      end
      if kratos:PickupIsAcquired("Perk_Throw_OnHeadshot_HealthDrain") == true then
        kratos:CallScript("LuaHook_Perk_Throw_OnHeadshot_HealthDrain")
      end
      if kratos:PickupGetStage("Perk_Offense_OnMeleeDamage_ProcLightning") == 2 and kratos:PickupIsAcquired("Buff_LightningAxe") ~= true then
        kratos:PickupAcquire("Buff_LightningAxe")
      end
    else
      game.FX.SubmitEffect(rumbles.ffbRumbleThrow)
    end
  end
end
function UpdateSprintMaintainHelper(C)
  if C:PickupIsAcquired("SprintMaintainHelper") and not C:HasMarker("MaintainSprint") then
    C:PickupRelinquish("SprintMaintainHelper")
  end
end
local weaponSwitchButtonStates = {up = 1, down = 0}
local weaponSwitchData = {
  leftButtonState = weaponSwitchButtonStates.up,
  downButtonState = weaponSwitchButtonStates.up,
  rightButtonState = weaponSwitchButtonStates.up,
  rightPickupStage = 0,
  leftPickupStage = 1,
  downPickupStage = 2,
  downToBarePickupStage = 3,
  invalidRequestStage = 4,
  lastDownPickupStage = nil,
  spear = nil
}
function GivePickupIfNotAcquired(C, pickup)
  if not C:PickupIsAcquired(pickup) then
    C:PickupAcquire(pickup)
  end
end
function SetStageAndRelinquishPickupIfAcquired(C, stage, pickup)
  if C:PickupIsAcquired(pickup) then
    C:PickupSetStage(pickup, 4)
    C:PickupRelinquish(pickup)
  end
end
function IsPickupAcquiredNotAtStage(C, pickup, stage)
  if C:PickupIsAcquired(pickup) and C:PickupGetStage(pickup) ~= stage then
    return true
  end
  return false
end
local Hash_IgnoreWeaponSwitchRequests = game.LargeInteger.HashString("IgnoreWeaponSwitchRequests")
local Hash_AllowWeaponSwitchRequests = game.LargeInteger.HashString("AllowWeaponSwitchRequestsOverride")
local Hash_TraverseGraph = game.LargeInteger.HashString("TraverseGraph")
local Hash_Zipline = game.LargeInteger.HashString("Zipline")
local Hash_Ledge_Peek = game.LargeInteger.HashString("Ledge_Peek")
local Hash_InRageGrab = game.LargeInteger.HashString("InRageGrab")
local Hash_CleaveAttack = game.LargeInteger.HashString("CleaveAttack")
local Hash_StriderHang = game.LargeInteger.HashString("StriderHang")
local Hash_Quickturn = game.LargeInteger.HashString("Quickturn")
local Hash_Parry = game.LargeInteger.HashString("Parry")
local Hash_QuickTurn_Defend = game.LargeInteger.HashString("QuickTurn_Defend")
function InvalidateWeaponSwitchRequests(C)
  if C:CheckDynamicFlagLargeInteger(Hash_AllowWeaponSwitchRequests) then
    return
  end
  if not isPlayer or C:IsDoingSyncMove() or components.AnyRageModeIsActive(C) or game.Cinematics.IsInCinematicMode() or C.IsAxeInFlightReturn or C:HasMarkerLargeInteger(Hash_TraverseGraph) or C:HasMarkerLargeInteger(Hash_Zipline) or C:HasMarkerLargeInteger(Hash_Ledge_Peek) or C:HasMarkerLargeInteger(Hash_InRageGrab) or C:HasMarkerLargeInteger(Hash_CleaveAttack) or C:HasMarkerLargeInteger(Hash_StriderHang) or C:HasMarkerLargeInteger(Hash_Quickturn) or C:CheckDynamicFlagLargeInteger(Hash_IgnoreWeaponSwitchRequests) or C:CheckDynamicFlagLargeInteger(Hash_QuickTurn_Defend) and isBlocking and not isAttacking and not C:HasMarkerLargeInteger(Hash_Parry) then
    game.ClearLastInput()
    return
  end
end
function LuaHook_ClearLastInput(Creature)
  game.ClearLastInput()
end
function UpdateMomentum(C)
  local hasMomentumMeter = C:HasMeter("Momentum")
  if hitCounterDrain == true and C:IsDoingSyncMove() == false and hasMomentumMeter then
    local momentum = C:MeterGetValue("Momentum")
    if 0 < momentum then
      game.Audio.SetBusLevelRTPCValue("WPN_Axe_Momentum_Level", momentum / C:MeterGetMax("Momentum"))
      C:CallScript("LuaHook_DrainMomentumLoops", momentum)
    else
      hitCounterDrain = false
    end
  end
  local hasMomentumBladesMeter = C:HasMeter("MomentumBlades")
  if hitCounterDrain == true and C:IsDoingSyncMove() == false and hasMomentumBladesMeter then
    local momentumBlades = C:MeterGetValue("MomentumBlades")
    if 0 < momentumBlades then
      game.Audio.SetBusLevelRTPCValue("WPN_Blades_Momentum_Level", momentumBlades / C:MeterGetMax("MomentumBlades"))
    else
      hitCounterDrain = false
    end
  end
  if C:HasMeter("MomentumBaseShared") then
    local momentumBaseShared = C:MeterGetValue("MomentumBaseShared")
    if hasMomentumMeter then
      if C:PickupIsAcquired("WeaponBuff_Axe_Momentum_2") or not C:CheckDynamicFlag("AxeMomentumEnabled") then
        C:MeterSetValue("Momentum", 0)
      else
        C:MeterSetValue("Momentum", momentumBaseShared)
      end
    end
    if hasMomentumBladesMeter then
      if C:PickupIsAcquired("WeaponBuff_Blades_Momentum_2") or not C:CheckDynamicFlag("BladesMomentumEnabled") then
        C:MeterSetValue("MomentumBlades", 0)
      else
        C:MeterSetValue("MomentumBlades", momentumBaseShared)
      end
    end
    local hasMomentumSpearMeter = C:HasMeter("MomentumSpear")
    if hasMomentumSpearMeter then
      if C:PickupIsAcquired("WeaponBuff_Spear_Momentum_2") or not C:CheckDynamicFlag("SpearMomentumEnabled") then
        C:MeterSetValue("MomentumSpear", 0)
      else
        C:MeterSetValue("MomentumSpear", momentumBaseShared)
      end
    end
  end
end
local momentumStops = {66, 33}
local momentumLostOnHitPerDifficultyNotFull = {
  ["1"] = 25,
  ["2"] = 33,
  ["3"] = 50,
  ["4"] = 100
}
local momentumLostOnHitPerDifficultyNotFullPerkResilience = {
  ["1"] = 15,
  ["2"] = 20,
  ["3"] = 30,
  ["4"] = 50
}
local GetNextMomentumStopFromMeterValue = function(C, meterName)
  local meterValue = C:MeterGetValue(meterName)
  for i = #momentumStops, 1, -1 do
    if meterValue > momentumStops[i] then
      return momentumStops[i]
    end
  end
  return 0
end
local RoundDifficultyValueToString = function(value)
  if value <= 1 then
    return "1"
  elseif value <= 2 then
    return "2"
  elseif value <= 3 then
    return "3"
  else
    return "4"
  end
end
local ClearMomentumType_Incremental = function(Creature)
  if Creature:HasMeter("MomentumBaseShared") and (Creature:HasMeter("Momentum") or Creature:HasMeter("MomentumBlades") or Creature:HasMeter("MomentumSpear")) then
    local difficultyValue = Creature:AttributeGetValue("Difficulty")
    local difficultyValueString = RoundDifficultyValueToString(difficultyValue)
    local momentumLostPerDifficulty = momentumLostOnHitPerDifficultyNotFull[difficultyValueString]
    if Creature:MeterGetValue("MomentumBaseShared") == Creature:MeterGetMax("MomentumBaseShared") then
      if Creature:PickupIsAcquired("Perk_Effect_MomentumOnHitResilience") then
        momentumLostPerDifficulty = 50
      else
        momentumLostPerDifficulty = 100
      end
    end
    if Creature:PickupIsAcquired("Perk_Effect_MomentumOnHitResilience") and Creature:MeterGetValue("MomentumBaseShared") < Creature:MeterGetMax("MomentumBaseShared") then
      momentumLostPerDifficulty = momentumLostPerDifficulty * 0.5
    end
    Creature:MeterSetValue("MomentumBaseShared", Creature:MeterGetValue("MomentumBaseShared") - momentumLostPerDifficulty)
    if Creature:HasMeter("Momentum") then
      Creature:CallScript("LuaHook_StopMomentumLoops")
      game.Audio.SetBusLevelRTPCValue("WPN_Axe_Momentum_Level", 0)
    end
    hitCounterDrain = false
  end
end
function Luahook_MomentumClear(Creature)
  if Creature:PickupIsAcquired("MomentumArmor") and Creature:PickupGetStage("MomentumArmor") == 1 and Creature:MeterGetValue("MomentumBaseShared") >= 100 then
    Creature:PickupSetStage("MomentumArmor", 2)
  else
    ClearMomentumType_Incremental(Creature)
  end
end
local HitCounterStartDrain = function()
  hitCounterDrain = true
end
function LuaHook_MomentumAxeIncrease()
  hitCounterDrain = false
  if kratos:HasMeter("Momentum") then
    game.Audio.SetBusLevelRTPCValue("WPN_Axe_Momentum_Level", kratos:MeterGetValue("Momentum") / kratos:MeterGetMax("Momentum"))
  end
end
function LuaHook_MomentumBladesIncrease()
  hitCounterDrain = false
  if kratos:HasMeter("MomentumBlades") then
    game.Audio.SetBusLevelRTPCValue("WPN_Blades_Momentum_Level", kratos:MeterGetValue("MomentumBlades") / kratos:MeterGetMax("MomentumBlades"))
  end
end
function LuaHook_MomentumSpearIncrease()
  hitCounterDrain = false
end
function GiveEquipment(equipmentName)
  if game.Equipment.CanCreate(equipmentName) then
    local equipmentID = game.Equipment.CreateEquipment(equipmentName)
    game.Wallets.AddEquipment("HERO", equipmentID)
  end
end
local offscreenindicatorName = "indicator"
local offscreenTable = {}
function OffScreenRingUpate(player)
  local enemiesAround = player:FindEnemies(40)
  for _, i in ipairs(enemiesAround) do
    if i:HasMarker("Attacking") and i:GetTargetCreature() == player and not i:CheckDecision("tweak_Decision_OnCamera") and not CreatureExistsInTable(i, offscreenTable) then
      local newEntry = {}
      newEntry.thisCreature = i
      newEntry.thisEffect = game.FX.Spawn(offscreenindicatorName, nil)
      table.insert(offscreenTable, newEntry)
    end
  end
  local tablesize = #offscreenTable
  for i = tablesize, 1, -1 do
    local thisCreature = offscreenTable[i].thisCreature
    if not (thisCreature ~= nil and thisCreature:HasMarker("Attacking")) or thisCreature:CheckDecision("tweak_Decision_OnCamera") then
      offscreenTable[i].thisEffect:Destroy()
      table.remove(offscreenTable, i)
    else
      local facing = (player.WorldPosition - thisCreature.WorldPosition):Normalized()
      offscreenTable[i].thisEffect:SetWorldFacing(facing)
      offscreenTable[i].thisEffect:SetWorldPosition(player.WorldPosition + player:GetWorldUp() * 1)
    end
  end
end
function CreatureExistsInTable(thisCreature, thisTable)
  for _, i in ipairs(thisTable) do
    if i.thisCreature == thisCreature then
      return true
    end
  end
  return false
end
local offscreenTableSon = {}
function OffScreenRingSonUpate(player)
  local i = game.AI.FindSon()
  if i == nil then
    return
  end
  local sonBB = i:GetBlackboard()
  local inCombat = false
  if sonBB ~= nil and sonBB:Exists("InCombat") and sonBB:GetNumber("InCombat") == 1 then
    inCombat = true
  end
  if inCombat == false then
    if 0 < #offscreenTableSon then
      offscreenTableSon[1].thisEffect:Destroy()
      table.remove(offscreenTableSon, 1)
    end
    return
  end
  if not i:CheckDecision("tweak_Decision_OnCamera") and not CreatureExistsInTable(i, offscreenTableSon) then
    local newEntry = {}
    newEntry.thisCreature = i
    newEntry.thisEffect = game.FX.Spawn(offscreenindicatorName, nil)
    table.insert(offscreenTableSon, newEntry)
  end
  local tablesize = #offscreenTableSon
  for i = tablesize, 1, -1 do
    local thisCreature = offscreenTableSon[i].thisCreature
    if thisCreature:CheckDecision("tweak_Decision_OnCamera") then
      offscreenTableSon[i].thisEffect:Destroy()
      table.remove(offscreenTableSon, i)
    else
      local facing = (player.WorldPosition - thisCreature.WorldPosition):Normalized()
      offscreenTableSon[i].thisEffect:SetWorldFacing(facing)
      offscreenTableSon[i].thisEffect:SetWorldPosition(player.WorldPosition + player:GetWorldUp() * 1)
    end
  end
end
function BreatheFrequencyRTPC()
  if kratos == nil then
    return 0
  end
  if game.Audio.GetBreathingFrequency then
    return game.Audio.GetBreathingFrequency(kratos)
  else
    return 0
  end
end
function BreatheAmplitudeRTPC()
  if kratos == nil then
    return 0
  end
  if game.Audio.GetBreathingAmplitude then
    return game.Audio.GetBreathingAmplitude(kratos)
  else
    return 0
  end
end
function MOV_PercentageRTPC()
  if kratos ~= nil then
    return kratos:GetActiveMovePercent() * 100
  else
    return 0
  end
end
function LuaHookDecision_TargetUseSafeSpots(player)
  local target = player:GetTargetCreature()
  if target ~= nil and target:HasMarker("UseSafeSpots") then
    return true
  end
  return false
end
function LuaHookDecision_BaldurCheckCloseThrow(ai, data)
  if ai ~= nil then
    local myLevel = game.FindLevel("For300_BossArena")
    local destinationPos = myLevel:FindSingleGameObject("Warp_Stage2_BaldurAgainstStatue"):GetWorldPosition()
    local dist = ai:GetWorldPosition() - destinationPos
    dist = dist.length
    if dist < 8 then
      return data:FindOutcomeBranchesEntry("Close")
    elseif dist < 15 then
      return data:FindOutcomeBranchesEntry("Medium")
    end
  end
  return data:FindOutcomeBranchesEntry("Far")
end
function LuaHook_ZiplineMaxSpeedOverride(ai)
  ai:SetMaxSpeedOverride(100)
end
function LuaHook_ZiplineClearMaxSpeedOverride(ai)
  ai:ClearMaxSpeedOverride()
end
function LuaHook_ValkBlightStart()
  local thisLevel = kratos.GroundLevel
  if thisLevel == "WAD_Nid100_Entrance" or thisLevel == game.FindLevel("Nid100_Entrance") or thisLevel == game.FindLevel("Nid310_NWRoom") then
    LuaHook_NiflheimBlightStart()
    kratos:MeterSetValue("Health", kratos:MeterGetMax("Health"))
  end
end
function LuaHook_ValkBlightEnd()
  local thisLevel = kratos.GroundLevel
  if thisLevel == "WAD_Nid100_Entrance" or thisLevel == game.FindLevel("Nid100_Entrance") or thisLevel == game.FindLevel("Nid310_NWRoom") then
    LuaHook_NiflheimBlightEnd()
  end
end
function LuaHook_NiflheimBlightStart()
  kratos:PickupAcquire("Debuff_Hero_Blight")
  kratos:PickupAcquire("Debuff_Hero_Blight_Protection")
end
function LuaHook_NiflheimBlightEnd()
  if kratos:PickupIsAcquired("Debuff_Hero_Blight_Protection") then
    kratos:PickupRelinquish("Debuff_Hero_Blight_Protection")
  end
  timer.StartCreatureTimer(0.5, RemoveBlightPickupHelper)
end
function RemoveBlightPickupHelper()
  if kratos:PickupIsAcquired("Debuff_Hero_Blight") then
    kratos:PickupRelinquish("Debuff_Hero_Blight")
  end
end
function LuaHook_NiflheimBlightProtectionIncreaseSml()
  kratos:MeterSetValue("NiflheimBlightProtection", 10)
end
function LuaHook_NiflheimBlightProtectionIncreaseMed()
  kratos:MeterSetValue("NiflheimBlightProtection", 20)
end
function LuaHook_NiflheimBlightProtectionIncreaseLrg()
  kratos:MeterSetValue("NiflheimBlightProtection", 50)
end
function LuaHook_NiflheimBlightProtectionIncreaseFull()
  kratos:MeterSetValue("NiflheimBlightProtection", 200)
end
function LuaHook_GiveEvadeTimer()
  kratos:PickupAcquire("EvadeRollTimer", 0)
end
function LuaHook_ClearWarpData()
  local gbl00 = game.FindLevel("Gbl000_FastTravel")
  if gbl00 ~= nil then
    gbl00:CallScript("ClearWarpData")
  end
  local bboard = kratos:GetPrivateBlackboard()
  if bboard and bboard:Exists("PlayerIsFastTraveling") then
    bboard:Erase("PlayerIsFastTraveling")
  end
  if bboard and bboard:Exists("FastTravelLoadRequested") then
    bboard:Erase("FastTravelLoadRequested")
  end
  if bboard and bboard:Exists("FinalDestinationMarker") then
    bboard:Erase("FinalDestinationMarker")
  end
end
function LuaHook_OnKratosBlockReact(player)
end
function LuaHook_OnKratosBlockBreakReact(player)
end
function LuaHook_OnKratosParryReact(player)
end
function LuaHook_OnKratosParryFast(player)
end
function LuaHook_OnKratosHitReact(player)
end
local bladesCounter = 0
function PlayBladeAudioOnLoad()
  bladesCounter = bladesCounter + 1
  local currentWeapon = kratos.GetCurrentWeapon and kratos:GetCurrentWeapon() or nil
  if currentWeapon ~= nil then
    if currentWeapon == "Blades" then
      print("Kratos was holding his blades on load")
      weaponsLoaded = true
    elseif 10 <= bladesCounter then
      print("Kratos was legitimately not holding the blades on load")
      weaponsLoaded = true
    end
  end
end
local hundredPrctAnimFrameCount = 0
function MimirHeadIdleSetup()
  local mimirHead = game.Player.FindPlayer().MimirHead
  if mimirHead ~= nil then
    if mimirHead.AnimPercent == 1 then
      if 1 <= hundredPrctAnimFrameCount then
        mimirHead:PlayAnimationCycle({
          Animation = "AttachmentIdle",
          Tween = 1
        })
        hundredPrctAnimFrameCount = 0
      else
        hundredPrctAnimFrameCount = hundredPrctAnimFrameCount + 1
      end
    else
      hundredPrctAnimFrameCount = 0
    end
    local MimirHeadState = mimirHead:GetPrimaryAnimationName()
    local canInterrupt = MimirHeadState == "AttachmentIdle" or MimirHeadState == "MimirDead" or MimirHeadState == "MimirCombat"
    if canInterrupt then
      local desiredMimirHeadState = "AttachmentIdle"
      if game.Combat.GetCombatStatus() == true then
        desiredMimirHeadState = "MimirCombat"
      end
      if MimirHeadState ~= desiredMimirHeadState then
        mimirHead:PlayAnimationCycle({Animation = desiredMimirHeadState, Tween = 1})
      end
    end
  end
end
function LuaHook_PlayMomentumAxeConcussion(player)
  local concussionParams = {
    Tweak = "CNC_AXE_FROST_MOMENTUM_FULL_FIXED_POSITION",
    EnemyId = player:GetID(),
    GameObject = player
  }
  game.Combat.PlayConcussion(concussionParams)
end
function Debug_PlayConcussionOnPlayer(player)
  local concussionParams = {
    Tweak = "CNC_DEBUG_VFS_FORCE_DAMAGE",
    EnemyId = player:GetID(),
    GameObject = player
  }
  game.Combat.PlayConcussion(concussionParams)
end
function LuaHook_SpawnGameObject(C, spawnArgs)
  C:SpawnGameObject(spawnArgs)
end
function LuaHook_Baldur2Fight_Punch()
  local cineNum = game.Level.GetVariable("CompletedCineNumber")
  local peak800 = game.FindLevel("Peak800_DragonRide")
  if cineNum == 470 and peak800 ~= nil then
    peak800:GetGameObject("Peak800_Banter"):CallScript("KratosPunch_Banters")
  end
end
local enum_UseWorld = tweaks.eControls.kC_UseWorld
function LuaHook_AccessibilityCheck()
  local pad = game.Pad.GetPad(0)
  if pad and game.GetRepeatedButtonPressChoice() == 1 and IsPlayer() and pad and pad:IsControlDown(enum_UseWorld) then
    kratos:TriggerMoveEvent("LE_AccessibilityBranch")
  end
end
function LuaHook_RopeDrop(creature)
  local interactObj = kratos:GetCurrentInteractObject()
  if interactObj ~= nil then
    interactObj:CallScript("ChainedObjectDrop")
  end
end
function LuaHook_CombatInteract_PillarSwingBreak(creature)
end
function SetCurrentCarryObject(creature, obj)
  if obj ~= nil then
    currentCarry = obj
  end
end
function AttemptToDropCurrentCarry(creature, obj)
  if currentCarry ~= nil and creature:HasMarker("CrystalCarry") then
    currentCarry:CallScript("StartCarryExit")
  end
end
function ClearCurrentCarryObject()
  currentCarry = nil
end
function SetCurrentBaseObject(creature, obj)
  if obj ~= nil then
    currentBase = obj
    PassBaseToCrystal()
  end
end
function PassBaseToCrystal()
  if currentCarry ~= nil and currentBase ~= nil then
    currentCarry:CallScript("SetCurrentBaseOnCrystal", currentBase)
  end
end
function ClearCurrentBaseObject()
  currentBase = nil
end
function LuaHook_SetCrystalSocketed()
  if currentCarry ~= nil then
    currentCarry:CallScript("OnPutDown")
    currentCarry:CallScript("SetSocketed", true)
  end
end
function LuaHookDecision_RageR1SpeedUpCheck(player)
  local target = player:GetTargetCreature()
  if target ~= nil and DL.GetDistanceBetweenTwoObjects(player, target) < 5 then
    return true
  end
  return false
end
function LuaHookDecision_CanRageSeekPunchInAirToTarget(player)
  local target = player:GetTargetCreature()
  if target == nil then
    return false
  end
  local targetPos = target:GetWorldPosition()
  local playerPos = player:GetWorldPosition()
  playerPos.y = playerPos.y + 0.5
  targetPos.y = playerPos.y
  local playerToTarget = targetPos - playerPos
  targetPos = targetPos + playerToTarget:Normalized() * 0.5
  local hit = game.World.RaycastCollision(playerPos, targetPos, {
    SourceGameObject = player,
    EntityType = game.CollisionType.New("kEnvironment", "kInvisibleBarrier")
  }, false)
  if hit == nil then
    return true
  else
    return false
  end
end
function LuaHook_RemoveBloodFromHero(player)
  game.Combat.ForceBloodDecayInCombat(true)
end
function LuaHook_AddBlood_Baldur_MMA_Reaction(player)
  player:AddBlood(game.GameObject.eRegionId.kHead, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kLeftChest, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightChest, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kFrontAbdomen, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontUpperArm, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontLowerArm, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftBack, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightBack, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackUpperArm, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackLowerArm, 0.1)
end
function LuaHook_AddBlood_Baldur_MMA_LeftHand(player)
  player:AddBlood(game.GameObject.eRegionId.kHead, 0.05)
  player:AddBlood(game.GameObject.eRegionId.kLeftChest, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightChest, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kFrontAbdomen, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontUpperArm, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontLowerArm, 0.4)
  player:AddBlood(game.GameObject.eRegionId.kLeftBack, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightBack, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackUpperArm, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackLowerArm, 0.4)
end
function LuaHook_AddBlood_Baldur_MMA_RightHand(player)
  player:AddBlood(game.GameObject.eRegionId.kHead, 0.05)
  player:AddBlood(game.GameObject.eRegionId.kLeftChest, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightChest, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kFrontAbdomen, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightFrontUpperArm, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kRightFrontLowerArm, 0.4)
  player:AddBlood(game.GameObject.eRegionId.kLeftBack, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightBack, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kRightBackUpperArm, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kRightBackLowerArm, 0.4)
end
function LuaHook_AddBlood_Baldur_Pummel(player)
  player:AddBlood(game.GameObject.eRegionId.kHead, 0.025)
  player:AddBlood(game.GameObject.eRegionId.kLeftChest, 0.05)
  player:AddBlood(game.GameObject.eRegionId.kRightChest, 0.05)
  player:AddBlood(game.GameObject.eRegionId.kFrontAbdomen, 0.05)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontUpperArm, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontLowerArm, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kRightFrontUpperArm, 0.05)
  player:AddBlood(game.GameObject.eRegionId.kRightFrontLowerArm, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftBack, 0.025)
  player:AddBlood(game.GameObject.eRegionId.kRightBack, 0.025)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackUpperArm, 0.1)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackLowerArm, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kRightBackUpperArm, 0.05)
  player:AddBlood(game.GameObject.eRegionId.kRightBackLowerArm, 0.1)
end
function LuaHook_AddBlood_Magni_Finisher(player)
  player:AddBlood(game.GameObject.eRegionId.kHead, 0.6)
  player:AddBlood(game.GameObject.eRegionId.kLeftChest, 0.8)
  player:AddBlood(game.GameObject.eRegionId.kRightChest, 0.8)
  player:AddBlood(game.GameObject.eRegionId.kFrontAbdomen, 0.8)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontUpperArm, 0.6)
  player:AddBlood(game.GameObject.eRegionId.kLeftFrontLowerArm, 0.4)
  player:AddBlood(game.GameObject.eRegionId.kRightFrontUpperArm, 0.6)
  player:AddBlood(game.GameObject.eRegionId.kRightFrontLowerArm, 0.4)
  player:AddBlood(game.GameObject.eRegionId.kLeftBack, 0.8)
  player:AddBlood(game.GameObject.eRegionId.kRightBack, 0.8)
  player:AddBlood(game.GameObject.eRegionId.kBackAbdomen, 0.8)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackUpperArm, 0.4)
  player:AddBlood(game.GameObject.eRegionId.kLeftBackLowerArm, 0.2)
  player:AddBlood(game.GameObject.eRegionId.kRightBackUpperArm, 0.4)
  player:AddBlood(game.GameObject.eRegionId.kRightBackLowerArm, 0.2)
end
function LuaHookDecision_IsDefaultRageModeInput(C, data)
  if game.GetCurrentOptionIndexForSetting ~= nil and game.GetCurrentOptionIndexForSetting("RageMode") == 1 then
    return false
  end
  return true
end
function LuaHook_ClearRageModeUIMessage(C, data)
  uiCalls.DisableMechanicRage()
end
function FindCreatureByID(enemyID)
  local foundCreature
  for creature in game.Creature.IterateAllCreatures() do
    if creature:GetID() == enemyID then
      foundCreature = creature
      break
    end
  end
  return foundCreature
end
function getOnScreenEnemySorted()
  local player = game.Player.FindPlayer()
  local creaturesOnScreen = {}
  local creaturesAroundPlayer = DL.FindLivingEnemies(player, 35)
  for _, thisCreature in ipairs(creaturesAroundPlayer) do
    if thisCreature:GetAI():CheckDecision("tweak_Decision_OnCamera") then
      table.insert(creaturesOnScreen, thisCreature)
    end
  end
  return creaturesOnScreen
end
function CheckForCompanionContextualR3(C)
  if not C:CheckDynamicFlag("InContextualR3FollowUp") then
    local currentTarget = C:GetTargetCreature()
    if currentTarget ~= nil and currentTarget:CheckDynamicFlag("InGrabMoveFlipThrowReadyToFollowup") then
      C:TriggerMoveEvent("Kratos_Contextual_R3")
    end
  end
end
local bladeTwirlCharge = {
  updateDecrement = 30,
  maxChargeValue = 100,
  holdTimeToFullCharge = 1.55,
  buttonHeldTime = 0,
  buttonHeldTimeMin = 0.15,
  idleTimeBeforeDrain = 0.75,
  idleTimeBeforeDrainWhenMaxed = 2.25,
  unitTimeModifierWhenAiming = 0.6,
  currentDrainTime = 0
}
local enum_AxeRecall = tweaks.eControls.kC_AxeRecall
function UpdateWhiplash(C)
  local hasWhiplashFlag = C:CheckDynamicFlag("Whiplash")
  if hasWhiplashFlag then
    if C:CheckDynamicFlag("WhiplashEnter") then
      bladeTwirlCharge.currentDrainTime = 0
    end
    local unitTime = C:GetUnitTime()
    local modifiedUnitTime = unitTime
    if isAiming then
      modifiedUnitTime = unitTime * bladeTwirlCharge.unitTimeModifierWhenAiming
    end
    bladeTwirlCharge.currentDrainTime = bladeTwirlCharge.currentDrainTime + modifiedUnitTime
    local idleTime = 0
    if C:CheckDynamicFlag("BladeTwirlSpeed_10") then
      idleTime = bladeTwirlCharge.idleTimeBeforeDrainWhenMaxed
    else
      idleTime = bladeTwirlCharge.idleTimeBeforeDrain
    end
    if C:CheckDynamicFlag("BladeTwirl") then
      local pad = game.Pad.GetPad(0)
      if pad:IsControlDown(enum_AxeRecall) then
        bladeTwirlCharge.buttonHeldTime = bladeTwirlCharge.buttonHeldTime + unitTime
        if bladeTwirlCharge.buttonHeldTime >= bladeTwirlCharge.buttonHeldTimeMin then
          bladeTwirlCharge.currentDrainTime = 0
          AddChargeToWhiplashMeter_Lua(C, bladeTwirlCharge.maxChargeValue / bladeTwirlCharge.holdTimeToFullCharge * unitTime, false)
        end
      else
        bladeTwirlCharge.buttonHeldTime = 0
      end
    end
    if idleTime <= bladeTwirlCharge.currentDrainTime then
      local lossPerFrame = bladeTwirlCharge.updateDecrement * unitTime
      local currentMeterValue = C:MeterGetValue("WhiplashMeter")
      C:MeterSetValue("WhiplashMeter", currentMeterValue - lossPerFrame)
    end
  end
  if not C:HasMarker("MaintainBladeTwirlStage") then
    C:MeterSetValue("WhiplashMeter", 0)
    C:PickupSetStage("BladesTriangleChargeStage", 0)
  elseif not hasWhiplashFlag then
    bladeTwirlCharge.currentDrainTime = 0
  end
end
function LuaHook_Whiplash_Charged(C)
  bladeTwirlCharge.currentDrainTime = 0
end
function AddChargeToWhiplashMeter_Lua(C, twirlAmount, useTimerHack)
  bladeTwirlCharge.currentDrainTime = 0
  local currentMeter = C:MeterGetValue("WhiplashMeter")
  local newMeterValue = currentMeter + twirlAmount
  C:MeterSetValue("WhiplashMeter", newMeterValue)
end
function LuaHook_BladeTwirlEnterChargedMaxed(C)
  bladeTwirlCharge.currentDrainTime = 0
  C:MeterSetValue("WhiplashMeter", C:MeterGetMax("WhiplashMeter"))
end
local lastEquippedShield
local equippableShields = {
  Guardian = 0,
  Siege = 1,
  Parry = 2,
  Buster = 3,
  Blitz = 4
}
local OnShieldEquipped = function(C, equippedShield)
  if (equippedShield == equippableShields.Siege or equippedShield == equippableShields.Buster) and C:HasMeter("DefenseMeter") then
    C:MeterSetValue("DefenseMeter", C:MeterGetMax("DefenseMeter"))
  end
end
local ignore = 0
local has = 1
local notHas = 2
local scriptedMatAnimStates = {
  AxeFreezeOn = {
    hasFlags = game.LargeInteger.HashString("AxeFreezeMatAnim"),
    notHasFlags = nil,
    hasFlagsStrings = "AxeFreezeMatAnim",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetAxeWeapon,
    anim = "Axe_Momentum_ON",
    inverseState = "AxeFreezeOff",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  AxeFreezeOff = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("AxeFreezeMatAnim"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = "AxeFreezeMatAnim",
    goReferenceCallback = GetAxeWeapon,
    anim = "Axe_Momentum_OFF",
    inverseState = "AxeFreezeOn",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  LeftBladeBurnOn = {
    hasFlags = game.LargeInteger.HashString("LeftBladeBurnMatAnim"),
    notHasFlags = nil,
    hasFlagsStrings = "LeftBladeBurnMatAnim",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetLeftBladeWeapon,
    anim = "blade_ON",
    inverseState = "LeftBladeBurnOff",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  LeftBladeBurnOff = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("LeftBladeBurnMatAnim"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = "LeftBladeBurnMatAnim",
    goReferenceCallback = GetLeftBladeWeapon,
    anim = "blade_OFF",
    inverseState = "LeftBladeBurnOn",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  RightBladeBurnOn = {
    hasFlags = game.LargeInteger.HashString("RightBladeBurnMatAnim"),
    notHasFlags = nil,
    hasFlagsStrings = "RightBladeBurnMatAnim",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetRightBladeWeapon,
    anim = "blade_ON",
    inverseState = "RightBladeBurnOff",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  RightBladeBurnOff = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("RightBladeBurnMatAnim"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = "RightBladeBurnMatAnim",
    goReferenceCallback = GetRightBladeWeapon,
    anim = "blade_OFF",
    inverseState = "RightBladeBurnOn",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  SpearGlowOn = {
    hasFlags = game.LargeInteger.HashString("SpearGlowMatAnim"),
    notHasFlags = nil,
    hasFlagsStrings = "SpearGlowMatAnim",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetSpearWeapon,
    anim = "attEmi_allSpears_ON",
    inverseState = "SpearGlowOff",
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  SpearGlowOff = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("SpearGlowMatAnim"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = "SpearGlowMatAnim",
    goReferenceCallback = GetSpearWeapon,
    anim = "attEmi_allSpears_OFF",
    inverseState = "SpearGlowOn",
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Rage_On = {
    hasFlags = game.LargeInteger.HashString("AnyRageModeActive"),
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = function()
      return kratos
    end,
    anim = "RageMode00",
    animRate = 2,
    inverseState = "Rage_Off",
    requiresInverseStateActive = false,
    onOffTweenTime = 0.2,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Rage_Off = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("AnyRageModeActive"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = function()
      return kratos
    end,
    anim = "RageMode00_fadeout",
    animRate = 1.5,
    inverseState = "Rage_On",
    requiresInverseStateActive = true,
    onOffTweenTime = 0.2,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  RageBOO_Charge_On = {
    hasFlags = game.LargeInteger.HashString("BOO_CHARGED"),
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetBOOWeapon,
    anim = "olympusBlade_glowOn",
    animRate = 2.5,
    inverseState = "RageBOO_Charge_Off",
    requiresInverseStateActive = false,
    onOffTweenTime = 0.2,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  RageBOO_Charge_Off = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("BOO_CHARGED"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetBOOWeapon,
    anim = "olympusBlade_glowOff",
    animRate = 0.75,
    inverseState = "RageBOO_Charge_On",
    requiresInverseStateActive = true,
    onOffTweenTime = 0.2,
    conditional = nil,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  RageBOO_Attack_On = {
    hasFlags = game.LargeInteger.HashString("BOO_EDGE_GLOW"),
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetBOOWeapon,
    anim = "olympusBlade_edgeGlowOn",
    animRate = 2.5,
    inverseState = "RageBOO_Attack_Off",
    requiresInverseStateActive = false,
    onOffTweenTime = 0.2,
    conditional = GetBOOEquipped,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  RageBOO_Attack_Off = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("BOO_EDGE_GLOW"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetBOOWeapon,
    anim = "olympusBlade_edgeGlowOff",
    animRate = 1,
    inverseState = "RageBOO_Attack_On",
    requiresInverseStateActive = true,
    onOffTweenTime = 0.2,
    conditional = GetBOOEquipped,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Shield_Guardian_Open = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockEnter03",
    inverseState = "Shield_Guardian_Close",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = GuardianShieldEquipped,
    blocking = has,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Shield_Guardian_Close = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockExit03",
    inverseState = "Shield_Guardian_Open",
    useInverseStateForStartPos = true,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    animRate = 1,
    conditional = GuardianShieldEquipped,
    blocking = notHas,
    Samurai_CSClash = notHas,
    active = false,
    flagsValid = false
  },
  Shield_PerfectParry_Open = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockEnter03_PerfectParry",
    inverseState = "Shield_PerfectParry_Close",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = PerfectParryShieldEquipped,
    blocking = has,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Shield_PerfectParry_Close = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockExit03_PerfectParry",
    inverseState = "Shield_PerfectParry_Open",
    useInverseStateForStartPos = true,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = PerfectParryShieldEquipped,
    blocking = notHas,
    Samurai_CSClash = notHas,
    active = false,
    flagsValid = false
  },
  Shield_MegaBuster_Open = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockEnter03_MegaBuster",
    inverseState = "Shield_MegaBuster_Close",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = MegaBusterShieldEquipped,
    animRate = 2.5,
    blocking = has,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Shield_MegaBuster_Close = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockExit03_MegaBuster",
    inverseState = "Shield_MegaBuster_Open",
    useInverseStateForStartPos = true,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = MegaBusterShieldEquipped,
    animRate = 2,
    blocking = notHas,
    Samurai_CSClash = notHas,
    active = false,
    flagsValid = false
  },
  Shield_BlitzRush_Open = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockEnter03_BlitzRush",
    inverseState = "Shield_BlitzRush_Close",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = BlitzRushShieldEquipped,
    blocking = has,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Shield_BlitzRush_Close = {
    hasFlags = nil,
    notHasFlags = nil,
    hasFlagsStrings = nil,
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockExit03_BlitzRush",
    inverseState = "Shield_BlitzRush_Open",
    useInverseStateForStartPos = true,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = BlitzRushShieldEquipped,
    blocking = notHas,
    Samurai_CSClash = notHas,
    active = false,
    flagsValid = false
  },
  Shield_SiegeGuard_Open = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("SiegeGuard_GroundSmash"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = "SiegeGuard_GroundSmash",
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockEnter03_Siege",
    inverseState = "Shield_SiegeGuard_Close",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = SiegeGuardShieldEquipped_NoDoingGroundSmash,
    blocking = has,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Shield_SiegeGuard_Close = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("SiegeGuard_GroundSmash"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = "SiegeGuard_GroundSmash",
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockExit03_Siege",
    inverseState = "Shield_SiegeGuard_Open",
    useInverseStateForStartPos = true,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = SiegeGuardShieldEquipped_NoDoingGroundSmash,
    blocking = notHas,
    Samurai_CSClash = notHas,
    active = false,
    flagsValid = false
  },
  SiegeGuard_GroundSmash = {
    hasFlags = game.LargeInteger.HashString("SiegeGuard_GroundSmash"),
    notHasFlags = nil,
    hasFlagsStrings = "SiegeGuard_GroundSmash",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "attShieldBlockBreakerSiege01",
    inverseState = "SiegeGuard_GroundSmash_Exit",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = false,
    onOffTweenTime = 0,
    conditional = SiegeGuardShieldEquipped,
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  SiegeGuard_GroundSmash_Exit = {
    hasFlags = nil,
    notHasFlags = game.LargeInteger.HashString("SiegeGuard_GroundSmash"),
    hasFlagsStrings = nil,
    notHasFlagsStrings = "SiegeGuard_GroundSmash",
    goReferenceCallback = GetShieldWeapon,
    anim = "DefBlockExit03_Siege",
    inverseState = "SiegeGuard_GroundSmash",
    useInverseStateForStartPos = false,
    requiresInverseStateActive = true,
    onOffTweenTime = 0,
    conditional = SiegeGuardShieldEquipped,
    blocking = notHas,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Samurai_CSClashEnter = {
    hasFlags = game.LargeInteger.HashString("Samurai_CSClashEnter"),
    notHasFlags = nil,
    hasFlagsStrings = "Samurai_CSClashEnter",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csSamuraiClashEnter",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Samurai_CSClashFail = {
    hasFlags = game.LargeInteger.HashString("Samurai_CSClashFail"),
    notHasFlags = nil,
    hasFlagsStrings = "Samurai_CSClashFail",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csSamuraiClashFail",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  Samurai_CSClashWin = {
    hasFlags = game.LargeInteger.HashString("Samurai_CSClashWin"),
    notHasFlags = nil,
    hasFlagsStrings = "Samurai_CSClashWin",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csSamuraiClashWin",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  LindwormStruggleEnter = {
    hasFlags = game.LargeInteger.HashString("LindwormStruggleEnter"),
    notHasFlags = nil,
    hasFlagsStrings = "LindwormStruggleEnter",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csLindwormLatchStruggleEnter",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  LindwormStruggleLoop = {
    hasFlags = game.LargeInteger.HashString("LindwormStruggleLoop"),
    notHasFlags = nil,
    hasFlagsStrings = "LindwormStruggleLoop",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csLindwormLatchStruggleLoop",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  LindwormStruggleWin = {
    hasFlags = game.LargeInteger.HashString("LindwormStruggleWin"),
    notHasFlags = nil,
    hasFlagsStrings = "LindwormStruggleWin",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csLindwormLatchStruggleWin",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  LindwormStruggleRelease = {
    hasFlags = game.LargeInteger.HashString("LindwormStruggleRelease"),
    notHasFlags = nil,
    hasFlagsStrings = "LindwormStruggleRelease",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csLindwormLatchStruggleRelease",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  },
  LindwormStruggleFail = {
    hasFlags = game.LargeInteger.HashString("LindwormStruggleFail"),
    notHasFlags = nil,
    hasFlagsStrings = "LindwormStruggleFail",
    notHasFlagsStrings = nil,
    goReferenceCallback = GetShieldWeapon,
    anim = "csLindwormLatchStruggleFail",
    onOffTweenTime = 0,
    cancelAnimGroup = "Shield",
    blocking = ignore,
    Samurai_CSClash = ignore,
    active = false,
    flagsValid = false
  }
}
local Samurai_CSClashHash = game.LargeInteger.HashString("Samurai_CSClash")
function UpdateScriptedMaterialAnims(C, player)
  local hasSamurai_CSClashHash = false
  if DynamicFlagLargeIntegerOptimization then
    hasSamurai_CSClashHash = C:CheckDynamicFlagLargeInteger(Samurai_CSClashHash)
  else
    hasSamurai_CSClashHash = C:CheckDynamicFlag("Samurai_CSClash")
  end
  for entry in pairs(scriptedMatAnimStates) do
    local curEntryTable = scriptedMatAnimStates[entry]
    local flagsValid = true
    local blocking = curEntryTable.blocking
    if blocking ~= ignore then
      flagsValid = blocking == has == isBlocking
    end
    local samuraiCSClash = curEntryTable.Samurai_CSClash
    if samuraiCSClash ~= ignore then
      flagsValid = flagsValid and false
    end
    if DynamicFlagLargeIntegerOptimization then
      if flagsValid then
        local hasFlag = curEntryTable.hasFlags
        if hasFlag ~= nil and C:CheckDynamicFlagLargeInteger(hasFlag) == false then
          flagsValid = false
        end
      end
      if flagsValid then
        local notHasFlag = curEntryTable.notHasFlags
        if notHasFlag ~= nil and C:CheckDynamicFlagLargeInteger(notHasFlag) == true then
          flagsValid = false
        end
      end
    else
      if flagsValid then
        local hasFlag = curEntryTable.hasFlagsStrings
        if hasFlag ~= nil and C:CheckDynamicFlag(hasFlag) == false then
          flagsValid = false
        end
      end
      if flagsValid then
        local notHasFlag = curEntryTable.notHasFlagsStrings
        if notHasFlag ~= nil and C:CheckDynamicFlag(notHasFlag) == true then
          flagsValid = false
        end
      end
    end
    curEntryTable.flagsValid = flagsValid
    if flagsValid and curEntryTable.active == false and (curEntryTable.conditional == nil or curEntryTable.conditional ~= nil and curEntryTable.conditional() == true) and (curEntryTable.inverseState == nil or curEntryTable.inverseState ~= nil and curEntryTable.requiresInverseStateActive == false or curEntryTable.inverseState ~= nil and curEntryTable.requiresInverseStateActive == true and scriptedMatAnimStates[curEntryTable.inverseState].active == true) then
      local object = curEntryTable.goReferenceCallback()
      if object ~= nil then
        curEntryTable.active = true
        local startPos = 0
        if curEntryTable.inverseState ~= nil then
          local inverseAnim = scriptedMatAnimStates[curEntryTable.inverseState].anim
          if curEntryTable.useInverseStateForStartPos ~= false then
            startPos = 1 - object:GetAnimationTimeByName({Animation = inverseAnim}) / object:GetAnimationTotalTimeByName({Animation = inverseAnim})
          end
          scriptedMatAnimStates[curEntryTable.inverseState].active = false
          object:PauseAnimation({Animation = inverseAnim})
        end
        local animRate = 1
        if curEntryTable.animRate ~= nil then
          animRate = curEntryTable.animRate
        end
        object:JumpAnimationToPercent(startPos, {
          Animation = curEntryTable.anim
        })
        object:StartAnimation({
          Animation = curEntryTable.anim,
          Tween = curEntryTable.onOffTweenTime,
          Rate = animRate
        })
      end
    end
  end
  for entry in pairs(scriptedMatAnimStates) do
    local curEntryTable = scriptedMatAnimStates[entry]
    if curEntryTable.flagsValid == false then
      curEntryTable.active = false
    end
  end
end
local siegeGuardChargeMaxFrame = 44
local GetSiegeMatAnimFrameFromDefenseMeter = function(C)
  local currentDefenseMeterValue = C:MeterGetValue("DefenseMeter")
  if currentDefenseMeterValue == 100 then
    return 0
  elseif currentDefenseMeterValue == 75 then
    return 11
  elseif currentDefenseMeterValue == 50 then
    return 20
  elseif currentDefenseMeterValue == 25 then
    return 30
  else
    return siegeGuardChargeMaxFrame
  end
end
local shieldChargeUp = "kratosShield00_siege_chargeUp"
local shieldChargeUpHash = game.LargeInteger.HashString("kratosShield00_siege_chargeUp")
function UpdateShieldChargeMaterialAnims(C, player)
  if C:CheckDynamicFlag("InVendorUI") == true then
    return false
  end
  if SiegeGuardShieldEquipped() then
    local shieldObj = GetShieldWeapon()
    if shieldObj ~= nil then
      if lastEquippedShield ~= equippableShields.Siege then
        shieldObj:PlayAnimationToPercent(0, {Animation = shieldChargeUp, Rate = -0.1})
        shieldObj:JumpAnimationToPercent(0, {Animation = shieldChargeUp})
        if shieldObj:GetAnimationTimeByName({Animation = shieldChargeUp}) ~= -1 then
          lastEquippedShield = equippableShields.Siege
          OnShieldEquipped(C, lastEquippedShield)
        end
        return true
      end
      local targetFrame = GetSiegeMatAnimFrameFromDefenseMeter(C)
      local targetPercent = targetFrame / siegeGuardChargeMaxFrame
      local currentPercent = 0
      if DynamicFlagLargeIntegerOptimization then
        currentPercent = shieldObj:GetAnimationTimeByNameLargeInteger(shieldChargeUpHash) / shieldObj:GetAnimationTotalTimeByNameLargeInteger(shieldChargeUpHash)
        if currentPercent == targetPercent then
          return false
        end
        local animRate = 1
        if targetPercent < currentPercent then
          animRate = -1
        end
        shieldObj:PlayAnimationToPercentWithParams(targetPercent, shieldChargeUp, animRate, -1, false)
      else
        currentPercent = shieldObj:GetAnimationTimeByName({Animation = shieldChargeUp}) / shieldObj:GetAnimationTotalTimeByName({Animation = shieldChargeUp})
        if currentPercent == targetPercent then
          return false
        end
        local animRate = 1
        if targetPercent < currentPercent then
          animRate = -1
        end
        shieldObj:PlayAnimationToPercent(targetPercent, {Animation = shieldChargeUp, Rate = animRate})
      end
      game.Audio.SetBusLevelRTPCValue("shields_charge_meter", currentPercent)
    end
    return false
  end
  if MegaBusterShieldEquipped() then
    local shieldObj = GetShieldWeapon()
    if shieldObj ~= nil then
      if lastEquippedShield ~= equippableShields.Buster then
        shieldObj:PlayAnimationToPercent(0, {
          Animation = "kratosShield00_megaBuster_chargeUp",
          Rate = -0.1
        })
        shieldObj:JumpAnimationToPercent(0, {
          Animation = "kratosShield00_megaBuster_chargeUp"
        })
        if shieldObj:GetAnimationTimeByName({
          Animation = "kratosShield00_megaBuster_chargeUp"
        }) ~= -1 then
          lastEquippedShield = equippableShields.Buster
          OnShieldEquipped(C, lastEquippedShield)
        end
        return true
      end
      local targetPercent = 1 - C:MeterGetValue("DefenseMeter") / C:MeterGetMax("DefenseMeter")
      local currentPercent = shieldObj:GetAnimationTimeByName({
        Animation = "kratosShield00_megaBuster_chargeUp"
      }) / shieldObj:GetAnimationTotalTimeByName({
        Animation = "kratosShield00_megaBuster_chargeUp"
      })
      local animRate = 1
      if targetPercent < currentPercent then
        animRate = -1
      end
      if C:CheckDynamicFlag("MegaBusterClear") then
        shieldObj:PlayAnimationToPercent(targetPercent, {
          Animation = "kratosShield00_megaBuster_chargeUp",
          Rate = -2.5
        })
      else
        shieldObj:PlayAnimationToPercent(targetPercent, {
          Animation = "kratosShield00_megaBuster_chargeUp",
          Rate = animRate
        })
      end
      game.Audio.SetBusLevelRTPCValue("shields_charge_meter", currentPercent)
    end
    return false
  end
  if BlitzRushShieldEquipped() then
    local shieldObj = GetShieldWeapon()
    if shieldObj ~= nil then
      if lastEquippedShield ~= equippableShields.Blitz then
        shieldObj:PlayAnimationToPercent(0, {
          Animation = "kratosShield00_blitz_chargeUp",
          Rate = -0.1
        })
        shieldObj:JumpAnimationToPercent(0, {
          Animation = "kratosShield00_blitz_chargeUp"
        })
        if shieldObj:GetAnimationTimeByName({
          Animation = "kratosShield00_blitz_chargeUp"
        }) ~= -1 then
          lastEquippedShield = equippableShields.Blitz
          OnShieldEquipped(C, lastEquippedShield)
        end
        return true
      end
      if C:CheckDynamicFlag("BlitzRushMatAnim") then
        shieldObj:PlayAnimationToPercent(0.75, {
          Animation = "kratosShield00_blitz_chargeUp",
          Rate = 0.9
        })
      else
        shieldObj:PlayAnimationToPercent(0, {
          Animation = "kratosShield00_blitz_chargeUp",
          Rate = -2
        })
      end
      local currentPercent = shieldObj:GetAnimationTimeByName({
        Animation = "kratosShield00_blitz_chargeUp"
      }) / shieldObj:GetAnimationTotalTimeByName({
        Animation = "kratosShield00_blitz_chargeUp"
      })
      game.Audio.SetBusLevelRTPCValue("shields_charge_meter", currentPercent)
    end
    return false
  end
  if GuardianShieldEquipped() then
    local shieldObj = GetShieldWeapon()
    if shieldObj ~= nil then
      if lastEquippedShield ~= equippableShields.Guardian then
        shieldObj:PlayAnimationToPercent(0, {
          Animation = "kratosShield00_guardian_chargeUp",
          Rate = -0.1
        })
        shieldObj:JumpAnimationToPercent(0, {
          Animation = "kratosShield00_guardian_chargeUp"
        })
        if shieldObj:GetAnimationTimeByName({
          Animation = "kratosShield00_guardian_chargeUp"
        }) ~= -1 then
          lastEquippedShield = equippableShields.Guardian
          OnShieldEquipped(C, lastEquippedShield)
        end
        return true
      end
      if C:CheckDynamicFlag("GuardianParryFollowUpAttack") then
        shieldObj:PlayAnimationToPercent(1, {
          Animation = "kratosShield00_guardian_chargeUp",
          Rate = 3
        })
      else
        shieldObj:PlayAnimationToPercent(0, {
          Animation = "kratosShield00_guardian_chargeUp",
          Rate = -2.5
        })
      end
      local currentPercent = shieldObj:GetAnimationTimeByName({
        Animation = "kratosShield00_guardian_chargeUp"
      }) / shieldObj:GetAnimationTotalTimeByName({
        Animation = "kratosShield00_guardian_chargeUp"
      })
      game.Audio.SetBusLevelRTPCValue("shields_charge_meter", currentPercent)
    end
    return false
  end
  if PerfectParryShieldEquipped() then
    local shieldObj = GetShieldWeapon()
    if shieldObj ~= nil then
      if lastEquippedShield ~= equippableShields.Parry then
        shieldObj:PlayAnimationToPercent(0, {
          Animation = "kratosShield00_parry_chargeUp",
          Rate = -0.1
        })
        shieldObj:JumpAnimationToPercent(0, {
          Animation = "kratosShield00_parry_chargeUp"
        })
        if shieldObj:GetAnimationTimeByName({
          Animation = "kratosShield00_parry_chargeUp"
        }) ~= -1 then
          lastEquippedShield = equippableShields.Parry
          OnShieldEquipped(C, lastEquippedShield)
        end
        return true
      end
      local targetPercent = 0
      local currentPercent = shieldObj:GetAnimationTimeByName({
        Animation = "kratosShield00_parry_chargeUp"
      }) / shieldObj:GetAnimationTotalTimeByName({
        Animation = "kratosShield00_parry_chargeUp"
      })
      if C:PickupGetStage("DefensePrototype_TypeParry") == 1 then
        targetPercent = 0.68
      elseif C:PickupGetStage("DefensePrototype_TypeParry") == 2 then
        targetPercent = 1
      end
      if C:CheckDynamicFlag("PerfectParryClear") then
        shieldObj:PlayAnimationToPercent(0, {
          Animation = "kratosShield00_parry_chargeUp",
          Rate = -2.5
        })
      elseif C:CheckDynamicFlag("InPerfectParryClearMove") == false then
        local animRate = 3.25
        if currentPercent > targetPercent then
          animRate = -3.25
        end
        shieldObj:PlayAnimationToPercent(targetPercent, {
          Animation = "kratosShield00_parry_chargeUp",
          Rate = animRate
        })
      end
      game.Audio.SetBusLevelRTPCValue("shields_charge_meter", currentPercent)
    end
    return false
  end
end
function LuaHook_OnSiegeChargeCleared(C)
  local object = GetShieldWeapon()
  object:JumpAnimationToFrame(1, {
    Animation = "kratosShield00_siege_chargeUp"
  })
  object:PlayAnimationToFrame(0, {
    Animation = "kratosShield00_siege_chargeUp",
    Rate = -1.5
  })
end
function LuaHook_OnBlitzRushCleared(C)
  local object = GetShieldWeapon()
  object:JumpAnimationToFrame(1, {
    Animation = "kratosShield00_blitz_chargeUp"
  })
  object:PlayAnimationToFrame(0, {
    Animation = "kratosShield00_blitz_chargeUp",
    Rate = -1.5
  })
end
