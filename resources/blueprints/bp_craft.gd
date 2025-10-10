extends Resource
class_name craft

# Receita de craft. Vai ser adicionado ao inventário, pra aparecer na aba
# de fabricação.

#propriedades gerais
@export var nome_item: String
@export_multiline var desc: String
@export var material_necessario: Array[Resource]
@export var ferramenta_necessaria: Array[Resource]
@export var bancada: bool
@export_enum (
	"Geral", 
	"Marcenaria", 
	"Alvenaria",
	"Cozinha",
	"Primeiros socorros",
	"Mecanica",
	"Metalurgia") var tipo: String
@export var item_craftado: Resource
@export var craftavel: bool
# adicionar variavel que acrescenta experiencia baseada na variavel tipo
# se tipo == Marcenaria, adiciona x exp na habilidade marcenaria.

func checar(pers, UI):
	for x in material_necessario: # Iteração sobre cada item necessario
		for y in pers.inventario: # Iteração sobre cada item do inventario
			if x.qntreserva >= y.qntreserva: # se qnt material necessario >= item do inventario
				y.qntreserva -= x.qntreserva # qnt do item no inventario é subtraida pela qnt necessaria
				for slot in UI.get_children(): # esse trecho do código precisa pegar o nodo UI, pra chamar a função atualizarinventarioUI()
					if slot is PanelContainer and slot.item == null:
						slot.item = item_craftado
						slot.skip = false
						pers.inventario[int(slot.name) - 1] = item_craftado
						if y.qntreserva == 0: # Se não sobrar mais nenhuma quantidade do item no inventario:
							y = null # item é removido do inventário
			if x.qntreserva < y.qntreserva:
				print("material não suficiente")


func fabricar(pers):
	for i in pers.inventario:
		# Se i =
		pass
	pass
	
