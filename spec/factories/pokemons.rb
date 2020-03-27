FactoryBot.define do
  factory :pokemon do
    id_national { 6 }
    name { 'Charizard' }
    chosen_at { Time.current }
  end
end
