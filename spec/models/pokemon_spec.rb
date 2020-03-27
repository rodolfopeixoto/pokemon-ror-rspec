require 'rails_helper'

RSpec.describe Pokemon do

  let!(:today) do
    Time.zone.local(2014, 3, 3, 12)
  end

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

  describe 'scoped' do
    describe '.chosen_yesterday' do
      it 'tem o pokemon escolhido ontem' do
        pokemon_escolhido_ontem = create(:pokemon,
          chosen_at: Time.zone.local(2010, 3, 3, 23, 59, 59)) 
        Timecop.freeze(today) do
          expect(subject).to include(pokemon_escolhido_ontem)
        end
      end
    end

    describe '.chosen_the_day_before_yesterday' do
      it 'não tem o pokemon escolhido antes de ontem' do
        chosen_yesterday = FactoryBot.create(:pokemon, chosen_at: Time.zone.local(2015, 1, 2, 23, 59, 59))

        expect(Pokemon.chosen_yesterday).to_not include(chosen_yesterday)
      end
    end
    describe '.chosen_today' do
      it 'não tem o pokemon hoje' do
        chosen_yesterday = FactoryBot.create(:pokemon, chosen_at: Time.zone.local(2014, 1, 2))
        expect(Pokemon.chosen_yesterday).to_not include(chosen_yesterday)
      end
    end
  end
end
