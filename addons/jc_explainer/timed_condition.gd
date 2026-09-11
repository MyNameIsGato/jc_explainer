class_name TimedCondition extends SignalCondition

@export var duration: float = 1.0

var _timer: SceneTreeTimer

func _init() -> void:
	pass

func emit() -> void:
	_timer = Engine.get_main_loop().create_timer(duration)
	_timer.timeout.connect(time_up)

func time_up() -> void:
	signal_fired = true
	met.emit()
