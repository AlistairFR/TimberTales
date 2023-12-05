extends Sprite2D

@onready var game_level = $".."

@export var chicken_count: int = 4

func _ready():
	spawn_chicken()

#Chickens spawn in front of the coop
# Spawning chickens
func spawn_chicken() -> void:
	for chickens in chicken_count:
		var chicken = preload("res://Characters/chicken.tscn").instantiate()
		chicken.position = self.global_position + Vector2(0, 15)
		chicken.move_speed = 20
		game_level.add_child.call_deferred(chicken)
		chicken_count -= 1
		await get_tree().create_timer(1).timeout

#Chickens need to go back inside
func despawn_chicken(chicken) -> void:
	chicken_count +=1
	chicken.queue_free()

#When a chicken is inside
	#Added to an array
	#Each chicken has an egg-laying timer that starts
	#At the of the timer, add an egg to the coop

#When player interacts with the coop
	#Create slot_data inside player_inventory
	#Add all eggs to the slot
