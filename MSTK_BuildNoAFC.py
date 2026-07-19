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
    "textures/chapter0_image.png"
]

meta = """
{
	"GameName":"Masonry Toolkit Base",
	"Version":"1.0",
	"GameInternalName":"replaceme",
	"Chapters":{
        "devtest/devtest2":"chapter0_image.png"
	},
	"BonusChapters":{
	},
	"BackgroundMaps":[
        "devtest/background_devtest2"
	],
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

import os, shutil

try:
    os.mkdir("../masonry-toolkit-clean")
except:
    print("WARN: Failed to create Masonry Toolkit dir. Does it already exist?")


print("Copying files that aren't minus'd!")

for f in content_noncopyright:
    if not f.startswith("-"):
        if os.path.isdir(f): # directory. rawdog copy it.
            shutil.copytree(f, "../masonry-toolkit-clean/" + f)
        if os.path.isfile(f): # file. file file file file-
            shutil.copy(f, "../masonry-toolkit-clean/" + f)
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
            if os.path.isdir("../masonry-toolkit-clean/" + v):
                shutil.rmtree("../masonry-toolkit-clean/" + v)
            if os.path.isfile("../masonry-toolkit-clean/" + v):
                os.remove("../masonry-toolkit-clean/" + v)

os.mkdir("../masonry-toolkit-clean/resources")

f = open("../masonry-toolkit-clean/resources/FPSC_GameMetadata.json","w")
f.write(meta)
f.close()

f = open("../masonry-toolkit-clean/resources/FPSC_lang_en_US.json","w")
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
