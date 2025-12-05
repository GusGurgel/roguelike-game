extends Node
class_name FieldOfView

var game: Game
var fov_radius: int = 8  # Aumentei um pouco para testar melhor o efeito

# Armazena os tiles que estão atualmente visíveis para podermos 
# "apagá-los" antes de calcular o próximo frame.
var _visible_tiles: Array[Tile] = []

# Mapeamento de multiplicadores para transformar as coordenadas de cada octante
# para um sistema de coordenadas padrão (x positivo, y positivo)
const OCTANT_TRANSFORMS = [
	Vector2i(1, 0), Vector2i(0, 1),   # 0: E-NE
	Vector2i(0, 1), Vector2i(1, 0),   # 1: N-NE
	Vector2i(0, 1), Vector2i(-1, 0),  # 2: N-NW
	Vector2i(-1, 0), Vector2i(0, 1),  # 3: W-NW
	Vector2i(-1, 0), Vector2i(0, -1), # 4: W-SW
	Vector2i(0, -1), Vector2i(-1, 0), # 5: S-SW
	Vector2i(0, -1), Vector2i(1, 0),  # 6: S-SE
	Vector2i(1, 0), Vector2i(0, -1),  # 7: E-SE
]

## Chamado pelo Player. Agora só precisamos da nova posição.
## O sistema limpa automaticamente o estado anterior.
func update_fov(origin: Vector2i):
	# 1. Resetar tiles visíveis do frame anterior
	for tile in _visible_tiles:
		tile.is_in_view = false
	_visible_tiles.clear()

	# 2. O tile onde o jogador está é sempre visível
	_mark_visible(origin)

	# 3. Calcular FOV para os 8 octantes
	# O algoritmo processa um cone de 45 graus por vez
	for i in range(8):
		_cast_light(
			origin, 
			1, 
			1.0, 
			0.0, 
			OCTANT_TRANSFORMS[i * 2], 
			OCTANT_TRANSFORMS[i * 2 + 1]
		)

## Função recursiva que projeta a "luz"
## row: distância atual do jogador
## start_slope: inclinação inicial do feixe de luz (1.0 = diagonal)
## end_slope: inclinação final do feixe (0.0 = reto)
func _cast_light(origin: Vector2i, row: int, start_slope: float, end_slope: float, xx: Vector2i, xy: Vector2i):
	if start_slope < end_slope:
		return

	var next_start_slope = start_slope
	
	for i in range(row, fov_radius + 1):
		var blocked = false
		var dy = -i
		
		# Loop através das células na linha atual dentro dos slopes permitidos
		for dx in range(-i, 1): # dx vai de -row até 0 (no sistema transformado)
			# Cálculo das inclinações para a célula atual
			# Usamos 0.5 para simular o centro do tile
			var l_slope = (dx - 0.5) / (dy + 0.5)
			var r_slope = (dx + 0.5) / (dy - 0.5)
			
			if start_slope < r_slope:
				continue
			
			if end_slope > l_slope:
				break
			
			# Transforma a coordenada local do octante para coordenada global do mapa
			# A matemática aqui usa os vetores base passados (xx, xy) para rotacionar o grid
			var map_x = origin.x + (dx * xx.x + dy * xy.x)
			var map_y = origin.y + (dx * xx.y + dy * xy.y)
			var pos = Vector2i(map_x, map_y)
			
			# Distância euclidiana simples para garantir que o FOV seja circular e não quadrado
			if (dx * dx + dy * dy) < (fov_radius * fov_radius):
				_mark_visible(pos)
			
			var tile = game.get_tile(pos)
			
			if blocked:
				# Se estávamos bloqueados anteriormente e encontramos um tile transparente (buraco na parede)
				if tile and tile.is_transparent:
					blocked = false
					start_slope = next_start_slope
				else:
					next_start_slope = r_slope
					
			elif tile and not tile.is_transparent:
				# Se encontramos uma parede nova vindo de um espaço vazio
				blocked = true
				next_start_slope = r_slope
				# Recursão: Dispara um novo feixe de luz para a área transparente anterior
				_cast_light(origin, i + 1, start_slope, l_slope, xx, xy)
		
		if blocked:
			break

## Helper para marcar o tile e adicionar ao cache
func _mark_visible(pos: Vector2i):
	var tile: Tile = game.get_tile(pos)
	if tile:
		tile.is_in_view = true
		_visible_tiles.append(tile)
