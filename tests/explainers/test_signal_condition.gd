extends GdUnitTestSuite

class_name TestSignalCondition

func test_initial_state() -> void:
	var condition = CYSSignalCondition.new()
	assert_bool(condition.is_met()).is_false()
	assert_bool(condition.signal_fired).is_false()

func test_emit() -> void:
	var condition = CYSSignalCondition.new()
	var received = {"signal": false}
	condition.met.connect(func(): received["signal"] = true)
	
	condition.emit()
	
	assert_bool(condition.is_met()).is_true()
	assert_bool(condition.signal_fired).is_true()
	assert_bool(received["signal"]).is_true()

func test_cancel() -> void:
	var condition = CYSSignalCondition.new()
	condition.emit()
	assert_bool(condition.is_met()).is_true()
	
	condition.cancel()
	assert_bool(condition.is_met()).is_false()
	assert_bool(condition.signal_fired).is_false()

func test_reset() -> void:
	var condition = CYSSignalCondition.new()
	condition.emit()
	assert_bool(condition.is_met()).is_true()
	
	condition.reset()
	assert_bool(condition.is_met()).is_false()
	assert_bool(condition.signal_fired).is_false()

func test_multiple_emissions() -> void:
	var condition = CYSSignalCondition.new()
	var received = {"emitted": 0}
	condition.met.connect(func(): received["emitted"] += 1)
	
	condition.emit()
	condition.reset()
	condition.emit()
	
	assert_int(received["emitted"]).is_equal(2)
	assert_bool(condition.is_met()).is_true()
