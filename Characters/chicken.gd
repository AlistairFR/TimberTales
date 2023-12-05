extends CharacterBody2D

enum CHICKEN_STATE { IDLE, WALK, GO_HOME }

@export var move_speed : float = 20
@export var idle_time : float = 7
@export var rayon_min : float = 20
@export var rayon_max : float = 35

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprite = $Sprite2D
@onready var timer = $Timer
@onready var collision_right = $CollisionShapeRight
@onready var collision_left = $CollisionShapeLeft
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var navReg = $"/root/GameLevel/NavigationRegion2D"
@onready var chicken_coop = $"/root/GameLevel/Chicken_Coop"

var current_state : CHICKEN_STATE = CHICKEN_STATE.IDLE
var direction : Vector2 = Vector2.ZERO
var last_destination: Vector2 = Vector2.ZERO

func _ready():
	call_deferred("pick_new_state")

func _physics_process(delta):
	if (current_state == CHICKEN_STATE.WALK):
		# If target is inside the nav region
		if nav.is_target_reachable():
			# retrieve next destination point
			var next_location = nav.get_target_position()
			# if far enough
			if int(nav.distance_to_target()) > 1:
				#move to destination point
				direction = global_position.direction_to(next_location)
				global_position += direction * delta * move_speed
			# Close enough to idle
			else:
				current_state = CHICKEN_STATE.IDLE
				state_machine.travel("Idle")
		# pick a new destination if point is outside the nav region
		else:
			pick_destination()
	elif (current_state == CHICKEN_STATE.GO_HOME):
		# If target is inside the nav region
		if nav.is_target_reachable():
			# retrieve next destination point
			var next_location = nav.get_target_position()
			# if far enough
			if int(nav.distance_to_target()) > 1:
				#move to destination point
				direction = global_position.direction_to(next_location)
				global_position += direction * delta * move_speed
		else:
			print("Home not reachable")
	# keep sprite updated
	update_flip()

# get a random point around the current position
func get_point_near(rayon_min, rayon_max) -> Vector2:
	last_destination = global_position
	var angle = randf_range(0, 2 * PI)
	var distance = randf_range(rayon_min, rayon_max)
	
	# Utiliser la dernière destination comme base pour le point aléatoire
	var x = last_destination.x + cos(angle) * distance
	var y = last_destination.y + sin(angle) * distance
	
	return Vector2(x, y)

# pick a new destination point
func pick_destination():
	last_destination = get_point_near(rayon_min, rayon_max)
	nav.target_position = last_destination
	return nav.target_position

#Go back to the coop
func go_to_coop():
	nav.target_position = chicken_coop.global_position + Vector2(0,15)
	return nav.target_position

# update sprite flip and CollisionShapes based on x axis
func update_flip():
	if (direction.x < 0):
		sprite.flip_h = true
		collision_right.disabled = true
		collision_left.disabled = false
	elif (direction.x > 0):
		sprite.flip_h = false
		collision_right.disabled = false
		collision_left.disabled = true

# pick another state
func pick_new_state():
	if(current_state == CHICKEN_STATE.IDLE):
		timer.start(randf_range(1, idle_time))
		if randi_range(1,40) != 40:
			pick_destination()
			state_machine.travel("Walk")
			current_state = CHICKEN_STATE.WALK
		else:
			current_state = CHICKEN_STATE.GO_HOME
	elif(current_state == CHICKEN_STATE.WALK):
		state_machine.travel("Idle")
		current_state = CHICKEN_STATE.IDLE
	elif(current_state == CHICKEN_STATE.GO_HOME):
		go_to_coop()
		state_machine.travel("Walk")


func _on_timer_timeout():
	pick_new_state()

# Chicken interactions
func _on_interact_area_area_entered(area):
	if area and current_state == CHICKEN_STATE.GO_HOME:
		match area.interact_type:
			"chicken_despawn": area.get_parent().despawn_chicken(self)
