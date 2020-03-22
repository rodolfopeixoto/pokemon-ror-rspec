require 'rails_helper'

RSpec.describe PokemonCreator do
  describe '#creator', vcr:
    { cassette_name: 'PokemonCreator/creator' } do
    it 'does create a new pokémon' do
      pokemon_creator = described_class.new(6)
      expect do
        pokemon_creator.create
      end.to change{ Pokemon.count }.by(1)
    end

    it 'does have the name correct' do
      pokemon_creator = described_class.new(6)
      pokemon_creator.create
      subject = Pokemon.last

      expect(subject.name).to eq('Charizard')
    end
  end
end
