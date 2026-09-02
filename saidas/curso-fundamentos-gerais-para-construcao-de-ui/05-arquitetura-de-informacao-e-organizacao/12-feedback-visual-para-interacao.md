## Feedback visual para interação

Imagine que você está usando um aplicativo e toca em um botão para enviar um formulário. Se nada acontecer na tela, você fica em dúvida: o comando foi recebido? O que está acontecendo? Esse tipo de incerteza gera frustração e prejudica a interação.

O feedback visual para interação é a resposta que a interface fornece ao usuário imediatamente após uma ação, confirmando que aquela ação foi percebida pelo sistema. Ele reduz a incerteza, aumenta a confiança do usuário e torna a experiência mais fluida. Sem esse retorno, mesmo a melhor arquitetura de informação e organização visual podem parecer confusas ou pouco responsivas.

### Por que o feedback visual é essencial?

O cérebro humano depende de estímulos visuais para entender o ambiente e as consequências de suas ações. Quando um usuário interage com uma interface, espera uma resposta clara e rápida. Se a resposta visual demora ou não aparece, o usuário pode pensar que a ação falhou, repetir o comando desnecessariamente, ou abandonar a tarefa.

Além disso, o feedback visual ajuda a guiar os usuários pelo fluxo da interface, indicando estados, erros, sucessos e mudanças contextuais. Isso complementa a arquitetura da informação e a hierarquia visual, tornando a navegação mais natural.

### Como fornecer feedback visual eficaz?

O feedback visual deve ser imediato, claro e consistente com o restante do design visual. Ele pode ser aplicado em diferentes elementos, como botões, links, campos de formulário, menus e ícones.

Veja alguns tipos comuns de feedback visual para interação:

- **Mudança de cor ou sombra ao clicar:** Indica que o botão ou link foi acionado.
- **Alteração de forma ou tamanho temporária:** Como um leve “apertar” do botão, simulando um toque físico.
- **Exibição de um ícone de carregamento:** Para ações que demoram a processar.
- **Realce de campo ativo:** Mostra qual campo está selecionado para digitação.
- **Indicação de erro ou sucesso:** Como bordas vermelhas em campos inválidos ou mensagens de confirmação.

### Exemplo prático em HTML e CSS

Vamos criar um botão que muda de cor e dá a sensação de “apertar” quando clicado, simulando um feedback visual simples e eficaz.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Feedback Visual - Exemplo</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 2rem;
      background-color: #f0f0f0;
    }

    button {
      background-color: #007bff;
      color: white;
      border: none;
      padding: 1rem 2rem;
      font-size: 1.25rem;
      border-radius: 4px;
      cursor: pointer;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      transition: background-color 0.2s ease, transform 0.1s ease;
      user-select: none;
    }

    button:hover {
      background-color: #0056b3;
    }

    button:active {
      background-color: #004085;
      transform: translateY(2px);
      box-shadow: 0 2px 3px rgba(0,0,0,0.2);
    }

    /* Feedback para foco via teclado */
    button:focus {
      outline: 3px solid #80bdff;
      outline-offset: 2px;
    }
  </style>
</head>
<body>

  <button id="sendBtn" aria-live="polite" aria-label="Enviar formulário">
    Enviar
  </button>

</body>
</html>
```

#### Explicação do código

- O botão tem uma cor azul padrão (#007bff).
- Ao passar o mouse (`:hover`), ele escurece um pouco, indicando que está interativo.
- Ao ser clicado (`:active`), a cor escurece mais e o botão se move 2 pixels para baixo (`transform: translateY(2px)`), simulando uma pressão tátil.
- O `box-shadow` é ajustado para reforçar o efeito de profundidade.
- O foco com teclado (`:focus`) recebe um contorno visível para acessibilidade, sinalizando que está selecionado.
- O atributo `aria-live="polite"` no botão indica que as mudanças de texto ou estado podem ser comunicadas a leitores de tela, embora neste caso o texto não mude.

### Erro comum e sua correção

Considere o seguinte código incompleto e problemático:

```html
<button>Enviar</button>
```

Sem estilos, esse botão não fornece nenhum feedback visual além do padrão do navegador, que pode variar e ser pouco perceptível. O usuário pode não perceber se o clique foi registrado, especialmente em dispositivos móveis.

Além disso, sem foco visível, usuários que navegam via teclado ou tecnologias assistivas podem se perder na navegação, prejudicando acessibilidade.

Corrigindo com o código anterior, garantimos que o botão seja perceptível, responsivo e acessível.

### Aplicando feedback visual em campos de formulário

Outro exemplo importante é o feedback ao focar campos de entrada para preenchimento. Quando o usuário clica ou navega até um campo, ele deve ficar destacado para indicar onde está digitando.

Veja um exemplo simples:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Feedback em Campo de Formulário</title>
  <style>
    input[type="text"] {
      padding: 0.5rem;
      font-size: 1rem;
      border: 2px solid #ccc;
      border-radius: 4px;
      transition: border-color 0.3s ease;
      width: 300px;
    }

    input[type="text"]:focus {
      border-color: #007bff;
      outline: none;
      box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
    }
  </style>
</head>
<body>

  <label for="nome">Nome:</label><br />
  <input type="text" id="nome" name="nome" placeholder="Digite seu nome" />

</body>
</html>
```

#### Como funciona?

- O campo tem uma borda cinza clara por padrão.
- Quando o campo recebe foco (`:focus`), a borda muda para azul (#007bff) e um brilho suave aparece ao redor.
- A transição suave torna a mudança agradável visualmente.
- A ausência do contorno padrão (`outline`) é compensada pelo `box-shadow`, mantendo a acessibilidade e clareza visual.

### Feedback para erros e validações

Um dos momentos mais críticos para o usuário é quando ele comete um erro, por exemplo, em um formulário. O feedback visual deve indicar claramente onde está o problema e o que precisa ser corrigido.

Veja um exemplo de campo com validação simples em JavaScript e feedback visual:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Feedback de Erro em Formulário</title>
  <style>
    input {
      padding: 0.5rem;
      font-size: 1rem;
      border: 2px solid #ccc;
      border-radius: 4px;
      width: 300px;
      transition: border-color 0.3s ease;
    }

    input.error {
      border-color: #dc3545;
      background-color: #f8d7da;
    }

    .error-message {
      color: #dc3545;
      font-size: 0.9rem;
      margin-top: 0.25rem;
      font-weight: bold;
      display: none;
    }

    .error-message.active {
      display: block;
    }
  </style>
</head>
<body>

  <label for="email">Email:</label><br />
  <input type="text" id="email" name="email" placeholder="Digite seu email" aria-describedby="emailError" />
  <div id="emailError" class="error-message">Email inválido. Por favor, corrija.</div>

  <button id="submitBtn">Enviar</button>

  <script>
    const emailInput = document.getElementById('email');
    const errorMessage = document.getElementById('emailError');
    const submitBtn = document.getElementById('submitBtn');

    function validateEmail(email) {
      // Expressão regular simples para validar email
      return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    submitBtn.addEventListener('click', function() {
      if (!validateEmail(emailInput.value)) {
        emailInput.classList.add('error');
        errorMessage.classList.add('active');
        emailInput.focus();
      } else {
        emailInput.classList.remove('error');
        errorMessage.classList.remove('active');
        alert('Email válido! Formulário enviado.');
      }
    });
  </script>

</body>
</html>
```

#### O que acontece?

- Ao clicar em "Enviar", o JavaScript valida o formato do email.
- Se inválido, o campo ganha uma borda vermelha e fundo rosado, e a mensagem de erro aparece.
- O campo é focado para que o usuário corrija facilmente.
- Se válido, o feedback visual de erro desaparece e o alerta confirma o envio.

### Evitando excessos e confusão

Embora o feedback visual seja essencial, é importante não exagerar. Muitos efeitos visuais simultâneos podem cansar e distrair o usuário, além de impactar a performance em dispositivos mais simples.

Evite:

- Feedbacks que desaparecem rápido demais, antes que o usuário perceba.
- Mudanças bruscas e inconsistentes com o restante da interface.
- Uso excessivo de cores fortes e piscantes.
- Feedbacks que dependem apenas de cor (problema para pessoas com daltonismo).

### Exercício prático

Construa uma pequena página HTML com um formulário de login contendo:

- Dois campos: usuário e senha.
- Um botão "Entrar".
- Forneça feedback visual quando o botão for clicado:
  - O botão deve mudar visualmente para indicar que foi pressionado.
  - Se algum dos campos estiver vazio, o campo deve ficar com borda vermelha e uma mensagem de erro deve aparecer abaixo.
  - O campo com erro deve ser automaticamente focado para correção.
  - Se ambos os campos estiverem preenchidos, exiba uma mensagem de sucesso.

Comente seu código para explicar como cada feedback visual ajuda o usuário.

---

### Solução comentada

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Exercício - Feedback Visual no Login</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 2rem;
      background-color: #fafafa;
    }

    label {
      font-weight: bold;
    }

    input {
      display: block;
      margin: 0.25rem 0 1rem 0;
      padding: 0.5rem;
      width: 300px;
      font-size: 1rem;
      border: 2px solid #ccc;
      border-radius: 4px;
      transition: border-color 0.3s ease, background-color 0.3s ease;
    }

    input:focus {
      border-color: #007bff;
      outline: none;
      box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
    }

    input.error {
      border-color: #dc3545;
      background-color: #f8d7da;
    }

    .error-message {
      color: #dc3545;
      font-size: 0.9rem;
      margin-top: -0.75rem;
      margin-bottom: 1rem;
      font-weight: bold;
      display: none;
    }

    .error-message.active {
      display: block;
    }

    button {
      background-color: #28a745;
      color: white;
      border: none;
      padding: 1rem 2rem;
      font-size: 1.25rem;
      border-radius: 4px;
      cursor: pointer;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      transition: background-color 0.2s ease, transform 0.1s ease;
      user-select: none;
    }

    button:active {
      background-color: #218838;
      transform: translateY(2px);
      box-shadow: 0 2px 3px rgba(0,0,0,0.2);
    }

    #successMessage {
      color: #155724;
      background-color: #d4edda;
      border: 1px solid #c3e6cb;
      padding: 1rem;
      border-radius: 4px;
      margin-top: 1rem;
      display: none;
    }
  </style>
</head>
<body>

  <form id="loginForm" novalidate>
    <label for="usuario">Usuário:</label>
    <input type="text" id="usuario" name="usuario" aria-describedby="usuarioError" />
    <div id="usuarioError" class="error-message">O campo usuário é obrigatório.</div>

    <label for="senha">Senha:</label>
    <input type="password" id="senha" name="senha" aria-describedby="senhaError" />
    <div id="senhaError" class="error-message">O campo senha é obrigatório.</div>

    <button type="submit" aria-live="polite" aria-label="Entrar no sistema">Entrar</button>
  </form>

  <div id="successMessage" role="alert" aria-live="assertive">
    Login realizado com sucesso!
  </div>

  <script>
    const form = document.getElementById('loginForm');
    const usuario = document.getElementById('usuario');
    const senha = document.getElementById('senha');
    const usuarioError = document.getElementById('usuarioError');
    const senhaError = document.getElementById('senhaError');
    const successMessage = document.getElementById('successMessage');

    form.addEventListener('submit', function(event) {
      event.preventDefault(); // Evita envio padrão para demonstrar feedback

      // Remove estados anteriores
      usuario.classList.remove('error');
      senha.classList.remove('error');
      usuarioError.classList.remove('active');
      senhaError.classList.remove('active');
      successMessage.style.display = 'none';

      let hasError = false;

      if (usuario.value.trim() === '') {
        usuario.classList.add('error');
        usuarioError.classList.add('active');
        usuario.focus();
        hasError = true;
      }

      if (!hasError && senha.value.trim() === '') {
        senha.classList.add('error');
        senhaError.classList.add('active');
        senha.focus();
        hasError = true;
      }

      if (!hasError) {
        // Feedback de sucesso visível e acessível
        successMessage.style.display = 'block';
        // Limpa campos para nova interação
        form.reset();
      }
    });
  </script>

</body>
</html>
```

#### Comentários sobre a solução

- O botão muda visualmente ao ser pressionado (`:active`), confirmando o clique.
- Campos vazios recebem borda vermelha e fundo rosado para destacar o erro.
- Mensagens de erro aparecem logo abaixo do campo, em vermelho, com texto claro.
- O foco vai automaticamente para o primeiro campo com erro, facilitando a correção.
- Quando o formulário é enviado com sucesso, uma mensagem verde aparece, confirmando a ação.
- Todos os elementos usam atributos ARIA para melhorar a acessibilidade.

---

Esse controle visual do feedback torna a interação mais clara, reduz dúvidas e ajuda a guiar o usuário pela interface com segurança e conforto, essencial para uma boa experiência.