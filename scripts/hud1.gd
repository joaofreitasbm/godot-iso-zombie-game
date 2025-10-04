extends Control

@onready var pers = $"../pers"
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
		"Movement speed: ", get_node("/root/main/pers").velandar, "\n", "\n",
		"vsync on / FPS: ", Engine.get_frames_per_second()
		
	)
	
	if pers.arma_atual != null:
		$arma.text = str(
			get_node("/root/main/pers").inventario, "\n",
			get_node("/root/main/pers").arma_atual.nome_item, "\n",
			#get_node("/root/main/pers").inventario, "\n",
			)
