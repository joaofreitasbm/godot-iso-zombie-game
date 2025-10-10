extends PanelContainer

@export var item: Resource
@onready var pers: CharacterBody3D = $"../../../.."
var reciclar: Array[Resource]
var skip: bool = false
@onready var UI: Control = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !skip:
		if item != null:
			if item.tipo == "Arma de fogo":
				$Button/qnt.text = str(item.qntatual, "/", item.qntreserva)
			if item.tipo == "Arremessavel" or item.tipo == "Consumivel" or item.tipo == "Material":
				$Button/qnt.text = str(item.qntreserva)
			$Button/nome.text = str(item.nome_item)
			$Button/tipo.text = str(item.tipo)

			$Button/nome.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
			$Button/qnt.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 
			$Button/tipo.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0)) 


		if item == null:
			$Button/nome.text = "Vazio"
			$Button/qnt.text = "-"
			$Button/tipo.text = "-"

			$Button/nome.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
			$Button/qnt.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
			$Button/tipo.add_theme_color_override("font_color",  Color(0.248, 0.248, 0.248, 1.0))
		skip = true


func _on_button_pressed() -> void: # apertou botão do MENU
	print("botão apertado! item atual: ", item, self.name)
	for x in pers.inventario:
		if x != null and x == item:
			print("i: ", x, "item clickado: ", str(item))
			$submenu.clear()
			if item.tipo == "Arma de fogo" or item.tipo == "Corpo a corpo":
				$submenu.add_item(str("Equipar arma no slot ", pers.hotkey + 1))
			$submenu.add_item("Dropar")
			$submenu.add_item("Descartar")
			if item.reciclavel:
				$submenu.add_item("Reciclar")
			$submenu.position = get_global_mouse_position() - Vector2(65, 0)
			$submenu.popup()


func _on_submenu_id_pressed(id: int) -> void: # apertou botão do SUBMENU
	var aux = $submenu.get_item_text(id)
	if aux == str("Equipar arma no slot ", pers.hotkey + 1):
		for x in pers.inventario: # Itera sobre cada item do INVENTÁRIO
			if x != null and x == item:

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
							if i.item == x: # Se a variavel da hotkey for igual x (item do inventario)
								i.item = null # Limpa slot do hotkey
								print("Item removido do slot ", y + 1)

				# Equipa no slot atual
				pers.itenshotkey[pers.hotkey] = x
				pers.arma_atual = x
				pers.equipado = true
				for z in %hotkeycontainer.get_children(): # Itera sobre cada item do HOTKEY
					if int(z.name) == int(pers.hotkey) + 1:
						z.item = x
						print("Item ", x.nome_item, " equipado no slot ", pers.hotkey + 1)
						break

	if aux == "Dropar":
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
		pers.arma_atual = pers.mlivre # troca pra mãos livres
		item = null
		pers.equipado = false
		print("função rodou completamente")


	if aux == "Reciclar": ## EM ANDAMENTO
		print("reciclagem começou")
		reciclar.clear() 
		$reciclar/vbc/textoreciclar.text = ""
		$reciclar/vbc/botaoreciclar.text = ""
		$reciclar.position = Vector2(global_position.x, global_position.y + 25)
		var texto = ""
		for x in item.material_reciclado:
			texto += (str("\n", x.nome_item, ", x",x.qntreserva))
			reciclar.push_front(x)
		#$reciclar/botaoreciclar.position = $reciclar/textoreciclar.position + Vector2($reciclar/textoreciclar - 5, global_position.y + 150)
		$reciclar/vbc/textoreciclar.text = texto
		$reciclar/vbc/botaoreciclar.text = "Clique aqui para reciclar"
		$reciclar.show()
		#$reciclar/vbc/botaoreciclar.position = $reciclar/vbc/textoreciclar.size
		$reciclar/vbc/botaoreciclar.show()
		$reciclar.position = get_global_mouse_position() - Vector2(65, 0)
		UI.atualizarinventarioUI()



	if aux == "Descartar":
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
		UI.atualizarinventarioUI()


func hover_on() -> void: # Exibe informações dos itens ao passar o mouse por cima do inventario
	if item != null:
		$hover.clear()
		$hover.add_item(str("Dano: ", item.dano))
		$hover.add_item(str("DPS: ", item.velocidade_ataque))
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
			itens_nao_stackaveis += i.qntreserva
		if i.stackavel:
			itens_stackaveis += 1

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
		if x.stackavel:
			for y in range(len(pers.inventario)):
				if pers.inventario[y] == null:
					pers.inventario[y] = x
					break
		if !x.stackavel:
			var qntitensnaostack: int = 0
			for y in range(len(pers.inventario)):
				if pers.inventario[y] == null:
					pers.inventario[y] = x.duplicate(true)
					pers.inventario[y].qntreserva = 1
					print("item adicionado! ", pers.inventario[y].nome_item, pers.inventario[y].qntreserva)
					qntitensnaostack += 1
					print(qntitensnaostack, " ", itens_nao_stackaveis)
					if x.qntreserva == qntitensnaostack:
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
	item = null
	UI.atualizarinventarioUI()
	
	
	
	
	
	#print("BOTÃO reciclar APERTADO")
#
	## Pega o limite máximo de slots do inventário
	#var inv_max = UI.invmax
#
	## Conta quantos slots estão vazios
	#var slots_vazios := 0
	#for i in pers.inventario:
		#if i == null:
			#slots_vazios += 1
#
	## Conta quantos itens reciclados não são stackáveis
	#var itens_nao_stackaveis: int = 0
	#var itens_stackaveis: int = 0
	#for i in reciclar:
		#if not i.stackavel:
			#itens_nao_stackaveis += i.qntreserva
		#if i.stackavel:
			#itens_stackaveis += 1
#
	## Calcula se há espaço suficiente no inventário
	#var ocupados = pers.inventario.size() - slots_vazios # 20slot - 8slot vazios = 12slot ocupados
	#var total_previsto = ocupados + itens_nao_stackaveis + itens_stackaveis
	#print("slots ocupados = ", ocupados, "\n",
	#"não stackaveis: ", itens_nao_stackaveis, "\n",
	#"stackaveis: ", itens_stackaveis)
#
	#if total_previsto > inv_max:
		#print("Inventário cheio! Não há espaço suficiente para reciclar.")
		#return
#
	## Continua normalmente se houver espaço
	#for x in reciclar:
		#var adicionado := false
#
		## Tenta empilhar caso o item seja stackável
		#if x.stackavel:
			#for i in range(len(pers.inventario)):
				#var slot = pers.inventario[i]
				#if slot != null and slot.nome_item == x.nome_item:
					#slot.qntreserva += x.qntreserva
					#adicionado = true
					#break
		#if !x.stackavel:
			#
#
		## Se não empilhou, tenta colocar em um slot vazio
		#if not adicionado:
			#for i in range(len(pers.inventario)):
				#if pers.inventario[i] == null:
					#pers.inventario[i] = x.duplicate(true)
					#adicionado = true
					#break
#
		## Caso não tenha conseguido adicionar de jeito nenhum
		#if not adicionado:
			#print("Inventário cheio! Não foi possível adicionar: ", x.nome_item)
			#break
	#
#
	## Remove o item original que foi reciclado
	#for i in range(len(pers.inventario)):
		#if pers.inventario[i] == item:
			#pers.inventario[i] = null
			#break
#
	## Limpa e atualiza a UI
	#reciclar.clear()
	#$reciclar.hide()
	#item = null
	#UI.atualizarinventarioUI()
