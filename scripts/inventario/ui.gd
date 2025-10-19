extends Control

# Referências UI:
@onready var inventarioUI: VBoxContainer = $"invcontainer/Inventário [TAB]"
@onready var equipUI: HBoxContainer = $"invcontainer/Equipamento [J]"
@onready var statusUI: VBoxContainer = $"invcontainer/Status [K]"
@onready var craftUI: VBoxContainer = $"invcontainer/Fabricação [L]"
@onready var slotsUI: VBoxContainer = $hud_slots

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
signal resultado_reciclar(itens_obtidos: Array[itens], item_consumido: itens)

# Variáveis auxiliares largar/descartar/recicraft
var acao_atual: String = ""
var item_selecionado: itens = null
var reciclar: Array[itens]
var item_reciclado: itens


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
	for i in inventarioUI.get_children():
		if i is PanelContainer:
			i.skip = false
	print("Inventário atualizado")


func atualizarequipUI():
	for i in equipUI.find_children("", "Label", true, false):
		if pers.slots.has(i.name):
			print(i.name)


func atualizarcraftUI():
	for i in craftUI.find_children("", "TabContainer", false, false):
		i.skip = false


func atualizarslotsUI():
	for i in slotsUI.find_children("", "Button"):
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


func _abrir_recicraft(texto_recicraft: String, resultado: Array[itens], item: itens):
	$recicraft/submenu.position = Vector2(global_position.x, global_position.y + 25)
	$recicraft/submenu/vbc/titulo.text = "Materiais obtidos:"
	$recicraft/submenu/vbc/texto.text = texto_recicraft
	$recicraft/submenu/vbc/botao.text = "Clique aqui para reciclar"
	$recicraft/submenu.show()
	$recicraft/submenu/vbc/botao.show()
	$recicraft/submenu.position = get_global_mouse_position() - Vector2(65, 0)
	reciclar = resultado
	item_reciclado = item
	
	atualizarinventarioUI()


func _on_botao_contador_pressed() -> void:
	print("botão pressionado")
	var qtd = int(spinbox.value)
	submenu.hide()
	emit_signal("resultado_contador", qtd, acao_atual, item_selecionado)


func _on_botao_recicraft_pressed() -> void:
	# pegar quantidade de itens stackaveis e não stackaveis:
	var stack: int = 0
	var nao_stack: int = 0
	
	#separar itens stackaveis de nao stackaveis
	var itens_stack: Array[itens]
	var itens_nao_stack: Array[itens]
	
	# total de itens e slots livres do inventario
	var quantidade: int = stack + nao_stack
	var slots_livres = pers.inventario_max - len(pers.inventario)
	
	for x in reciclar:
		if x.stackavel:
			stack += 1
			itens_stack.append(x.duplicate(true))
		if !x.stackavel:
			nao_stack += x.quantidade
			itens_nao_stack.append(x)

	prints("stack", stack)
	prints("nao_stack", nao_stack)
	
	if quantidade <= slots_livres:
		print("tem espaço")
		
		# tratar itens não stackaveis
		var itens_nao_stack_tratados: Array[itens]
		for y in itens_nao_stack:
			for z in range(y.quantidade):
				print(z)
				var novo_item = y.duplicate(true)
				novo_item.quantidade = 1
				itens_nao_stack_tratados.append(novo_item)
		
		var itens_recebidos: Array[itens] = []
		itens_recebidos.append_array(itens_stack + itens_nao_stack_tratados)
		$recicraft/submenu.hide()
		emit_signal("resultado_reciclar", itens_recebidos, item_reciclado)
		
	
	
