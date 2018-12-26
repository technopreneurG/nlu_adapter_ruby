require "google/cloud/dialogflow"

module NLUWS
	module Adapters
		class Dialogflow
			def initialize(options = {})
				@project_id = options[:project_id]
				@session_id = options[:session_id]
			end

			def parse(text, language_code = 'en')
				sessions_client = Google::Cloud::Dialogflow::Sessions.new(version: :v2)
				formatted_session = Google::Cloud::Dialogflow::V2::SessionsClient.session_path(@project_id, @session_id)
				query_input = Google::Cloud::Dialogflow::V2::QueryInput.new({text: {language_code: language_code, text: text}})
				response = sessions_client.detect_intent(formatted_session, query_input)
				response.query_result.intent.display_name
			end

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

			def new_intent(name, utterences = [])
				i = get_intent(name)

				i = Intent.new if !i
				i.name = name
				i.utterences = utterences
				return i
			end

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

			def get_intent_collection(name)
			end

			def new_intent_collection(name, intents)
			end

			def create_intent_collection(collection)
			end

			class Intent
				include NLUWSIntent
				attr_accessor :id

				def initialize(options = {})
					@name = options[:name] #DF.intent.display_name
					@id = options[:id] #DF.intent.name
					@utterences = options[:utterences]
				end

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

				def to_json
					to_h.to_json
				end

			end

			class IntentCollection
				include NLUWSIntentCollection

				def initialize(options = {})
				end

				def to_h
				end

				def to_json
				end
			end

		end
	end
end
