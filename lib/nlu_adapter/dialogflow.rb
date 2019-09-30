require "google/cloud/dialogflow"

module NluAdapter
	module Adapters
		# Dialogflow wrapper class
		#
		class Dialogflow
			include ParseHelper

			# Constructor
			def initialize(options = {})
				@project_id = options[:project_id]
				@session_id = options[:session_id]
			end

			# Understand a given text
			#
			# @param text [String] a text to parse using the NLU provider
			# @return [Json] return the identified intent name
			#
			def parse(text)
				sessions_client = Google::Cloud::Dialogflow::Sessions.new(version: :v2)
				formatted_session = Google::Cloud::Dialogflow::V2::SessionsClient.session_path(@project_id, @session_id)
				language_code = 'en'
				intent_name = nil

				query_input = Google::Cloud::Dialogflow::V2::QueryInput.new({text: {language_code: language_code, text: text}})
				response = sessions_client.detect_intent(formatted_session, query_input)

				unless response.nil? || response.query_result.nil? || response.query_result.intent.nil? || response.query_result.intent.display_name.empty?
					intent_name = response.query_result.intent.display_name
				end
				return { intent_name: intent_name }
			end

			# Get an instance of Intent, if it exists else nil
			#
			# @param name [String] name of the intent
			# @return [Intent] intent object
			#
			def get_intent(name)
				intents_client = Google::Cloud::Dialogflow::Intents.new(version: :v2)
				formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path(@project_id)

				#Iterate over all results.
				#todo: should be cached for better performance
				intents_client.list_intents(formatted_parent).each do |intent|
					if intent.display_name == name
						return Intent.new({id: intent.name, display_name: intent.display_name})
					end
				end
				return nil
			end

			# Get a new instance of Intent
			#
			# @param name [String] name of the intent
			# @param utterences [Array] phrases for training
			# @return [Intent] Intent object
			#
			def new_intent(name, utterences = [])
				i = get_intent(name)

				i = Intent.new if !i
				i.name = name
				i.utterences = utterences
				return i
			end

			# Given an Intent object, create/update it in Dialogflow
			#
			# @param intent [Intent] Intent object
			# @return [Intent] Intent object
			#
			# @todo convert response -> Intent
			#
			def create_intent(intent)
				intents_client = Google::Cloud::Dialogflow::Intents.new(version: :v2)
				formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path(@project_id)

				#check: to create / update
				if !intent.id
					i = intent.to_h
					response = intents_client.create_intent(formatted_parent, i)
				else
					i = intent.to_h
					language_code = 'en'
					response = intents_client.update_intent(i, language_code)
				end
			end

			# Not implemented
			# @todo check back
			#
			def get_intent_collection(name)
			end

			# Not implemented
			# @todo check back
			#
			def new_intent_collection(name, intents)
			end

			# Not implemented
			# @todo check back
			#
			def create_intent_collection(collection)
			end

			# Class represents Intent in an IntentCollection
			class Intent
				include NluAdapterIntent
				attr_accessor :id

				# Constructor
				def initialize(options = {})
					@name = options[:name] #DF.intent.display_name
					@id = options[:id] #DF.intent.name
					@utterences = options[:utterences]
				end

				# Convert self to Hash
				# @return [Hash] ruby hash
				#
				def to_h
					training_phrases = []
					@utterences.each do |u|
						training_phrases << {"type" => "EXAMPLE", "parts" =>[{"text" => u }]}
					end

					{
						name: @id,
						display_name: @name,
						training_phrases: training_phrases
					}
				end

				# convert self to json
				# @return [json] json
				#
				def to_json
					to_h.to_json
				end

			end

			# Class represents a collection of Intents
			class IntentCollection
				include NluAdapterIntentCollection

				# Constructor
				def initialize(options = {})
				end

				# Convert self to Hash
				# @return [Hash] ruby hash
				#
				def to_h
				end

				# convert self to json
				# @return [json] json
				#
				def to_json
				end
			end

		end
	end
end
