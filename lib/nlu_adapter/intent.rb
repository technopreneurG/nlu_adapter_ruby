require 'json'

#Class represents Intent in an IntentCollection
module NluAdapterIntent
	attr_accessor :name, :utterences

	# Convert self to Hash
	# @return [Hash] ruby hash
	#
	def to_h
		{
			:name => @name,
			:utterences => @utterences
		}
	end

	# Convert self to Json
	# @return [Json] json
	#
	def to_json
		to_h.to_json
	end
end
