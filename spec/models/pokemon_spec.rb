require 'rails_helper'

RSpec.describe Pokemon do
  describe '#full_name' do
    context 'when exists name and id national' do
      it 'show the name and id national' do
        pokemon = described_class.new(name: 'Charizard', id_national: 6)
        expect(pokemon.full_name).to eq('Charizard - 6')
      end
    end

    context 'when not exists name and id national' do
      it 'is nil' do
        pokemon = Pokemon.new
        expect(pokemon.full_name).to be_nil
      end
    end
  end
  it { is_expected.to be_a(ActiveRecord::Base) }
end
