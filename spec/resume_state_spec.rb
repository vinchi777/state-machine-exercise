require 'spec_helper'
require 'pry'

describe ResumeState do
  let(:app) { ResumeState.new }

  it 'asks for full name' do
    input_sequence = ['1', 'john', 'doe', '3'] 
    allow_any_instance_of(HighLine).to receive(:ask).and_return(*input_sequence)
    app.start

    expect(app.first_name).to eq('john')
    expect(app.last_name).to eq('doe')
  end

  it 'goes to work experience menu' do
    input_sequence = ['work experience', '1', 'junior dev', '2', 'facebook', 'back to menu', 'exit']
    allow_any_instance_of(HighLine).to receive(:ask).and_return(*input_sequence)

    expect{ app.start }.to output(/- Company: facebook, Job Position: junior dev/).to_stdout
  end

  it 'can accept string as option choice' do
    input_sequence = ['enter name', 'john', 'doe', 'exit']
    allow_any_instance_of(HighLine).to receive(:ask).and_return(*input_sequence)

    expect{ app.start }.to output(/john doe - Company: , Job Position: /).to_stdout
  end

  it 'displays result on exit' do
    input_sequence = ['1', 'john', 'doe', '2', '1', 'team lead', '2', 'ListingSpark', '3', '3']
    allow_any_instance_of(HighLine).to receive(:ask).and_return(*input_sequence)
    expect{ app.start }.to output(/john doe - Company: ListingSpark, Job Position: team lead/).to_stdout
  end

  it 'does not accept invalid input' do
    input_sequence = ['random', 'exit']
    allow_any_instance_of(HighLine).to receive(:ask).and_return(*input_sequence)
    expect{ app.start }.to output(/Invalid Option/).to_stdout
  end

end
