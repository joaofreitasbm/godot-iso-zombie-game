extends Node3D

@onready var listaspawn = [
	$spawn1.position,
	$spawn2.position, 
	$spawn3.position, 
	$spawn4.position
]

@onready var timer: Timer = $Timer   # adicione um nó Timer como filho deste Node3D e ligue aqui
@onready var inimrestantes = 0


var inimpreload = preload("res://tscn/inim.tscn")
var onda = 0

func _ready() -> void:
	pass

func _process(_delta: float) -> void:

	$Label.text = str("Wave ", onda, "\n",
					"Enemies left ", inimrestantes, "\n")
					
	# se todos inimigos morreram e timer não está rodando, prepara nova onda
	if inimrestantes <= 0:
		pass
		#iniciar_nova_onda() <- desmarcar isso pros inimigos voltarem a spawnar


func iniciar_nova_onda() -> void:
	onda += 1
	var quantidade = onda * randi_range(1, 3) # 1x, 2x ou 3x o número da onda
	for i in quantidade:
		var spawnaleatorio = listaspawn.pick_random()
		var inimigo = inimpreload.instantiate()
		inimigo.position = spawnaleatorio
		get_tree().get_root().get_node("main").add_child(inimigo)
		if inimigo.has_signal("morreu"):
			inimigo.morreu.connect(_on_inimigo_morreu)
	inimrestantes = quantidade
	print("Onda %d iniciada com %d inimigos" % [onda, quantidade])

func _on_inimigo_morreu() -> void:
	inimrestantes -= 1
