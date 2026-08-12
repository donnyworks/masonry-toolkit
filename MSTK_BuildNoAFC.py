print("Masonry Toolkit Branching Software")
print("Creates a folder containing Masonry Toolkit without Aerial Testing Course.")

content_noncopyright = [
    "instances",
    "src",
    "vgui",
    "viewmodel",
    "materials",
    "maps",
    "sound",
    "textures",
    "project.godot",
    "masonry-toolkit-icon.png",
    "readme.txt",
    "thirdpartylicensedetails.txt",
    "changelog.txt",
    "MSTK_BuildNoAFC.py",
    "-instances/afc",
    "-materials/esc_pure_black.tres",
    "-materials/FiftyShadesOFBRICK.tres",
    "-materials/InnoGlass.tres",
    "-sound/music",
    "-sound/vo",
    "-sound/vo_jokelang",
    "-sound/*.mid",
    "-sound/teleporter_entry.wav",
    "-sound/teleporter_exit.wav",
    "-sound/velocity_test",
    "-sound/chordsample.wav",
    "-sound/doorOpen.wav",
    "-sound/faithPlateActivated.wav",
    "-sound/floor_button_down.wav",
    "-sound/floor_button_up.wav",
    "-sound/button_pressed.wav",
    "-maps/*.tscn",
    "-maps/nullified",
    "-textures/*.png",
    "-textures/*.import",
    "-textures/clipboard",
    "-instances/teleporter_exit_model_scaled.tscn",
    "-sound/afc-sfx",
    "-src/afc",
    "textures/chapter0_image.png"
]

meta = """
{
	"GameName":"Masonry Toolkit Base",
	"Version":"1.0",
	"GameInternalName":"%in",
	"Chapters":{
        "devtest/devtest2":"chapter0_image.png"
	},
	"BonusChapters":{
	},
	"BackgroundMaps":[
        "devtest/background_devtest2"
	],,
	"SupportsChapters":true,
	"SupportsBonusChapters":false,
	"BuildFeatures":{
		"FEATURE_SRCBOX":true,
		"FEATURE_TESTWPN":true,
		"FEATURE_DYNAMO":true,
		"FEATURE_SCRIPTEDSEQUENCE":true,
		"FEATURE_MAPSELECTOR":true
	},
	"DebugMapList":{
		"DYNAMO lighting system test":"res://maps/devtest/FPSC_Test.tscn",
		"Physics testing area":"res://maps/devtest/devtest2.tscn",
		"Portal testing area":"res://maps/devtest/devtest_portals.tscn",
		"Catapult testing area":"res://maps/devtest/devtest_catapult.tscn",
		"NPC testing area":"res://maps/devtest/devtest_pathfinder.tscn"
	},
    "CheckboxValues":{
        "propvis":"Show Held Props"
    }
}"""

import os, shutil, sys

target_dir = "masonry-toolkit-clean"

game_internal_name = "replaceme"

if len(sys.argv) > 1:
    target_dir = sys.argv[1]
if len(sys.argv) > 2:
    game_internal_name = sys.argv[2]

try:
    os.mkdir("../" + target_dir)
except:
    print("WARN: Failed to create Masonry Toolkit dir. Does it already exist?")


print("Copying files that aren't minus'd!")

for f in content_noncopyright:
    if not f.startswith("-"):
        if os.path.isdir(f): # directory. rawdog copy it.
            shutil.copytree(f, "../" + target_dir + "/" + f)
        if os.path.isfile(f): # file. file file file file-
            shutil.copy(f, "../" + target_dir + "/" + f)
    else:
        variants = []
        if not "*" in f: # i hate those astrisks
            variants = [f.split("-",1)[1]]
        else:
            deastrified = f.split("-",1)[1].split("*")
            dir_host = deastrified[0]
            if len(deastrified) < 3:
                for thing in os.listdir(dir_host):
                    #print(thing,deastrified[1])
                    if thing.endswith(deastrified[1]):
                        variants.append(dir_host + thing)
            else:
                raise Exception("Unimplemented.")
        for v in variants:
            if os.path.isdir("../" + target_dir + "/" + v):
                shutil.rmtree("../" + target_dir + "/" + v)
            if os.path.isfile("../" + target_dir + "/" + v):
                os.remove("../" + target_dir + "/" + v)

os.mkdir("../" + target_dir + "/resources")

f = open("../" + target_dir + "/resources/FPSC_GameMetadata.json","w")
f.write(meta.replace("%in",game_internal_name))
f.close()

f = open("../" + target_dir + "/resources/FPSC_lang_en_US.json","w")
f.write("""{
	"Player.InteractionFailed":"[i][Can't Use][/i]",
	"Player.Death":"[i][Death][/i]",
	"Generic.ButtonPress":"[i][Button Pressed][/i]",
	"Generic.ButtonDisabled":"[i][Button Access Denied][/i]",
    "Chapters.devtest/devtest2":"Devtest 2",
	"Devtest2.title":"DEV TEST 2",
	"Devtest2.subtext":"[font_size=24]The Part Where Developers Test You[/font_size]"
}""")
f.close()
