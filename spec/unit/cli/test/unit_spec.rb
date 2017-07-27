require 'spec_helper'
require 'pdk/tests/unit'

describe 'Running `pdk test unit`' do
  subject { PDK::CLI.instance_variable_get(:@test_unit_cmd) }

  it { is_expected.not_to be_nil }

  context 'with --help' do
    it do
      # require'pry';binding.pry
      begin
        expect {
          PDK::CLI.run(['test', 'unit', '--help'])
        }.to output(%r{^USAGE\s+pdk test unit}m).to_stdout
      rescue SystemExit => e
        expect(e.status).to eq 0
      end
    end
  end

  context 'when listing tests' do
    let(:args){['--list']}
    before(:each) do
      expect(PDK::CLI::Util).to receive(:ensure_in_module!).with(no_args).once
    end

    context 'when no tests are found' do
      before(:each) do
        expect(PDK::Test::Unit).to receive(:list).with(no_args).once.and_return([])
        expect($stdout).to receive(:puts).with(/No examples found/)
      end

      it { subject.run_this(args) }
    end

    context 'when some tests are found' do
      let(:test_list) {[{id: 'first_id', full_description: 'first_description'}, {id: 'second_id', full_description: 'second_description'}]}
      before(:each) do
        expect(PDK::Test::Unit).to receive(:list).with(no_args).once.and_return(test_list)
        expect($stdout).to receive(:puts).with('Examples:')
        expect($stdout).to receive(:puts).with(/first_id\tfirst_description/)
        expect($stdout).to receive(:puts).with(/second_id\tsecond_description/)
      end

      it { subject.run_this(args) }
    end

  end
end
