extends CharacterBody3D

# variaveis usadas pro sistema de mira e movimentação
var mirando: bool = false
var correndo: bool = false

@onready var raio: RayCast3D = $raycastmira
@onready var circ:MeshInstance3D = $cursor3d
@onready var cam: Camera3D = $Camera3D
@onready var opac: RayCast3D = $Camera3D/raycastopacidade

var colmira
var listaopac: Array = []
var ultimoalvo

# Inventario/UI
@export var inventario: Array[itens]
@export var itenshotkey: Array[itens]
@onready var hotkey: int = 0
@onready var inventarioUI: VBoxContainer = $"UI/invcontainer/Inventário [TAB]"
@onready var hotkeyUI: HBoxContainer = $UI/fundo/hotkeycontainer
@onready var UI: Control = $UI

var mlivre: itens = preload("res://resources/armas/maos livres.tres")
var arma_atual = mlivre
var equipado: bool = false

@onready var interagir: bool = false
var itemdrop: Resource = preload("res://tscn/item.tscn")

# Saúde/status
@onready var velandar: float = 5.0
var vida: int = 100
var stamina: float = 100
var fome: float = 100
var sede: float = 100
var fadiga: float = (fome + sede) / 2
var sanidade: int = 100
var debuffs: Array[Resource] ## AVALIAR NECESSIDADE DE FAZER UMA CLASSE DE DEBUFFS
var lista_de_receitas: Array[receitas]


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	opacidade()
	#if arma_atual.receita_craft != null:
		#for x in arma_atual.receita_craft: # Itera sobre cada resource
			#print(x) # Retorna cada resource
			#print(arma_atual.receita_craft[x]) # Retorna cada quantidade


	if not is_on_floor(): velocity += get_gravity() * delta


	var input_dir: Vector2 = Input.get_vector("A", "D", "W", "S")
	var direction = (cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		position += direction * velandar * delta
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 10)
	else:
		correndo = false


	if Input.is_action_just_pressed("correr"): correndo = true


	# controlar velocidade do movimento
	if mirando: correndo = false; velandar = 3
	if correndo: mirando = false; velandar = 20 #7.5
	if not mirando and not correndo: velandar = 5


	if Input.is_action_pressed("mirar"):
		mirar()


	if Input.is_action_just_released("mirar"):
		mirando = false
		circ.hide()
		raio.target_position = Vector3.ZERO
		rotation.x = 0
		rotation.z = 0
		if ultimoalvo != null:
			ultimoalvo.stencil = false


	if not $timer.is_stopped():
		$Label.text = str(round($timer.time_left))
	else:
		$Label.text = "Pronto!"


	if Input.is_action_pressed("atirar"):
		if arma_atual.tipo == "Consumivel": #consumivel
			arma_atual.usar_equipado(colmira, self, UI)
			return
		if mirando and $timer.is_stopped(): 
			$timer.wait_time = arma_atual.velocidade_ataque
			$timer.start()
			arma_atual.usar_equipado(colmira, self, UI)
			print("atirou em: ", colmira)


	if Input.is_action_just_released("atirar"):
		if mirando: arma_atual.aux = true
		else: return


	move_and_slide()


	# fechar jogo
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("R"): itenshotkey[hotkey].recarregar(self, UI)

	if Input.is_action_just_pressed("E"): interagir = true; print(interagir)
	if Input.is_action_just_released("E"): interagir = false; print(interagir)


	# controle e posicionamento da camera
	if Input.is_action_just_pressed("mouse+"): cam.size -= 1 
	elif Input.is_action_just_pressed("mouse-"): cam.size += 1
	cam.size = clamp(cam.size, 5, 50)
	cam.position = position + Vector3(-100, 40, 100)


	#spawnar inimigo (debug)
	if Input.is_action_just_pressed("F"):
		var inim = preload("res://tscn/inim.tscn").instantiate()
		inim.position = position + Vector3(10, 0, 0)
		get_tree().get_root().get_node("main").add_child(inim)


	#dropar item
	if Input.is_action_just_pressed("G"): 
		if arma_atual != mlivre:
			for x in itenshotkey:
				if x != null and arma_atual == x:
					inventario.erase(x) # apaga do inventario
					itenshotkey[hotkey] = null # remove da hotkey atual
					for y in $"UI/invcontainer/Inventário [TAB]".get_children(): # retorna os PanelContainers 
						if y is PanelContainer and y.item == arma_atual:
							y.item = null
							break
					for z in $UI/fundo/hotkeycontainer.get_children():
						if z.item == arma_atual:
							z.item = null
							break
					var drop = itemdrop.instantiate()
					drop.item = arma_atual.duplicate(true)
					drop.position = position
					get_parent().add_child(drop) # spawnar item dropado nesse nodo
					arma_atual = mlivre
					equipado = false


	# guardar item
	if Input.is_action_just_pressed("Q"):
		if itenshotkey[hotkey] == null: # Se não tiver nada equipado na hotkey atual
			arma_atual = mlivre
			equipado = false
			return
		if itenshotkey[hotkey].nome_item != "Mãos livres": # Se a hotkey atual for algo diferente de mãos livres
			for i in itenshotkey: # Itera sobre cada item da hotkey
				if itenshotkey[hotkey] == i and equipado == true: # Se a iteração for igual a hotkey atual
					arma_atual = mlivre
					equipado = false
					break
				else:
					arma_atual = itenshotkey[hotkey]
					equipado = true


		# Abrir inventário
	if Input.is_action_just_pressed("TAB"):
		if $UI/invcontainer.visible == true:
			$UI/invcontainer.hide()
			return
		if $UI/invcontainer.visible == false:
			$UI/invcontainer.current_tab = 0
			UI.atualizarinventarioUI()
			$UI/invcontainer.show()
	
			# Abrir inventário (ABA 2)
	if Input.is_action_just_pressed("K"):
		if $UI/invcontainer.visible == true:
			$UI/invcontainer.hide()
			return
		if $UI/invcontainer.visible == false:
			$UI/invcontainer.current_tab = 1
			UI.atualizarinventarioUI()
			$UI/invcontainer.show()

			# Abrir inventário (ABA 3)
	if Input.is_action_just_pressed("L"):
		if $UI/invcontainer.visible == true:
			$UI/invcontainer.hide()
			return
		if $UI/invcontainer.visible == false:
			$UI/invcontainer.current_tab = 2
			UI.atualizarinventarioUI()
			$UI/invcontainer.show()



	$UI/hotkeys.text = str("slot atual: ", hotkey + 1, "\n", "hotkey: ", itenshotkey, itenshotkey[hotkey],"equipado: ", equipado)
	$UI/invlabel.text = str("inventario: ", inventario, "\n", "arma atual: ", arma_atual)

	# se no inventario tiver a munição necessaria: true
	# se nao tiver munição necessaria no inventario: false
	
	#for i in range(len(inventario)):
		#print(inventario[i])
		#if inventario[i] != null and inventario[i].municao != null and inventario[i].municao.tipo == inventario[i].tipo:
			#$UI/info.text = str(
				#"tem a munição no inventario. \n",
				#"nome: ", arma_atual.municao.nome_item,"\n",
				#"slot do inventario:", i)
			#
		#if inventario[i] == null:
			#print("slot nulo: ", inventario[i])
			#
		#if arma_atual.municao != inventario[i]:
			#$UI/info.text = str("nao tem a munição no inventario")
			##print(" nao tem a municao no inventario ")
			
				
	

	if vida <= 0:
		get_tree().reload_current_scene()


func alvo2d(): 
	mirando = true
	velandar = 3
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_lenght = 1000
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * ray_lenght
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = 2 
	var raycast_results = space.intersect_ray(ray_query)
	raycast_results["position"].y += 1
	return raycast_results["position"]


func mirar():
	circ.show()
	look_at(alvo2d(), Vector3.UP)
	raio.position = position
	raio.target_position = ((alvo2d() - position).normalized() * arma_atual.alcance) #substituir ray_length pelo alcance da arma
	circ.position = alvo2d()
	circ.position.y = alvo2d().y - 1
	colmira = raio.get_collider()
	if colmira != null and colmira.is_in_group("Inimigo") and colmira.stencil == false:
		colmira.stencil = true
		ultimoalvo = colmira
	if is_instance_valid(ultimoalvo) and colmira is not CharacterBody3D and ultimoalvo is CharacterBody3D:
		ultimoalvo.stencil = false


func opacidade():
	opac.position = cam.position
	opac.target_position = opac.to_local(position)
	opac.force_raycast_update()
	var colopac = opac.get_collider()
	if colopac != null and !colopac.is_in_group("Player") and !colopac.is_in_group("Inimigo") and !listaopac.has(colopac.get_children()):
		for i in colopac.get_children():
			if i is MeshInstance3D and !listaopac.has(i):
				listaopac.append(i)
				i.transparency = listaopac.size() * 0.75
				print(listaopac)
				break
	if colopac.is_in_group("Player"):
		for i in listaopac:
			i.transparency = 0
		listaopac.clear()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.as_text_key_label().is_valid_int() and event.pressed and not event.echo and event.keycode != 48:
		var index := int(event.as_text_key_label()) - 1
		if index < 0 or index >= len(itenshotkey):
			return

		hotkey = index
		$timer.stop()
		if itenshotkey[hotkey] == null:
			equipado = false
			arma_atual = mlivre  # mlivre = sem arma
			print("Desequipou arma do slot ", hotkey)
			return


		if itenshotkey[hotkey] != null:
			equipado = true
			arma_atual = itenshotkey[hotkey]
			print("Equipou arma: ", arma_atual.nome_item, " no slot ", hotkey)
