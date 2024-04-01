extends Node
class_name CMDprocessor


static var vars := {}
static var _thrown := false


class Command extends RefCounted:
	func getCommandInvocation() -> String:
		return "__invalid__"
	
	
	func getCommandArgList(index:int) -> Array:
		return []
	
	
	func exectue(args:Array) -> Variant:
		return null


static var commands:Array[Command] = []


static func run(con:String) -> Variant:
	con = con.strip_edges()
	var scon:Array = con.split("\n")
	if scon.size() == 0:
		return
	if scon.size() > 1:
		var outs := []
		for i in scon:
			outs.append(run(i))
		return outs
	scon = scon[0].split(";")
	if scon.size() > 1:
		var outs := []
		for i in scon:
			outs.append(run(i))
		return outs
	con = scon[0]
	
	var tokens := _extTokens(con)
	if _thrown:
		return
	print(tokens)
	
	return _run(tokens)


static func _run(tokens:Array) -> Variant:
	for i in tokens.size():
		if tokens[i] is Array:
			tokens[i] = _run(tokens[i])
			if _thrown:
				return
		if tokens[i] is String:
			print(tokens[i])
			if tokens[i][0] == "$":
				var j = tokens[i].erase(0, 1)
				if j[-1] == "=":
					pass
				elif vars.has(j):
					tokens[i] = vars[j]
				else:
					throw("cmd.error.undefined_var")
	return


static func _extTokens(con:String) -> Array:
	var tokens:Array = []
	var depth:int = 0
	var innerd := ""
	var insideStr := false
	var escaped := false
	for i in con.length():
		if depth > 0:
			if escaped:
				escaped = false
				innerd += con[i]
			else: match con[i]:
				"\"":
					insideStr = !insideStr
				"(" when !insideStr:
					depth += 1
					innerd += "("
				")" when !insideStr:
					depth -= 1
					if depth == 0:
						if (tokens.size() == 0) or (not (tokens[-1] is String)) or (tokens[-1] != ""):
							tokens.append(_extTokens(innerd))
						else:
							tokens[-1] = _extTokens(innerd)
						if _thrown:
							return []
					else:
						innerd += ")"
				"\\" when !insideStr:
					escaped = true
					innerd += "\\"
				_:
					innerd += con[i]
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
				innerd = ""
				depth = 1
			")" when !insideStr:
				throw("cmd.error.unblanced")
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
		throw("cmd.error.unbalanced")
		return []
	if insideStr:
		throw("cmd.error.unbalanced_string")
		return []
	return tokens


static func registerCommand(command:Command) -> void:
	commands.append(command)


static func throw(error:String):
	BlockManager.log("Command Processor", Translator.translate(error))
	_thrown = true
