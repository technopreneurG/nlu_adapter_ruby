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
						workspace_id: ENV["WATSON_WORKSPACE_ID"],
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
		end
	end
end
