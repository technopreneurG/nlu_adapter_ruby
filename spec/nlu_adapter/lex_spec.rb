require 'nlu_adapter'

RSpec.describe NluAdapter::Adapters::Lex do
	context "parser tests" do
		before(:example) do
			@lex = instance_double('Aws::Lex::Client')
			@lexm = instance_double('Aws::LexModelBuildingService::Client')
			allow(Aws::Lex::Client).to receive(:new).and_return(@lex)
			allow(Aws::LexModelBuildingService::Client).to receive(:new).and_return(@lexm)
			class Resp
				attr_accessor :intent_name
			end

		end

		it "test Lex parser init" do
			lp = NluAdapter.new(:Lex)
			expect(lp).to_not be_nil
			expect(lp).to be_instance_of(NluAdapter::Adapters::Lex)
		end

		it "parse text: Hello" do
			resp = Resp.new
			resp.intent_name = 'hello'
			allow(@lex).to receive(:post_text).and_return(resp)

			lp = NluAdapter.new(:Lex)
			i = lp.parse('Hello')
			expect(i[:intent_name]).to eq 'hello'
		end

		it "parse text: need a hotel room" do
			resp = Resp.new
			resp.intent_name = 'BookHotel'
			allow(@lex).to receive(:post_text).and_return(resp)

			lp = NluAdapter.new(:Lex)
			i = lp.parse('need a hotel room')
			expect(i[:intent_name]).to eq 'BookHotel'
		end

		it "parse report: 1" do
			resp = Resp.new
			resp.intent_name = 'BookHotel'
			allow(@lex).to receive(:post_text).and_return(resp)

			lp = NluAdapter.new(:Lex)
			got = lp.parse_test_report({"BookHotel":["please book a hotel"],"intent1":["book me a hotel, please","book a hotel"]})

			expected = {:accuracy=>33.3333, :classification_report => {:BookHotel=>{:class_total=>1, :precision=>0.3333, :recall=>1.0}, :intent1=>{:class_total=>2, :precision=>0.0, :recall=>0.0}}, :confusion_matrix => Matrix[[1, 0], [2, 0]]}
			expect(got).to eq expected
		end
	end
end
