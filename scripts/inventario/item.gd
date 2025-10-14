extends Area3D

@export var item: itens # item que está sendo adquirido
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
	
	if item.tipo == "Receita":
		pers.lista_de_receitas.append(item)
		UI.atualizarcraftUI()
		queue_free()
		return
	
	# Conta quantos slots estão vazios
	var slots_vazios := 0
	for i in pers.inventario:
		if i == null:
			slots_vazios += 1

	# Calcula se há espaço suficiente no inventário
	var ocupados = pers.inventario.size() - slots_vazios # 20slot - 8slot vazios = 12slot ocupados
	if ocupados >= UI.invmax:
		$erro.position = $erro.get_global_mouse_position() - Vector2(65, 0)
		$erro.popup()
		print("Inventário cheio! Não há espaço suficiente para reciclar.")
		return

	# Adiciona o item no inventário lógico (o código só chega aqui se o if anterior for verdade pra ambas variaveis)

	if item.stackavel: # SE O ITEM FOR STACKAVEL
		print("stackavel!")
		#item.quantidade = 5#randi_range(10, 30) # quantidade aleatoria pra itens stackaveis
		print(item.quantidade, " quantidade adquirida")
		for y in range(len(pers.inventario)):
			if pers.inventario[y] != null and pers.inventario[y].nome_item == item.nome_item:
				print("itens iguais! ", pers.inventario[y], " ", item)
				pers.inventario[y].quantidade += item.quantidade
				break
			if pers.inventario[y] == null:
				pers.inventario[y] = item.duplicate(true)
				break
	if !item.stackavel: # SE O ITEM NÃO FOR STACKAVEL
		var qntitensnaostack: int = 0
		for y in range(len(pers.inventario)):
			print(qntitensnaostack, " itens nao stack ")
			if pers.inventario[y] == null:
				pers.inventario[y] = item.duplicate(true)
				pers.inventario[y].quantidade = 1
				qntitensnaostack += 1
				print("item adicionado! ", pers.inventario[y].nome_item, pers.inventario[y].quantidade)
				if item.quantidade == qntitensnaostack:
					print("parou loop")
					break


	# Remove o item do mundo
	UI.atualizarslotsUI()
	UI.atualizarinventarioUI()
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = false
