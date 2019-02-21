require "ibm_watson/assistant_v1"


module NluAdapter
	module Adapters
		# IBM Watson Assistant wrapper class
		#
		class WatsonAssistant
			include ParseHelper

			include IBMWatson

			# Constructor
			def initialize(options = {})
				@url = options[:url] || "https://gateway-lon.watsonplatform.net/assistant/api"
				@version = options[:version] || "2018-09-20"
				@workspace_id = ENV["WATSON_WORKSPACE_ID"]
				begin
					@assistant = AssistantV1.new(
						iam_apikey: ENV["WATSON_API_KEY"],
						version: @version,
						url: @url
					)
				rescue WatsonApiException => ex
					puts "Error: #{ex.inspect}"
				end
			end

			# Understand a given text
			#
			# @param text [String] a text to parse using the NLU provider
			# @return [Json] return the identified intent name
			#
			def parse(text)
				intent_name = nil
				begin
					response = @assistant.message(
						workspace_id: @workspace_id,
						input: {
							text: text
						}
					)

					intent_name = response.result["intents"][0]["intent"]
				rescue WatsonApiException => ex
					puts "Error: #{ex.inspect}"
				end
				return { intent_name: intent_name}
			end

			# Get an instance of Intent, if it exists else nil
			#
			# @param name [String] name of the intent
			# @return [Intent] intent object
			#
			def get_intent(name)
				begin
					response = @assistant.get_intent(
						workspace_id: @workspace_id,
						intent: name,
						export: true
					)

					return Intent.new({id: response.result['intent'], #for is update check
						name: response.result['intent'],
						description: response.result['description'],
						utterences: response.result['examples'].map { |e| e['text']} })

				rescue WatsonApiException => ex
					puts "Error: #{ex.inspect}"
				end
				return nil
			end

			# Get a new instance of Intent
			#
			# @param name [String] name of the intent
			# @param utterences [Array] phrases for training
			# @return [Intent] Intent object
			#
			def new_intent(name, description, utterences = [])
				i = get_intent(name)

				i = Intent.new if !i
				i.name = name
				i.description = description
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
				#check: to create / update
				i = intent.to_h
				if !intent.id
					response = @assistant.create_intent(
						workspace_id: @workspace_id,
						intent: i[:name],
						description: i[:description],
						examples: i[:examples]
					)
				else
					response = @assistant.update_intent(
						workspace_id: @workspace_id,
						intent: intent.id,
						new_examples: i[:examples],
						new_description: i[:description],
						new_intent: i[:name]
					)

				end
			end


			# Class represents Intent in an IntentCollection
			class Intent
				include NluAdapterIntent
				attr_accessor :id, :description

				# Constructor
				def initialize(options = {})
					@id = options[:id] #check for is update
					@name = options[:name]
					@description = options[:description]
					@utterences = options[:utterences]
				end

				# Convert self to Hash
				# @return [Hash] ruby hash
				#
				def to_h
					{
						name: @name,
						description: @description,
						examples: @utterences.map {|u| {"text" => u } }
					}
				end

				# convert self to json
				# @return [json] json
				#
				def to_json
					to_h.to_json
				end

			end

		end
	end
end
