extends Control

@onready var pers: CharacterBody3D = $".."
var itemclickado


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atualizar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
		pass


	


func _on_popup_menu_id_pressed(id: int) -> void:
	var aux = $ItemList/PopupMenu.get_item_text(id)
	if aux == "Equipar":
		for x in pers.inventario:
			if x != null and str(x.nome_item) == itemclickado:

				# ✅ Se o item já está equipado no slot atual, desequipa
				if pers.itenshotkey[pers.hotkey] == x:
					pers.itenshotkey[pers.hotkey] = null
					if pers.arma_atual == x:
						pers.arma_atual = pers.mlivre
						pers.equipado = false
					print("Item ", x.nome_item, " foi desequipado do slot ", pers.hotkey + 1)
					atualizar()
					return  # sai da função, não equipa de novo

				# 🔁 Remove o item de outros slots (se estiver em outro lugar)
				for y in range(len(pers.itenshotkey)):
					if pers.itenshotkey[y] == x:
						pers.itenshotkey[y] = null
						atualizar()
						print("Item removido do slot ", y + 1)

				# ✅ Equipa no slot atual
				pers.itenshotkey[pers.hotkey] = x
				pers.arma_atual = x
				pers.equipado = true
				atualizar()
				print("Item ", x.nome_item, " equipado no slot ", pers.hotkey + 1)
				break


func _inventario_click(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	itemclickado = $ItemList.get_item_text(index)
	print(itemclickado)
	for i in pers.inventario:
		if i != null and i.nome_item == itemclickado:
			$ItemList/PopupMenu.clear()
			$ItemList/PopupMenu.add_item("Equipar")
			$ItemList/PopupMenu.popup()

func atualizar():
	# Atualiza os slots do HBoxContainer
	var slots = $hotkeycontainer.get_children()

	for i in range(len(slots)):
		var slot = slots[i]

		# Pega o item correspondente ao índice do hotkey
		var item = null
		if i < len(pers.itenshotkey):
			item = pers.itenshotkey[i]

		# Atualiza o slot com o item
		slot.item_slot = item

		if item != null:
			slot.icon = item.imagem
			if item.tipo == 1: # arma de fogo
				slot.get_node("quantidade").text = str(item.qntatual, "/", item.qntreserva)
			elif item.tipo == 3: # consumível
				slot.get_node("quantidade").text = str(item.qntreserva)
			else:
				slot.get_node("quantidade").text = ""
		else:
			slot.icon = null
			slot.get_node("quantidade").text = ""

	# Atualiza a ItemList com o inventário completo
	$ItemList.clear()
	for i in pers.inventario:
		if i != null:
			$ItemList.add_item(str(i.nome_item))
