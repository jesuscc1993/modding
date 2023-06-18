Turns helmets invisble by scaling them down to 0.
Only works on playable characters, by overriding the scale for each class to 0.
Modifying the initial scale would make them invisible as well when dropped, so I don't think it would be possible to hide them for mercenaries too.

To replicate, prettify the JSON files and run the following regex replace:

`          "playerClassTransforms"(.|\n)*?\n          \},`

```
          "playerClassTransforms": {
            "0": {
              "name": "entity_root_OverrideAttachmentTransform_playerClassTransforms_Amazon",
              "scale": {
                "x": 0,
                "y": 0,
                "z": 0
              },
              "type": "Transform"
            },
            "1": {
              "name": "entity_root_OverrideAttachmentTransform_playerClassTransforms_Sorceress",
              "scale": {
                "x": 0,
                "y": 0,
                "z": 0
              },
              "type": "Transform"
            },
            "2": {
              "name": "entity_root_OverrideAttachmentTransform_playerClassTransforms_Necromancer",
              "scale": {
                "x": 0,
                "y": 0,
                "z": 0
              },
              "type": "Transform"
            },
            "3": {
              "name": "entity_root_OverrideAttachmentTransform_playerClassTransforms_Paladin",
              "scale": {
                "x": 0,
                "y": 0,
                "z": 0
              },
              "type": "Transform"
            },
            "4": {
              "name": "entity_root_OverrideAttachmentTransform_playerClassTransforms_Barbarian",
              "scale": {
                "x": 0,
                "y": 0,
                "z": 0
              },
              "type": "Transform"
            },
            "5": {
              "name": "entity_root_OverrideAttachmentTransform_playerClassTransforms_Druid",
              "scale": {
                "x": 0,
                "y": 0,
                "z": 0
              },
              "type": "Transform"
            },
            "6": {
              "name": "entity_root_OverrideAttachmentTransform_playerClassTransforms_Assassin",
              "scale": {
                "x": 0,
                "y": 0,
                "z": 0
              },
              "type": "Transform"
            }
          },
```

Optionally, you can also run this second replace to remove unnecessary data:

`          "playerClassOverrides": \{\n(.|\n)*?\n          \},`

```
          "playerClassOverrides": {},
```
