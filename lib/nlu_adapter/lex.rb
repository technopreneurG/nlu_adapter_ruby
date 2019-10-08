require 'aws-sdk-lex'
require 'aws-sdk-lexmodelbuildingservice'

module NluAdapter
	module Adapters
		# AWS Lex wrapper class
		class Lex
			include ParseHelper

			# Constructor
			def initialize(options = {})
				#creds & region from config/env
				@bot_name = options[:bot_name]
				@bot_alias = options[:bot_alias]
				@user_id = options[:user_id]
				@lex_client = Aws::Lex::Client.new()
				@lexm_client = Aws::LexModelBuildingService::Client.new()
			end

			# Understand a given text
			#
			# @param text [String] a text to parse using the NLU provider
			# @return [Json] return the identified intent name
			#
			def parse(text)
				intent_name = :NO_INTENT_FOUND
				begin
					resp = @lex_client.post_text({
						bot_name: @bot_name, # required
						bot_alias: @bot_alias, # required
						user_id: @user_id, # required
						session_attributes: {
							"String" => "String",
						},
						request_attributes: {
							"String" => "String",
						},
						input_text: text, # required
					})

					unless resp.intent_name.nil? || resp.intent_name.empty?
						intent_name = resp.intent_name  #=> String
					end
				rescue Aws::Lex::Errors::ServiceError => e
					puts "Error: #{e.inspect}"
				end
				return { intent_name: intent_name }
			end

			# Get an instance of Intent, if it exists else nil
			#
			# @param name [String] name of the intent
			# @param version [String] version of the intent
			# @return [Intent] intent object
			#
			def get_intent(name, version = nil)
				version = '$LATEST'

				begin
					resp = @lexm_client.get_intent({name: name, version: version})
					return Intent.new(resp.to_h)

				rescue Aws::LexModelBuildingService::Errors::NotFoundException => e
					puts "Error: #{e.inspect}"
				end
				return nil
			end

			# Get a new instance of Intent
			#
			# @param name [String] name of the intent
			# @param utterences [Array] phrases for training
			# @return [Intent] Intent object
			#
			def new_intent(name, utterences= [])
				#check for existing intent, and get checksum

				i = get_intent(name)
				i = Intent.new if !i
				i.name = name
				i.utterences = utterences

				return i
			end

			# Given an Intent object, create/update it in Lex
			#
			# @param intent [Intent] Intent object
			# @return [Intent] Intent object
			#
			# @todo convert response -> Intent
			#
			def create_intent(intent)
				resp = @lexm_client.put_intent(intent.to_h)
			end

			# Get an instance of IntentCollection, if it exists
			# @param name [String] intent collection name
			# @param version [String] version
			def get_intent_collection(name, version = nil)
				version = '$LATEST'
				begin
					resp = @lexm_client.get_bot({name: name, version_or_alias: version})

					return IntentCollection.new(resp.to_h)
				rescue Aws::LexModelBuildingService::Errors::NotFoundException => e
					puts "Error: #{e.inspect}"
				end
				return nil
			end

			# Get a new instance of Intent
			# @param name [String] intent collection name
			# @param intents [Array<Intent>] array of intent objects
			def new_intent_collection(name, intents)
				ic = get_intent_collection(name)

				ic = IntentCollection.new if !ic
				ic.name = name
				ic.intents = intents
				return ic
			end

			# Given an IntentCollection object, create it in Lex
			#
			# @param collection [IntentCollection] the Bot to be created
			#
			def create_intent_collection(collection)
				#create/update intents
				collection.intents.each do |i|
					create_intent(i)
				end

				resp = @lexm_client.put_bot(collection.to_h)
			end

			# Class represents Intent in an IntentCollection
			class Intent
				include NluAdapterIntent

				# Constructor
				def initialize(options = {})
					@name = options[:name]
					@version = options[:version]
					@checksum = options[:checksum]
				end

				# Convert self to Hash
				# @return [Hash] ruby hash
				#
				def to_h
					{
						name: @name,
						sample_utterances: @utterences,
						fulfillment_activity: {
							type: "ReturnIntent"
						},
						checksum: @checksum
					}
				end

				# convert self to Json
				# @return [json] json
				#
				def to_json
					to_h.to_json
				end
			end

			# Class represents a collection of Intents
			class IntentCollection
				include NluAdapterIntentCollection
				attr_accessor :extra

				# Constructor
				def initialize(options = {})
					@name = options[:name]
					@checksum = options[:checksum]
					@intents = options[:intents]
				end

				# Convert self to Hash
				# @return [Hash] ruby hash
				#
				def to_h
					intents = []
					@intents.each do |i|
						intents << {
							intent_name: i.name,
							intent_version: '$LATEST'
						}
					end

					{
						name: @name,
						intents: intents,
						locale: "en-US",
						child_directed: false,
						voice_id: "0",
						clarification_prompt: {
							max_attempts: 1,
							messages: [
								{
									content: "I'm sorry, Can you please repeat that?",
									content_type: "PlainText"
								},
								{
									content: "Can you say that again?",
									content_type: "PlainText"
								}
							]
						},
						abort_statement: {
							messages: [
								{
									content: "I don't understand. Can you try again?",
									content_type: "PlainText"
								},
								{
									content: "I'm sorry, I don't understand.",
									content_type: "PlainText"
								}
							]
						},
						checksum: @checksum
					}
				end

				# Convert self to Json
				# @return [Json] json
				#
				def to_json
					to_h.to_json
				end

			end
		end
	end
end
