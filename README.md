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
  end 
end

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

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    FactoryGirl.lint
  end
end
```

##### Ordem aleatória nos testes

```ruby
config.order = "random"
```

ou no arquivo `.rspec` podemos adicionar

```ruby
--order random
```

Execução do seed para debugger

```ruby
rspec spec --seed 182
```


#### Utilizar timecop ou ActiveSupport::Testing::TimeHelpers

A partir do Rails 4.1, foi criado o módulo ActiveSupport::Testing::TimeHelpers, que nos oferece méto- dos para viajarmos no tempo assim como com o timecop.
Como estamos utilizando o RSpec, primeiro temos que incluir o módulo. Para isso, utilizamos o spec_helper.rb.
 
```ruby
RSpec.configure do |config|
# ...
  config.include ActiveSupport::Testing::TimeHelpers
end

```

Com o módulo inserido simplesmente trocamos de `Timecop.freeze` para `travel_to` e de `Timecop.return` para `travel_back`, e mantemos o mesmo comportamento do timecop. No entanto, agora não há necessidade de uma gem extra.

```ruby
  before do
    hoje = Time.zone.local(2010, 3, 3, 12) travel_to(hoje)
  end
  after do
    travel_back
  end
```
Assim como o Timecop.freeze, o travel_to também aceita um bloco, de forma que não é necessário usar o travel_back. No entanto, não se esqueça de sempre usar o travel_back se não estiver usando um bloco, como no nosso exemplo, para evitarmos o problema de testes quebradiços que vimos anteriormente.
Mas e o timecop ainda faz sentido? Sim! Em projetos que não são Rails ou que não utilizem o ActiveSupport. A dica é: se tiver em uma app Rails, ou se seu projeto tiver o ActiveSupport, utilize o travel_to; nos demais casos utilize o timecop.


#### SimpleCov

```ruby
require ’simplecov’
SimpleCov.start ’rails’
```

Por padrão, o SimpleCov é rodado todas as vezes que um teste é execu- tado, sempre exibindo este output durante o nosso TDD, o que é bastante chato, afinal não estamos preocupados com isso enquanto escrevemos nos- sos testes. Para isso, podemos definir que o SimpleCov será executado apenas se uma variável de ambiente estiver definida, vamos chamá-la de coverage e colocar o código do SimpleCov dentro de um if.

```ruby
if ENV[’coverage’] == ’on’
  require ’simplecov’
  SimpleCov.start ’rails’ do
    minimum_coverage 100
  end
end

```
Deste modo, ao rodarmos nossos testes, não teremos a saída do Sim- pleCov apenas se definirmos isso explicitamente utilizando $coverage=on rspec spec.


#### Stub

Vamos agora às dicas de quando utilizar stub.
• Quando o resultado de um dos seus colaboradores não é determinís- tico;
• Apenasemcolaboradores,nuncanoobjeto(osujeito),doseuteste;
• Quandoocolaboradorfazumaoperaçãolenta,comoacessarumaAPI.

```ruby
it ’é um valor aleatório’ do
  allow(random).to receive(:rand).with(60..80).and_return(75)
  pokemon = pokemon.new
  expect(pokemon.ataque_critico).to eq(75)
end
```

#### dublês


Agora temos o nosso cenário montado. Temos o colaborador, que é o objeto, e o nosso sujeito, o CardPresenter, que consegue fazer sua as- serção. Vamos agora escrever a nossa classe CardPresenter.

```ruby

it ’retorna um paragrafo por chave’ do
  objeto = double(’Um objeto’)
  to_presenter = { nome: ’Mauro’, idade: 24 }
  allow(objeto).to receive(:to_presenter).
    and_return(to_presenter)
  card_presenter = CardPresenter.new(objeto)
  expect(card_presenter.show).
    to eq(%{<p>nome: Mauro</p><p>idade: 24</p>})
  end
end
```



```ruby
describe ’#show’ do
  let(:objeto) do
    double(’Um objeto’)
end
  subject(:card_presenter) do
    CardPresenter.new(objeto)
end
  before do
    to_presenter = { nome: ’Mauro’, idade: 24 }
    allow(objeto).to receive(:to_presenter).
      and_return(to_presenter)
end
  it ’retorna um paragrafo por chave’ do
    expect(card_presenter.show).
      to eq(%{<p>nome: Mauro</p><p>idade: 24</p>})
  end
end

```


Super doubles

```ruby
context ’Pokemon’ do

  let(:objeto) do
    instance_double(Pokemon, to_presenter: {nome: ’Charizard’})
  end
  it ’retorna um paragrafo por chave’ do
    expect(card_presenter.show).to eq(%{<p>nome: Charizard</p>})
  end 
end
```


#### Duplications with Shared Exemple

Por con- venção, os shared examples são armazenados em spec/support/ e possuem o prefixo shared_examples_for_. Criaremos o nosso spec/support/shared_examples_for_validacao.rb.
Para criar- mos um shared example, utilizaremos o método shared_examples, que recebe como primeiro parâmetro o nome do nosso shared example e um bloco com o conteúdo do exemplo compartilhado.

```ruby
shared_examples ’valida presenca de string’ do
  describe ’#nome’ do
    it ’possui erro quando está vazio’ do
     pokemon = Pokemon.new
     pokemon.valid?
     expect(pokemon.errors[:nome]).
        to include(’não pode ficar em branco’)
    end
    # ...
  end 
end
```

utilizamos o include_examples passando o nome do shared example.

```ruby
describe ’validações’ do
  include_examples ’valida presenca de string’
end
```

##### Shared examples dinâmicos
O shared example aceita parâmetros, sendo assim, temos que passar como parâmetro a classe e um símbolo com o nome do campo do model cuja pre- sença queremos testar. Alteramos o nosso shared example para agora utili- zar o atributo que foi passado por parâmetro. Além disso, instanciamos uma classe de acordo com a que foi passada por parâmetro e assim realizamos nossa validação de presença.

```ruby
shared_examples ’valida presenca de string’ do |klass, attr|
  describe "#{attr}" do
    it ’possui erro quando está vazio’ do
      instancia = klass.new
      instancia.valid?
      expect(instancia.errors[attr]).
          to include(’não pode ficar em branco’)
    end
  end 
end
```

 Depois de executarmos as valida- ções da nossa classe, verificamos se o atributo passado não possui nenhum erro.

```ruby
it ’não possui erro quando está preenchido’ do
  params = {}
  params[attr] = ’Charizard’
  instancia = klass.new(params)
  instancia.valid?
  expect(instancia.errors[attr]).to be_empty
end
```


definimos o nosso shared example de uma maneira dinâmica temos que alterar o nosso teste para passar os parâmetros corretos. Simples- mente passamos a nossa classe Pokemon e um símbolo :nome, que é o valor que queremos testar.

```ruby
describe ’validações’ do
  include_examples ’valida presenca de string’, Pokemon, :nome
end
```


#### Create Matchers RSpec

o método failure_message, que recebe um bloco em que passamos o nosso sujeito e mostramos uma mensagem customizada.


 to_not, porém, ficaria estranha a saída se ti- véssemos a mesma mensagem que definimos no failure_message, afinal estamos fazendo o oposto agora.
Para definirmos a mensagem para quando estivermos utilizando o to_not, temos o método failure_message_when_negated que fun- ciona exatamente como failure_message, onde apenas definimos uma mensagem que faça sentido em caso de negação.

```ruby
RSpec::Matchers.define :valida_presenca_de_string do |attr|
  match do |sujeito|
    verifica_vazio?(sujeito, attr) &&
    verifica_preenchido?(sujeito, attr)
  end
  failure_message do |sujeito|
    "esperava-se que #{sujeito} tivesse validação em #{attr}"
  end

  failure_message_when_negated do |sujeito|
    "esperava-se que #{sujeito} não tivesse validação em #{attr}"
  end
end

def verifica_vazio?(sujeito, attr)
  instancia = sujeito.new
  instancia.valid?
  instancia.errors[attr].include?(’não pode ficar em branco’)
end

def verifica_preenchido?(sujeito, attr)
  params = {}
  params[attr] = ’Charizard’
  instancia = sujeito.new(params)
  instancia.valid?
  instancia.errors[attr].empty?
end





### Use in specs
it { expect(Pokemon).to valida_presenca_de_string(:nome) }
```


###### Should-matchers

```ruby

it { should validate_numericality_of(:id_nacional).only_integer
        .is_greater_than(0) }


# Model 

class Pokemon < ActiveRecord::Base
  validates :nome, :id_nacional, presence: true
  validates :id_nacional, numericality: {
    only_integer: true, greater_than: 0 }
end
```

Matchers


• email-spec:comoonomejádiz,ajuda-nosatestarose-mailsdoActi- onMailer (Email Spec)[https://github.com/bmabey/email-spec].
• rspec-sidekiq: para quando estamos utilizando o Sidekiq (ferramenta de background job) (Rspec Sidekiq)[https://github.com/philostler/rspec-sidekiq].
