extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event:InputEvent):
	if ($Chat/chatInput.has_focus() and event is InputEventMouseButton and not $Chat.get_global_rect().has_point(event.position)):
		$Chat/chatInput.release_focus()
