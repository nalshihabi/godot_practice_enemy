extends KinematicBody2D

#-----------------------------------------------------
# Numeric constants
const BASE_SPEED = 100
const JUMP_FORCE = -1000
const GRAVITY = 9.8
const WEIGHT = 20
const EPSILON = 1
const BODY_HITBOX_OFFSET = 8.428
const BASE_RANGE = 120

#-----------------------------------------------------
# String constants
# Animation states
const RUNNING = "Running"
const IDLE = "Idle"
const ATTACK = "Attack"

# Input keys
const LEFT = "left"
const RIGHT = "right"
const SAME = "same"
const JUMP = "jump"
const SELECT = "select"

# Enemy State
const STATE_NO_ATTACK = "NO ATTACK"
const STATE_ATTACK = "ATTACK"

#-----------------------------------------------------
# Member Variables
var dir = 1
var velocity
var state = STATE_NO_ATTACK
var last_x

#-----------------------------------------------------
# Member methods
func flip(new_dir):
	# $Sprite.flip_h = false if new_dir == 1 else true
	print("calling flip ", new_dir, " ", dir, " ", self.scale.x)
	self.scale.x *= -1 if new_dir != dir else 1
	dir = new_dir

func set_running():
	# $Sprite.animation = RUNNING
	pass

func attack():
	state = STATE_ATTACK
	# $Sprite.play(ATTACK)

func calcGravity():
	return WEIGHT * GRAVITY

func get_move_direction(target):
	# print("currently ", self.position.x, " tar ", target.position.x)
	if self.position.x < target.position.x:
		return RIGHT
	elif self.position.x > target.position.x:
		return LEFT
	else:
		return SAME
	# return RIGHT if self.position.x < target.position.x else LEFT if self.position.x != target.position.x else SAME

func distance(pos1, pos2):
	var total = 0.0
	for i in range(pos1.length):
		total += (pos1[i] - pos2[i]) * (pos1[i] - pos2[i])

	return sqrt(total)

func speed():
	return BASE_SPEED if dir == RIGHT else -BASE_SPEED

func turn_if_needed(direction):
	# print("Player Direction ", direction, " FACING ", dir)
	if direction == LEFT and not dir == LEFT:
		flip(LEFT)
	elif direction == RIGHT and not dir == RIGHT:
		flip(RIGHT)

func in_range(target):
	return self.position.distance_to(target.position) <= abs(BASE_RANGE)

func move_or_attack(target):
	if in_range(target):
		print("got here")
		state = STATE_ATTACK
		$AnimationPlayer.play(ATTACK)
		print("doing attack")
		return Vector2(0, 0)
	else:
		var y = 0
		# if abs(self.position.x - last_x) <= EPSILON and is_on_floor():
		# 	print("calling jump ", JUMP_FORCE)
		# 	y = JUMP_FORCE
		# else:
		# 	print("??? ", self.position.x, " ", last_x, " ", is_on_floor())
		$AnimationPlayer.play(RUNNING)
		return Vector2(speed(), y)

#-----------------------------------------------------
# Internal methods
func _ready():
	velocity = Vector2()
	state = STATE_NO_ATTACK
	last_x = self.position.x
	dir = LEFT if self.scale.x > 0 else RIGHT
	$AnimationPlayer.play(IDLE)
	$Hurtbox.disabled = true

func _physics_process(_delta):
	var player = get_node("../PlayerCharacter")
	if $AnimationPlayer.is_playing():
		# print("playing attack")
		pass
	else:
		print("not playing attack")

	if state == STATE_NO_ATTACK:
		var direction = get_move_direction(player)
		if direction != SAME:
			turn_if_needed(direction)
			var nv = move_or_attack(player)
			# print("nv", nv)
			velocity += nv
		else:
			pass

	velocity.y += calcGravity()
	if abs(velocity.x) <= EPSILON and not state == STATE_ATTACK:
		velocity.x = 0
		$AnimationPlayer.play(IDLE)

	var s = move_and_collide(Vector2(velocity.x, 0), true, true, true)
	if s != null and not in_range(player) and is_on_floor() and s.remainder.x != 0:
		velocity = move_and_slide(Vector2(velocity.x / 4, JUMP_FORCE), Vector2.UP)
	else:
		velocity = move_and_slide(velocity, Vector2.UP)

	# velocity = move_and_slide(velocity, Vector2.UP)
	# if abs(self.position.x - last_x) <= EPSILON and is_on_floor():
	# 	var jump = Vector2(0, JUMP_FORCE)
	# 	velocity = move_and_slide(jump + velocity, Vector2.UP)
	# else:
	# 	print("why am i here ", self.position.x, " ", last_x)
	last_x = self.position.x

	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, .6)

func _on_animation_player_finished(anim_name):
	print("here????? ", anim_name)
	if anim_name == ATTACK:
		state = STATE_NO_ATTACK
		$AnimationPlayer.play(IDLE)
