extends Resource
class_name itens

#propriedades gerais
@export var nome_item: String
@export_multiline var desc_item: String
@export var quantidade: int
@export var stackavel: bool
@export var reciclavel: bool
@export var imagem: Texture2D
@export var mesh: Mesh
@export var alcance: int
@export var audio_impacto: AudioStreamMP3
@export var velocidade_ataque: float
@export var impacto: float 
@export var receita_craft: Array[itens]
@export var material_reciclado: Array[itens]
@export_enum (
	"Corpo a corpo", 
	"Arma de fogo", 
	"Arremessavel",
	"Consumivel",
	"Material",
	"Munição - fuzil") var tipo: String

#propriedades armas de fogo
@export var qntmaxima: int
@export var qntatual: int
@export var municao: int # NÃO USAR. IMPLEMENTAR QUANTIDADE RESERVA COMO MUNIÇÃO
@export_enum (
	"Munição - fuzil") var tipo_municao: String
@export var durabilidade: int
@export var tempo_carregamento: float
@export var semiauto: bool
@export var dano: int
@export var aux: bool = true # variavel auxiliar pra diferenciar disparos semi de auto


func usar_equipado(alvo, pers, UI):
	if tipo == "Corpo a corpo": #CORPO A CORPO
		if alvo != null:
			if aux == true and durabilidade >= 1:
				print("bateu com corpo a corpo, durabilidade atual: ", durabilidade)
				aux = false
				if alvo.is_in_group("Inimigo"):
					alvo.vida -= dano
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
				alvo.vida -= dano
				alvo.add_child(part)
				part.top_level = true
				part.position = alvo.position
				part.emitting = true
			return

		if semiauto == false and aux == true and qntatual >= 1:
			qntatual -= 1
			print("atirou auto, ", qntatual)
			if alvo != null and alvo.is_in_group("Inimigo"):
				alvo.vida -= dano
				alvo.add_child(part)
				part.top_level = true
				part.position = alvo.position
				part.emitting = true
			return 

		#if qntatual == 0:
			## REPRODUZIR SOM DE DISPARO SEM MUNIÇÃO
			print("sem munição")
			return
	else: 
		qntatual -= 1

	if tipo == "Arremessavel": #ARREMESSAVEL
		pass
	
	if tipo == "Consumivel": #CONSUMIVEL
		pers.vida += dano
		#quantidade -= 1
		



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
				return
			if pers.inventario[x].quantidade <= diferenca: # se munição disponivel <= o que falta no pente pra carregar:
				print("vai encher só o que dá")
				print("qnt munição disponivel: ", pers.inventario[x].quantidade)
				print("diferença: ", diferenca)
				print("qnt atual: ", qntatual)
				qntatual += pers.inventario[x].quantidade # soma o que tem disponivel à qnt atual
				pers.inventario[x] = null # apaga item do inventario (não da UI)
				UI.atualizarinventarioUI()
				return
	
