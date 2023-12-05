extends ItemData
class_name ItemDataConsumable

@export var recovery_value: int

func use(target) -> void:
	if recovery_value !=0:
		target.recover(recovery_value)
