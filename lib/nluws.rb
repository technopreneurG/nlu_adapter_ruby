
module NLUWS
	module Adapters
		autoload :Lex,					'../lib/nluws/lex'
		autoload :Dialogflow,			'../lib/nluws/dialogflow'
	end

	def self.new(name, options = {})
	    aforadapter = Adapters.const_get(name).new(options)
	end
end
