class_name CYSSignalCondition extends CYSTriggerCondition

@export var signal_fired: bool = false

func is_met() -> bool:
	return signal_fired

func emit() -> void:
	signal_fired = true
	met.emit()

func cancel() -> void:
	signal_fired = false

func reset() -> void:
	signal_fired = false
