import Commandant
import Result

let commandRegistry = CommandRegistry<AnyError>()
commandRegistry.register(OkCommand())
commandRegistry.register(HelpCommand(registry: commandRegistry))
commandRegistry.main(defaultVerb: "help") { error in print(error) }
