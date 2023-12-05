extends Node2D

const PickUp = preload("res://Item/pick_up/pick_up.tscn")

@onready var player_cat: CharacterBody2D = $PlayerCat
@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var hotbar = $UI/Hotbar

var input_enabled = true

func _ready() -> void:
	player_cat.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player_cat.inventory_data)
	hotbar.set_inventory_data(player_cat.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

func _physics_process(delta):
	if input_enabled == false:
		set_process_input(false)
	else:
		set_process_input(true)

#Inventory management
func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		hotbar.hide()
		input_enabled = false
	else:
		hotbar.show()
		input_enabled = true
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()


func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player_cat.get_drop_position()
	add_child(pick_up)
