require 'matrix'

module NluAdapter

	# A utility class to calculate classification matrics
	# @see https://scikit-learn.org/stable/modules/model_evaluation.html#classification-metrics
	#
	class Metrics

		# Constructor
		# @param actual [Array] an array of actual results (true values)
		# @param predicted [Array] an array of predicted results (predicted values)
		# @param class_labels [Array] an array of class_labels for the results,
		#               this is required if actual & predicted values are numeric
		#
		def initialize(actual, predicted, class_labels = [])
			@actual = actual
			@predicted = predicted
			@class_labels = class_labels
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

		# Get the confusion matrix
		# @return [Matrix] confusion matrix
		# @see https://en.wikipedia.org/wiki/Confusion_matrix
		#
		def confusion_matrix
			class_labels = @class_labels
			actual = @actual
			predicted = @predicted

			#if no class_labels, convert to numeric values, and extract the class_labels
			if @class_labels.empty?
				class_labels = (@actual + @predicted).uniq.sort
				@actual.each_with_index do |v, i|
					actual[i] = class_labels.index(v)
				end

				@predicted.each_with_index do |v, i|
					predicted[i] = class_labels.index(v)
				end
			else
				#check if any string passed in actual/predicted
				i = actual.select { |a| a.is_a?(String) }.size
				j = predicted.select { |a| a.is_a?(String) }.size

				if i > 0 || j > 0
					#todo: fix it OR throw error
					puts "actual, predicted & class_labels array having string values not implemented"
					return

				end
			end

			m = Matrix.zero(class_labels.size)

			@class_totals = Hash[class_labels.collect { |c| [c, 0] }]
			actual.each_with_index do |vi, i|
				vj = predicted[i]
				m[vi, vj] = m[vi, vj] + 1
				@class_totals[class_labels[vi]] += 1
			end

			@class_labels = class_labels
			@actual = actual
			@predicted = predicted

			@m = m
			return m
		end

		def class_totals
			return @class_totals
		end

		def tp(class_name)
			i = @class_labels.index(class_name)
			return nil if i == nil || @m == nil || @m.empty?
			@tp = @m[i, i]
			return @tp
		end

		def fp(class_name)
			i = @class_labels.index(class_name)
			return nil if i == nil || @m == nil || @m.empty?
			@fp = @m.column(i).sum - tp(class_name)
			return @fp
		end

		def fn(class_name)
			i = @class_labels.index(class_name)
			return nil if i == nil || @m == nil || @m.empty?
			@fp = @m.row(i).sum - tp(class_name)
			return @fp
		end

		#todo: precision, recall, f1-score
	end
end

