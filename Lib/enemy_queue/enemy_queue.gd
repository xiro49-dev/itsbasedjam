extends Marker3D
class_name EnemyQueue

var queue = []

func init():
	queue = []
	for child in get_children():
		if child.type == Enums.EnemyTypes.Chase:
			child.can_attack = false
			queue.append(child)
	if queue != []:
		queue[0].can_attack = true
	
func shuffle():
	queue.shuffle()
	if len(queue) > 0:
		queue[0].can_attack = true
	for child in range(1, len(queue)-1):
		if queue[child].type == Enums.EnemyTypes.Chase:
			queue[child].can_attack = false
