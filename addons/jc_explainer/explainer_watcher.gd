class_name CYSExplainerWatcher extends SubViewportContainer

signal revealed
signal dismissed

@onready var subview := $SubViewport

@export var signal_condition: CYSSignalCondition
@export var optional_conditions: Array[CYSTriggerCondition]
@export var context_mapping: Dictionary[StringName, StringName]
@export var debug: bool = false
@export var oneshot: bool = true
@export var subview_size: Vector2

var explainer_index: int = 0
var fired: bool = false

func _ready() -> void:
	hide()
	if !stretch: subview.size = subview_size
	
	for c: Node in get_children():
		if !c is CYSExplainer:
			continue
		c.reparent(subview, true)
	
	signal_condition.met.connect(activate)
	for cond: CYSTriggerCondition in optional_conditions:
		cond.met.connect(activate)

func activate() -> void:
	if (fired and oneshot) or !check_triggered(): return
	if !visible: display()
	explainer_index = 0
	display_explainer()
	fired = true

func display_explainer() -> void:
	if explainer_index >= subview.get_child_count():
		conceal()
		return
	var child: CYSExplainer = subview.get_child(explainer_index)
	if !child.dismissed.has_connections():
		child.dismissed.connect(next_explainer)
	child.display(context_mapping)

func next_explainer() -> void:
	explainer_index += 1
	display_explainer()

func display() -> void:
	show()
	revealed.emit()
	
func conceal() -> void:
	hide()
	dismissed.emit()

func check_triggered() -> bool:
	if !signal_condition.is_met(): return false
	if optional_conditions.size() > 0 and\
		optional_conditions.any(func(x:CYSTriggerCondition)->bool: return !x.is_met()): return false
	return true

func in_debug() -> bool:
	return debug and debug
