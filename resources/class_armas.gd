extends Resource
class_name armas

#propriedades gerais
@export var nome_item: String
@export var imagem: Texture2D
@export var dps: float
@export var alcance: int

#propriedades armas corpo a corpo
@export var durabilidade: int

#propriedades armas de fogo
@export var pente: int
@export var reserva: int
@export var modo_disparo: modo
@export var dano: int
enum modo {
	SEMI,
	AUTO
}
