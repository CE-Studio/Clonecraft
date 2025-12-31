extends Node
class_name CMDprocessor


static var instance:CMDprocessor
static var vars := {}
static var _thrown := false
static var _err:String
static var _why_err:String
static var _called_by_player := false


static func _reset() -> void:
	instance = null
	vars = {}
	_thrown = false
	_err = ""
	_why_err = ""
	_called_by_player = false


class Command extends RefCounted:
	func get_command_invocation() -> String:
		return "__invalid__"
	
	
	func get_command_arg_list(_index:int) -> Array:
		return []
	
	
	func execute(_args:Array) -> Variant:
		return null


static var commands:Array[Command] = []


static func run(con:String) -> Variant:
	con = con.strip_edges()
	var split_con:Array = con.split("\n")
	if split_con.size() == 0:
		return
	if split_con.size() > 1:
		var outs := []
		for i in split_con:
			outs.append(run(i))
		return outs
	split_con = split_con[0].split(";")
	if split_con.size() > 1:
		var outs := []
		for i in split_con:
			outs.append(run(i))
		return outs
	con = split_con[0]
	
	var tokens := _ext_tokens(con)
	if _thrown:
		_thrown = false
		return
	
	var k = _run(tokens)
	if _thrown:
		_thrown = false
	return k


static func _run(tokens:Array) -> Variant:
	for i in tokens.size():
		if tokens[i] is Array:
			tokens[i] = _run(tokens[i])
			if _thrown:
				return
		if tokens[i] is String:
			if tokens[i][0] == "$":
				var j = tokens[i].erase(0, 1)
				if j[-1] == "=":
					pass
				elif vars.has(j):
					tokens[i] = vars[j]
				else:
					throw("cmd.error.undefined_var", "No variable named \"" + j + "\" exists")
	if (tokens.size() > 0) and (tokens[0] is String):
		if (tokens[0][0] == "$") and (tokens[0][-1] == "="):
			if tokens.size() == 1:
				throw("cmd.error.missing_arg", "Missing value to assign to variable \"" + tokens[0] + "\"")
				return
			var h = tokens[0].replace("$", "").replace("=", "")
			vars[h] = tokens[1]
			return tokens[1]
		else:
			for i in commands:
				if i.get_command_invocation() == tokens[0]:
					var output = i.execute(tokens.slice(1))
					if _thrown:
						if _called_by_player:
							Chat.push_text(
								Translator.translate(_err) + ": " + _why_err + "\n" +
								"In command: " + str(tokens)
							)
						return
					return output
	else:
		return tokens
	return false


static func _ext_tokens(con:String) -> Array:
	var tokens:Array = []
	var depth:int = 0
	var inner_data := ""
	var insideStr := false
	var escaped := false
	for i in con.length():
		if depth > 0:
			if escaped:
				escaped = false
				inner_data += con[i]
			else: match con[i]:
				"\"":
					insideStr = !insideStr
				"(" when !insideStr:
					depth += 1
					inner_data += "("
				")" when !insideStr:
					depth -= 1
					if depth == 0:
						if (tokens.size() == 0) or (not (tokens[-1] is String)) or (tokens[-1] != ""):
							tokens.append(_ext_tokens(inner_data))
						else:
							tokens[-1] = _ext_tokens(inner_data)
						if _thrown:
							return []
					else:
						inner_data += ")"
				"\\" when !insideStr:
					escaped = true
					inner_data += "\\"
				_:
					inner_data += con[i]
		elif escaped:
			escaped = false
			if tokens.size() == 0:
				tokens.append("")
			if not (tokens[-1] is String):
				tokens.append("")
			tokens[-1] += con[i]
		else: match con[i]:
			"\"":
				insideStr = !insideStr
			"(" when !insideStr:
				inner_data = ""
				depth = 1
			")" when !insideStr:
				throw("cmd.error.unbalanced", "Unexpected closing parenthesis in token set \"" + con + "\"")
				return []
			"\\":
				escaped = true
			" " when !insideStr:
				if (tokens.size() == 0) or (not (tokens[-1] is String)) or (tokens[-1] != ""):
					tokens.append("")
			_:
				if tokens.size() == 0:
					tokens.append("")
				if not (tokens[-1] is String):
					tokens.append("")
				tokens[-1] += con[i]
	if depth > 0:
		throw("cmd.error.unbalanced", "Imbalanced parenthesis in token set \"" + con + "\"")
		return []
	if insideStr:
		throw("cmd.error.unbalanced_string", "Unterminated string in token set \"" + con + "\"")
		return []
	return tokens


static func register_command(command:Command) -> void:
	commands.append(command)


static func throw(error:String, why:String) -> void:
	_err = error
	_why_err = why
	_thrown = true
	BlockManager.log("Command Processor", Translator.translate(error) + " For reason: " + why)


class _helpCMD extends Command:
	func get_command_invocation() -> String:
		return "help"
		
	func get_command_arg_list(_index:int) -> Array:
		return []
		
	func execute(_args:Array) -> Variant:
		if _args.size() > 0:
			CMDprocessor.throw("cmd.error.too_many_args", "Expected 0 arguments, got " + str(_args.size()))
		var h := "Help: " + str(CMDprocessor.commands.size()) + " command(s) found"
		for i in CMDprocessor.commands:
			h += "\n  - " + i.get_command_invocation() + " "
			for j in i.get_command_arg_list(-1):
				h += str(j) + " "
		return h


func _ready():
	instance = self
	CMDprocessor.register_command(_helpCMD.new())
