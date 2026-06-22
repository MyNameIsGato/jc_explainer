class_name CYSExplainer extends Control

signal dismissed

@export var title: String
@export_multiline var text: String
@export var image: Texture2D
@export var location: Vector2

@onready var ui_image := $Image
@onready var ui_title := $Title
@onready var ui_text := $Text

func _ready() -> void:
	global_position = location
	visible = false
	ui_title.text = title

func display(context: Dictionary) -> void:
	var parsed_string: String = text.format(context)
	ui_text.text = parsed_string
	visible = true

func conceal() -> void:
	visible = false
	dismissed.emit()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		conceal()
