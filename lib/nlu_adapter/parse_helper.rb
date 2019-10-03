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
		#    {
		#      "Intent1"=>["APR for personal credit cards", "interest rates for personal credit cards"], 
		#      "Intent2"=>["Am I still part of the rewards program?", "Am I still in the loyalty program?"]
		#    }
		#  test_results
		#    json:
		#      [
		#         {
		#            "text" : "APR for personal credit cards",
		#            "expected" : "Intent1",
		#            "got" : "Intent1"
		#         },
		#         {
		#            "text" : "interest rates for personal credit cards",
		#            "expected" : "Intent1",
		#            "got" : "Intent1"
		#         },
		#         {
		#            "text" : "Am I still part of the rewards program?",
		#            "expected" : "Intent2",
		#            "got" : "Intent3"
		#         },
		#         {
		#            "text" : "Am I still in the loyalty program?",
		#            "expected" : "Intent2",
		#            "got" : "Intent3"
		#         }
		#      ]
		#    csv:
		#      APR for personal credit cards,Intent1,Intent1
		#      interest rates for personal credit cards,Intent1,Intent1
		#      Am I still part of the rewards program?,Intent2,Intent3
		#      Am I still in the loyalty program?,Intent2,Intent3
		#    hash:
		#      [
		#        {:text=>"APR for personal credit cards", :expected=>"Intent1", :got=>"Intent1"},
		#        {:text=>"interest rates for personal credit cards", :expected=>"Intent1", :got=>"Intent1"},
		#        {:text=>"Am I still part of the rewards program?", :expected=>"Intent2", :got=>"Intent3"},
		#        {:text=>"Am I still in the loyalty program?", :expected=>"Intent2", :got=>"Intent3"}
		#      ]
		#    yaml:
		#      ---
		#      - :text: APR for personal credit cards
		#        :expected: Intent1
		#        :got: Intent1
		#      - :text: interest rates for personal credit cards
		#        :expected: Intent1
		#        :got: Intent1
		#      - :text: Am I still part of the rewards program?
		#        :expected: Intent2
		#        :got: Intent3
		#      - :text: Am I still in the loyalty program?
		#        :expected: Intent2
		#        :got: Intent3
		#
		# @param test_data [Json]: Test data in specified format
		# @param output_format [Symbol] supported formats :csv, :json, :yaml or :hash
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
			when :yaml
				return test_results.to_yaml
			else
				puts 'Warning: valid format not specified'
				return test_results
			end

		end


		# run the parse tests with test_data and generate test report
		#
		#  Example input/output
		#  test_data
		#    {
		#      "Intent1"=>["APR for personal credit cards", "interest rates for personal credit cards"], 
		#      "Intent2"=>["Am I still part of the rewards program?", "Am I still in the loyalty program?"]
		#    }
		#  test_report
		#    json:
		#      {
		#        "accuracy":50.0,
		#        "confusion_matrix":"Matrix[[2, 0, 0], [0, 0, 2], [0, 0, 0]]",
		#        "classification_report": {
		#            "Intent1":{"precision":1.0,"recall":1.0,"class_total":2},
		#            "Intent2":{"precision":0.0,"recall":0.0,"class_total":2},
		#            "Intent3":{"precision":0.0,"recall":0.0,"class_total":0}
		#        }
		#      }
		#    csv:
		#      Accuracy,50.0
		#      CONFUSION MATRIX:
		#      "",Intent1,Intent2,Intent3
		#      Intent1,2,0,0
		#      Intent2,0,0,2
		#      Intent3,0,0,0
		#      CLASSIFICATION REPORT:
		#      Class,Precision,Recall,Class total
		#      Intent1,1.0,1.0,2
		#      Intent2,0.0,0.0,2
		#      Intent3,0.0,0.0,0
		#    hash:
		#      {
		#        :accuracy=>50.0,
		#        :confusion_matrix=>Matrix[[2, 0, 0], [0, 0, 2], [0, 0, 0]],
		#        :classification_report=>{
		#          :"Intent1"=>{:precision=>1.0, :recall=>1.0, :class_total=>2},
		#          :"Intent2"=>{:precision=>0.0, :recall=>0.0, :class_total=>2},
		#          :"Intent3"=>{:precision=>0.0, :recall=>0.0, :class_total=>0}
		#        }
		#      }
		#    yaml:
		#      ---
		#      :accuracy: 50.0
		#      :confusion_matrix: !ruby/object:Matrix
		#        rows:
		#        - - 2
		#          - 0
		#          - 0
		#        - - 0
		#          - 0
		#          - 2
		#        - - 0
		#          - 0
		#          - 0
		#        column_count: 3
		#      :classification_report:
		#        :Intent1:
		#          :precision: 1.0
		#          :recall: 1.0
		#          :class_total: 2
		#        :Intent2:
		#          :precision: 0.0
		#          :recall: 0.0
		#          :class_total: 2
		#        :Intent3:
		#          :precision: 0.0
		#          :recall: 0.0
		#          :class_total: 0
		#
		# @param test_data [Json]: Test data in specified format
		# @param output_format [Symbol] supported formats :csv, :json, :yaml or :hash
		# @return [test_report]: generate a test report
		# @todo F1-Score
		#
		def parse_test_report(test_data, output_format = :hash)
			test_results = parse_test(test_data)
			expected = []
			got = []
			test_results.each do |result|
				expected << result[:expected]
				got << result[:got]
			end

			test_report = {accuracy: 0, confusion_matrix: [], classification_report: {}}
			if !got.reject { |e| e.to_s.empty? }.empty?
				m = Metrics.new(expected, got)
				test_report = {accuracy: m.accuracy, confusion_matrix: m.confusion_matrix, classification_report: m.classification_report}
			end

			case output_format
			when :json
				return test_report.to_json
			when :csv
				return report_to_csv(test_report)
			when :hash
				return test_report
			when :yaml
				return test_report.to_yaml
			else
				puts 'Warning: valid format not specified'
				return test_report
			end
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

		def report_to_csv(test_report)

			csv_string = CSV.generate do |csv|
				csv << ["Accuracy", test_report[:accuracy]]
				csv << ["CONFUSION MATRIX:"]
				class_row = [""]
				test_report[:classification_report].each do |c, r|
					class_row << c
				end
				csv << class_row
				test_report[:confusion_matrix].to_a.each_with_index do |row, i|
					csv << [class_row[i+1]] + row
				end
				csv << ["CLASSIFICATION REPORT:"]
				csv << ["Class", "Precision", "Recall", "Class total"]
				test_report[:classification_report].each do |c, r|
					csv << [c, r[:precision], r[:recall], r[:class_total]]
				end
			end
			csv_string
		end
	end
end
