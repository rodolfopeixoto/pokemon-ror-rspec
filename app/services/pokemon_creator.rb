class PokemonCreator
  def initialize(id_national)
    @id_national = id_national
    create_info
  end

  def create
    Pokemon.create(name: name)
  end

  def name
    information['name'].capitalize
  end

  private

  attr_reader :id_national, :information

  def endpoint
    URI("https://pokeapi.co/api/v2/pokemon/#{id_national}/")
  end

  def create_info
    response = Net::HTTP.get(endpoint)
    @information = JSON.parse(response)
  end
end
