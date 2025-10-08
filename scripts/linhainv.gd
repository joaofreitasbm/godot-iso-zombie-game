extends PanelContainer

@export var itemtabela: Resource
@onready var pers = $"../../../.."
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


func _on_button_pressed() -> void: # apertou botão do MENU
	print("botão apertado! item atual: ", itemtabela, self.name)
	for x in pers.inventario:
		print(x)
		if x != null and x == itemtabela:
			print("i: ", x, "item clickado: ", str(itemtabela))
			$submenu.clear()
			if itemtabela.tipo == "Arma de fogo" or itemtabela.tipo == "Corpo a corpo":
				$submenu.add_item("Equipar")
			$submenu.add_item("Dropar")
			$submenu.add_item("Descartar")
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

		
				
		
	if aux == "Reciclar":
		print("AGUARDANDO DIGITAR FUNÇÃO EM linhainv.gd")
		
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


func hover_on() -> void:
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


func hover_off() -> void:
	$hover.hide()
