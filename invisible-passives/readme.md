# Invisible Passives and Silent Tis Rozain

![](thumbnail.jpg)

## DESCRIPTION

**Disables visual effects for the following shards**:

- Detective Eye
- Money is Power
- Regenerate
- Words of Wisdom

It will not disable visual effects for the following shards:

- Healing
  - disabling the effect for this shard results in the passive not working properly

**Disables voice lines for the following shards**:

- Tis Rozain

Shard sounds will still play, but Miriam will not shout the shard's name.
This change is included because both changes are done to the same file and I am too lazy to provide separate files.

## TECHNICAL DETAILS

The following changes have been made to `PB_DT_ShardMaster.uasset`:

- SkilledDetectiveeye
  - `BulletSTR "P0000_DETECTIVE_EYE" > "None"`
- SkilledMoneyispower
  - `BulletSTR "P0000_MONEY_IS_POWER" > "None"`
- SkilledRegeneration
  - `BulletSTR "P0000_REGENERATION" > "None"`
- SkilledWisdomwords
  - `BulletSTR "P0000_WISDOM_WORDS" > "None"`
- TissRosain
  - `VoiceIdArray ["Vo_P1000_080_jp"] > ["None"]`
- Wisdomwords
  - `BulletOverRoom true > false`
  - `BulletSTR "P0000_WISDOM_WORDS" > "None"`

This mod will be incompatible with any other updating this same file.

## CREDITS

Kudos to _ashtar01_ for their "Words of Wisdom / Healing / Regenerate Invisible" mod, which this one was based on.
I used their mod as a base, reverting their removal of the effects for the healing shard in order to prevent a resulting bug that prevented it from working properly.
