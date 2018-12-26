
module NLUWS
	autoload :NLUWSIntent, 'nluws/intent'
	autoload :NLUWSIntentCollection, 'nluws/intent_collection'
	module Adapters
		autoload :Lex,					'nluws/lex'
		autoload :Dialogflow,			'nluws/dialogflow'
	end

	def self.new(name, options = {})
	    aforadapter = Adapters.const_get(name).new(options)
	end
end
