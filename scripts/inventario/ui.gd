extends Control

@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers/")
@onready var invmax: int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$"invcontainer/Status [K]/VBoxContainer/saude/barra".value = pers.vida
	$"invcontainer/Status [K]/VBoxContainer/folego/barra".value = pers.stamina
	$"invcontainer/Status [K]/VBoxContainer/fadiga/barra".value = pers.fadiga
	$"invcontainer/Status [K]/VBoxContainer/fome/barra".value = pers.fome
	$"invcontainer/Status [K]/VBoxContainer/sede/barra".value = pers.sede
	$"invcontainer/Status [K]/VBoxContainer/sanidade/barra".value = pers.sanidade

func atualizarinventarioUI():
	for i in %"Inventário [TAB]".get_children():
		if i is PanelContainer:
			var slot = int(i.name) - 1
			var item = pers.inventario[slot]
			if item != null:
				i.item = item.duplicate(true)
			else:
				i.item = null
			i.skip = false


func atualizarcraftUI():
	for i in $"invcontainer/Fabricação [L]".get_children():
		if i is PanelContainer:
			var slot = int(i.name) - 1
			var item = pers.lista_de_receitas[slot]
			print(pers.lista_de_receitas[slot])
			if item != null:
				i.item = item.duplicate(true)
			else:
				i.item = null
			i.skip = false

func ordenarinventarioUI():
	pers.inventario.sort()
		
#func atualizarhotkeyUI(): # AVALIAR NECESSIDADE DE EXISTIR ESSA FUNÇÃO
	#for i in %hotkeycontainer.get_children():
		#if i is Button:
			#var slot = int(i.name) - 1
			#var item = pers.inventario[slot]
			#
			#if item != null:
				#i.item = item
				#
			#else:
				#i.item = null
