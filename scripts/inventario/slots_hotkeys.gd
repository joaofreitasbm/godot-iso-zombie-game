extends Button

@export var item: itens
@onready var pers: CharacterBody3D = $"../../../.."

@onready var slot = int(self.name) - 1
var slotvazio: Resource = preload("res://pngs/vazio.png")

var skip: bool = false
func _ready() -> void:
	$nome_slot.text = self.name

func _process(_delta: float) -> void:

	if !skip:

		# Atribui slot do inventario à variavel item
		if pers.itenshotkey[int(self.name) - 1] == null:
			item = null
			icon = slotvazio
			$quantidade.text = ""
			return

		if pers.itenshotkey[int(self.name) - 1] != null:
			item = pers.itenshotkey[int(self.name) - 1]
			icon = item.imagem
			if item.tipo == "Arma de fogo": # arma de fogo
				$quantidade.text = str(item.qntatual)
			if item.tipo == "Consumivel": # consumível
				$quantidade.text = str(item.quantidade)

		skip = true


func _on_pressed() -> void:
	var index = get_index()
	pers.hotkey = index
	print("Selecionou slot ", index)
