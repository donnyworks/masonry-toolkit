# Masonry Toolkit [Aerial Testing Course]
Welcome to the official repository for *Aerial Testing Course*, the first game made on Masonry Toolkit.
Masonry Toolkit (2026) is a game development toolkit built in Godot 4.5.1, designed for easy rapid-development game making with semi-familiar structures.

Masonry Toolkit's usage policy is as follows: If you're going to use it, please give me credit. Please nothing inappropriate, and if you do use it for something inappropriate, _keep it off the Masonry Toolkit brand name_. Third-party assets require special permission as detailed in thirdpartylicensedetails.txt

When using Masonry Toolkit for a project, unless it's a spinoff of Aerial Testing Course (fan-made spinoffs are welcome and appreciated), please use MSTK_BuildNoAFC to create a version of the toolkit without Aerial Testing Course content in it. Pull requests will not be accepted, as this is a one-man team*. *Subject to change.

## Aerial Testing Course
Let's have a quick chat about ATC and its future:
1. Not sure if I'm gonna finish it.
 The reason for thinking this is that I'm not good at finishing games and frankly, I've got burnout.
 2. ATC isn't meant to be redistributed.
  Unless through official channels or with explicit confirmation, Aerial Testing Course is NOT to be uploaded to third-party hosters. The only official channel for Aerial Testing Course is [itch.io](https://vulvegames.itch.io/atc-playtest-ch1). If you see it anywhere else, tell me. If you try to reupload it somewhere else, _I will know._
  3. Making custom maps and mods for Aerial Testing Course is completely fine, and I don't mind!
   Wanna turn it into a run-and-gun? Go right ahead! Trying to make a physics course? Who am I to stop you?! The sky is the limit. The floor is also the limit, but that's not the point.
 
 Aerial Testing Course is a 2-chapter (may have more in the future) game about Test Subject 4-0-8-0, awoken in the Aerial Testing Course facility (work in progress name, also referred to as "Hassleford Research", though that may also change. I usually just call it the "Masonry Toolkit" facility.)

It has three characters, and this is an important distinction storywise: The Player (that's you!), Test Subject 4-0-8-0 (The playable character), and the Announcer(s), the voice of the game and its constant presence.

Aerial Testing Course uses the following music in order of appearance:
- Normal Mode
	- Greener (Tally Hall, 2008 - cover by [several people on Online Sequencer](https://onlinesequencer.net/5454058))
	- Good Day (Tally Hall, 2008 - cover by [leed on Online Sequencer](https://onlinesequencer.net/members/47901))
	- (I Know) It's Just The Same (Tally Hall, 2005? - cover by [praisedrays on YouTube](https://www.youtube.com/channel/UCLCq4b9rSyixZlUniMNNWrQ))
	- Greener (same cover)
- Hard Mode
	- Greener (same cover)
	- Good Day (same cover)
	- (I Know) It's Just The Same (same cover)
	- Greener (same cover)
	- \\\\?\\gr0x00FF00er.dat (Brickmason Games, modified version of Greener (same cover))
- Unused / Unseen in main campaign right now
	- velocity_test (Brickmason Games, produced with [jampea](jampea.com)) (Used in trailer)
	- the song that plays when its 7am and you really should still be in bed (Brickmason Games, produced with [jampea](jampea.com)) (Used in trailer)
	- OS95 Abridged - Intro Theme (Extended Mix) (Gev Creates, cover by Brickmason Games)
	- OS95 Abridged - Radio Music (Gev Creates, cover by Brickmason Games)
	- chordsample.wav (Technically Gev Creates, a sampling of the extended mix's chord progression, cover by Brickmason Games)
	
Audio Samples:
- sound/player/death.wav - Me going "ch!" into the microphone.
- sound/player/footsteps(1-3).wav - Me recording the sound of my mouse "waddling" on my iPhone
- sound/afc-sfx/elevbell1.wav - A recording of a hotel bell I had in my house
- sound/afc-sfx/faithPlateActivated.wav - Me going "pfeew!" into the microphone
- sound/afc-sfx/button_pressed.wav - Me going "beep" into the microphone
- sound/afc-sfx/floor_button_(up/down).wav - Me humming in front of the microphone
- sound/afc-sfx/energy_ball_(launcher/moving).wav - A spliced recording of me going "wanananananananana"
- sound/afc-sfx/teleporter_(entry/exit).wav - Me making "fssssh!" "whssi-sheeo" sounds
- sound/afc-sfx/weird-route-jingle.mp3 - The _Weird Route_ sound effect from Deltarune, used in afc_ch1_trust_fling_hard
- sound/afc-sfx/doorOpen.wav - Me humming into the microphone (again)

So let's run through the breakdown of what all is here:
- 
- /
 This is the folder containing project.godot, this readme, and the engine "stamps" as I call them.
	 - /src
	  This is the folder containing all the game's actual logical source code.
		  - /src/base
		   This is the folder containing all "entities" and managerial components the game uses, from the player to the title screen.
		   - /src/config
		    This is the folder containing the build flags container, the localization system, and the _LevelManager_, which is arguably the most important piece of the MSTK code as it manages demos, versioning, level transitions, the console command system, and loading localization and game configuration files.
		    - /src/afc
		     This folder contains Aerial Testing Course specific entities, like the turrets.
		     - /src/portal
		      This folder contains all "portal" related mechanics, including:
			      - The Portalgun
			      - The portals themselves
			      - The portal rendering surfaces
			      - The portal cleansers (currently unused in AFC)
			  - /src/weapons
			   Arguably, this should be /src/base/weapons, but it contains the base test weapons (both of which are controlled by feature flags)
			  - /src/bsploader
			   Masonry Toolkit has a stripped-down copy of LibBSP under the bsploader folder. It's currently capable of loading most BSP 20 levels, minus displacements, certain materials, lightmaps, and models.
	- /instances
		 This is the folder containing all the game's "prefabs", otherwise known as instances. These are objects you can drag-and-drop into the level with varying levels of prerequisite setup required.
	 - /materials
		  This folder contains all the (.tres) materials the game uses, the most common and important ones being InnoGlass, portallable_surface, SkyboxShader, and TemplateMaterial
	 - /models
		  This folder contains all the models, of which right now there are only 3, being the cube, the "straight fence", and the "bent fence".
	  - /resources
	   This folder contains localization and game metadata, including: The game's name, its chapter list, all subtitles and closed captions, buildvars, the debug map list, the values shown in the settings miscellaneous tab, the game's version, the game's save folder name (GameInternalName)
	  - /textures
	   Big shocker, this folder contains every texture in the game.
	  - /vgui
	   This folder contains the DWGUI VGUI window frame and theme recreation framework.
	  - /sound
	   Big shocker again, this folder contains every sound in the game.
	  - /viewmodel
	   A folder containing every viewmodel in the game, all of which are loaded by the weapon scripts.
	   - /maps
	    A folder containing every map the game uses. It's currently split into two subdirectories:
		  - /maps
		   This folder contains the main campeign content for Aerial Testing Course
		  - /maps/devtest
		   This folder contains all Masonry Toolkit developer test maps.
		  - /maps/nullified
		   This folder contains every map that was formerly part of Aerial Testing Course, but has since been deprecated and/or moved to being bonus content (Scrapter 2)



