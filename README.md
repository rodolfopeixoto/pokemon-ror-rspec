# Ruby on Rails and TDD


### VCR

#### URI dinâmica

Deste modo, não estamos nos importando com o método HTTP e a URI da requisição. Apenas estamos enviando o mesmo body sempre, ou seja, a imagem.
Assim conseguimos fazer com que nossos testes continuem passando, e não precisamos testar novamente o Paperclip no teste do controller. Somente precisamos verificar que ele não nos gera problemas devido a URIs não de- terminísticas.


```ruby
describe PlayersController do
  describe "POST ’create’",
      vcr: { match_requests_on: [:body] } do
  # ...
end
```

Executar os dados sem persistir.

```
rails c --sandbox
```

### FactoryBot

Remover a verbosidade do FactoryBot, ao invés de adicionar `FactoryBot.create(:employee)`, e sim adicionar `create(:employee)`

```ruby
# Adicionar no rails_helper.rb ou no spec_helper.rb
RSpec.configure do |config|
  # ...
  config.include FactoryBot::Syntax::Methods
end
```

#### Traits

Utilização das traits com o uso de todos os campos de traits

```ruby
factory :artigo do
  titulo ’Diversas dicas do RSpec’
  conteudo ’Contenteúdo de Diversas dicas do RSpec’
trait :aprovado doaprovado true
  end
  trait :nao_aprovado do
    aprovado false
end
  trait :titulo_maiusculo do
    titulo ’TITLE’
end
  factory :artigo_aprovado_titulo_maiusculo,
    traits: [:aprovado, :titulo_maiusculo]
end


# FactoryGirl.create(:artigo_aprovado_titulo_maiusculo)
```

#### Attributos Dinâmicos

Lazy Attributes

```ruby

factory :artigo do
  titulo ’Diversas dicas do RSpec’
  conteudo ’Contenteúdo de Diversas dicas do RSpec’
  created_at { 2.days.ago }
end
```

Dependent Attributes

exibindo informações do titulo e do aprovado. Para isso, passamos um bloco, afinal será um atributo lazy. Den- tro deste bloco temos acesso aos outros atributos do model.

```
factory :artigo do
  titulo ’Diversas dicas do RSpec’
  conteudo
    { "Conteudo do artigo #{titulo}. Approved: #{aprovado}" }
end
```

#### Associations

``` 
factory :artigo do
  titulo ’Diversas dicas do RSpec’
    conteudo { "Conteudo do #{titulo}" }
    usuario
    trait :aprovado do
       aprovado true
   end
     factory :artigo_aprovado, traits: [:aprovado]
   end
```

#### Change name class

```ruby
# model
class Artigo < ActiveRecord::Base
  belongs_to :autor, class_name: ’Usuario’
end

# factory

factory :artigo do
  titulo ’Diversas dicas do RSpec’
  conteudo { "Conteudo do #{titulo}" }
  association :autor, factory: :usuario
  trait :aprovado do
    aprovado true
end
  factory :artigo_aprovado, traits: [:aprovado]
end
```

Podemos modificar também da seguinte forma:

```ruby
association :autor, factory: :usuarios, nome: ’Mauro George’
```

#### Aliases


No exemplo anterior, utilizamos o método association para definir a factory da associação. Não podemos nos referenciar a autor diretamente, dado que nossa factory está declarada como usuario.
Podemos declarar um alias para nossa factory de Usuario ,assim po- deremos utilizar autor diretamente. Para isso, simplesmente passamos um array para a chave aliases.

```ruby
factory :usuario, aliases: [:autor] do
  nome ’Mauro’
  email { "#{nome}@helabs.com.br" }
end

```

Dessa forma, além de podermos como ``FactoryGirl.create(:usuario), FactoryGirl.create(:autor)`.

```ruby
factory :artigo do
  titulo ’Diversas dicas do RSpec’
  conteudo { "Conteudo do #{titulo}" }
  autor
  trait :aprovado do
    aprovado true
end
  factory :artigo_aprovado, traits: [:aprovado]
end
```

#### Associations has_many ( callbacks )


```

factory :usuario, aliases: [:autor] do
  nome ’Mauro’
  email { "#{nome}@helabs.com.br" }
  trait :com_artigo do
    after(:create) do |usuario|
      create(:artigo, autor: usuario)
    end
  end
end
```

O problema é que todo autor terá apenas um artigo criado. Seria bom se conseguíssemos aumentar este número.


#### create_list

```ruby
FactoryBot.create_list(:artigo, 3)
```

```ruby

factory :usuario, aliases: [:autor] do
  nome ’Mauro’
  email { "#{nome}@helabs.com.br" }
  trait :com_artigo do
    after(:create) do |usuario|
      create_list(:artigo, 3, autor: usuario)
    end
  end 
end

```

#### Transient Attributes


A factory_girl nos dá a opção de definirmos atributos que não estão em nosso model. Para isso, utilizamos um bloco no método ignore e, se utili- zarmos estes atributos em conjunto com o callback, conseguiremos definir a quantidade de artigos que queremos criar dinamicamente.
Para isso, passamos para o bloco ignore o nosso transient attribute, o total_de_artigos e definimos o valor 3. Passamos para o nosso bloco do after(:create) um novo parâmetro, o evaluator, que armazena todos os valores da factory, inclusive os ignorados. Assim, passamos o valor de total_de_artigos para o create_list.

```ruby
factory :usuario, aliases: [:autor] do
  nome ’Mauro’
  email { "#{nome}@helabs.com.br" }
  trait :com_artigo do
    ignore do
      total_de_artigos 3
    end
    after(:create) do |usuario, evaluator|
      create_list(:artigo, evaluator.total_de_artigos,
    end 
  end
end
```
Podemos agora criar usuários com a quantidade de artigos que desejar- mos da seguinte maneira:

```ruby
FactoryGirl.create(:usuarios, :com_artigo, total_de_artigos: 10)
```

#### FactoryBot Fake without ActiveRecord

```ruby
factory :pokeapi, class: String do
  skip_create
  ignore do
    id_nacional 6
    nome ’Charizard’
    ataque 84
    defesa 78
  end
  initialize_with do
    info = { national_id: id_nacional, name: nome,
             attack: ataque, defense: defesa }
    JSON.generate(info)
end end

```

Agora sim nossa factory está funcionando! E retornando o nosso JSON.

`FactoryGirl.create(:pokeapi)`

#### Use build 

Uma das estratégias da factory_girl é o build. Diferentemente do create, o build apenas cria o objeto Active Record não o persistindo no banco de dados. Vamos ver um exemplo.

```ruby
pokemon = FactoryGirl.build(:pokemon)
```

Podemos ver se nosso objeto está salvo ou não simplesmente usando o

método persisted? do Active Record. pokemon.persisted?

No nosso caso, é retornado false. Podemos pensar que o build da factory_girl seria o mesmo que utilizarmos o new do Active Record, passando os atributos definidos na factory.

#### build_stubbed

build_stubbed, o irmão mais poderoso do build

Uma outra estratégia disponibilizada pela factory_bot é o build_stubbed. Diferente do build, não estamos criando um objeto
Active Record real, mas sim fazendo stub de seus métodos. Em consequência, esta estratégia é a mais rápida de todas. Vamos a um exemplo.

```ruby
pokemon = FactoryGirl.build_stubbed(:pokemon)

```

Diferentemente do build, nosso objeto age como estivesse persistido, por isso, ao usarmos pokemon.persisted?,
nosso resultado será true. Nosso objeto somente age como se estivesse persistido, pois se fizermos um Pokemon.count
antes e depois do uso do build_stubbed obteremos o mesmo valor,
mesmo que explicitamente salvemos nosso objeto com #save!.
Com o build, realmente o objeto é salvo no banco de dados se usarmos #save!.


#### FactoryGirl.lint

No arquivo: `spec_helper.rb`

```
RSpec.configure do |config|
  config.before(:suite) do
    FactoryGirl.lint
  end
end
```
