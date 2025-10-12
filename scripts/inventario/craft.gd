extends PanelContainer

# LÓGICA DA UI DO CRAFT
@export var item: itens
@onready var pers: CharacterBody3D = $"../../../.."
var skip: bool = false
@onready var UI: Control = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if !skip:
		
		if item != null:
			$Button/nome.text = str(item.nome_item)
			#$Button/qnt.text = str(item.quantidade)
			$Button/nome.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
			#$Button/qnt.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
			print("mudou nome e cor do botão")


		if item == null:
			$Button/nome.text = "Vazio"
			#$Button/qnt.text = "-"
			$Button/nome.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
			#$Button/qnt.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
			print("zerou nome e cor do botão")
		skip = true


func botao_craft() -> void:
	if item == null:
		return

	var pode_craftar := true

	# 1️⃣ Verificar se há materiais suficientes
	for x in item.material_necessario:
		var encontrou := false
		for y in pers.inventario:
			if y == null:
				continue
			if x.nome_item == y.nome_item and y.quantidade >= x.quantidade:
				encontrou = true
				break
		if not encontrou:
			pode_craftar = false
			break

	if not pode_craftar:
		print("⚠️ Faltam materiais para craftar ", item.nome_item)
		$submenu.popup()
		return

	# 2️⃣ Verificar se há espaço no inventário
	var tem_espaco := false
	for slot in %"Inventário [TAB]".get_children():
		if slot is PanelContainer and slot.item == null:
			tem_espaco = true
			break

	if not tem_espaco:
		print("⚠️ Inventário cheio! Não é possível craftar ", item.nome_item)
		$submenu.popup()
		return

	# 3️⃣ Consumir os materiais
	for x in item.material_necessario:
		for i in range(len(pers.inventario)):
			var y = pers.inventario[i]
			if y == null:
				continue
			if x.nome_item == y.nome_item:
				y.quantidade -= x.quantidade
				if y.quantidade <= 0:
					pers.inventario[i] = null
				break

	# 4️⃣ Adicionar o item craftado ao primeiro slot vazio
	for slot in %"Inventário [TAB]".get_children():
		if slot is PanelContainer and slot.item == null:
			slot.item = item.item_craftado
			slot.skip = false
			pers.inventario[int(slot.name) - 1] = item.item_craftado
			print("✅ Item craftado:", item.item_craftado.nome_item)
			break

	# 5️⃣ Atualizar UI
	UI.atualizarinventarioUI()



							
						

	#print("botão apertado! item atual: ", item, self.name)
	#if item == null:
		#return
#
	#var falta_material = false
#
	#for x in item.material_necessario:
		#var material_ok = false
#
		#for i in range(len(pers.inventario)):
			#var y = pers.inventario[i]
#
			#if y != null and y.nome_item == x.nome_item:
				#if y.quantidade >= x.quantidade:
					#y.quantidade -= x.quantidade
					#if y.quantidade == 0:
						#pers.inventario[i] = null
					#material_ok = true
					#break
#
		#if not material_ok:
			#falta_material = true
			#print("material insuficiente:", x.nome_item)
#
	#if falta_material:
		#$submenu.popup()
		#return
#
	## Adiciona o item craftado
	#for slot in UI.get_children():
		#if slot is PanelContainer and slot.item == null:
			#slot.item = item.item_craftado
			#slot.skip = false
			#pers.inventario[int(slot.name) - 1] = item.item_craftado
			#break
#
	#UI.atualizarinventarioUI()
