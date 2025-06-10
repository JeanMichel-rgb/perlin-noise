extends Node

var seed : float = randi()+randf()
@export var side : int
@export var density : int
@export var details : int
@export var scale : float

#side is an exponent of 2
#density is an exponent of 2
#density-details >= 0
#side > density

func _ready() -> void:
	draw_map_2D(perlin(seed, pow(2, side), pow(2, density), details))

func perlin(world_seed : float, map_side : int, base_gradient_grid_side : int, quantitie : int):
	seed = world_seed
	var map : Array = create_map(map_side)
	var nosq : int = map_side/base_gradient_grid_side #number of square on one gradient grid's line
	var ls : int = base_gradient_grid_side #number of pixels on one gradient grid's square
	var intensity : float = 1
	for time in quantitie:
		map = make_a_perlin(map, vetor_angle(ls, nosq), map_side, ls, nosq, intensity)
		ls /= 2
		nosq *= 2
		intensity /= 2
	return map

func create_map(side):
	var map : Array = []
	for i in pow(side, 2):
		map.append(0)
	return map

func vetor_angle(ls : int, nosq : int):
	var gradients_angles : Array = []
	for y in nosq+1 :
		for x in nosq+1 :
			gradients_angles.append(pseudo_random_rad())
	return gradients_angles

func make_a_perlin(global_map : Array, gradient_angle : Array, map_side : int, ls : float, nosq : int, intensity : float):
	var gradient : Array = gradient_angle
	var map : Array = global_map
	var A = -1
	for square_y in nosq:
		for y in ls:
			for square_x in nosq:
				for x in ls:
					A += 1
					#get angles
					var ang_a : float = gradient[square_y*(nosq+1) + square_x]
					var ang_b : float = gradient[square_y*(nosq+1) + square_x + 1]
					var ang_c : float = gradient[square_y*(nosq+1) + square_x + nosq+1]
					var ang_d : float = gradient[square_y*(nosq+1) + square_x + nosq+2]
					#dot product
					var a : float = ((x/(ls-1)) * cos(ang_a) + y/(ls-1) * sin(ang_a))
					var b : float = (((x-ls)/(ls-1)) * cos(ang_b) + y/(ls-1) * sin(ang_b))
					var c : float = ((x/(ls-1)) * cos(ang_c) + (y-ls)/(ls-1) * sin(ang_c))
					var d : float = (((x-ls)/(ls-1)) * cos(ang_d) + (y-ls)/(ls-1) * sin(ang_d))
					#set interpollation's coefficient
					var t : float = ease_in_out_quad(x/ls)
					var g : float = ease_in_out_quad(y/ls)
					#interpolate dot products
					var pixel_value : float = interpolation(a,b,c,d,t,g)*intensity
					#store the value in map
					map[A] += pixel_value
	return map

func ease_in_out_quad(x):
	return (x*x*(3-(2*x)))

func interpolation(a,b,c,d,t,g):
	
	return a+g*(c-a)+t*(b-a+g*(d-c-b+a))
	
	#all in one
	#
	#return (1-pow((y/l),2)*(3-(2*y/l)))*(x/(l-1) * sin(ang_a) + y/(l-1) * cos(ang_a))+pow((y/l),2)*(3-(2*y/l))*(x/(l-1) * sin(ang_c) + -(l-y)/(l-1) * cos(ang_c))+pow((x/l),2)*(3-(2*x/l))*((-(l-x)/(l-1) * sin(ang_b) + y/(l-1) * cos(ang_b))-(x/(l-1) * sin(ang_a) + y/(l-1) * cos(ang_a))+pow((y/l),2)*(3-(2*y/l))*((-(l-x)/(l-1) * sin(ang_d) + -(l-y)/(l-1) * cos(ang_d))-(x/(l-1) * sin(ang_c) + -(l-y)/(l-1) * cos(ang_c))-(-(l-x)/(l-1) * sin(ang_b) + y/(l-1) * cos(ang_b))+(x/(l-1) * sin(ang_a) + y/(l-1) * cos(ang_a))))

func pseudo_random_rad():
	var A = pow(2,32)
	seed = fmod((1664525*seed + 1013904223), A)
	return 2*PI*seed/A

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout

func draw_map_2D(map : Array):
	var tiles_size : float = scale
	var side : int = sqrt(map.size())
	for y in side:
		for x in side:
			var meshinstance : MeshInstance2D = MeshInstance2D.new()
			var mesh : QuadMesh = QuadMesh.new()
			meshinstance.mesh = mesh
			mesh.size = Vector2(1,1) * tiles_size
			meshinstance.modulate = Color(1,1,1) * (map[y*side + x])  +  Color(0,0,0,1)
			meshinstance.position = mesh.size/2 + Vector2(x,y) * tiles_size
			$map_2D.add_child(meshinstance)
