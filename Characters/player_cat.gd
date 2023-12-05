extends CharacterBody2D

signal toggle_inventory()

#Mouvement
@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0, 1)

#Inventaire
@export var inventory_data: InventoryData
@onready var game_level_script = $"/root/GameLevel"

#Stats
var stamina: int = 100

#Animations
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

#Interactions
@onready var all_interactions = []
@onready var interactLabel = $"Interaction Components/InteractLabel"

func _ready():
	update_animation_parameters(starting_direction)
	update_interactions()
	PlayerManager.player = self

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	
	#Interaction
	if Input.is_action_just_pressed('interact'):
		execute_interation()

func _physics_process(_delta):
	if game_level_script.input_enabled == true:
		#Get input direction
		var input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		).normalized()
		
		update_animation_parameters(input_direction)
		
		#Update velocity
		velocity = input_direction * move_speed
		
		#Move and Slide function uses velocity of character body to move character on map
		move_and_slide()
		
		pick_new_state()
	else:
		velocity = Vector2.ZERO
		pick_new_state()
	

func get_drop_position() -> Vector2:
	var look_direction = animation_tree.get("parameters/Idle/blend_position")
	look_direction = look_direction.normalized()
	var drop_distance = 15
	var drop_position = global_position + look_direction * drop_distance
	
	return drop_position

func update_animation_parameters(move_input : Vector2):
	#Don't change animation parameters if there is no move input
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

#Choose state based on what is happening with the player
func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

#Stat changes
func recover(recovery_value: int) -> void:
	stamina += recovery_value
	print(stamina)


##########################################
# Interaction Methods

func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	update_interactions()

func _on_interaction_area_area_exited(area):
	all_interactions.erase(area)
	update_interactions()

func update_interactions():
	if all_interactions and all_interactions[0].visible:
		interactLabel.text = all_interactions[0].interact_value
	else:
		interactLabel.text = ""

func execute_interation():
	if all_interactions:
		var current_interaction = all_interactions[0]
		if current_interaction.visible:
			match current_interaction.interact_type:
				"print_text": print(current_interaction.interact_value)
				"open_external_inventory":
					current_interaction.get_parent().player_interact()
				"pick_up":
					current_interaction.get_parent().is_picked_up(self)
				"tree_cut":
					current_interaction.get_parent().tree_cutdown(current_interaction.get_parent())
					update_interactions()
		else:
			return
