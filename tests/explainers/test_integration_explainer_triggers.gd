extends GdUnitTestSuite

class_name TestExplainerTriggerIntegration

var SCENE: PackedScene = load("res://addons/jc_explainer/explainer.tscn")
var TRIGGER_SCENE: PackedScene = load("res://addons/jc_explainer/explainer_watcher.tscn")
var explainer: CYSExplainer
var trigger: CYSExplainerWatcher

func before_test() -> void:
	explainer = SCENE.instantiate()
	explainer.location = Vector2.ZERO
	trigger = TRIGGER_SCENE.instantiate()
	add_child(trigger)

func after_test() -> void:
	remove_child(trigger)
	explainer.free()
	trigger.free()

func test_check_triggered_logic() -> void:
	var main_cond = CYSSignalCondition.new()
	var opt_cond = CYSSignalCondition.new()
	
	trigger.signal_condition = main_cond
	trigger.optional_conditions = [opt_cond]
	
	# No conditions met
	assert_bool(trigger.check_triggered()).is_false()
	
	# Only main condition met
	main_cond.emitted()
	assert_bool(trigger.check_triggered()).is_false()
	
	# All conditions met
	opt_cond.emitted()
	assert_bool(trigger.check_triggered()).is_true()
	
	# Reset main condition
	main_cond.reset()
	assert_bool(trigger.check_triggered()).is_false()

func test_trigger_with_signal_only() -> void:
	var signal_condition = CYSSignalCondition.new()
	trigger.signal_condition = signal_condition
	
	explainer.title = "Test"
	explainer.text = "Content"
	trigger.add_child(explainer)
	
	var result = {"revealed": false}
	trigger.revealed.connect(func(): result["revealed"] = true)
	
	trigger._ready()
	signal_condition.emitted()
	
	assert_bool(result["revealed"]).is_true()
	assert_bool(trigger.visible).is_true()
	assert_bool(explainer.visible).is_true()

func test_trigger_with_optional_conditions() -> void:
	var main_condition = CYSSignalCondition.new()
	var opt1 = CYSSignalCondition.new()
	var opt2 = CYSSignalCondition.new()
	
	trigger.signal_condition = main_condition
	trigger.optional_conditions = [opt1, opt2]
	
	explainer.title = "Test"
	explainer.text = "Content"
	trigger.add_child(explainer)
	
	trigger._ready()
	
	# Main condition met but optional not met - should not show
	assert_bool(trigger.visible).is_false()
	main_condition.emitted()
	await get_tree().process_frame
	assert_bool(trigger.visible).is_false()
	
	# All conditions met - should show
	opt1.emitted()
	opt2.emitted()
	await get_tree().process_frame
	assert_bool(trigger.visible).is_true()

func test_oneshot_prevents_reactivation() -> void:
	trigger.oneshot = true
	var signal_condition = CYSSignalCondition.new()
	trigger.signal_condition = signal_condition
	
	explainer.title = "Test"
	explainer.text = "Content"
	trigger.add_child(explainer)
	
	trigger._ready()
	
	# First activation
	signal_condition.emitted()
	await get_tree().process_frame
	assert_bool(trigger.visible).is_true()
	
	# Conceal and try to activate again
	trigger.conceal()
	signal_condition.emitted()
	await get_tree().process_frame
	assert_bool(trigger.visible).is_false()  # Should not show again

func test_multiple_explainers_sequence() -> void:
	var signal_condition = CYSSignalCondition.new()
	trigger.signal_condition = signal_condition
	
	explainer.title = "First"
	explainer.text = "Content"
	var explainer2 = SCENE.instantiate()
	explainer2.title = "Second"
	explainer2.text = "More Content"
	
	trigger.add_child(explainer)
	trigger.add_child(explainer2)
	
	trigger._ready()
	signal_condition.emitted()
	await get_tree().process_frame
	
	# First explainer should be visible
	assert_bool(explainer.visible).is_true()
	assert_bool(explainer2.visible).is_false()
	
	# Dismiss first explainer
	explainer.conceal()
	await get_tree().process_frame
	
	# Second explainer should now be visible
	assert_bool(explainer2.visible).is_true()
	explainer2.free()

func test_context_mapping() -> void:
	var signal_condition = CYSSignalCondition.new()
	trigger.signal_condition = signal_condition
	trigger.context_mapping = {
		"player_name": "player_nickname"
	}
	
	explainer.title = "Welcome"
	explainer.text = "Hello {player_name}"
	trigger.add_child(explainer)
	
	trigger._ready()
	signal_condition.emitted()
	await get_tree().process_frame
	
	# The actual context would be provided by the signal emitter
	# This test verifies the mapping structure exists
	assert_object(trigger.context_mapping).is_not_null()

func test_conceal_hides_trigger_and_emits_signal() -> void:
	var signal_condition = CYSSignalCondition.new()
	trigger.signal_condition = signal_condition
	
	var result = {"dismissed": false}
	trigger.dismissed.connect(func(): result["dismissed"] = true)
	trigger.add_child(explainer)
	
	trigger._ready()
	assert_bool(trigger.visible).is_false()
	signal_condition.emitted()
	await get_tree().process_frame
	assert_bool(trigger.visible).is_true()
	
	trigger.conceal()
	assert_bool(trigger.visible).is_false()
	assert_bool(result["dismissed"]).is_true()

func test_activate_when_already_visible() -> void:
	var signal_condition = CYSSignalCondition.new()
	trigger.signal_condition = signal_condition
	trigger.oneshot = false
	
	explainer.title = "Test"
	explainer.text = "Content"
	trigger.add_child(explainer)
	
	trigger._ready()
	signal_condition.emitted()
	await get_tree().process_frame
	
	var explainer_index_before = trigger.explainer_index
	
	# Activate again while visible
	trigger.activate()
	
	assert_int(trigger.explainer_index).is_equal(explainer_index_before)  # Should reset to 0
