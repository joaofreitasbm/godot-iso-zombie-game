extends PanelContainer

@onready var pers: CharacterBody3D = $"../../../.."
var reciclar: Array[itens]
var skip: bool = false
@onready var UI: Control = $"../../.."
var indice: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	indice = int(self.name) - 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if skip: return
	if pers.inventario.is_empty() or indice >= pers.inventario.size():
		$Button/nome.text = "Vazio"
		$Button/tipo.text = "-"
		$Button/nome.add_theme_color_override("font_color", Color(0.248, 0.248, 0.248, 1.0))
		$Button/tipo.add_theme_color_override("font_color", Color(0.248, 0.248, 0.248, 1.0))
		
	else: 
		$Button/nome.text = str(pers.inventario[indice].nome_item)
		$Button/tipo.text = str(pers.inventario[indice].tipo)
		if pers.inventario[indice].stackavel and pers.inventario[indice].quantidade > 1:
			$Button/nome.text = "%s x%d" % [pers.inventario[indice].nome_item, pers.inventario[indice].quantidade]
		$Button/nome.add_theme_color_override("font_color", Color(1, 1, 1))
		$Button/tipo.add_theme_color_override("font_color", Color(1, 1, 1))
	
	skip = true


func _on_button_pressed() -> void: # apertou em algum item do MENU
	if indice < pers.inventario.size():
		$submenu.clear()
		if pers.inventario[indice].tipo == "Arma de fogo" or pers.inventario[indice].tipo == "Corpo a corpo":
			$submenu.add_item(str("Equipar como primaria"))
			$submenu.add_item(str("Equipar como secundaria"))
		$submenu.add_item("Largar")
		$submenu.add_item("Descartar")
		if pers.inventario[indice].reciclavel:
			$submenu.add_item("Reciclar")
		if pers.inventario[indice].tipo == "Consumivel":
			$submenu.add_item("Equipar no atalho")
		$submenu.position = get_global_mouse_position() - Vector2(65, 0)
		$submenu.popup()
			


func _on_submenu_id_pressed(id: int) -> void:
	var aux = $submenu.get_item_text(id)

	if aux == "Equipar como primaria": # FUNCIONANDO
		if pers.slots["primaria"] != null and pers.slots["primaria"] == pers.inventario[indice]:
			pers.slots["primaria"] = null
		else:
			pers.slots["primaria"] = pers.inventario[indice]
			pers.arma_atual = pers.slots["primaria"]
			pers.equipado = true
		UI.atualizarslotsUI()


	if aux == "Equipar como secundaria": # FUNCIONANDO
		if pers.slots["secundaria"] != null and pers.slots["secundaria"] == pers.inventario[indice]:
			pers.slots["secundaria"] = null
		else:
			pers.slots["secundaria"] = pers.inventario[indice]
			pers.arma_atual = pers.slots["secundaria"]
			pers.equipado = true
		UI.atualizarslotsUI()


	if aux == "Largar": # REFATORADO
		print("largar inventario")
		print(pers.inventario[indice].nome_item)
		pers.largar_item(pers.inventario[indice])


	if aux == "Reciclar": # REFATORAR PRA PADRONIZAR O CÓDIGO
		print("reciclagem começou")
		
		# Limpar e adicionar textos relacionados da UI
		reciclar.clear() 
		$reciclar.position = Vector2(global_position.x, global_position.y + 25)
		var texto = ""
		for x in pers.inventario[indice].material_reciclado:
			texto += (str("\n", x.nome_item, ", x",x.quantidade))
			reciclar.append(x)
		$reciclar/vbc/titulo.text = "Materiais obtidos:"
		$reciclar/vbc/textoreciclar.text = texto
		$reciclar/vbc/botaoreciclar.text = "Clique aqui para reciclar"
		$reciclar.show()
		$reciclar/vbc/botaoreciclar.show()
		$reciclar.position = get_global_mouse_position() - Vector2(65, 0)
		UI.atualizarinventarioUI()


	if aux == "Descartar": # REFATORADO
		print("descartar inventario")
		print(pers.inventario[indice].nome_item)
		pers.descartar_item(pers.inventario[indice])


	if aux == "Equipar no atalho": # REFATORADO
		# FALTA IMPLEMENTAR
		# SE NÃO TIVER ATALHOS DISPONIVEIS, NÃO EXIBE
		# SE TIVER SÓ UM ATALHO DISPONIVEL, ADICIONA O ITEM A ELE
		# SE TIVER MAIS ATALHOS DISPONIVEIS, CONTA QUANTOS TEM
		# PRA CADA ATALHO DISPONIVEL, DÁ UMA OPÇÃO
		# EXEMPLO ("Equipar no slot 1", "Equipar no slot 2", etc)
		
		# TAMBÉM FAZER COM QUE, SE O ATALHO ESTIVER OCUPADO,
		# AO CLICAR COM O BOTÃO DIREITO, DESEQUIPA
		# VER SE, AO FICAR COM QNT ZERO, O INVENTARIO JÁ LIMPA O ITEM
		# SE NÃO O FIZER, IMPLEMENTAR TAMBÉM
		pass


func hover_on() -> void: # Exibe informações dos itens ao passar o mouse por cima do inventario
	if indice < pers.inventario.size():
		$hover.clear()
		$hover.add_item(str("Dano: ", pers.inventario[indice].dano))
		$hover.add_item(str("DPS: ", pers.inventario[indice].velocidade_ataque))
		$hover.add_item(str("Stackavel: ", pers.inventario[indice].stackavel))
		$hover.add_item(str("Quantidade: ", pers.inventario[indice].quantidade))
		$hover.add_item(str("Modo de disparo: ", "Auto" if pers.inventario[indice].semiauto == false else "Semiauto"))
		$hover.add_item(str("Durabilidade: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.add_item(str("Munição usada: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.add_item(str("Peso: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.add_item(str("Reciclagem: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.position = Vector2(global_position.x - 315, global_position.y)
		$hover.popup()


func hover_off() -> void: # Esconde informações dos itens ao tirar o mouse de cima do inventario
	$hover.hide()

# lógica da reciclagem
func _on_botaoreciclar_pressed() -> void: 
	for x in reciclar:
		pers.adicionar_item(x.duplicate(true))

	if indice < pers.inventario.size():
		pers.inventario.remove_at(indice)

	reciclar.clear()
	$reciclar.hide()
	UI.atualizarinventarioUI()
