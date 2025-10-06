extends Area3D

@export var item: Resource
var area = false
@onready var pers = $"../pers"
@onready var lista_item: ItemList = $"../pers/inventarioUI/ItemList"

func _process(_delta: float) -> void:
	if pers.interagir == true and area == true:
		pers.inventario.push_front(item)
		print(item, item.nome_item)
		lista_item.add_item(str(item.nome_item))
		print("item adicionado na posição ", pers.hotkey + 1)
		pers.get_node("inventarioUI").atualizar()
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = false
