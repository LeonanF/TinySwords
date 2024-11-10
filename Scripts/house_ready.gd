extends Node2D

func _process(delta):
	# Ajuste o Z-Index de todos os filhos (ou um grupo específico de objetos)
	adjust_z_index()

func adjust_z_index():
	# Para cada filho (ou qualquer grupo de objetos), ajusta o Z-Index com base na posição Y
	for child in get_children():
		if child is Sprite2D:  # Verifica se o filho é um Sprite
			adjust_sprite_z_index(child)

		# Se o filho for outro tipo de nó com Sprite (por exemplo, um KinematicBody2D ou Area2D), pode ser necessário verificar o Sprite dentro dele
		elif child is Node2D:
			var sprite = child.get_node("Sprite")  # Supondo que o Sprite esteja dentro do Node2D
			if sprite:
				adjust_sprite_z_index(sprite)

func adjust_sprite_z_index(sprite: Sprite2D):
	# Ajuste do Z-Index baseado na posição Y (quanto maior o Y, mais embaixo na tela)
	sprite.z_index = int(sprite.position.y * -1)  # Multiplica por -1 para garantir que objetos mais embaixo têm Z-Index maior
