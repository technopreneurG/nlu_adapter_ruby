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
		end
	end
end
