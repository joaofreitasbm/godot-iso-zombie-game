extends CharacterBody3D

@export var velocidade := 2.0 ## ADICIONAR RANDINT
@export var saude := 100
@export var raio_repulsao := 3.0
@export var forca_repulsao := 2.0
@export var update_logica := 0.1 # tempo entre updates de IA
@export var timer_logica: float = 0
var idle_skip: bool = false

# logica IA
@onready var raycast: RayCast3D = $raycast
var timer_raycast: float = 0.0
var ultima_pos: Vector3
@onready var navi_agent: NavigationAgent3D = $NavigationAgent3D


@onready var stun: bool = false
var timer_stun: float
@onready var stencil: bool = false
@onready var pers := get_node("/root/main/pers")
@onready var gamemode := get_node("/root/main/spawn inimigo")
var idle: bool = true
var area := false
var velocity_y := 0.0
var timer_update := 0.0
var pos_alvo: Vector3

# Referência cacheada (não chame get_tree().get_nodes_in_group() sempre)
static var inimigos := []

# LOD
var timer_lod: float = 0.0
var update_lod: float = 0.5

enum estados {
	OCIOSO,
	SEGUINDO
}

var estado_atual = estados.OCIOSO

@export var estado_distancia: String = ""


func _ready() -> void:
	inimigos.append(self)
	set_physics_process(false)

func _exit_tree() -> void:
	inimigos.erase(self)

func _process(delta: float) -> void:
	if saude <= 0:
		queue_free()
	#ativar_stencil() < desativado por enquanto, não apagar
	
	# posição inimigo:
	#> 30: = 900 desativar completamente (POTENCIA = X^2)
	#<= 30: ativar lógica sem animações e modelos
	#<= 20: ativar animações e modelos


	timer_lod += delta # avaliar forma de parar esse calculo quando inimigo estiver longe
	if timer_lod >= update_lod:

		var distancia = global_position.distance_squared_to(pers.global_position)

		# FORA DA ZONA DE CARREGAMENTO, ACIMA DE 50m.
		# aqui o inimigo é completamente desligado
		if distancia > 2500 and estado_distancia != "longe":
			set_physics_process(false)
			$CollisionShape3D.disabled = true
			$"detectar/detectar pers".disabled = true
			self.hide()
			$visual/persteste/AnimationPlayer.active = false
			timer_lod = -5 # timer de 5 segundos até checar novamente
			estado_distancia = "longe"
			

		# Entrando na zona de carregamento, abaixo dos 50m 
		# aqui tudo exceto a lógica do inimigo continua desligado
		if distancia <= 2500 and estado_distancia != "perto":
			self.show()
			set_physics_process(false)
			$CollisionShape3D.disabled = true
			$"detectar/detectar pers".disabled = true
			$visual/persteste/AnimationPlayer.active = false
			$Label3D.text = str("+20m")
			timer_lod = -1 # timer de 2 segundos até checar novamente
			estado_distancia = "perto"
			

		# ativar animações (logica já deve estar ativada do passo anterior)
		if distancia <= 400 and estado_distancia != "visivel": #20m
			set_physics_process(true)
			$CollisionShape3D.disabled = false
			$"detectar/detectar pers".disabled = false
			$visual/persteste/AnimationPlayer.active = true
			$Label3D.text = str("-20m")
			timer_lod = -1 
			estado_distancia = "visivel"


func _physics_process(delta: float) -> void:
	
	
	$visual/persteste/AnimationPlayer.play("Armature|mixamo_com|Layer0")
	
	#if not is_on_floor(): velocity = get_gravity()

	
	
	
	
	#if not stun:
		#var dir = Vector3(pers.position.x - position.x, 0, pers.position.z - position.z).normalized() * velocidade
		#velocity.x += dir.x * delta * velocidade
		#velocity.z += dir.z * delta * velocidade
		#var rotacao_alvo := atan2(-dir.x, -dir.z)
		#rotation.y = lerp_angle(rotation.y, rotacao_alvo, 0.1)
		#if velocity.length() > velocidade:
			#velocity = velocity.normalized() * velocidade
			#if not is_on_floor():
				#velocity.y -= 9.8
		#if velocity.length_squared() > 0.001:
			#var move_dir = velocity.normalized()
			#move_dir.y = 0
			
	
	timer_logica += delta
	if timer_logica >= update_logica and !stun:
		#atualizar_ia() #< desativado por enquanto, nao apagar
		#movimentar_navimesh(pers.global_position)
		#look_at(pos_alvo.lerp(pos_alvo, 0.1))
		timer_logica = 0
#
	if stun:
		velocity -= Vector3.ZERO
		var random = randf_range(0.3, 2.0)
		timer_stun += delta
		prints("vel stunado:", velocity)
		if velocity.x > 1 or velocity.z > 1:
			print("DERRUBAR INIMIGO")
		if timer_stun >= random:
			timer_stun = 0
			stun = false
			
	if not is_on_floor(): velocity.y += -9.8
	move_and_slide()
	
	
	
			
	#pos_alvo = pers.position
	#pos_alvo.y = self.position.y


func ativar_stencil():
	if stencil == true:
		for i in self.get_children():
			if i is MeshInstance3D:
				i.mesh.material.stencil_mode = 1 
				i.mesh.material.stencil_color = Color(1,0,0)
				i.mesh.material.stencil_outline_thickness = .1
	if stencil == false:
		for i in self.get_children():
			if i is MeshInstance3D:
				i.mesh.material.stencil_mode = 0
	


func atualizar_ia():
	
	if area: atacar(pers)
	
	
	#movimentar_navimesh(pers.global_position)
	logica_raycast()




func _atacar_pers(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true


func _parar_de_atacar(_body: Node3D) -> void:
	area = false


func atacar(alvo):
	if $Timer.is_stopped():
		alvo.saude -= randi_range(-10, -30)
		$Timer.wait_time = randf_range(1.5, 4.0)
		$Timer.start()
		print("atacando...")

func logica_raycast():
	if !stun:
		var colisor = raycast.get_collider()
		print(ultima_pos)
		if global_position.distance_to(pers.global_position) < 30:
			raycast.show()
			raycast.position = position
			raycast.target_position = raycast.to_local(pers.global_position)
			if colisor != null and colisor.is_in_group("Player"):
				ultima_pos = colisor.global_position
				movimentar_navimesh(pers.global_position)

			else:
				movimentar_navimesh(ultima_pos)
				raycast.hide()


		
	

func movimentar_navimesh(alvo: Vector3) -> void:
	
	# Atualiza o destino apenas se mudou significativamente
	if navi_agent.target_position.distance_to(alvo) > 0.5:
		navi_agent.target_position = alvo

	# Se o caminho ainda está sendo calculado, não faz nada neste frame
	if navi_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return

	var destino = navi_agent.get_next_path_position()
	var direcao = (destino - global_position)
	direcao.y = 0
	if direcao.length() > 0.1:
		direcao = direcao.normalized()
		velocity = direcao * velocidade
		look_at(global_position + direcao)

func inim_idle():
	var random_pos = Vector3.ZERO
	random_pos.x = randf_range(-5.0, 5.0)
	random_pos.z = randf_range(-5.0, 5.0) 
	navi_agent.target_position = random_pos
	prints("random_pos", random_pos)
	
	var destino = (navi_agent.get_next_path_position()).normalized()
	prints("destino", destino)
	velocity = destino * velocidade
	
		
