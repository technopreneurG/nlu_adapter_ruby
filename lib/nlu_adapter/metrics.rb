module NluAdapter

	# A utility class to calculate classification matrics
	# @see https://scikit-learn.org/stable/modules/model_evaluation.html#classification-metrics
	#
	class Metrics

		# Constructor
		# @param actual [Array] an array of actual results (true values)
		# @param predicted [Array] an array of predicted results (predicted values)
		# @param labels [Array] an array of labels for the results,
		#               this is required if actual & predicted values are numeric
		#
		def initialize(actual, predicted, labels = [])
			@actual = actual
			@predicted = predicted
			@labels = labels
		end

		# Caclulate the accuracy
		# @return [Float] accuracy
		# @see https://en.wikipedia.org/wiki/Accuracy_and_precision
		#
		def accuracy
			if @actual.size != @predicted.size
				#todo: throw error
				puts "actual & predicted array are not of same size"
				return
			end

			total = @actual.size
			correct = 0
			@actual.each_with_index do |v, i|
				correct+=1 if @predicted[i] == v
			end
			(correct.fdiv(total) * 100).round(4)
		end

		#todo: precision, recall, f1-score
	end
end

