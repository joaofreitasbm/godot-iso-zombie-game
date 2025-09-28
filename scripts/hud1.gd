extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movimentação
	if get_node("/root/main/pers").movtank == false:
		movimentação = "3D free controls"
	if get_node("/root/main/pers").movtank == true:
		movimentação = "tank controls"
		
	$hp.text = str(
		"Health: ", get_node("/root/main/pers").vida, "\n",
		"Press E to change controls", "\n",
		 movimentação, "\n", "\n",
		"movement > WASD", "\n",
		"Aim > RMB", "\n",
		"Shoot > LMB", "\n", 
		"Run > shift", "\n", "\n",
		"Movement speed: ", get_node("/root/main/pers").velandar
		
	)
	pass
