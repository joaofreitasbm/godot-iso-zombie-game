extends Control

@onready var pers: CharacterBody3D = $".."
var itemclickado



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for i in pers.inventario:
		if i != null:
			pass


	


func _on_popup_menu_id_pressed(id: int) -> void:
	var aux = $PopupMenu.get_item_text(id)
	if aux == "Equipar":
		for x in pers.inventario:
			if x != null and str(x.nome_item) == itemclickado:

				# ✅ Se o item já está equipado no slot atual, desequipa
				if pers.itenshotkey[pers.hotkey] == x:
					pers.itenshotkey[pers.hotkey] = null
					if pers.arma_atual == x:
						pers.arma_atual = pers.mlivre
						pers.equipado = false
					print("Item ", x.nome_item, " foi desequipado do slot ", pers.hotkey)
					return  # sai da função, não equipa de novo
				
				# 🔁 Remove o item de outros slots (se estiver em outro lugar)
				for y in range(len(pers.itenshotkey)):
					if pers.itenshotkey[y] == x:
						pers.itenshotkey[y] = null
						print("Item removido do slot ", y)

				# ✅ Equipa no slot atual
				pers.itenshotkey[pers.hotkey] = x
				pers.arma_atual = x
				pers.equipado = true
				print("Item ", x.nome_item, " equipado no slot ", pers.hotkey)
				break


		
		#print("nome item depois: ", pers.itenshotkey[pers.hotkey].nome_item)



func _inventario_click(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	itemclickado = $ItemList.get_item_text(index)
	print(itemclickado)
	for i in pers.inventario:
		if i != null and i.nome_item == itemclickado:
			$PopupMenu.clear()
			$PopupMenu.add_item("Equipar")
			$PopupMenu.popup()
