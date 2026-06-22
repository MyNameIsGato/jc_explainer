extends GdUnitTestSuite

class_name TestFocusExplainer

var SCENE: PackedScene = load("res://addons/jc_explainer/focus_explainer.tscn")
var focus_explainer: CYSFocusExplainer

func before_test() -> void:
	focus_explainer = SCENE.instantiate()
	add_child(focus_explainer)

func after_test() -> void:
	remove_child(focus_explainer)
	focus_explainer.free()

func test_initial_position() -> void:
	var marker = auto_free(Marker2D.new())
	marker.position = Vector2(300, 400)
	focus_explainer.locator = marker
	
	focus_explainer._ready()
	
	# Should be offset by (-200, -50) from locator
	assert_vector(focus_explainer.location).is_equal(Vector2(100, 350))

func test_display_creates_tween() -> void:
	var marker = auto_free(Marker2D.new())
	focus_explainer.locator = marker
	focus_explainer._ready()
	
	focus_explainer.display({})
	
	assert_object(focus_explainer.tween).is_not_null()

func test_conceal_emits_dismissed_after_tween() -> void:
	var marker = auto_free(Marker2D.new())
	focus_explainer.locator = marker
	var received = {"signal": false}
	focus_explainer.dismissed.connect(func(): received["signal"] = true)
	focus_explainer._ready()
	focus_explainer.display({})
	
	focus_explainer.conceal()
	
	# Wait for tween to complete
	await get_tree().create_timer(CYSFocusExplainer.TWEEN_LENGTH + 0.05).timeout
	assert_bool(received["signal"]).is_true()
	assert_bool(focus_explainer.visible).is_false()
