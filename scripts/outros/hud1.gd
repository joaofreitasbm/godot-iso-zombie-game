extends Control

@onready var pers = $"../pers"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
		
	$hp.text = str(
		"Health: ", get_node("/root/main/pers").vida, "\n",
		"Press E to change controls", "\n",
		"movement > WASD", "\n",
		"Aim > RMB", "\n",
		"Shoot > LMB", "\n", 
		"Run > shift", "\n", "\n",
		"Movement speed: ", get_node("/root/main/pers").velandar, "\n", "\n",
		"vsync off / FPS: ", Engine.get_frames_per_second()
		
	)
