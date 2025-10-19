extends PanelContainer

@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers")
@onready var UI: Control = get_tree().get_root().get_node("main/pers/UI")
var reciclar: Array[itens]
var skip: bool = false
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
		$Button/subtipo.text = "-"
		$Button/nome.add_theme_color_override("font_color", Color(0.248, 0.248, 0.248, 1.0))
		$Button/tipo.add_theme_color_override("font_color", Color(0.248, 0.248, 0.248, 1.0))
		$Button/subtipo.add_theme_color_override("font_color", Color(0.248, 0.248, 0.248, 1.0))
		
	else: 
		$Button/nome.text = str(pers.inventario[indice].nome_item)
		$Button/tipo.text = str(pers.inventario[indice].tipo)
		$Button/subtipo.text = str(pers.inventario[indice].subtipo)
		if pers.inventario[indice].stackavel and pers.inventario[indice].quantidade > 1:
			$Button/nome.text = "%s x%d" % [pers.inventario[indice].nome_item, pers.inventario[indice].quantidade]
		$Button/nome.add_theme_color_override("font_color", Color(1, 1, 1))
		$Button/tipo.add_theme_color_override("font_color", Color(1, 1, 1))
		$Button/subtipo.add_theme_color_override("font_color", Color(1, 1, 1))
	skip = true


func _on_button_pressed() -> void: # apertou em algum item do MENU
	if indice < pers.inventario.size():
		$submenu.clear()
		if pers.inventario[indice].tipo == "Armas":
			$submenu.add_item(str("Equipar como primária"))
			$submenu.add_item(str("Equipar como secundária"))
		if pers.inventario[indice].tipo == "Equipamentos":
			$submenu.add_item(str("Equipar no slot ", (pers.inventario[indice].subtipo.to_lower())))
		$submenu.add_item("Largar")
		$submenu.add_item("Descartar")
		if pers.inventario[indice].reciclavel:
			$submenu.add_item("Reciclar")
		if pers.inventario[indice].tipo == "Consumivel":
			$submenu.add_item("Equipar no atalho")
		$submenu.popup()
		$submenu.position = get_global_mouse_position() - Vector2(($submenu.size.x / 2), 0)
			


func _on_submenu_id_pressed(id: int) -> void:
	var aux = $submenu.get_item_text(id)

	if aux == "Equipar como primária": # FUNCIONANDO

		# Se já está equipada como primária, desequipa
		if pers.slots["primaria"] == pers.inventario[indice]:
			pers.slots["primaria"] = null

		else:
			# Se já está equipada como secundária, remove de lá
			if pers.slots["secundaria"] == pers.inventario[indice]:
				pers.slots["secundaria"] = null

			# Agora equipa como primária normalmente
			pers.slots["primaria"] = pers.inventario[indice]
			pers.arma_atual = pers.inventario[indice]
			pers.equipado = true
		UI.atualizarequipUI()
		UI.atualizarhudUI()


	if aux == "Equipar como secundária": # FUNCIONANDO
		# Se já está equipada como primária, desequipa
		if pers.slots["secundaria"] == pers.inventario[indice]:
			pers.slots["secundaria"] = null

		else:
			# Se já está equipada como secundária, remove de lá
			if pers.slots["primaria"] == pers.inventario[indice]:
				pers.slots["primaria"] = null

			# Agora equipa como primária normalmente
			pers.slots["secundaria"] = pers.inventario[indice]
		UI.atualizarequipUI()
		UI.atualizarhudUI()


	# equipamentos como superior, inferior, botas, etc
	if aux == str("Equipar no slot ", (pers.inventario[indice].subtipo.to_lower())):
		pers.slots[pers.inventario[indice].subtipo.to_lower()] = pers.inventario[indice]
		UI.atualizarequipUI()
		prints("subtipo:", pers.inventario[indice].subtipo)
		prints("slots:", pers.slots)


	if aux == "Largar": # REFATORADO
		pers.largar_item(pers.inventario[indice])


	if aux == "Reciclar": # REFATORADO
		pers.reciclar_item(pers.inventario[indice])
		


	if aux == "Descartar": # REFATORADO
		print("descartar inventario")
		print(pers.inventario[indice].nome_item)
		pers.descartar_item(pers.inventario[indice])


	if aux == "Equipar no atalho": # 
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
		if pers.inventario[indice].tipo == "Arma de fogo":
			$hover.add_item(str("Modo de disparo: ", "Auto" if pers.inventario[indice].semiauto == false else "Semiauto"))
		$hover.add_item(str("Durabilidade: ", pers.inventario[indice].durabilidade))
		$hover.add_item(str("Munição usada: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.add_item(str("Peso: ", pers.inventario[indice].peso))
		$hover.add_item(str("Reciclavel: ", "Sim" if pers.inventario[indice].reciclavel == false else "Não"))
		$hover.show()
		$hover.global_position = global_position + Vector2(-310, 0)


func hover_off() -> void: # Esconde informações dos itens ao tirar o mouse de cima do inventario
	$hover.hide()
