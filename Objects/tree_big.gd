extends Node2D

@export var drop_item_data: SlotData

var pickup_scene = preload("res://Item/pick_up/pick_up.tscn")
@onready var game_level = $".."

@onready var tree_big_sprite = $Tree_big_sprite
@onready var tree_big_cut_sprite = $Tree_big_cut_sprite
@onready var interact_area = $InteractArea

func tree_cutdown(target) -> void:
	interact_area.visible = false
	tree_big_sprite.visible = false
	tree_big_cut_sprite.visible = true
	# TODO : Spawn x amount of pickup items
	spawn_pickup_item(target)

# Spawning items
func spawn_pickup_item(drop_parent) -> void:
	var spawned_item = pickup_scene.instantiate()
	spawned_item.slot_data = drop_parent.drop_item_data
	spawned_item.position = drop_parent.get_drop_position()
	game_level.add_child(spawned_item)

func get_drop_position() -> Vector2:
	var origin_position = self.global_position
	var angle = randf_range(0, 2 * PI)
	var drop_distance = 5
	
	# Utiliser la dernière destination comme base pour le point aléatoire
	var x = origin_position.x + cos(angle) * drop_distance
	var y = origin_position.y + sin(angle) * drop_distance
	
	return Vector2(x, y)
