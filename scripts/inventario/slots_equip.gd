extends HBoxContainer

@onready var UI: Control = get_tree().get_root().get_node("main/pers/UI")
@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers")
@onready var titulo: Label = $VBoxContainer/titulo
@onready var item: Label = $VBoxContainer/item
@onready var botao: Button = $Button
var hover: bool = false

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


func _gui_input(event: InputEvent) -> void:
	if event.button_mask == 1 and hover == true: # BOTÃO ESQUERDO
		
		
		print("clicou botão esquerdo")
	elif event.button_mask == 2 and hover == true: # BOTÃO DIREITO
		$popup.clear()
		$popup.add_item("Desequipar")
		$popup.add_item("Largar")
		for i in range($popup.item_count):
			$popup.set_item_metadata(i, pers.slots[indice])
		$popup.popup()
		$popup.position = get_global_mouse_position() - Vector2(($popup.size.x / 2), 0)
		print("submenu botão direito")


# desequipar item do slot quando clicar com o botão direito
#func _on_button_pressed() -> void:
	#for i in pers.slots:
		#if i == str(self.name) and pers.slots[i] != null:
			#pers.slots[i] = null
			#UI.atualizarequipUI()
			#UI.atualizarinventarioUI()
			#UI.atualizarhudUI()



func _on_popup_id_pressed(id: int) -> void:
	var aux = $popup.get_item_text(id)
	var metadata = $popup.get_item_metadata(id)
	
	prints(aux, metadata) # isso aqui, onde deveria imprimir o metadata, tá imprimindo <null>
	if aux == "Desequipar":
		
		# checar se tem espaço antes de desequipar
		if pers.slots["mochila"] == null or pers.slots["mochila"].itens_guardados.size() >= pers.slots["mochila"].slots_mochila:
			print("não tem espaço pra desequipar")
			return
			
		# remover do equipamento
		for i in pers.slots:
			if pers.slots[i] == metadata:
				print("desequipou")
				pers.slots["mochila"].itens_guardados.append(pers.slots[i])
				pers.slots[i] = null
		
		UI.atualizarequipUI()
		UI.atualizarinventarioUI()
				
	if aux == "Largar":
		
		#remover item do equipamento (porque ele não fica mais no inventario)
		for i in pers.slots:
			if pers.slots[i] == metadata:
				pers.largar_item(pers.slots[i])
				print("ok")
				pers.atualizarstatus()
				UI.atualizarequipUI()
				UI.atualizarinventarioUI()
		return

		
		print("rodou todos loops, atualizando UI e status")
		pers.atualizarstatus()
		UI.atualizarequipUI()
		UI.atualizarinventarioUI()

func hover_on() -> void:
	print("on")
	hover = true


func hover_off() -> void:
	print("off")
	hover = false
