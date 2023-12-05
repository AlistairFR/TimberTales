extends Sprite2D

@export var slot_data : SlotData
var pickup = preload("res://Item/pick_up/pick_up.tscn")
@onready var sprite_2d = $"."

func _ready() -> void:
	sprite_2d.texture = slot_data.item_data.texture

func is_picked_up(body:CharacterBody2D) -> void:
	if body.inventory_data.pick_up_slot_data(slot_data):
		queue_free()
