extends Node

## Addendum: Credit Gev for this code, it's ripped straight from OS95 Plus!, you thief. [Donovan 06/10/26]








@export_category("debrisGeneric")

@export var lifespan: float = 5.0


@export var template: bool = false

func _ready():
	if !template:
		await get_tree().create_timer(lifespan, false).timeout
		queue_free()
