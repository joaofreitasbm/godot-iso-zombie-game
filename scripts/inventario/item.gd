extends Area3D

@export var item: Resource # item que está sendo adquirido
var area: bool = false # controlado pelos sinais no final do código (entrou/saiu da área)

@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers")
@onready var inventarioUI: VBoxContainer = get_tree().get_root().get_node("main/pers/UI/invcontainer/Inventário [TAB]")
@onready var UI: Control = get_tree().get_root().get_node("main/pers/UI")

func _ready() -> void:
	if item != null:
		$MeshInstance3D.mesh = item.mesh
		
func _process(_delta: float) -> void:
	#print("invmax: ", UI.invmax, "OCUPADOS: ", pers.inventario.size() - pers.inventario.count(null))
	if !(pers.interagir and area): # se ambas variaveis forem negativas, não roda daqui pra baixo
		return
	
	if UI.invmax <= (pers.inventario.size() - pers.inventario.count(null)): # não deixa função rodar se não tiver espaço no inventario
		print("LOTOU")
		return

	# Adiciona o item no inventário lógico (o código só chega aqui se o if anterior for verdade pra ambas variaveis)
	#pers.inventario.push_front(item)

	# Busca o primeiro slot vazio
	for slot in inventarioUI.get_children():
		if slot is PanelContainer and slot.item == null:
			slot.item = item
			slot.skip = false
			pers.inventario[int(slot.name) - 1] = item
			break

	# Remove o item do mundo
	queue_free()



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = false
