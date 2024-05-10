# Invisible Passives and Silent Tis Rozain

![thumbnail.jpg](thumbnail.jpg)

## DESCRIPTION

**Disables visual effects for the following shards**:

- Money is Power
- Regenerate
- Words of Wisdom

It will **not** disable visual effects for the following shards, as it results in them not working properly:

- Detective Eye
- Healing

**Disables voice lines for the following shards**:

- Tis Rozain

Shard sounds will still play, but Miriam will not shout the shard's name.
This change is included because both changes are done to the same file and I am too lazy to provide separate files.

## TECHNICAL DETAILS

The following changes have been made to `PB_DT_ShardMaster.uasset`:

### Invisible Passives

- Moneyispower, SkilledMoneyispower
  - `BulletSTR "P0000_MONEY_IS_POWER" > "None"`
- Regeneration, SkilledRegeneration
  - `BulletSTR "P0000_REGENERATION" > "None"`
- Wisdomwords, SkilledWisdomwords
  - `BulletSTR "P0000_WISDOM_WORDS" > "None"`

### Invisible Passives (Extra)

- Detectiveeye
  - `minGradeValue 10.0 > 100.0`
  - `maxGradeValue 15.0 > 100.0`

Kept this separate as it increases the effect range and it's an advantadge not everyone might want.

### Silent Shards

- TissRosain
  - `VoiceIdArray ["Vo_P1000_080_jp"] > ["None"]`

This mod will be incompatible with any other updating this same file.

## CREDITS

Kudos to [ashtar01](https://www.nexusmods.com/bloodstainedritualofthenight/users/883766) for their ["Words of Wisdom / Healing / Regenerate Invisible"](https://www.nexusmods.com/bloodstainedritualofthenight/mods/96) mod, which this one was based on.
I used their mod as a base, reverting their removal of the effects for the healing shard in order to prevent a resulting bug that prevented it from working properly.

Kudos to [wgnwaugvwh](https://www.nexusmods.com/bloodstainedritualofthenight/users/133051303) for their ["Detective Eye No Ring and Global"](https://www.nexusmods.com/bloodstainedritualofthenight/mods/196?) mod, which I incorporated into mine. I kept my values smaller than theirs, just big enough to cover the screen. Hopefully this prevents issues with having a range too big.

Thanks to [joneirik](https://www.nexusmods.com/bloodstainedritualofthenight/users/46391987) for their support with modding the game.
