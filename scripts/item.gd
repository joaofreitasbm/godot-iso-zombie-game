extends Area3D

@export var item: Resource
var area = false
@onready var pers = $"../pers"

func _process(_delta: float) -> void:
	if pers.interagir == true and area == true:
		if pers.itenshotkey.is_empty():
			print("pegou primeiro item")
			pers.itenshotkey.append(item)
			pers.arma_atual = item
		else:
			pers.itenshotkey.append(item)
			print("item adicionado na posição ", len(pers.itenshotkey))
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = false
