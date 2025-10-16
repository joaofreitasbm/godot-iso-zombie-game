extends Control

# Referências
@onready var submenu: PopupPanel = $contador/submenu
@onready var texto: Label = $contador/submenu/vbc/texto
@onready var spinbox: SpinBox = $contador/submenu/vbc/SpinBox
@onready var botao: Button = $contador/submenu/vbc/botao


@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers/")

signal resultado_contador(quantidade: int, acao: String, item)

# Variáveis auxiliares
var acao_atual: String = ""
var item_selecionado: itens = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	## ADICIONAR SKIP
	$barras/cont_vida/barra_vida.value = pers.vida
	$barras/cont_folego/barra_vida.value = pers.stamina
	$barras/cont_folego/barra_vida.max_value = (pers.fome + pers.sede) / 2
	
	$"invcontainer/Status [K]/VBoxContainer/saude/barra".value = pers.vida
	$"invcontainer/Status [K]/VBoxContainer/folego/barra".value = pers.stamina
	$"invcontainer/Status [K]/VBoxContainer/fadiga/barra".value = (pers.fome + pers.sede) / 2
	$"invcontainer/Status [K]/VBoxContainer/fome/barra".value = pers.fome
	$"invcontainer/Status [K]/VBoxContainer/sede/barra".value = pers.sede
	$"invcontainer/Status [K]/VBoxContainer/sanidade/barra".value = pers.sanidade

			
func atualizarinventarioUI(): # VERSÃO ATUALIZADA
	for i in %"Inventário [TAB]".get_children():
		if i is PanelContainer:
			i.skip = false
	print("Inventário atualizado")



func atualizarcraftUI():
	for i in $"invcontainer/Fabricação [L]/tiposcraft".get_children():
		if i is ItemList:
			i.get_parent().skip = false


func atualizarslotsUI():
	for i in $hud_slots.find_children("", "Button"):
		#print(i)
		i.skip = false



	
func _abrir_contador(item: itens, acao: String):
	print("contador aberto")
	#variaveis auxiliares que foram declaradas no começo do código sendo usadas
	acao_atual = acao
	item_selecionado = item
	
	submenu.position = get_global_mouse_position() - Vector2(65, 0)
	texto.text = "Quantos '" + item.nome_item + "' deseja " + acao + "?"
	botao.hide()
	botao.show()
	spinbox.show()
	spinbox.min_value = 1
	spinbox.max_value = item.quantidade
	spinbox.value = 1
	botao.text = str("Clique aqui para ", acao)
	submenu.show()
	


func _on_botao_contador_pressed() -> void:
	print("botão pressionado")
	var qtd = int(spinbox.value)
	submenu.hide()
	emit_signal("resultado_contador", qtd, acao_atual, item_selecionado)


func _on_bucete_pressed() -> void:
	print("bucete")
