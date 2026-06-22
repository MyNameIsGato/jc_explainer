extends GdUnitTestSuite

class_name TestExplainer

var SCENE: PackedScene = load("res://addons/jc_explainer/explainer.tscn")
var explainer: CYSExplainer

func before_test() -> void:
	explainer = SCENE.instantiate()
	add_child(explainer)

func after_test() -> void:
	remove_child(explainer)
	explainer.free()

func test_initialization() -> void:
	explainer.title = "Test Title"
	explainer.text = "Test Text"
	explainer.location = Vector2(100, 200)
	
	explainer._ready()
	
	assert_str(explainer.ui_title.text).is_equal("Test Title")
	assert_vector(explainer.global_position).is_equal(Vector2(100, 200))
	assert_bool(explainer.visible).is_false()

func test_display() -> void:
	explainer.text = "Plain text"
	explainer._ready()
	
	explainer.display({})
	
	assert_str(explainer.ui_text.text).is_equal("Plain text")
	assert_bool(explainer.visible).is_true()

func test_display_with_context() -> void:
	explainer.text = "Hello {name}"
	explainer._ready()
	
	var context = {"name": "World"}
	explainer.display(context)
	
	assert_str(explainer.ui_text.text).is_equal("Hello World")
	assert_bool(explainer.visible).is_true()

func test_conceal() -> void:
	var received = {"signal": false}
	explainer.dismissed.connect(func(): received["signal"] = true)
	
	explainer._ready()
	explainer.display({})
	explainer.conceal()
	
	assert_bool(explainer.visible).is_false()
	assert_bool(received["signal"]).is_true()

func test_mouse_click_conceals() -> void:
	var received = {"signal": false}
	explainer.dismissed.connect(func(): received["signal"] = true)
	explainer._ready()
	explainer.display({})
	
	var mouse_event = InputEventMouseButton.new()
	mouse_event.button_index = MOUSE_BUTTON_LEFT
	mouse_event.pressed = true
	
	explainer._on_gui_input(mouse_event)
	
	assert_bool(explainer.visible).is_false()
	assert_bool(received["signal"]).is_true()
