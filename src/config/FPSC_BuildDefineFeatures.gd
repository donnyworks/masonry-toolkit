extends Object
class_name FPSC_BuildFeatures

# Defines features that FPSC is allowed to use. Like game-specific things.

## Shouldn't this be constant? Why would we want to modify build features mid-runtime? [Donovan 06/10/26]
## Because, we have GameMetadata now. [Donovan 06/29/26]

static var BuildFeatures = {
	"FEATURE_SRCBOX":true,
	"FEATURE_TESTWPN":false,
	"FEATURE_DYNAMO":true,
	"FEATURE_SCRIPTEDSEQUENCE":true,
	"FEATURE_MAPSELECTOR":false
}
