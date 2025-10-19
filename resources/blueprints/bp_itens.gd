extends Resource
class_name itens

@export_group("Propriedades gerais")
#propriedades gerais
@export var nome_item: String
@export var posicao: Vector3
#@export_multiline var desc_item: String
@export var quantidade: int
@export var stackavel: bool
@export var reciclavel: bool
@export var imagem: Texture2D
@export var mesh: Mesh
@export var impacto: float 
@export var material_reciclado: Array[itens]
@export_enum (
	"Armas",
	"Equipamentos",
	"Utilidades",
	"Consumiveis",
	"Craft") var tipo: String

@export_enum (
	#"Armas",
	"Arma de fogo",
	"Corpo a corpo",
	"Arremessavel",
	
	#"Equipamentos",
	"Cabeça",
	"Superior",
	"Inferior",
	"Cintura",
	"Luvas",
	"Botas",
	"Face",
	"Mochila",
	
	#"Utilidades",
	"Lanterna",
	
	#"Consumiveis",
	"Cura",
	"Comida",
	"Bebida",
	
	#"Craft"		| MATERIAL DE PROCESSAMENTO NÃO VAI SER USADO AGORA
	"Material", #   | VAI SERVIR DE INGREDIENTE PRA CRIAR ITEM DE CRAFT
	"Receita") var subtipo: String


@export_group("Propriedades de armas")
#propriedades armas
@export var qntmaxima: int
@export var qntatual: int
@export var alcance: int
@export_enum (
	"Munição - fuzil",
	"Munição - pistola") var tipo_municao: String
@export var tempo_carregamento: float
@export var semiauto: bool
@export var audio_impacto: AudioStreamMP3
@export var velocidade_ataque: float
@export var dano: int
@export var aux: bool = true # variavel auxiliar pra diferenciar disparos semi de auto

@export_group("Propriedades de receitas")
@export var material_necessario: Array[itens]
@export var ferramenta_necessaria: Array[itens]
@export var bancada: bool
@export_enum (
	"Geral", 
	"Armas",
	"Marcenaria", 
	"Alvenaria",
	"Cozinha",
	"Primeiros socorros",
	"Mecanica",
	"Metalurgia") var tipo_receita: String
@export var item_craftado: itens
# adicionar variavel que acrescenta experiencia baseada na variavel tipo
# se tipo == Marcenaria, adiciona x exp na habilidade marcenaria.

@export_group("Propriedades de equipamentos")
@export var saude_max: int
@export var slots_inventario: int
@export var slots_hotkey: int
@export var durabilidade: int
@export var itens_guardados: Array[itens]
@export var peso: int


func usar_equipado(alvo, pers, UI):
	if subtipo == "Corpo a corpo": #CORPO A CORPO
		if alvo != null:
			if aux == true: # and durabilidade >= 1:
				print("bateu com corpo a corpo, durabilidade atual: ", durabilidade)
				aux = false
				if alvo.is_in_group("Inimigo"):
					print("bateu?")
					alvo.stun = true
					alvo.velocity += (alvo.global_position - pers.global_position).normalized() * impacto
					alvo.saude -= dano
					var part = preload("res://tscn/particula_sangue.tscn").instantiate()
					part.top_level = true
					part.position = alvo.position
					part.emitting = true
					alvo.add_child(part)
					if nome_item != "Mãos livres":
						durabilidade -= 1

	if tipo == "Arma de fogo": #ARMA DE FOGO
		var part = preload("res://tscn/particula_sangue.tscn").instantiate()
		
		if qntatual == 0:
			recarregar(pers, UI)
			return

		if semiauto == true and aux == true and qntatual >= 1:
			qntatual -= 1
			print("atirou semi, munição atual: ", qntatual)
			aux = false
			if alvo != null and alvo.is_in_group("Inimigo"):
				alvo.saude -= dano
				alvo.add_child(part)
				part.top_level = true
				part.position = alvo.position
				part.emitting = true
				UI.atualizarslotsUI()
				UI.atualizarinventarioUI()
			return

		if semiauto == false and aux == true and qntatual >= 1:
			qntatual -= 1
			print("atirou auto, ", qntatual)
			if alvo != null and alvo.is_in_group("Inimigo"):
				alvo.saude -= dano
				alvo.add_child(part)
				part.top_level = true
				part.position = alvo.position
				part.emitting = true
				UI.atualizarslotsUI()
				UI.atualizarinventarioUI()
			return 

		if qntatual == 0:
			## REPRODUZIR SOM DE DISPARO SEM MUNIÇÃO
			print("sem munição")
			return
	else: 
		qntatual -= 1
	
	
	
	if tipo == "Arremessavel": #ARREMESSAVEL
		pass
	
	if tipo == "Consumivel": #CONSUMIVEL
		if quantidade >= 1:
			pers.saude += dano
			quantidade -= 1
		

func equipar(pers, UI):
	
	pass

func recarregar(pers, UI):
	print("Recarregando...")
	var diferenca = qntmaxima - qntatual # x == qnt faltando no pente
	
	for x in range(len(pers.inventario)): # procurando a munição
		if pers.inventario[x] == null:
			continue

		# se o tipo da munição no inventario == munição necessaria pra arma atual
		if pers.inventario[x].tipo == pers.arma_atual.tipo_municao: 

			if pers.inventario[x].quantidade > diferenca: # se munição disponivel > o que falta no pente pra carregar:
				print("vai encher o pente todo")
				print("qnt munição disponivel: ", pers.inventario[x].quantidade)
				print("diferença: ", diferenca)
				print("qnt atual: ", qntatual)
				pers.inventario[x].quantidade -= diferenca # tira a qnt que falta da munição disponivel
				qntatual = qntmaxima # enche o pente
				UI.atualizarinventarioUI()
				UI.atualizarslotsUI()
				return

			if pers.inventario[x].quantidade <= diferenca: # se munição disponivel <= o que falta no pente pra carregar:
				print("vai encher só o que dá")
				print("qnt munição disponivel: ", pers.inventario[x].quantidade)
				print("diferença: ", diferenca)
				print("qnt atual: ", qntatual)
				qntatual += pers.inventario[x].quantidade # soma o que tem disponivel à qnt atual
				pers.inventario.erase(pers.inventario[x]) # apaga item do inventario (não da UI)
				UI.atualizarinventarioUI()
				UI.atualizarslotsUI()
				return

	
