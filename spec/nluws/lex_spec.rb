require 'nluws'

RSpec.describe NLUWS::Adapters::Lex do
	context "parser tests" do
		before(:example) do
			@lex = instance_double('Aws::Lex::Client')
			allow(Aws::Lex::Client).to receive(:new).and_return(@lex)
			class Resp
				attr_accessor :intent_name
			end

		end

		it "test Lex parser init" do
			lp = NLUWS.new(:Lex)
			expect(lp).to_not be_nil
			expect(lp).to be_instance_of(NLUWS::Adapters::Lex)
		end

		it "parse text: Hello" do
			resp = Resp.new
			resp.intent_name = 'hello'
			allow(@lex).to receive(:post_text).and_return(resp)

			lp = NLUWS.new(:Lex)
			i = lp.parse('Hello')
			expect(i[:intent_name]).to eq 'hello'
		end

		it "parse text: need a hotel room" do
			resp = Resp.new
			resp.intent_name = 'BookHotel'
			allow(@lex).to receive(:post_text).and_return(resp)

			lp = NLUWS.new(:Lex)
			i = lp.parse('need a hotel room')
			expect(i[:intent_name]).to eq 'BookHotel'
		end
	end
end
