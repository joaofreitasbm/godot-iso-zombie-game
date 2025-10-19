extends HBoxContainer

@onready var UI: Control = get_tree().get_root().get_node("main/pers/UI")
@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers")
@onready var titulo: Label = $VBoxContainer/titulo
@onready var item: Label = $VBoxContainer/item
@onready var botao: Button = $Button

var skip: bool = false
var slotvazio: Resource = preload("res://pngs/vazio.png")
var indice: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	indice = self.name
	titulo.text = indice.capitalize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !skip:
		for i in pers.slots:
			print(i)
			if i == str(self.name) and pers.slots[i] == null:
				item.text = "Vazio"
				item.add_theme_color_override("font_color", Color(0.248, 0.248, 0.248, 1.0))
				botao.icon = slotvazio
				
			if i == str(self.name) and pers.slots[i] != null:
				item.text = pers.slots[i].nome_item
				item.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
				botao.icon = pers.slots[i].imagem
			
			if "hotkey" in i and str(self.name) == i:
				item.text = ""
				titulo.text = ""
				
	skip = true


# desequipar item do slot
func _on_button_pressed() -> void:
	for i in pers.slots:
		if i == str(self.name) and pers.slots[i] != null:
			pers.slots[i] = null
			UI.atualizarequipUI()
			UI.atualizarhudUI()
	pass # Replace with function body.
