extends TabContainer

# LÓGICA DA UI DO CRAFT
@onready var pers: CharacterBody3D = $"../../../.."
@onready var receitas: Array[itens]
var skip: bool = false
@onready var UI: Control = $"../../.."
var craftar: Array[itens]


var indice: int
var aba: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if !skip:
		for x in pers.lista_de_receitas: # Itera sobre cada item da receita
			for y in self.get_children(): # Itera sobre cada item do menu do craft
				if y is ItemList and y.name == x.tipo_receita:
					if x.nome_item == y.name:
						return
					y.add_item(x.nome_item)
					break
		skip = true


func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	
	# COMPARAR INDEX COM INVENTARIO (LISTA DE FABRICAÇÃO)
	for x in range(len(pers.lista_de_receitas)):
		if pers.lista_de_receitas[x].tipo_receita == get_child(index + 1).name:
			craftar.clear()
			$craftar/vbc/textocraftar.text = ""
			$craftar/vbc/botaocraftar.text = ""
			$craftar.position = Vector2(global_position.x, global_position.y + 25)
			var texto = ""
			for y in pers.lista_de_receitas[x].material_necessario:
				texto += (str("\n", y.nome_item, ", x",y.quantidade))
				craftar.push_front(y)
			$craftar/vbc/textocraftar.text = texto
			$craftar/vbc/botaocraftar.text = "Clique aqui para craftar"
			$craftar.show()
			$craftar/vbc/botaocraftar.show()
			$craftar.position = get_global_mouse_position() - Vector2(65, 0)
			UI.atualizarinventarioUI()
			for i in craftar:
				print(i.nome_item," ", i.quantidade)




func _on_botaocraftar_pressed() -> void:
	print("🛠️ Botão craftar apertado!")

	# 1️⃣ Verificar se há materiais suficientes
	var pode_craftar := true

	for receita in craftar:
		var encontrou := false
		for item in pers.inventario:
			if item == null:
				continue
			if item.nome_item == receita.nome_item and item.quantidade >= receita.quantidade:
				encontrou = true
				break
		if not encontrou:
			pode_craftar = false
			break

	if not pode_craftar:
		print("⚠️ Faltam materiais para craftar!")
		$erro.clear()
		$erro.add_item("Faltam materiais pra craftar!")
		$erro.popup()
		return

	# 2️⃣ Consumir os materiais necessários
	for receita in craftar:
		for i in range(len(pers.inventario)):
			var inv_item = pers.inventario[i]
			if inv_item == null:
				continue
			if inv_item.nome_item == receita.nome_item:
				inv_item.quantidade -= receita.quantidade
				if inv_item.quantidade <= 0:
					pers.inventario[i] = null
				break

	# 3️⃣ Adicionar o item craftado ao primeiro slot vazio
	var item_craftado: Resource = null

	# 🔍 Encontra o item que gerou a lista craftar
	for receita in pers.lista_de_receitas:
		# se o tipo da aba de craft for igual ao tipo da receita
		if receita.tipo_receita == get_child(current_tab).name:
			item_craftado = receita.item_craftado.duplicate(true)
			break

	if item_craftado == null:
		print("❌ Nenhum item resultante encontrado pra essa receita!")
		return

	# 🧩 Coloca o item no primeiro slot vazio
	for i in range(len(pers.inventario)):
		if pers.inventario[i] == null:
			pers.inventario[i] = item_craftado.duplicate(true)
			print("✅ Item craftado:", item_craftado.nome_item, "adicionado no slot", i)
			UI.atualizarinventarioUI()
			$craftar.hide()
			return

	# 4️⃣ Caso o inventário esteja cheio
	print("⚠️ Inventário cheio! Não é possível adicionar o item craftado.")
	$erro.popup()
