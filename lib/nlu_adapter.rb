require "nlu_adapter/version"

module NluAdapter
	autoload :NluAdapterIntent, 'nlu_adapter/intent'
	autoload :NluAdapterIntentCollection, 'nlu_adapter/intent_collection'
	module Adapters
		autoload :Lex,					'nlu_adapter/lex'
		autoload :Dialogflow,			'nlu_adapter/dialogflow'
	end

	def self.new(name, options = {})
		aforadapter = Adapters.const_get(name).new(options)
	end
end
