# mrp_cablecar

An implementation of the Pala Springs Aerial Tramway for FiveM.

Rework of [jimathy's jim-cablecar](https://github.com/jimathy/jim-cablecar) for the roleplay server Mouchoirs RP.

## Preview
TODO

## Features
- Spawn cablecar on player request through an NPC interaction on each station
- Cars can be ridden by entering them, the player that spawned it can start it by pressing E
- Syncing between players
- Audio like the movement sound, doors opening/closing and the arrival/departure cue.
- Configurable price
- Cleaning up unused cars after some amount of time

## Requirements
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_target](https://github.com/overextended/ox_target)
- [PolyZone](https://github.com/mkafrin/PolyZone)

## Disclaimer and Limitations

**This script is provided as is**, if you open an issue : expect support only on a best effort / good-will basis.

Pull requests to fix bugs or improve the script are welcome !

- Only one cablecar on each track can be spawned simultaneously.
- Players can glitch out of the cablecar on some occurences due to unknown reasons.
- Cablecars can be a bit laggy/jerky for passengers but remains synced at all times.
- Disabling phone during a ride is only available for lb-phone, if you use any other script you will need to adapt DisablePhone() and EnablePhone() in client.lua.

## Credits and Thanks
Thanks to [jimathy](https://github.com/jimathy) and [glitchdetector](https://github.com/glitchdetector) for their work.

Thanks to the Mouchoirs RP team for their precious support and to the Mouchoirs RP players for their feedback which helped improve the script.