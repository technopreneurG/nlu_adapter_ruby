
require 'aws-sdk-lex'

module NLUWS
	module Adapters
		class Lex

			def initialize(options = {})
				#creds & region from config/env
				@bot_name = options[:bot_name]
				@bot_alias = options[:bot_alias]
				@user_id = options[:user_id]
				@client = Aws::Lex::Client.new()
			end

			#understand a given text
			def parse(text)
				intent_name = nil
				begin
					resp = @client.post_text({
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

					intent_name = resp.intent_name #=> String
				rescue Aws::Lex::Errors::ServiceError => e
					puts "Error: #{e.inspect}"
				end
				return { intent_name: intent_name }
			end
		end
	end
end
