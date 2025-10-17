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
	if !(pers.interagir and area):
		return

	if pers.adicionar_item(item.duplicate(true)):
		UI.atualizarslotsUI()
		UI.atualizarinventarioUI()
		queue_free()
	else:
		$PopupPanel.position = $PopupPanel.get_global_mouse_position() - Vector2(65, 0)
		$PopupPanel/erro.popup()




func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = false
