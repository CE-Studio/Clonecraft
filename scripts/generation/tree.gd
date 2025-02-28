extends RefCounted
class_name TreeDefinition

#A: air
#L: log
#F: leaf
#f: leaf (50%)
const DEFAULT_TREE := {
	&"log_vert": &"clonecraft:logVertOak",
	&"leaf": &"clonecraft:leavesOak",
	&"layers": [
		{
			&"min": 2, &"max":4, &"branch_chance": 0.0, &"data": [
				["A", "A", "A", "A", "A"],
				["A", "A", "A", "A", "A"],
				["A", "A", "L", "A", "A"],
				["A", "A", "A", "A", "A"],
				["A", "A", "A", "A", "A"],
			]
		},
		{
			&"min": 2, &"max":2, &"branch_chance": 0.0, &"data": [
				["f", "F", "F", "F", "f"],
				["F", "F", "F", "F", "F"],
				["F", "F", "L", "F", "F"],
				["F", "F", "F", "F", "F"],
				["f", "F", "F", "F", "f"],
			]
		},
		{
			&"min": 1, &"max":1, &"branch_chance": 0.0, &"data": [
				["A", "A", "A", "A", "A"],
				["A", "f", "F", "f", "A"],
				["A", "F", "L", "F", "A"],
				["A", "f", "F", "f", "A"],
				["A", "A", "A", "A", "A"],
			]
		},
		{
			&"min": 1, &"max":1, &"branch_chance": 0.0, &"data": [
				["A", "A", "A", "A", "A"],
				["A", "A", "F", "A", "A"],
				["A", "F", "F", "F", "A"],
				["A", "A", "F", "A", "A"],
				["A", "A", "A", "A", "A"],
			]
		},
	],
}
