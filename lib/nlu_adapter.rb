require "nlu_adapter/version"

module NluAdapter
	autoload :NluAdapterIntent, 'nlu_adapter/intent'
	autoload :NluAdapterIntentCollection, 'nlu_adapter/intent_collection'
	autoload :ParseHelper, 'nlu_adapter/parse_helper'
	autoload :Metrics, 'nlu_adapter/metrics'
	module Adapters
		autoload :Lex,				'nlu_adapter/lex'
		autoload :Dialogflow,			'nlu_adapter/dialogflow'
		autoload :WatsonAssistant,		'nlu_adapter/watson_assistant'
	end

	def self.new(name, options = {})
		aforadapter = Adapters.const_get(name).new(options)
	end
end
