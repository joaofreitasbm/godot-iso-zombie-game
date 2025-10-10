extends Resource
class_name armas

#propriedades gerais
@export var nome_item: String
@export var stackavel: bool
@export var reciclavel: bool
@export var imagem: Texture2D
@export var mesh: Mesh
@export var alcance: int
@export var audio_impacto: AudioStreamMP3
@export var velocidade_ataque: float
@export var impacto: float 
@export var receita_craft: Array[Resource]
@export var material_reciclado: Array[Resource]

@export_enum (
	"Corpo a corpo", 
	"Arma de fogo", 
	"Arremessavel",
	"Consumivel",
	"Material") var tipo: String

#propriedades armas de fogo
@export var qntmaxima: int
@export var qntatual: int
@export var qntreserva: int
@export var munição: Resource
@export var durabilidade: int
@export var tempo_carregamento: float
@export var semiauto: bool
@export var dano: int
@export var aux: bool = true # variavel auxiliar pra diferenciar disparos semi de auto




func usar_equipado(alvo, pers):
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
			recarregar()
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

		if qntatual == 0 and qntreserva == 0:
			print("sem munição")
			return
	else: 
		qntatual -= 1

	if tipo == "Arremessavel": #ARREMESSAVEL
		pass
	
	if tipo == "Consumivel": #CONSUMIVEL
		pers.vida += dano
		qntreserva -= 1


func recarregar():
	print("Recarregando...")
	var x = qntmaxima - qntatual # x == qnt faltando no pente
	if qntreserva > x:
		qntreserva -= x
		qntatual = qntmaxima
		return
	if qntreserva <= x:
		qntatual += qntreserva
		qntreserva = 0
