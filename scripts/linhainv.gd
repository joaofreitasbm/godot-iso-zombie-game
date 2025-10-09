extends PanelContainer

@export var itemtabela: Resource
@onready var pers = $"../../../.."
var recicraft: Array[Resource]
var skip: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if skip == true:
		return
	if itemtabela != null and skip == false:
		if itemtabela.tipo == "Arma de fogo":
			$Button/qnt.text = str(itemtabela.qntatual, "/", itemtabela.qntreserva)
		if itemtabela.tipo == "Arremessavel" or itemtabela.tipo == "Consumivel" or itemtabela.tipo == "Material":
			$Button/qnt.text = str(itemtabela.qntreserva)
		$Button/nome.text = str(itemtabela.nome_item)
		$Button/tipo.text = str(itemtabela.tipo)

		$Button/nome.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
		$Button/qnt.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
		$Button/tipo.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 

	if itemtabela == null:
		$Button/nome.text = "Vazio"
		$Button/qnt.text = "-"
		$Button/tipo.text = "-"

		$Button/nome.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
		$Button/qnt.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
		$Button/tipo.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))

func atualizarUI():
	for i in %"Inventário [TAB]".get_children():
		if i is PanelContainer:
			var slot = int(i.name) - 1
			var item = pers.inventario[slot]
			
			if item != null:
				i.itemtabela = item
				
			else:
				i.itemtabela = null
		

func _on_button_pressed() -> void: # apertou botão do MENU
	print("botão apertado! item atual: ", itemtabela, self.name)
	for x in pers.inventario:
		if x != null and x == itemtabela:
			print("i: ", x, "item clickado: ", str(itemtabela))
			$submenu.clear()
			if itemtabela.tipo == "Arma de fogo" or itemtabela.tipo == "Corpo a corpo":
				$submenu.add_item("Equipar")
			$submenu.add_item("Dropar")
			$submenu.add_item("Descartar")
			$submenu.add_item("Reciclar")
			$submenu.position = Vector2(global_position.x, global_position.y + 25)
			$submenu.popup()


func _on_submenu_id_pressed(id: int) -> void: # apertou botão do SUBMENU
	var aux = $submenu.get_item_text(id)
	if aux == "Equipar":
		for x in pers.inventario: # Itera sobre cada item do INVENTÁRIO
			if x != null and x == itemtabela:

				# Se o item já está equipado no slot atual, desequipa
				if pers.itenshotkey[pers.hotkey] == x: # Se hotkey atual == x, deixa nulo
					pers.itenshotkey[pers.hotkey] = null
					if pers.arma_atual == x: # Se arma atual == x, equipa mãos livres
						pers.arma_atual = pers.mlivre
						pers.equipado = false # Avaliar necessidade de existir essa variavel
					print("Item ", x.nome_item, " foi desequipado do slot ", pers.hotkey + 1)
					return  # sai da função, não equipa de novo

				# Remove o item de outros slots (se estiver em outro lugar)
				for y in range(len(pers.itenshotkey)):
					if pers.itenshotkey[y] == x: # Se a iteração y (item da hotkey) == iteração x (item do inventario)
						pers.itenshotkey[y] = null # Remove iteração y da hotkey pra adicionar ela na posição nova
						for i in %hotkeycontainer.get_children(): # Itera sobre cada item do HOTKEY
							if i.item_slot == x: # Se a variavel da hotkey for igual x (item do inventario)
								i.item_slot = null # Limpa slot do hotkey
								print("Item removido do slot ", y + 1)

				# Equipa no slot atual
				pers.itenshotkey[pers.hotkey] = x
				pers.arma_atual = x
				pers.equipado = true
				for z in %hotkeycontainer.get_children(): # Itera sobre cada item do HOTKEY
					print(z, " ", z.name, " ", z.item_slot)
					print(z.name, pers.hotkey)
					if int(z.name) == int(pers.hotkey) + 1:
						z.item_slot = x
						print("Item ", x.nome_item, " equipado no slot ", pers.hotkey + 1)
						break

	if aux == "Dropar":
		for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
			if pers.inventario[x] != null and pers.inventario[x] == itemtabela:
				print(aux, ", item removido do inventário: ", itemtabela)
				pers.inventario[x] = null
				break
		for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
			if pers.itenshotkey[y] != null and pers.itenshotkey[y] == itemtabela:
				print(aux, ", item removido da hotkey")
				pers.itenshotkey[y] = null
				break
		for z in %hotkeycontainer.get_children(): # Itera sobre cada item da UI HOTKEY
			if z.item_slot == itemtabela:
				z.item_slot = null
				print(aux, ", item removido da UI da hotkey")
				break
		var drop = pers.itemdrop.instantiate()
		drop.item = itemtabela.duplicate(true)
		drop.position = pers.position
		get_tree().get_root().get_node("main").add_child(drop) # spawnar item dropado nesse nodo
		print("dropou arma pelo menu: arma > ", pers.arma_atual.nome_item)
		pers.arma_atual = pers.mlivre # troca pra mãos livres
		itemtabela = null
		pers.equipado = false
		print("função rodou completamente")


	if aux == "Reciclar": ## EM ANDAMENTO
		print("reciclagem começou")
		recicraft.clear() 
		$recicraft/textorecicraft.text = ""
		$recicraft/botaorecicraft.clear()
		$recicraft.position = Vector2(global_position.x, global_position.y + 25)
		var texto: = str("Materiais obtidos", "\n")
		for x in itemtabela.material_reciclado:
			print(x,"    ", x.nome_item,"    ", x.qntreserva)
			texto += (str("\n", x.nome_item, ", x",x.qntreserva))
			recicraft.append(x)
			print(recicraft, "      recicraft")
		$recicraft/botaorecicraft.position = $recicraft/textorecicraft.position + Vector2(global_position.x, global_position.y + 175)
		$recicraft/textorecicraft.text = texto
		$recicraft/botaorecicraft.add_item("Clique aqui para reciclar")
		$recicraft.show()
		$recicraft/botaorecicraft.popup()
		print("código rodou por completo")


	if aux == "Descartar":
		for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
			if pers.inventario[x] != null and pers.inventario[x] == itemtabela:
				pers.inventario[x] = null
				break
		for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
			if pers.itenshotkey[y] != null and pers.itenshotkey[y] == itemtabela:
				pers.itenshotkey[y] = null
				break
		for z in %hotkeycontainer.get_children(): # Itera sobre cada item da UI HOTKEY
			print(z, z.item_slot, "AQUI")
			if z.item_slot == itemtabela:
				z.item_slot = null
				break
		if pers.arma_atual == itemtabela:
			pers.arma_atual = pers.mlivre
		itemtabela = null


func hover_on() -> void: # Exibe informações dos itens ao passar o mouse por cima do inventario
	if itemtabela != null:
		$hover.clear()
		$hover.add_item(str("Dano: ", itemtabela.dano))
		$hover.add_item(str("DPS: ", itemtabela.velocidade_ataque))
		$hover.add_item(str("Modo de disparo: ", "Auto" if itemtabela.semiauto == false else "Semiauto"))
		$hover.add_item(str("Durabilidade: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.add_item(str("Munição usada: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.add_item(str("Peso: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.add_item(str("Reciclagem: ", "(AGUARDANDO IMPLEMENTAÇÃO)"))
		$hover.position = Vector2(global_position.x - 315, global_position.y)
		$hover.popup()


func hover_off() -> void: # Esconde informações dos itens ao tirar o mouse de cima do inventario
	$hover.hide()


func _on_botaorecicraft_id_pressed(_id: int) -> void:
	print("BOTÃO RECICRAFT APERTADO")

	# Conta quantos slots vazios existem
	var slots_vazios := 0
	for item in pers.inventario:
		if item == null:
			slots_vazios += 1

	# Conta quantos itens não stackáveis existem na lista recicraft
	var itens_nao_stackaveis := 0
	for item in recicraft:
		if not item.stackavel:
			itens_nao_stackaveis += 1

	# Verifica se há espaço suficiente no inventário
	if itens_nao_stackaveis > slots_vazios:
		print("Inventário cheio! Não há espaço suficiente para reciclar.")
		return # Cancela a reciclagem

	# Continua normalmente se houver espaço
	for material in recicraft:
		var adicionado := false

		if material.stackavel:
			for i in range(len(pers.inventario)):
				var slot = pers.inventario[i]
				if slot != null and slot.nome_item == material.nome_item:
					slot.qntreserva += material.qntreserva
					adicionado = true
					break

		if not adicionado:
			for i in range(len(pers.inventario)):
				if pers.inventario[i] == null:
					pers.inventario[i] = material.duplicate(true)
					adicionado = true
					break

		if not adicionado:
			print("Inventário cheio! Não foi possível adicionar: ", material.nome_item)

	# Remove o item original que foi reciclado
	for i in range(len(pers.inventario)):
		if pers.inventario[i] == itemtabela:
			pers.inventario[i] = null
			break

	# Limpa e atualiza
	recicraft.clear()
	itemtabela = null
	atualizarUI()


	#print("BOTÃO RECICRAFT APERTADO")
	#for x in range(len(pers.inventario)): # Retorna indice de cada interação no inventario
		#for y in recicraft: # Itera sobre cada chave (recurso) de recicraft
			#if pers.inventario[x] == y: # Slot no inventário já ocupado com o mesmo item do recicraft
				#print(pers.inventario[x].qntreserva, "  x qnt reserva")
				#print(recicraft[y], "  recicraft[y]")
				#print(x, "  x")
				#print(y, "  y")
				#pers.inventario[x].qntreserva += recicraft[y] # atualiza inventario
			#elif pers.inventario[x] == null: # Se recurso do inventario for nulo
				#print("pers.inventario[x] antes da alteração: ", pers.inventario[x])
				#pers.inventario[x] = y # atualiza inventario
				#print("pers.inventario[x] depois da alteração: ", pers.inventario[x])
				#print("itemtabela antes da alteração: ", itemtabela)
				#itemtabela = null
				#print("itemtabela depois da alteração: ", itemtabela)
	#recicraft = {}
