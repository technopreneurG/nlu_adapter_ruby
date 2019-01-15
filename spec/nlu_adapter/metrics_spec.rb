require 'nlu_adapter'

RSpec.describe NluAdapter::Metrics do
	context "metrics tests" do

		it "check accuracy & confusion matrix - test #1" do
			actual=[0, 1, 2, 2, 2]
			pred=[0, 0, 2, 2, 1]
			class_names = ['class 0', 'class 1', 'class 2']
			m = Matrix[[1, 0, 0], [1, 0, 0], [0, 1, 2]]
			a = NluAdapter::Metrics.new(actual, pred, class_names)

			expect(a.accuracy).to eq 60.0
			expect(a.confusion_matrix).to eq m
			b={'class 0'=>1, 'class 1'=> 1, 'class 2' => 3}
			expect(a.class_totals).to eq b

			expect(a.tp('class 0')).to eq 1
			expect(a.tp('class 1')).to eq 0
			expect(a.tp('class 2')).to eq 2

			expect(a.fp('class 0')).to eq 1
			expect(a.fp('class 1')).to eq 1
			expect(a.fp('class 2')).to eq 0

			expect(a.fn('class 0')).to eq 0
			expect(a.fn('class 1')).to eq 1
			expect(a.fn('class 2')).to eq 1

			expect(a.precision('class 0')).to eq 0.5
			expect(a.recall('class 0')).to eq 1.0

		end

		it "check accuracy & confusion matrix - test #2" do
			actual=[2, 0, 2, 2, 0, 1]
			pred=[0, 0, 2, 2, 0, 2]
			class_names = ['class 0', 'class 1', 'class 2']
			m = Matrix[[2, 0, 0], [0, 0, 1], [1, 0, 2]]
			a = NluAdapter::Metrics.new(actual, pred, class_names)

			expect(a.accuracy).to eq 66.6667
			expect(a.confusion_matrix).to eq m

			b={'class 0'=>2, 'class 1'=> 1, 'class 2' => 3}
			expect(a.class_totals).to eq b

			expect(a.tp('class 0')).to eq 2
			expect(a.tp('class 1')).to eq 0
			expect(a.tp('class 2')).to eq 2

			expect(a.fp('class 0')).to eq 1
			expect(a.fp('class 1')).to eq 0
			expect(a.fp('class 2')).to eq 1

			expect(a.fn('class 0')).to eq 0
			expect(a.fn('class 1')).to eq 1
			expect(a.fn('class 2')).to eq 1

			expect(a.precision('class 0')).to eq 0.6667
			expect(a.recall('class 0')).to eq 1.0
		end

		it "check accuracy & confusion matrix - test #3" do
			actual=["cat", "ant", "cat", "cat", "ant", "bird"]
			pred=["ant", "ant", "cat", "cat", "ant", "cat"]
			class_names = ['class 0', 'class 1', 'class 2']
			a = NluAdapter::Metrics.new(actual, pred, class_names)

			expect(a.accuracy).to eq 66.6667
			expect(a.confusion_matrix).to be_nil
		end

	end
end

