extends Button

@export var item_slot: Resource
@onready var pers = $"../../../.."

@onready var slot = int(self.name) - 1
var slotvazio = preload("res://pngs/vazio.png")
func _ready() -> void:
	$nome_slot.text = self.name

func _process(_delta: float) -> void:
	if pers.hotkey == slot and pers.equipado == true:
		$ColorRect.show()
	else: 
		$ColorRect.hide()
	
	
	if item_slot == null:
		icon = slotvazio
		$quantidade.text = ""
		return
	
	if item_slot != null:
		icon = item_slot.imagem

	if item_slot.tipo == "Arma de fogo": # arma de fogo
		$quantidade.text = str(item_slot.qntatual, "/", item_slot.qntreserva)
	elif item_slot.tipo == "Consumivel": # consumível
		$quantidade.text = str(item_slot.qntreserva)
	else:
		$quantidade.text = ""


func _on_pressed() -> void:
	var index = get_index()
	pers.hotkey = index
	print("Selecionou slot ", index)
	
func limpar():
	item_slot = null
	$quantidade.text = ""
	icon = null
