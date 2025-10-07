extends PanelContainer

@export var itemtabela: Resource
@onready var pers = $"../../.."
var skip: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	if itemtabela == null:
		$Button/nome.text = ""
		$Button/qnt.text = ""
		$Button/tipo.text = ""


func _on_button_pressed() -> void: # apertou botão do MENU
	print("botão apertado! item atual: ", itemtabela, self.name)
	for i in pers.inventario:
		print(i)
		if i != null and i == itemtabela:
			print("i: ", i, "item clickado: ", str(itemtabela))
			$submenu.clear()
			$submenu.add_item("Equipar")
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
						for i in $"../../hotkeycontainer".get_children(): # Itera sobre cada item do HOTKEY
							if i.item_slot == x: # Se a variavel da hotkey for igual x (item do inventario)
								i.item_slot = null # Limpa slot do hotkey
								print("Item removido do slot ", y + 1)

				# ✅ Equipa no slot atual
				pers.itenshotkey[pers.hotkey] = x
				pers.arma_atual = x
				pers.equipado = true
				for z in $"../../hotkeycontainer".get_children(): # Itera sobre cada item do HOTKEY
					print(z, " ", z.name, " ", z.item_slot)
					print(z.name, pers.hotkey)
					if int(z.name) == int(pers.hotkey) + 1:
						z.item_slot = x
						print("Item ", x.nome_item, " equipado no slot ", pers.hotkey + 1)
						break
