# Birthday Quest

A personalised Roblox birthday adventure. The player is the hero; his younger
brother is an NPC sidekick who follows him around.

This is the **first prototype**: a small island, floating platforms, glowing
collectibles, a quest tracker, and a sidekick who follows and talks.

## Files

| File | Goes to (in Roblox) | What it does |
| --- | --- | --- |
| `src/shared/GameConfig.lua` | `ReplicatedStorage.GameConfig` (ModuleScript) | Every personal detail: names, ages, colours, dialogue |
| `src/server/BirthdayQuest.server.lua` | `ServerScriptService.BirthdayQuest` (Script) | World, collectibles, quest state, sidekick |
| `src/client/BirthdayQuestUI.client.lua` | `StarterPlayer.StarterPlayerScripts.BirthdayQuestUI` (LocalScript) | Quest tracker and sidekick speech bubble |
| `default.project.json` | — | Rojo layout |

Rojo picks the instance class from the file extension: `.lua` becomes a
ModuleScript, `.server.lua` a Script, `.client.lua` a LocalScript.

## Personalising it

Open `src/shared/GameConfig.lua` and edit the lines marked `CHANGE ME`. That is
the only file you need to touch to put the real names and ages in. Nothing is
hard-coded anywhere else.

## Running it in Roblox Studio

Manual steps — Studio cannot do these for you:

1. **Install Rojo.** Get the Rojo plugin from the Roblox Creator Marketplace
   (free), and the Rojo CLI from <https://rojo.space>.
2. **Create the place.** In Studio: *File → New*, pick the **Baseplate**
   template, and save it. The server script deletes the default `Baseplate`
   part at run time and builds its own island — set
   `GameConfig.World.RemoveDefaultBaseplate = false` if you would rather keep it.
3. **Start the server.** In this folder run `rojo serve`.
4. **Connect.** In Studio open the Rojo plugin, click **Connect**, and accept the
   sync. The three scripts appear in the places listed in the table above.
5. **Check the security setting.** *Game Settings → Security →* leave
   **Enable Studio Access to API Services** off (nothing here needs it) and make
   sure **Allow HTTP Requests** stays off too.
6. **Play.** Press **F5** (or the Play button). You spawn on the yellow pad, the
   sidekick appears a second later and says hello, and the tracker at the top of
   the screen counts your stars.

Nothing here uses a paid asset, an external model, or an asset ID.

## Controls

Standard Roblox controls, so desktop and tablet both work with no extra setup:
WASD and space on desktop, the on-screen thumbstick and jump button on a tablet.

## What comes next

Still to build: checkpoints, real star-shaped collectibles, pathfinding for the
sidekick, contextual dialogue, a revive ability, obstacles, three adventure
zones, simple enemies, a boss, hidden birthday stars, a cake-and-fireworks
finale, save data, and family Easter eggs.
