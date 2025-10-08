extends Area3D

@export var item: Resource # item que está sendo adquirido
var area = false # controlado pelos sinais no final do código (entrou/saiu da área)

@onready var pers = get_tree().get_root().get_node("main/pers")

func _process(_delta: float) -> void:
	if item != null:
		$MeshInstance3D.mesh = item.mesh
		
	if pers.interagir != null and pers.interagir == true and area == true:
		pers.inventario.push_front(item) # adiciona o item na primeira posição do inventario
		for i in $"../pers/inventarioUI/invcontainer/Inventário".get_children():
			if i is PanelContainer and i.itemtabela == null:
				i.itemtabela = item
				print(i.itemtabela)
				break 
		queue_free()
	else:
		return 

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = false
