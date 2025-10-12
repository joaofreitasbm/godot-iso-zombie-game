extends Control

@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers/")
@onready var invmax: int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	## ADICIONAR SKIP
	$"invcontainer/Status [K]/VBoxContainer/saude/barra".value = pers.vida
	$"invcontainer/Status [K]/VBoxContainer/folego/barra".value = pers.stamina
	$"invcontainer/Status [K]/VBoxContainer/fadiga/barra".value = pers.fadiga
	$"invcontainer/Status [K]/VBoxContainer/fome/barra".value = pers.fome
	$"invcontainer/Status [K]/VBoxContainer/sede/barra".value = pers.sede
	$"invcontainer/Status [K]/VBoxContainer/sanidade/barra".value = pers.sanidade

			
func atualizarinventarioUI(): # VERSÃO ATUALIZADA
	for i in %"Inventário [TAB]".get_children():
		if i is PanelContainer:
			i.skip = false


func atualizarcraftUI():
	for i in $"invcontainer/Fabricação [L]/tiposcraft".get_children():
		if i is ItemList:
			i.get_parent().skip = false

func ordenarinventarioUI():
	pers.inventario.sort()
		
