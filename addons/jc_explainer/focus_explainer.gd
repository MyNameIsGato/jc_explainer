class_name CYSFocusExplainer extends CYSExplainer

const TWEEN_LENGTH = 0.2

@export var locator: Marker2D
@onready var bg := $ColorRect
@onready var border := $Border
var tween: Tween

func _ready() -> void:
	location = locator.position - Vector2(200, 50)
	border.size.y = ui_title.size.y + 40
	super()
	bg.modulate = Color.TRANSPARENT
	bg.position -= location

func display(context: Dictionary) -> void:
	super(context)
	border.size.y += ui_text.size.y
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(bg, "modulate", Color.WHITE, TWEEN_LENGTH).set_ease(Tween.EASE_OUT)

func conceal() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(bg, "modulate", Color.TRANSPARENT, TWEEN_LENGTH).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(TWEEN_LENGTH + 0.05).timeout
	dismissed.emit()
	hide()
