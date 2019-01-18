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

			@actual.map!{ |a| a.is_a?(String)? a.intern : a }
			@predicted.map!{ |p| p.is_a?(String)? p.intern : p }
			@class_labels.map!{ |l| l.is_a?(String)? l.intern : l }
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
				class_labels = (@actual + @predicted).sort.uniq.sort
				class_labels.map!{|c| c.intern}
				@actual.each_with_index do |v, i|
					actual[i] = class_labels.index(v)
				end

				@predicted.each_with_index do |v, i|
					predicted[i] = class_labels.index(v)
				end
			else
				#check if any string passed in actual/predicted
				i = actual.select { |a| a.is_a?(Symbol) }.size
				j = predicted.select { |p| p.is_a?(Symbol) }.size

				if i > 0 || j > 0
					#todo: fix it OR throw error
					puts "actual, predicted & class_labels array having string values not implemented yet"
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

		# Get totals of actual values per class
		# @return [Hash] Hash of class totals
		#
		def class_totals
			return @class_totals
		end

		# Get total positives
		# @param class_name [String] class name
		# @return [Integer] total positive value for class_name
		#
		def tp(class_name)
			i = @class_labels.index(class_name.intern)
			return nil if i == nil || @m == nil || @m.empty?
			tp = @m[i, i]
			return tp
		end

		# Get false positive
		# @param class_name [String] class name
		# @return [Integer] false positive value for class_name
		#
		def fp(class_name)
			i = @class_labels.index(class_name.intern)
			return nil if i == nil || @m == nil || @m.empty?
			fp = @m.column(i).sum - tp(class_name)
			return fp
		end

		# Get false negative
		# @param class_name [String] class name
		# @return [Integer] false negative value for class_name
		#
		def fn(class_name)
			i = @class_labels.index(class_name.intern)
			return nil if i == nil || @m == nil || @m.empty?
			fn = @m.row(i).sum - tp(class_name)
			return fn
		end

		# Get the precision for given class
		# @param class_name [String] class name
		# @return [Float] precision rounded off to 4 decimal places
		#
		def precision(class_name)
			confusion_matrix if !@m
			return 0.00 if tp(class_name) == 0
			precision = tp(class_name).fdiv((tp(class_name) + fp(class_name))).round(4)
			return precision
		end

		# Get the recall for given class
		# @param class_name [String] class name
		# @return [Float] recall rounded off to 4 decimal places
		#
		def recall(class_name)
			confusion_matrix if !@m
			return 0.00 if tp(class_name) == 0
			recall = tp(class_name).fdiv((tp(class_name) + fn(class_name))).round(4)

			return recall
		end

		# Generate classification report
		# @return [Hash] precision, recall and totals for each class name as key
		#
		def classification_report
			confusion_matrix if !@m
			report = {}
			@class_labels.each do |label|
				report[label] = {
					precision: precision(label),
					recall: recall(label),
					class_total: class_totals[label]
				}
			end

			return report
		end

		#todo: f1-score
	end
end

