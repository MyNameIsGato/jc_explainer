extends GdUnitTestSuite

class_name TestTriggerCondition

func test_is_met_default() -> void:
	var condition = CYSTriggerCondition.new()
	assert_bool(condition.is_met()).is_false()

func test_reset_does_nothing() -> void:
	var condition = CYSTriggerCondition.new()
	condition.reset()  # Should not error
	assert_bool(condition.is_met()).is_false()
