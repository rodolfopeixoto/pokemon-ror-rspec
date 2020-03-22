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