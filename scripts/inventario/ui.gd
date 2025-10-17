extends Control

# Referências contador:
@onready var submenu: PopupPanel = $contador/submenu
@onready var texto: Label = $contador/submenu/vbc/texto
@onready var spinbox: SpinBox = $contador/submenu/vbc/SpinBox
@onready var botao: Button = $contador/submenu/vbc/botao

# referencias status:
@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers/")
@onready var saudeUI: ProgressBar = $barras/cont_saude/barra
@onready var folegoUI: ProgressBar = $barras/cont_folego/barra

@onready var saude_status: ProgressBar = $"invcontainer/Status [K]/VBoxContainer/saude/barra"
@onready var folego_status: ProgressBar = $"invcontainer/Status [K]/VBoxContainer/folego/barra"
@onready var fadiga_status: ProgressBar = $"invcontainer/Status [K]/VBoxContainer/fadiga/barra"
@onready var fome_status: ProgressBar = $"invcontainer/Status [K]/VBoxContainer/fome/barra"
@onready var sede_status: ProgressBar = $"invcontainer/Status [K]/VBoxContainer/sede/barra"
@onready var sanidade_status: ProgressBar = $"invcontainer/Status [K]/VBoxContainer/sanidade/barra"

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
	saudeUI.value = pers.saude
	folegoUI.value = pers.folego
	folegoUI.max_value = (pers.fome + pers.sede) / 2
	
	saude_status.value = pers.saude
	folego_status.value = pers.folego
	fadiga_status.value = (pers.fome + pers.sede) / 2
	fome_status.value = pers.fome
	sede_status.value = pers.sede
	sanidade_status.value = pers.sanidade

			
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
