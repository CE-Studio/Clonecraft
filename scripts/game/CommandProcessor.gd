extends Node
class_name CMDprocessor

class Command extends RefCounted:
	func getCommandInvocation() -> String:
		return "__invalid__"
	
	
	func getCommandArgList(index:int) -> Array:
		return []
	
	
	func exectue(args:Array) -> Variant:
		return null


static var commands:Array[Command] = []


static func registerCommand(command:Command) -> void:
	commands.append(command)


static func throw(error:String):
	pass
