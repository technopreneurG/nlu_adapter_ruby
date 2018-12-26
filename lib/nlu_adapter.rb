require "nlu_adapter/version"

module NluAdapter
	autoload :NluAdapterIntent, './lib/nlu_adapter/intent'
	autoload :NluAdapterIntentCollection, './lib/nlu_adapter/intent_collection'
	module Adapters
		autoload :Lex,					'./lib/nlu_adapter/lex'
		autoload :Dialogflow,			'./lib/nlu_adapter/dialogflow'
	end

	def self.new(name, options = {})
		aforadapter = Adapters.const_get(name).new(options)
	end
end
