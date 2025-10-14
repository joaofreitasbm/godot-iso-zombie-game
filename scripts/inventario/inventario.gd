extends PanelContainer

@onready var pers: CharacterBody3D = $"../../../.."
@onready var item: itens 

var reciclar: Array[itens]
var skip: bool = false
@onready var UI: Control = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !skip:
		
		# Atribui slot do inventario à variavel item
		if pers.inventario[int(self.name) - 1] == null:
			item = null
			$Button/nome.text = "Vazio"
			$Button/tipo.text = "-"
			$Button/nome.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
			$Button/tipo.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
			
		if pers.inventario[int(self.name) - 1] != null:
			item = pers.inventario[int(self.name) - 1]
			$Button/nome.text = str(item.nome_item)
			$Button/tipo.text = str(item.tipo)
			if item.stackavel and item.quantidade > 1:
				$Button/nome.text = str(item.nome_item, " x", item.quantidade)
			$Button/nome.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
			$Button/tipo.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
			
		skip = true


func _on_button_pressed() -> void: # apertou em algum item do MENU
	for x in pers.inventario:
		if x != null and x == item:
			$submenu.clear()
			if item.tipo == "Arma de fogo" or item.tipo == "Corpo a corpo":
				
				$submenu.add_item(str("Equipar como primaria"))
				$submenu.add_item(str("Equipar como secundaria"))
			$submenu.add_item("Largar")
			$submenu.add_item("Descartar")
			if item.reciclavel:
				$submenu.add_item("Reciclar")
			if item.tipo == "Consumivel":
				$submenu.add_item("Equipar no atalho")
			$submenu.position = get_global_mouse_position() - Vector2(65, 0)
			$submenu.popup()
			


func _on_submenu_id_pressed(id: int) -> void: # apertou em algum item do botão do SUBMENU
	var aux = $submenu.get_item_text(id)
	
	if aux == str("Equipar como primaria"):
		if pers.slots["primaria"] != null:
			if pers.slots["primaria"] == item:
				pers.slots["primaria"] = null
				UI.atualizarslotsUI()
				return
			if pers.slots["primaria"] != item:
				pers.slots["primaria"] = item
				UI.atualizarslotsUI()
				return
		if pers.slots["primaria"] == null:
			pers.slots["primaria"] = item
			pers.arma_atual = pers.slots["primaria"]
			pers.equipado = true
			UI.atualizarslotsUI()
			
	
	if aux == str("Equipar como secundaria"):
		if pers.slots["secundaria"] == item:
			pers.slots["secundaria"] = null
			UI.atualizarslotsUI()
			return
		if pers.slots["secundaria"] == null:
			pers.slots["secundaria"] = item
			pers.arma_atual = pers.slots["secundaria"]
			pers.equipado = true
			UI.atualizarslotsUI()

	if aux == "Largar":
		
		if !item.stackavel:
			for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
				if pers.inventario[x] != null and pers.inventario[x] == item:
					print(aux, ", item removido do inventário: ", item)
					pers.inventario[x] = null
					break
			for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
				if pers.itenshotkey[y] != null and pers.itenshotkey[y] == item:
					print(aux, ", item removido da hotkey")
					pers.itenshotkey[y] = null
					break
			for z in %hotkeycontainer.get_children(): # Itera sobre cada item da UI HOTKEY
				if z.item == item:
					z.item = null
					print(aux, ", item removido da UI da hotkey")
					break
			var drop = pers.itemdrop.instantiate()
			drop.item = item.duplicate(true)
			drop.position = pers.position
			get_tree().get_root().get_node("main").add_child(drop) # spawnar item dropado nesse nodo
			print("dropou arma pelo menu: arma > ", pers.arma_atual.nome_item)
			if pers.arma_atual == item:
				pers.arma_atual = pers.mlivre
			item = null
			print("função rodou completamente")
			UI.atualizarinventarioUI()
			UI.atualizarslotsUI()
			return
		
		if item.stackavel:
			# Se selecionar função descartar de dentro do menu, abre submenus pra selecionar quantidade
			$largar.position = get_global_mouse_position() - Vector2(65, 0)
			$largar/vbc/textolargar.text = item.nome_item
			$largar/vbc/botaolargar.hide()
			$largar/vbc/botaolargar.show()
			$largar/vbc/SpinBox.show()
			$largar/vbc/SpinBox.min_value = 1
			$largar/vbc/SpinBox.max_value = item.quantidade
			$largar.show()
			# AQUI ABRE O COMANDO DE APERTAR NO BOTÃO DE DESCARTAR. CÓDIGO MAIS ABAIXO


	if aux == "Reciclar": ## EM ANDAMENTO
		print("reciclagem começou")
		
		# Limpar e adicionar textos relacionados da UI
		reciclar.clear() 
		$reciclar.position = Vector2(global_position.x, global_position.y + 25)
		var texto = ""
		for x in item.material_reciclado:
			texto += (str("\n", x.nome_item, ", x",x.quantidade))
			reciclar.push_front(x)
		$reciclar/vbc/titulo.text = "Materiais obtidos:"
		$reciclar/vbc/textoreciclar.text = texto
		$reciclar/vbc/botaoreciclar.text = "Clique aqui para reciclar"
		$reciclar.show()
		$reciclar/vbc/botaoreciclar.show()
		$reciclar.position = get_global_mouse_position() - Vector2(65, 0)
		UI.atualizarinventarioUI()



	if aux == "Descartar":
		
		if !item.stackavel:
			for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
				if pers.inventario[x] != null and pers.inventario[x] == item:
					pers.inventario[x] = null
					break

			for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
				if pers.itenshotkey[y] != null and pers.itenshotkey[y] == item:
					pers.itenshotkey[y] = null
					break

			for z in %hotkeycontainer.get_children(): # Itera sobre cada item da UI HOTKEY
				if z.item == item:
					z.item = null
					break

			if pers.arma_atual == item:
				pers.arma_atual = pers.mlivre
			item = null
			UI.atualizarslotsUI()
			UI.atualizarinventarioUI()
			return

		if item.stackavel:
			# Se selecionar função descartar de dentro do menu, abre submenus pra selecionar quantidade
			$descartar.position = get_global_mouse_position() - Vector2(65, 0)
			$descartar/vbc/textodescartar.text = item.nome_item
			$descartar/vbc/botaodescartar.hide()
			$descartar/vbc/botaodescartar.show()
			$descartar/vbc/SpinBox.show()
			$descartar/vbc/SpinBox.min_value = 1
			$descartar/vbc/SpinBox.max_value = item.quantidade
			$descartar.show()
			# AQUI ABRE O COMANDO DE APERTAR NO BOTÃO DE DESCARTAR. CÓDIGO MAIS ABAIXO

func hover_on() -> void: # Exibe informações dos itens ao passar o mouse por cima do inventario
	if item != null:
		$hover.clear()
		$hover.add_item(str("Dano: ", item.dano))
		$hover.add_item(str("DPS: ", item.velocidade_ataque))
		$hover.add_item(str("Stackavel: ", item.stackavel))
		$hover.add_item(str("Quantidade: ", item.quantidade))
		$hover.add_item(str("Modo de disparo: ", "Auto" if item.semiauto == false else "Semiauto"))
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
	print("BOTÃO reciclar APERTADO")

	# Pega o limite máximo de slots do inventário
	var inv_max = UI.invmax

	# Conta quantos slots estão vazios
	var slots_vazios := 0
	for i in pers.inventario:
		if i == null:
			slots_vazios += 1

	# Conta quantos itens reciclados não são stackáveis
	var itens_nao_stackaveis: int = 0
	var itens_stackaveis: int = 0
	for i in reciclar:
		if not i.stackavel:
			itens_nao_stackaveis += i.quantidade
		if i.stackavel:
			itens_stackaveis += i.quantidade

	# Calcula se há espaço suficiente no inventário
	var ocupados = pers.inventario.size() - slots_vazios # 20slot - 8slot vazios = 12slot ocupados
	var total_previsto = ocupados + itens_nao_stackaveis + itens_stackaveis
	print("slots ocupados = ", ocupados, "\n",
	"não stackaveis: ", itens_nao_stackaveis, "\n",
	"stackaveis: ", itens_stackaveis, "\n",
	"total de slots previstos pra operação: ", total_previsto)

	if total_previsto > inv_max:
		$erro.position = get_global_mouse_position() - Vector2(65, 0)
		$erro.popup()
		print("Inventário cheio! Não há espaço suficiente para reciclar.")
		return

	# Continua normalmente se houver espaço
	for x in reciclar:
		if x.stackavel: # SE O ITEM FOR STACKAVEL
			for y in range(len(pers.inventario)):
				if pers.inventario[y] == null:
					pers.inventario[y] = x
					break
				if pers.inventario[y] == x:
					pers.inventario[y].quantidade += x.quantidade
					break
		if !x.stackavel: # SE O ITEM NÃO FOR STACKAVEL
			var qntitensnaostack: int = 0
			for y in range(len(pers.inventario)):
				if pers.inventario[y] == null:
					pers.inventario[y] = x.duplicate(true)
					pers.inventario[y].quantidade = 1
					print("item adicionado! ", pers.inventario[y].nome_item, pers.inventario[y].quantidade)
					qntitensnaostack += 1
					print(qntitensnaostack, " ", itens_nao_stackaveis)
					if x.quantidade == qntitensnaostack:
						print("parou loop")
						break

	# Remove o item original que foi reciclado
	for i in range(len(pers.inventario)):
		if pers.inventario[i] == item:
			pers.inventario[i] = null
			break

	# Limpa e atualiza a UI
	reciclar.clear()
	$reciclar.hide()
	UI.atualizarinventarioUI()
	print($reciclar/vbc/SpinBox.value)


func _on_botaodescartar_pressed() -> void:
	print("rodou")
	var qntdescartar = int($descartar/vbc/SpinBox.value)
	
	for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
		if pers.inventario[x] != null and pers.inventario[x] == item:
			pers.inventario[x].quantidade -= qntdescartar
			if pers.inventario[x].quantidade == 0:
				pers.inventario[x] = null
			$descartar.hide()
			break

	# AVALIAR NECESSIDADE DO FOR Y E FOR Z
	for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
		if pers.itenshotkey[y] != null and pers.itenshotkey[y] == item:
			pers.itenshotkey[y] = null
			break

	for z in %hotkeycontainer.get_children(): # Itera sobre cada item da UI HOTKEY
		if z.item == item:
			z.item = null
			break
			
	if pers.arma_atual == item:
		pers.arma_atual = pers.mlivre
	item = null
	UI.atualizarslotsUI()
	UI.atualizarinventarioUI()


func _on_botaolargar_pressed() -> void:
	var qntlargar = int($largar/vbc/SpinBox.value)
	var itemdrop: itens
	
	for x in range(len(pers.inventario)): # Itera sobre cada item do INVENTÁRIO
		if pers.inventario[x] != null and pers.inventario[x] == item:
			pers.inventario[x].quantidade -= qntlargar
			if pers.inventario[x].quantidade == 0:
				pers.inventario[x] = null
			$largar.hide()
			break

	for y in range(len(pers.itenshotkey)): # Itera sobre cada item do HOTKEY
		if pers.itenshotkey[y] != null and pers.itenshotkey[y].quantidade == 0:
			pers.itenshotkey[y] = null
			break
	
	var drop = pers.itemdrop.instantiate()
	drop.item = item.duplicate(true)
	drop.position = pers.position
	drop.item.quantidade = qntlargar
	get_tree().get_root().get_node("main").add_child(drop) # spawnar item dropado nesse nodo
	print("dropou arma pelo menu: arma > ", pers.arma_atual.nome_item)
	
	if pers.arma_atual == item:
		pers.arma_atual = pers.mlivre
	item = null
	UI.atualizarslotsUI()
	UI.atualizarinventarioUI()
	
	
	
	pass # Replace with function body.
