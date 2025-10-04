extends CharacterBody3D

# variaveis usadas pro sistema de mira e movimentação
var mirando = false
var correndo = false

@onready var raio = $raycastmira
@onready var circ = $cursor3d
@onready var cam = $Camera3D
@onready var opac = $Camera3D/raycastopacidade

var velgiro = .025
@onready var velandar = 5
@onready var vida = 100
@onready var movtank = false

var colmira
var listaopac = []
var ultimoalvo

@export var inventario: Array[Resource]
@onready var arma_atual
var equipado = false

var interagir = false

var hotkey

var part = preload("res://tscn/particula_sangue.tscn").instantiate()

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:


	opacidade()


	if not is_on_floor(): # gravidade
		velocity += get_gravity() * delta

	if !equipado:
		arma_atual = preload("res://resources/maoslivres.tres")
	if movtank == true: # MOVIMENTAÇÃO DE TANK
		var frente = -global_transform.basis.z # variavel pra salvar direção pra onde o personagem anda

		# andar pra frente
		if Input.is_action_pressed("W"): # mover pra func _input (avaliar necessidade)
			position += frente * velandar * delta

		# rotação do personagem
		rotation.y -= Input.get_axis("A", "D") * velgiro ## criar como alterar a velocidade de girar

		# andar pra trás ## dar um jeito de resolver o correr pra trás
		if Input.is_action_pressed("S"): 
			correndo = false
			position += -frente * velandar * delta
			if Input.is_action_just_pressed("correr"):
				rotation.y += deg_to_rad(180)

		if Input.is_action_just_released("W"):
			correndo = false


	if movtank == false: #MOVIMENTAÇÃO 3D LIVRE
		var input_dir = Input.get_vector("A", "D", "W", "S")
		var direction = (cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction != Vector3.ZERO:
			position += direction * velandar * delta
			rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 10)
		else:
			correndo = false


	if Input.is_action_just_pressed("correr"):
		correndo = true


	# controlar velocidade de andar
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
		if mirando and $timer.is_stopped(): 
			$timer.wait_time = arma_atual.velocidade_ataque
			$timer.start()
			arma_atual.atirar(colmira)
			print("atirou em: ", colmira)

	if Input.is_action_just_released("atirar"):
		arma_atual.aux = true

				
	if Input.is_action_just_pressed("B"):
		if movtank == true:
			print("não movtank")
			movtank = false
			return

		if movtank == false:
			print("sim movtank")
			movtank = true
			return

	cam.position = position + Vector3(-100, 40, 100) # posicionamento fixo da camera funcionando
	move_and_slide()


	# fechar jogo
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("R"): arma_atual.recarregar()

	if Input.is_action_just_pressed("E"): interagir = true; print(interagir)
	if Input.is_action_just_released("E"): interagir = false; print(interagir)


	# zoom da camera
	if Input.is_action_just_pressed("mouse+"):
		cam.size -= 1 
	elif Input.is_action_just_pressed("mouse-"):
		cam.size += 1
	cam.size = clamp(cam.size, 5, 30)


	if Input.is_action_just_pressed("F"):
		var inim = preload("res://tscn/inim.tscn").instantiate()
		inim.position = position + Vector3(10, 0, 0)
		get_tree().get_root().get_node("main").add_child(inim)


	#if arma_atual != null:
		#$Label.text = str(
			#arma_atual.nome_item, "\n",
			#arma_atual.municao_atual,"/",arma_atual.municao_reserva, "\n",
			#)


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


func _input(event: InputEvent) -> void: # controle do hotkey
	if event is InputEventKey and event.as_text_key_label().is_valid_int() and event.pressed and not event.echo and event.keycode != 48:
		print(event)
		hotkey = int(event.as_text_key_label()) - 1
		print(hotkey, len(inventario))
		
		if hotkey >= len(inventario):
			return
		if arma_atual == inventario[hotkey]: equipado = false; return
		else: equipado = true; arma_atual = inventario[hotkey]; return
		
		
