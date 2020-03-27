class AddChosenAtToPokemon < ActiveRecord::Migration[6.0]
  def change
    add_column :pokemons, :chosen_at, :date
  end
end
