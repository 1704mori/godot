extends CanvasLayer

signal toggle_draw_collision(enabled)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_check_box_toggled(toggled_on):
	emit_signal("toggle_draw_collision", toggled_on)
