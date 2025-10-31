extends CharacterBody3D

# variaveis usadas pro sistema de mira e movimentação
var mirando: bool = false
var andando: bool = false
var correndo: bool = false
var capoeira: bool = false

@onready var raio: RayCast3D = $utilidades/raycastmira
@onready var circ: MeshInstance3D = $utilidades/cursor3d
@onready var cam: Camera3D = $Camera3D
@onready var opac: RayCast3D = $Camera3D/raycastopacidade

var colmira
var listaopac: Array = []
var ultimoalvo

# Inventario/equipamento/UI
@export var inventario: Array[itens]
@onready var inventario_max: int = 10 + slots["mochila"].slots_mochila if slots["mochila"] != null else 10
@onready var hotkey_max: int = 0 + slots["mochila"].slots_hotkey if slots["mochila"] != null else 0
var lista_de_receitas: Array[itens]
@export var slots: Dictionary[String, Resource] = {
	# armas, utilidades e consumiveis
	"primaria": null,
	"secundaria": null,
	"hotkey1": null,
	"hotkey2": null,
	"hotkey3": null,
	"hotkey4": null,
	"hotkey5": null,
	
	# Equipamento
	"cabeça": null,
	"superior": null,
	"inferior": null,
	"cintura": null,
	"botas": null,
	"face": null,
	"luvas": null,
	"mochila": null,
}

# Variaveis relacionadas ao inventario
@onready var pers = self
@onready var arma_atual = null
@onready var hotkey: int = 0
@onready var UI: Control = $UI
@onready var menu: TabContainer = $UI/invcontainer

#var mlivre: itens = preload("res://resources/armas/maos livres.tres")
var equipado: bool = false

@onready var interagir: bool = false
var itemdrop: Resource = preload("res://tscn/item.tscn")

# Saúde/status
@onready var velandar: float = 2.0
var saude: int = 100
var folego: float = 100
var fome: float = 100
var sede: float = 100
var fadiga: float = (fome + sede) / 2
var sanidade: int = 100
var debuffs: Array[Resource] ## AVALIAR NECESSIDADE DE FAZER UMA CLASSE DE DEBUFFS

# Auxiliar da tecla Q
var segurando_q: bool
var tempo_q: float

@onready var inimigo = preload("res://tscn/inimigo/inim.tscn")

var inimigos = 0
func _ready() -> void:
	UI.connect("resultado_contador", Callable(self, "_on_resultado_contador"))
	UI.connect("resultado_reciclar", Callable(self, "_on_resultado_reciclar"))

func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	opacidade()
	
	#print(velandar)

	# lógica de movimentação:
	if not is_on_floor(): velocity += get_gravity() * delta
	var input_dir: Vector2 = Input.get_vector("A", "D", "W", "S")
	var sentidocamera = cam.global_transform.basis.get_euler().y
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, sentidocamera).normalized()
	if direction != Vector3.ZERO:
		andando = true
		position += direction * velandar * delta
		$visual.rotation.y = lerp_angle($visual.rotation.y, atan2(-direction.x, -direction.z), delta * 15)
		if Input.is_action_just_pressed("correr"): correndo = true
	else:
		correndo = false
		andando = false

		
	move_and_slide()


	# controlar velocidade do movimento
	if mirando: correndo = false; velandar = 3; 
	if correndo: mirando = false; velandar = 6; 
	if not mirando and not correndo: velandar = 2; 


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


	if not $timers/disparo.is_stopped():
		$Label.text = str(round($timers/disparo.time_left))
	else:
		$Label.text = "Pronto!"


	if Input.is_action_pressed("atirar"):
		if mirando and $timers/disparo.is_stopped() and arma_atual != null:
			if arma_atual.qntatual >= 1: 
				$timers/disparo.wait_time = arma_atual.velocidade_ataque
				$timers/disparo.start()
				arma_atual.usar_equipado(colmira, self, UI)
			else:
				iniciar_recarga(arma_atual)
			
	if Input.is_action_pressed("espaço"):
		if mirando and $timers/disparo.is_stopped() and colmira != null: 
			$timers/disparo.wait_time = 1.5 # < tempo de cooldown em segundos
			$timers/disparo.start()
			var dist = global_position.distance_to(colmira.global_position)
			print(dist)
			if colmira.is_in_group("Inimigo") and dist <= 2:
				colmira.stun = true
				colmira.velocity += (colmira.global_position - global_position).normalized() * 3
			else:
				return
	


	if Input.is_action_just_released("atirar"):
		if mirando and arma_atual != null: arma_atual.aux = true
		else: return


	# fechar jogo
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()


		
	if Input.is_action_just_pressed("R") and arma_atual != null and arma_atual.subtipo == "Arma de fogo":
		iniciar_recarga(arma_atual)
		#arma_atual.recarregar(self, UI, delta)
		

	if Input.is_action_just_pressed("E"): interagir = true;
	if Input.is_action_just_released("E"): interagir = false


	# controle e posicionamento da camera
	if Input.is_action_just_pressed("mouse+"): cam.size -= 1 
	elif Input.is_action_just_pressed("mouse-"): cam.size += 1
	cam.size = clamp(cam.size, 5, 100)



	if Input.is_action_just_pressed("M"):
		if capoeira == true: capoeira = false; return
		if capoeira == false: capoeira = true; return


	#spawnar inimigo (debug)
	if Input.is_action_just_pressed("F"):
		var inim = inimigo.instantiate()
		inimigos += 1
		inim.position = position + Vector3(10, 0, 0)
		get_tree().get_root().get_node("main").add_child(inim)


	#dropar arma atual
	if Input.is_action_just_pressed("G"): 
		largar_item(arma_atual)
		UI.atualizarinventarioUI()
		UI.atualizarhudUI()

	# LÓGICA DA TECLA Q
	# Começou a segurar
	if Input.is_action_just_pressed("Q"):
		segurando_q = true
		tempo_q = 0.0

	# Está segurando — acumula o tempo
	if segurando_q and Input.is_action_pressed("Q"):
		tempo_q += delta
		if tempo_q >= 1.0 and arma_atual != null:
			arma_atual = null
			UI.atualizarhudUI()
			segurando_q = false  # evita repetir

	# Soltou antes de 1 segundo
	if Input.is_action_just_released("Q") and segurando_q:
		if tempo_q < 1.0:
			if arma_atual == null and slots["primaria"] != null:
				arma_atual = slots["primaria"]
				UI.atualizarhudUI()
				return
			if slots["primaria"] != null and slots["secundaria"] != null:
				var aux = slots["primaria"]
				slots["primaria"] = slots["secundaria"]
				slots["secundaria"] = aux
				arma_atual = slots["primaria"]
				UI.atualizarhudUI()
				return
		if arma_atual == null:
			arma_atual = slots["primaria"]
			UI.atualizarhudUI()
		segurando_q = false
		tempo_q = 0.0


	if saude <= 0:
		get_tree().reload_current_scene()
		
	$Label2.text = str(
		slots["primaria"], "\n",
		slots["secundaria"], "\n", "\n",
		arma_atual, "\n", "\n",
		"inimigos: ", inimigos
	)



	
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
	ray_query.collision_mask = 4
	var raycast_results = space.intersect_ray(ray_query)
	raycast_results["position"].y += 1
	return raycast_results["position"]


func mirar():
	var alcance = 5 if arma_atual == null else arma_atual.alcance
	circ.show()
	$visual.look_at(alvo2d(), Vector3.UP)
	raio.position = position
	raio.target_position = ((alvo2d() - position).normalized() * alcance) #substituir ray_length pelo alcance da arma
	circ.position = alvo2d()
	circ.position.y = alvo2d().y - 1
	colmira = raio.get_collider()
	if colmira != null and colmira.is_in_group("Inimigo") and colmira.stencil == false:
		colmira.stencil = true
		ultimoalvo = colmira
	if is_instance_valid(ultimoalvo) and colmira is not CharacterBody3D and ultimoalvo is CharacterBody3D:
		ultimoalvo.stencil = false


func opacidade():
	opac.position = cam.global_position
	opac.target_position = opac.to_local(position)
	opac.force_raycast_update()
	var colopac = opac.get_collider()
	if colopac != null and !colopac.is_in_group("Player") and !colopac.is_in_group("Inimigo") and !listaopac.has(colopac.get_children()):
		for i in colopac.get_children():
			if i is MeshInstance3D and !listaopac.has(i):
				listaopac.append(i)
				i.transparency = listaopac.size() * 0.75
				break
	if colopac.is_in_group("Player"):
		for i in listaopac:
			i.transparency = 0
		listaopac.clear()


func adicionar_item(novo_item: itens) -> bool: # FUNCIONANDO EM TESTE
	# Adiciona um item ao inventário, retornando true se conseguiu ou false se o inventário estiver cheio.

	# 🔹 Verifica se é uma receita
	if novo_item.tipo == "Receita":
		lista_de_receitas.append(novo_item)
		UI.atualizarcraftUI()
		print("Receita adicionada: ", novo_item.nome_item)
		return true

	# 🔹 Verifica se há espaço
	var slots_ocupados := inventario.size()
	if slots_ocupados >= inventario_max:
		print("Inventário cheio, não foi possível adicionar ", novo_item.nome_item)
		return false

	# 🔹 Se for stackável, tenta empilhar em um existente
	if novo_item.stackavel:
		for inv_item in inventario:
			if inv_item.nome_item == novo_item.nome_item:
				inv_item.quantidade += novo_item.quantidade
				print("Empilhou ", novo_item.nome_item, " nova quantidade: ", inv_item.quantidade)
				return true

		# se não encontrou nenhum igual, adiciona como novo stack
		inventario.append(novo_item.duplicate(true))
		print("Novo stack criado: ", novo_item.nome_item)
		return true

	# 🔹 Se não for stackável, adiciona cada unidade separadamente
	for i in range(novo_item.quantidade):
		if inventario.size() < inventario_max:
			var copia := novo_item.duplicate(true)
			copia.quantidade = 1
			inventario.append(copia)
			print("Item não stackável adicionado: ", copia.nome_item)
		else:
			print("Inventário cheio durante adição de não stackáveis.")
			return false

	return true


func largar_item(item: itens) -> bool:
	# Checar se o item é null
	if item == null:
		return false
	
	# Checar se está equipado
	if item == slots["primaria"]:
		slots["primaria"] = null
	elif item == slots["secundaria"]:
		slots["secundaria"] = null
	UI.atualizarhudUI()
	
	# Checar se o item é stackavel
	if item.stackavel and item.quantidade > 1:
		UI._abrir_contador(item, "largar")
		return false #porque a função já tá aberta e ela vai tomar a frente a partir de lá
		
	# FUNÇÃO DE SPAWN ITEM
	_executar_largar(item, 1)
	UI.atualizarinventarioUI()
	return true


func descartar_item(item: itens) -> bool:
	# Checar se o item é null
	if item == null:
		return false
	
	# Checar se está equipado
	if item == slots["primaria"]:
		slots["primaria"] = null
	elif item == slots["secundaria"]:
		slots["secundaria"] = null
	UI.atualizarhudUI()
	
	# Checar se o item é stackavel
	if item.stackavel and item.quantidade > 1:
		UI._abrir_contador(item, "descartar")
		return false #porque a função já tá aberta e ela vai tomar a frente a partir de lá
		
	# Se não é stackável, ou é só 1 item, larga direto
	_executar_descartar(item, 1)
	return true


func _on_resultado_contador(quantidade: int, acao: String, item: Variant) -> void:
	print("Recebido do contador ->", quantidade, acao, item)
	if acao == "largar":
		_executar_largar(item, quantidade)
		print("_on_ui_resultado_contador")
	
	if acao == "descartar":
		_executar_largar(item, quantidade)
		print("_on_ui_resultado_contador")


func _executar_largar(item: itens, qtd: int) -> void:
	print("_executar_largar")
	if qtd < 1 or item == null:
		return
	
	# Diminui a quantidade no inventário
	item.quantidade -= qtd
	
	# Duplica o item e define a nova quantidade
	var novo_item = item.duplicate(true)
	novo_item.quantidade = qtd
	
	_drop_item_no_mundo(novo_item)
	
	# Se a quantidade original zerou, remove do inventário
	if item.quantidade <= 0:
		pers.inventario.erase(item)
	
	UI.atualizarinventarioUI()


func _executar_descartar(item: itens, qtd: int) -> void:
	print("_executar_descartar")
	if qtd < 1 or item == null:
		return
	
	# Diminui a quantidade no inventário
	item.quantidade -= qtd
	
	# Se a quantidade original zerou, remove do inventário
	if item.quantidade <= 0:
		pers.inventario.erase(item)
	
	UI.atualizarinventarioUI()


func _drop_item_no_mundo(item: itens) -> void:
	print("drop item no mundo")
	var drop = preload("res://tscn/item.tscn").instantiate()
	drop.item = item # não precisa ser duplicado porque já foi
	drop.position = position
	get_parent().add_child(drop)


func reciclar_item(item: itens) -> void:
	if item == null:
		return
	
	var texto = ""
	for i in item.material_reciclado:
		texto += (str("\n", i.nome_item, ", x",i.quantidade))
		
	UI._abrir_recicraft(texto, item.material_reciclado, item)
	return 


func _on_resultado_reciclar(itens_obtidos: Array[itens], item_consumido: itens) -> void:
	inventario.append_array(itens_obtidos)
	if inventario.has(item_consumido):
		inventario.erase(item_consumido)
	UI.atualizarinventarioUI()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.as_text_key_label().is_valid_int() and event.pressed and not event.echo and event.keycode != 48:
		hotkey = int(event.as_text_key_label())
		# ADICIONAR À FUNÇÃO QUE CONTROLA OS ITENS DA HOTKEY PRA ZERAR ESSA VARIAVEL QUANDO O ITEM FOR USADO
		return
	
	# Abrir inventário
	if Input.is_action_just_pressed("TAB"):
		print(inventario_max)
		if menu.visible == true:

			menu.hide()
			return
		if menu.visible == false:
			menu.current_tab = 0
			UI.atualizarinventarioUI()
			menu.show()

	# Abrir inventário (ABA 2)
	if Input.is_action_just_pressed("J"):
		if menu.visible == true:
			menu.hide()
			return
		if menu.visible == false:
			menu.current_tab = 1
			UI.atualizarinventarioUI()
			menu.show()

	# Abrir inventário (ABA 3)
	if Input.is_action_just_pressed("K"):
		if menu.visible == true:
			menu.hide()
			return
		if menu.visible == false:
			menu.current_tab = 2
			UI.atualizarinventarioUI()
			menu.show()

	# Abrir inventário (ABA 4)
	if Input.is_action_just_pressed("L"):
		if menu.visible == true:
			menu.hide()
			return
		if menu.visible == false:
			menu.current_tab = 3
			UI.atualizarinventarioUI()
			menu.show()


func iniciar_recarga(arma):
	$timers/recarga.wait_time = arma.tempo_carregamento
	$timers/recarga.start()


func _on_recarga_timeout() -> void:
	arma_atual.recarregar(self, UI)


#func usarhotkey(hotkey: int) -> void: ## PENDENTE
	#if hotkey:
		#slots[str("hotkey",hotkey)].usar_equipado()
	#hotkey = 0
	#pass
   
