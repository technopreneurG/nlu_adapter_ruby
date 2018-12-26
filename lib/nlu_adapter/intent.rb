require 'json'

#Class represents Intent in an IntentCollection
module NluAdapterIntent
	attr_accessor :name, :utterences

	def to_h
		{
			:name => @name,
			:utterences => @utterences
		}
	end

	def to_json
		to_h.to_json
	end
end
