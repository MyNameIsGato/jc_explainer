extends GdUnitTestSuite

class_name TestFullSystemIntegration

var SCENE: PackedScene = load("res://scenes/explainer/focus_explainer.tscn")
var TRIGGER_SCENE: PackedScene = load("res://scenes/explainer/explainer_watcher.tscn")
var focus_explainer: CYSFocusExplainer
var trigger: CYSExplainerWatcher

func before_test() -> void:
	focus_explainer = SCENE.instantiate()
	focus_explainer.location = Vector2.ZERO
	trigger = TRIGGER_SCENE.instantiate()
	add_child(trigger)

func after_test() -> void:
	remove_child(trigger)
	focus_explainer.free()
	trigger.free()

func test_complete_flow_with_focus_explainer() -> void:
	# Setup the full system
	var signal_condition = CYSSignalCondition.new()
	trigger.signal_condition = signal_condition
	
	# Create a focus explainer (mock the locator)
	var marker = auto_free(Marker2D.new())
	marker.position = Vector2(400, 300)
	focus_explainer.locator = marker
	focus_explainer.title = "Tutorial Step"
	focus_explainer.text = "Click here to continue"
	
	trigger.add_child(focus_explainer)
	
	var result = {
		"revealed": 0,
		"dismissed": 0
		}
	trigger.revealed.connect(func(): result["revealed"] += 1)
	trigger.dismissed.connect(func(): result["dismissed"] += 1)
	
	trigger._ready()
	
	# Trigger the tutorial
	signal_condition.emitted()
	await get_tree().process_frame
	
	assert_int(result["revealed"]).is_equal(1)
	assert_bool(trigger.visible).is_true()
	assert_bool(focus_explainer.visible).is_true()
	
	# Dismiss the tutorial
	focus_explainer.conceal()
	await get_tree().create_timer(0.3).timeout
	
	assert_int(result["dismissed"]).is_equal(1)
	assert_bool(trigger.visible).is_false()

func test_multiple_triggers_independent() -> void:
	var trigger2 = auto_free(trigger.duplicate())
	var focus_explainer2 = auto_free(focus_explainer.duplicate())
	focus_explainer.locator = auto_free(Marker2D.new())
	focus_explainer2.locator = auto_free(Marker2D.new())
	
	var cond1 = CYSSignalCondition.new()
	var cond2 = CYSSignalCondition.new()
	
	trigger.signal_condition = cond1
	trigger2.signal_condition = cond2
	
	focus_explainer.title = "Trigger 1"
	focus_explainer.text = "Content 1"
	focus_explainer2.title = "Trigger 2"
	focus_explainer2.text = "Content 2"
	
	add_child(trigger2)
	trigger.add_child(focus_explainer)
	trigger2.add_child(focus_explainer2)
	
	trigger._ready()
	trigger2._ready()
	
	# Activate only trigger1
	cond1.emitted()
	await get_tree().process_frame
	
	assert_bool(trigger.visible).is_true()
	assert_bool(trigger2.visible).is_false()
	
	# Activate only trigger2
	trigger.conceal()
	cond2.emitted()
	await get_tree().process_frame
	
	assert_bool(trigger.visible).is_false()
	assert_bool(trigger2.visible).is_true()
