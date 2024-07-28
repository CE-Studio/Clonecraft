extends Node
class_name CMDprocessor


static var instance:CMDprocessor
static var vars := {}
static var _thrown := false
static var _err:String
static var _whyerr:String
static var _calledByPlayer := false


class Command extends RefCounted:
	func getCommandInvocation() -> String:
		return "__invalid__"
	
	
	func getCommandArgList(_index:int) -> Array:
		return []
	
	
	func execute(_args:Array) -> Variant:
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
				if i.getCommandInvocation() == tokens[0]:
					var outp = i.execute(tokens.slice(1))
					if _thrown:
						if _calledByPlayer:
							Chat.pushText(
								Translator.translate(_err) + ": " + _whyerr + "\n" +
								"In command: " + str(tokens)
							)
						return
					return outp
	else:
		return tokens
	return false


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
				throw("cmd.error.unblanced", "Unexpected closing parenthesis in token set \"" + con + "\"")
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


static func registerCommand(command:Command) -> void:
	commands.append(command)


static func throw(error:String, why:String):
	_err = error
	_whyerr = why
	_thrown = true
	BlockManager.log("Command Processor", Translator.translate(error) + " For reason: " + why)


class _helpCMD extends Command:
	func getCommandInvocation() -> String:
		return "help"
		
	func getCommandArgList(_index:int) -> Array:
		return []
		
	func execute(_args:Array) -> Variant:
		if _args.size() > 0:
			CMDprocessor.throw("cmd.error.too_many_args", "Expected 0 arguments, got " + str(_args.size()))
		var h := "Help: " + str(CMDprocessor.commands.size()) + " command(s) found"
		for i in CMDprocessor.commands:
			h += "\n  - " + i.getCommandInvocation() + " "
			for j in i.getCommandArgList(-1):
				h += str(j) + " "
		return h


func _ready():
	instance = self
	CMDprocessor.registerCommand(_helpCMD.new())
