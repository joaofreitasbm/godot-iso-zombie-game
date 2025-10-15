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

	if aux == "Equipar como primaria":
		if pers.slots["primaria"] != null and pers.slots["primaria"] == pers.inventario[indice]:
			pers.slots["primaria"] = null
		else:
			pers.slots["primaria"] = pers.inventario[indice]
			pers.arma_atual = pers.slots["primaria"]
			pers.equipado = true
		UI.atualizarslotsUI()


	if aux == "Equipar como secundaria":
		if pers.slots["secundaria"] != null and pers.slots["secundaria"] == pers.inventario[indice]:
			pers.slots["secundaria"] = null
		else:
			pers.slots["secundaria"] = pers.inventario[indice]
			pers.arma_atual = pers.slots["secundaria"]
			pers.equipado = true
		UI.atualizarslotsUI()


	if aux == "Largar":
		print("largar inventario")
		print(pers.inventario[indice].nome_item)
		pers.largar_item(pers.inventario[indice])


	if aux == "Reciclar": ## EM ANDAMENTO
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



	if aux == "Descartar":
		
		if !pers.inventario[indice].stackavel:
			for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
				if pers.inventario[x] != null and pers.inventario[x] == pers.inventario[indice]:
					pers.inventario[x] = null
					break

			for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
				if pers.itenshotkey[y] != null and pers.itenshotkey[y] == pers.inventario[indice]:
					pers.itenshotkey[y] = null
					break

			for z in %hotkeycontainer.get_children(): # Itera sobre cada item da UI HOTKEY
				if z.item == pers.inventario[indice]:
					z.item = null
					break

			if pers.arma_atual == pers.inventario[indice]:
				pers.arma_atual = pers.mlivre
			pers.inventario.erase(indice)
			UI.atualizarslotsUI()
			UI.atualizarinventarioUI()
			return

		if pers.inventario[indice].stackavel:
			# Se selecionar função descartar de dentro do menu, abre submenus pra selecionar quantidade
			$descartar.position = get_global_mouse_position() - Vector2(65, 0)
			$descartar/vbc/textodescartar.text = pers.inventario[indice].nome_item
			$descartar/vbc/botaodescartar.hide()
			$descartar/vbc/botaodescartar.show()
			$descartar/vbc/SpinBox.show()
			$descartar/vbc/SpinBox.min_value = 1
			$descartar/vbc/SpinBox.max_value = pers.inventario[indice].quantidade
			$descartar.show()
			# AQUI ABRE O COMANDO DE APERTAR NO BOTÃO DE DESCARTAR. CÓDIGO MAIS ABAIXO

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



func _on_botaodescartar_pressed() -> void:
	print("rodou")
	var qntdescartar = int($descartar/vbc/SpinBox.value)
	
	for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
		if pers.inventario[x] != null and pers.inventario[x] == pers.inventario[indice]:
			pers.inventario[x].quantidade -= qntdescartar
			if pers.inventario[x].quantidade == 0:
				pers.inventario[x] = null
			$descartar.hide()
			break

	# AVALIAR NECESSIDADE DO FOR Y E FOR Z
	for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
		if pers.itenshotkey[y] != null and pers.itenshotkey[y] == pers.inventario[indice]:
			pers.itenshotkey[y] = null
			break

	for z in %hotkeycontainer.get_children(): # Itera sobre cada item da UI HOTKEY
		if z.pers.inventario[indice] == pers.inventario[indice]:
			z.item = null
			break
			
	if pers.arma_atual == pers.inventario[indice]:
		pers.arma_atual = pers.mlivre
	pers.inventario.erase(indice)
	UI.atualizarslotsUI()
	UI.atualizarinventarioUI()


#func _on_botaolargar_pressed() -> void:
	#var qntlargar = int($largar/vbc/SpinBox.value)
	#var itemdrop: itens
	#
	#for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
		#if pers.inventario[x] != null and pers.inventario[x] == pers.inventario[indice]:
			#pers.inventario[x].quantidade -= qntlargar
			#if pers.inventario[x].quantidade == 0:
				#pers.inventario[x] = null
			#$largar.hide()
			#break
#
	#for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
		#if pers.itenshotkey[y] != null and pers.itenshotkey[y].quantidade == 0:
			#pers.itenshotkey[y] = null
			#break
	#
	#var drop = pers.itemdrop.instantiate()
	#drop.item = pers.inventario[indice].duplicate(true)
	#drop.position = pers.position
	#drop.item.quantidade = qntlargar
	#get_tree().get_root().get_node("main").add_child(drop) # spawnar item dropado nesse nodo
	#print("dropou arma pelo menu: arma > ", pers.arma_atual.nome_item)
	#
	#if pers.arma_atual == pers.inventario[indice]:
		#pers.arma_atual = pers.mlivre
	#pers.inventario.erase(indice)
	#UI.atualizarslotsUI()
	#UI.atualizarinventarioUI()
	
	
	
	pass # Replace with function body.
