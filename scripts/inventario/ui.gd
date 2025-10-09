extends Control

@onready var pers = get_tree().get_root().get_node("main/pers/")
@onready var invmax = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func atualizarinventarioUI():
	for i in %"Inventário [TAB]".get_children():
		if i is PanelContainer:
			var slot = int(i.name) - 1
			var item = pers.inventario[slot]
			
			if item != null:
				i.item = item
				
			else:
				i.item = null
				
func atualizarhotkeyUI():
	for i in %hotkeycontainer.get_children():
		if i is Button:
			var slot = int(i.name) - 1
			var item = pers.inventario[slot]
			
			if item != null:
				i.item = item
				
			else:
				i.item = null
