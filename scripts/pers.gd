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

var listaopac = []
var ultimoalvo

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	

	opacidade()
	
	
	if not is_on_floor(): # gravidade
		velocity += get_gravity() * delta

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

	if Input.is_action_just_pressed("atirar"):
		if mirando == true:
			var col = raio.get_collider()
			if col != null and col.is_in_group("Inimigo"):
				#print(col.vida)
				col.vida -= 30


	if Input.is_action_just_pressed("E"):
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


	# zoom da camera
	if Input.is_action_just_pressed("mouse+"):
		cam.size -= 1 
	elif Input.is_action_just_pressed("mouse-"):
		cam.size += 1
	cam.size = clamp(cam.size, 5, 30)


	#$Label.text = str(
		#movtank, "\n",
		#velocity, "\n",
		#raio.target_position
		#)


	if vida <= 0:
		get_tree().reload_current_scene()


func mirar(): 
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
	#print(raycast_results)
	raycast_results["position"].y += 1
	if !raycast_results.is_empty():
		#print(raycast_results["position"], "   ", rotation)
		circ.show()
		look_at(raycast_results["position"], Vector3.UP)
		raio.position = position
		raio.target_position = ((raycast_results["position"] - position).normalized() * ray_lenght) #* Vector3(30, 0, 30)
		circ.position = raycast_results["position"]
		circ.position.y = raycast_results["position"].y - 1
		var col = raio.get_collider()
		if col != null and col.is_in_group("Inimigo") and col.stencil == false:
			col.stencil = true
			ultimoalvo = col
		if is_instance_valid(ultimoalvo) and col is not CharacterBody3D and ultimoalvo is CharacterBody3D:
			ultimoalvo.stencil = false



func opacidade():
	opac.position = cam.position
	opac.target_position = opac.to_local(position)
	opac.force_raycast_update()
	var col = opac.get_collider()
	if col != null and !col.is_in_group("Player") and !col.is_in_group("Inimigo") and !listaopac.has(col.get_children()):
		for i in col.get_children():
			if i is MeshInstance3D and !listaopac.has(i):
				listaopac.append(i)
				i.transparency = listaopac.size() * 0.75
				print(listaopac)
				break
	if col.is_in_group("Player"):
		for i in listaopac:
			i.transparency = 0
		listaopac.clear()

	
