extends CharacterBody3D

@export var velocidade := 2.0
@export var saude := 999
@export var raio_repulsao := 3.0
@export var forca_repulsao := 5.0
@export var update_rate := 0.2 # tempo entre updates de IA

@onready var pers := get_node("/root/main/pers")
@onready var gamemode := get_node("/root/main/spawn inimigo")

var area := false
var direcao := Vector3.ZERO
var velocity_y := 0.0
var timer_update := 0.0

# Referência cacheada (não chame get_tree().get_nodes_in_group() sempre)
static var inimigos := []

func _ready() -> void:
	inimigos.append(self)
	set_physics_process(true)

func _exit_tree() -> void:
	inimigos.erase(self)


func _physics_process(delta: float) -> void:
	# --- Atualização escalonada ---
	timer_update += delta
	if timer_update >= update_rate:
		atualizar_ia()
		timer_update = 0.0
	
	# --- Movimento básico ---
	if not is_on_floor():
		velocity_y += get_gravity().y * delta
	else:
		velocity_y = 0.0

	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade
	velocity.y = velocity_y

	move_and_slide()

	# --- Condição de morte ---
	if saude <= 0:
		gamemode.inimrestantes -= 1
		queue_free()


func atualizar_ia():
	# Evita cálculos desnecessários se estiver longe do player
	var dist_player = global_position.distance_to(pers.global_position)
	if dist_player > 80.0: # Inimigo muito longe: ignora IA
		direcao = Vector3.ZERO
		return

	# Atualiza direção pro jogador
	direcao = (pers.global_position - global_position).normalized()
	# Usa look_at só de vez em quando
	if randi() % 5 == 0:
		look_at(Vector3(pers.global_position.x, global_position.y, pers.global_position.z), Vector3.UP)

	# Soft collider simplificado e barato
	aplicar_soft_collider()


func aplicar_soft_collider():
	for outro in inimigos:
		if outro == self:
			continue
		var offset = global_position - outro.global_position
		var dist2 = offset.length_squared()
		if dist2 < raio_repulsao * raio_repulsao and dist2 > 0.01:
			var dist = sqrt(dist2)
			var push = (1.0 - dist / raio_repulsao) * forca_repulsao
			global_position += offset.normalized() * push * 0.1 # suave, proporcional


func _atacar_pers(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		pers.saude += randi_range(-10, -40)


func _parar_de_atacar(_body: Node3D) -> void:
	area = false
