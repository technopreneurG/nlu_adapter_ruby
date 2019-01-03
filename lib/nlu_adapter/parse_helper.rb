require 'csv'
require 'json'

#helper functions to parse text and match intent
module NluAdapter
	module ParseHelper
		# parse multiple texts
		#
		#  Example input/output
		#  texts:
		#  ["book me a hotel, please", "book a hotel"]
		#  result:
		#  {"book me a hotel, please"=>"BookHotel", "book a hotel"=>"BookHotel"}
		#
		# @param [Array<String>] texts An array of texts to be parsed
		# @return [Hash] return a hash of "text" => "result"
		# @todo parallize
		def bulk_parse(texts)
			result = {}
			texts.each do |text|
				resp = parse(text)
				result[text] = resp[:intent_name]
			end
			result
		end

		# run the parse tests with test_data and generate test_results in supported format
		#
		#  Example input/output
		#  test_data
		#   {"BookHotel":["please book a hotel"],"intent1":["book me a hotel, please","book a hotel"]}
		#  test_results
		#   json:
		#   [{"text":"book me a hotel, please","expected":"intent1","got":"BookHotel"},{"text":"book a hotel","expected":"intent1","got":"BookHotel"},{"text":"please book a hotel","expected":"BookHotel","got":"BookHotel"}]
		#   csv:
		#   "book me a hotel, please",intent1,BookHotel
		#   book a hotel,intent1,BookHotel
		#   please book a hotel,BookHotel,BookHotel
		#   hash:
		#   [{:text=>"book me a hotel, please", :expected=>"intent1", :got=>"BookHotel"}, {:text=>"book a hotel", :expected=>"intent1", :got=>"BookHotel"}, {:text=>"please book a hotel", :expected=>"BookHotel", :got=>"BookHotel"}]
		#
		# @param test_data [Json]: Test data in specified format
		# @param output_format [Symbol] supported formats :csv, :json or :hash
		# @return [test_results]: output the test results in expected format
		#
		def parse_test(test_data, output_format = :hash)
			test_results = []
			test_data.each do |intent_name, texts|
				resp = bulk_parse(texts)
				texts.each do |t|
					test_results << {text: t, expected: intent_name, got: resp[t]}
				end
			end

			case output_format
			when :json
				return test_results.to_json
			when :csv
				return to_csv(test_results)
			when :hash
				return test_results
			else
				puts 'Warning: valid format not specified'
				return test_results
			end

		end


		# run the parse tests with test_data and generate test report
		#
		# @param test_data [Json]: Test data in specified format
		# @return [test_report]: generate a test report (Only Accurcacy is available)
		# @todo Precision, Recall, F1-Score
		#
		def parse_test_report(test_data)
			test_results = parse_test(test_data)
			total = test_results.size
			correct = 0
			test_results.each do |result|
				if result[:expected] == result[:got]
					correct+=1
				end
			end
			{ accuracy: (correct.fdiv(total) * 100).round(4) }
		end

		private
		def to_csv(test_results)
			csv_string = CSV.generate do |csv|
				test_results.each do |result|
					csv << result.values
				end
			end
			csv_string
		end
	end
end
