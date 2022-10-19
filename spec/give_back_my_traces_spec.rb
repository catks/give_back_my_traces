# frozen_string_literal: true

RSpec.describe GiveBackMyTraces do
  it "has a version number" do
    expect(GiveBackMyTraces::VERSION).not_to be nil
  end

  before do
    described_class.clear
    described_class.stop

    GiveBackMyTraces.config[:mode] = :silent
  end

  let(:errors) { described_class.errors }
  let(:first_error) { errors.first }
  let(:last_error) { errors.last }

  describe ".init" do
    subject(:init) { described_class.init }

    context "with GBMT_ENABLE env" do
      before do
        stub_const("ENV", { "GBMT_ENABLE" => "true" })
      end

      it "starts collecting the errors" do
        init

        begin
          ErrorHelper.multiple_errors
        rescue StandardError
          true
        end

        expect(errors.first.class).to eq StandardError
        expect(errors.first.message).to eq "Error 1"
        expect(errors.last.class).to eq StandardError
        expect(errors.last.message).to eq "Error 2"
      end
    end

    context "without GBMT_ENABLE env" do
      before do
        stub_const("ENV", {})
      end

      it "starts collecting the errors" do
        init

        begin
          ErrorHelper.multiple_errors
        rescue StandardError
          true
        end

        expect(errors).to eq([])
      end
    end
  end

  describe ".errors" do
    subject(:errors) { described_class.errors }

    context "with a rescued error" do
      it "return the errors" do
        described_class.start

        begin
          ErrorHelper.multiple_errors
        rescue StandardError
          true
        end

        described_class.stop

        expect(errors.first.class).to eq StandardError
        expect(errors.first.message).to eq "Error 1"
        expect(errors.last.class).to eq StandardError
        expect(errors.last.message).to eq "Error 2"
      end

      context "with a block on start" do
        it "return the errors" do
          described_class.start do
            ErrorHelper.multiple_errors
          rescue StandardError
            true
          end

          expect(errors.first.class).to eq StandardError
          expect(errors.first.message).to eq "Error 1"
          expect(errors.last.class).to eq StandardError
          expect(errors.last.message).to eq "Error 2"
        end
      end
    end

    context "with no errors" do
      it "return the errors" do
        described_class.start

        ErrorHelper.no_errors

        described_class.stop

        expect(errors).to eq([])
      end

      context "with a block on start" do
        it "return the errors" do
          described_class.start do
            ErrorHelper.no_errors
          end

          expect(errors).to eq([])
        end
      end
    end
  end

  describe ".pretty_print" do
    subject(:pretty_print) { described_class.errors.pretty_print }

    context "with errors" do
      it "return the errors" do
        described_class.start

        begin
          ErrorHelper.multiple_errors
        rescue StandardError
          true
        end

        described_class.stop

        expect($stdout).to receive(:puts).with(
          <<~FORMAT
            ----------------------------------------------------
             Error: #{first_error.class}
             Message: #{first_error.message}
             Backtrace:
               #{first_error.backtrace.first(5).join("\n   ")}
               ...
            ----------------------------------------------------
          FORMAT
        ).once

        expect($stdout).to receive(:puts).with(
          <<~FORMAT
            ----------------------------------------------------
             Error: #{last_error.class}
             Message: #{last_error.message}
             Backtrace:
               #{last_error.backtrace.first(5).join("\n   ")}
               ...
            ----------------------------------------------------
          FORMAT
        ).once

        pretty_print
      end

      context "with backtrace max_lines config" do
        let(:backtrace_max_lines) { 2 }

        before do
          GiveBackMyTraces.config[:backtrace][:max_lines] = backtrace_max_lines
        end

        it "return the errors with the correct backtrace" do
          described_class.start

          begin
            ErrorHelper.multiple_errors
          rescue StandardError
            true
          end

          described_class.stop

          expect($stdout).to receive(:puts).with(
            <<~FORMAT
              ----------------------------------------------------
               Error: #{first_error.class}
               Message: #{first_error.message}
               Backtrace:
                 #{first_error.backtrace.first(backtrace_max_lines).join("\n   ")}
                 ...
              ----------------------------------------------------
            FORMAT
          ).once

          expect($stdout).to receive(:puts).with(
            <<~FORMAT
              ----------------------------------------------------
               Error: #{last_error.class}
               Message: #{last_error.message}
               Backtrace:
                 #{last_error.backtrace.first(backtrace_max_lines).join("\n   ")}
                 ...
              ----------------------------------------------------
            FORMAT
          ).once

          pretty_print
        end
      end
    end
  end
end
