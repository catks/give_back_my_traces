# frozen_string_literal: true

RSpec.describe GiveBackMyTraces::Tracker do
  let(:instance) { described_class.new(filters: filters, **options) }

  let(:filters) { [] }
  let(:options) { {} }

  let(:expected_backtrace) { "/home/foo/bar" }

  before do
    GiveBackMyTraces.config[:from] = expected_backtrace
  end

  describe "#call" do
    subject(:call) { instance.call(error) }

    before do
      allow(GiveBackMyTraces::Helpers).to receive(:pretty_format)
    end

    context "with filters" do
      let(:filters) do
        [GiveBackMyTraces::FROM_BACKTRACE_FILTER]
      end

      context "with a valid error" do
        let(:error) { instance_double(StandardError, backtrace: [expected_backtrace]) }

        it "print the error" do
          call

          expect(GiveBackMyTraces::Helpers).to have_received(:pretty_format).with(error, **options)
        end
      end

      context "with a invalid error" do
        let(:error) { instance_double(StandardError, backtrace: ["/home/nop"]) }

        it "print the error" do
          call

          expect(GiveBackMyTraces::Helpers).to_not have_received(:pretty_format)
        end
      end
    end
  end
end
