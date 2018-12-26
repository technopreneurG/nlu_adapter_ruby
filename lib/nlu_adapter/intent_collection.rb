require 'json'

#Class represents a collection of Intents
module NluAdapterIntentCollection
	attr_accessor :name, :intents

	def initialize(name, intents)
		@name = name
		@intents = intents
	end

	def to_h
		{
			:name => @name,
			:intents => @intents.map { |i| i.to_h }
		}
	end

	def to_json
		to_h.to_json
	end
end
