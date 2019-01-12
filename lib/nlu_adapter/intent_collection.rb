require 'json'

# Class represents a collection of Intents
module NluAdapterIntentCollection
	attr_accessor :name, :intents

	# Constructor
	def initialize(name, intents)
		@name = name
		@intents = intents
	end

	# Convert self to Hash
	# @return [Hash] ruby hash
	#
	def to_h
		{
			:name => @name,
			:intents => @intents.map { |i| i.to_h }
		}
	end

	# Convert self to Json
	# @return [Json] json
	#
	def to_json
		to_h.to_json
	end
end
