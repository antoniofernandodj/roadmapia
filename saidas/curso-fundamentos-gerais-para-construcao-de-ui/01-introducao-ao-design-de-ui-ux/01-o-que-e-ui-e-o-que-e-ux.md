## O que é UI e o que é UX

Imagine que você está usando um aplicativo no celular para pedir uma pizza. Você abre o app, vê um menu com imagens apetitosas, escolhe os sabores, insere seu endereço e finaliza o pedido. Se tudo acontece de forma simples, rápida e agradável, você está vivenciando uma boa experiência. Mas se o aplicativo é confuso, os botões são difíceis de encontrar ou as informações não ficam claras, a frustração aparece — e você provavelmente não vai recomendar ou usar aquele app novamente. Essa diferença entre uma experiência fácil e uma complicada está no coração do que chamamos de UX e UI, dois conceitos fundamentais para o sucesso de qualquer produto digital.

### UX: Experiência do Usuário

UX, ou *User Experience* (Experiência do Usuário), trata de todo o conjunto de sensações, emoções e percepções que uma pessoa tem ao interagir com um produto, sistema ou serviço. Não se limita a telas ou interfaces, mas inclui todos os aspectos da interação entre o usuário e a empresa, produto ou serviço.

Por que a experiência do usuário importa? Porque um produto pode ter a interface mais bonita do mundo, mas se for difícil de usar, lento ou frustrante, o usuário vai desistir. UX é o que garante que o produto atenda às necessidades reais do usuário, proporcionando facilidade, eficiência, satisfação e até prazer.

No caso do app de pizza, a UX envolve entender quem são os usuários, o que eles querem pedir, como eles preferem navegar, quais são seus principais problemas e expectativas. Também considera o tempo que o pedido demora para ser concluído, se as informações são claras, se o usuário sente segurança e confiança no processo.

### UI: Interface do Usuário

UI, ou *User Interface* (Interface do Usuário), é o conjunto de elementos visuais e interativos com os quais o usuário efetivamente interage. São os botões, menus, textos, cores, ícones, imagens, layouts e animações que compõem a tela do aplicativo ou site.

A UI é o ponto de contato imediato entre o usuário e o sistema. Ela deve ser intuitiva, coerente e visualmente agradável para tornar a experiência fluída. Em outras palavras, UI é a “fachada” do produto, o que você vê e toca.

Voltando ao exemplo do app de pizza: a UI é o design do cardápio, o formato dos botões para adicionar sabores, o posicionamento do campo para inserir o endereço, a cor do botão de “finalizar pedido” e a forma como os feedbacks visuais aparecem para confirmar as ações do usuário.

### Diferenças entre UI e UX — e como se complementam

É comum confundir UI e UX, porque estão intimamente ligadas e trabalham juntas para o sucesso do produto. Porém, são conceitos distintos:

- **UX trata do sentimento e da experiência global do usuário.** É o “porquê” e o “como” da interação funcionar para o usuário.
- **UI trata da aparência e da usabilidade da interface.** É o “o quê” o usuário vê e manipula.

Para ilustrar, pense em uma loja física:

- A UX é toda a experiência de entrar na loja, encontrar os produtos, ser atendido, pagar, sentir-se confortável e satisfeito.
- A UI é o design da vitrine, a disposição dos produtos, a sinalização das seções, a aparência dos caixas e das etiquetas.

Um produto com excelente UI, mas sem uma boa UX, pode ser bonito, porém usar difícil e frustrante. Por outro lado, um produto com uma UX muito bem planejada, mas com uma UI pobre ou desatualizada, pode parecer pouco confiável ou não atrativo, afastando o usuário. O ideal é que UI e UX caminhem juntas: a interface atraente e funcional suporta e realça a experiência positiva do usuário.

### Por que essa distinção importa para desenvolvedores em transição para UX?

Como desenvolvedor, você já conhece a importância de criar sistemas funcionais e estáveis. A UI e a UX entram como camadas adicionais para garantir que o sistema não só funcione, mas também seja útil, fácil e agradável para quem o usa.

Compreender a diferença entre UI e UX ajuda a:

- Comunicar-se melhor com designers e equipes multidisciplinares.
- Identificar problemas que não são apenas técnicos, mas de experiência.
- Participar ativamente da criação de produtos centrados no usuário.
- Evitar erros comuns, como focar só na aparência (UI) sem considerar se o usuário consegue realizar suas tarefas (UX).

### Exemplo prático: o erro comum de confundir UI com UX

Suponha que você crie um formulário de cadastro com um design moderno, cores vibrantes e muitos efeitos visuais (UI), mas não se preocupe em tornar o formulário simples ou claro para o usuário (UX). Resultado típico:

- Usuário não entende quais campos são obrigatórios.
- O botão de envio está escondido ou não responde rapidamente.
- Não há mensagens claras de erro ou sucesso.

Esse cenário gera frustração, abandono do formulário e perda de usuários, mesmo com uma interface bonita.

Mensagem de erro comum que o usuário poderia enfrentar:

```
Erro: Não foi possível enviar o formulário.
Por favor, preencha todos os campos obrigatórios.
```

Se essa mensagem aparece sem indicar quais campos faltam ou com um texto genérico, o usuário não sabe o que fazer.

Correção com foco em UX e UI:

- Use marcas visuais claras para campos obrigatórios.
- Apresente mensagens de erro específicas próximas ao campo que precisa de atenção.
- Torne o botão de envio visível e responsivo.
- Simplifique a quantidade de campos para o essencial.

### Código completo: formulário simples com feedback visual claro

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Formulário de Cadastro</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background: #f9f9f9;
    }
    form {
      background: #fff;
      padding: 20px;
      border-radius: 6px;
      max-width: 400px;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    label {
      display: block;
      margin-bottom: 6px;
      font-weight: bold;
    }
    input[type="text"], input[type="email"] {
      width: 100%;
      padding: 8px;
      margin-bottom: 12px;
      border: 1px solid #ccc;
      border-radius: 4px;
      box-sizing: border-box;
    }
    .error {
      border-color: #e74c3c;
      background: #fceae9;
    }
    .error-message {
      color: #e74c3c;
      font-size: 0.9em;
      margin-top: -10px;
      margin-bottom: 10px;
    }
    button {
      background-color: #3498db;
      color: white;
      border: none;
      padding: 10px 16px;
      border-radius: 4px;
      cursor: pointer;
      font-size: 1em;
    }
    button:disabled {
      background-color: #95a5a6;
      cursor: not-allowed;
    }
    .success-message {
      color: #27ae60;
      font-weight: bold;
      margin-top: 16px;
    }
  </style>
</head>
<body>
  <h2>Cadastro</h2>
  <form id="registerForm" novalidate>
    <label for="name">Nome completo <span style="color:#e74c3c;">*</span></label>
    <input type="text" id="name" name="name" required />
    <div class="error-message" id="nameError"></div>

    <label for="email">E-mail <span style="color:#e74c3c;">*</span></label>
    <input type="email" id="email" name="email" required />
    <div class="error-message" id="emailError"></div>

    <button type="submit">Enviar</button>
    <div class="success-message" id="successMessage"></div>
  </form>

  <script>
    const form = document.getElementById('registerForm');
    const nameInput = document.getElementById('name');
    const emailInput = document.getElementById('email');
    const nameError = document.getElementById('nameError');
    const emailError = document.getElementById('emailError');
    const successMessage = document.getElementById('successMessage');

    form.addEventListener('submit', event => {
      event.preventDefault();
      let isValid = true;

      // Limpa mensagens anteriores
      nameError.textContent = '';
      emailError.textContent = '';
      nameInput.classList.remove('error');
      emailInput.classList.remove('error');
      successMessage.textContent = '';

      // Validação do nome
      if (!nameInput.value.trim()) {
        nameError.textContent = 'Por favor, insira seu nome completo.';
        nameInput.classList.add('error');
        isValid = false;
      }

      // Validação do e-mail (simples)
      if (!emailInput.value.trim()) {
        emailError.textContent = 'Por favor, insira seu e-mail.';
        emailInput.classList.add('error');
        isValid = false;
      } else if (!emailInput.value.includes('@')) {
        emailError.textContent = 'E-mail inválido.';
        emailInput.classList.add('error');
        isValid = false;
      }

      if (isValid) {
        successMessage.textContent = 'Cadastro enviado com sucesso!';
        form.reset();
      }
    });
  </script>
</body>
</html>
```

#### Saída na prática

Ao abrir essa página e tentar enviar o formulário vazio, o usuário verá mensagens de erro específicas abaixo dos campos, com bordas vermelhas que indicam claramente onde corrigir. Se preencher corretamente, verá a mensagem de sucesso confirmando o envio.

---

### Exercício

Crie um formulário para login com dois campos: email e senha. Garanta que:

- Os campos sejam obrigatórios.
- A senha tenha no mínimo 6 caracteres.
- Mensagens de erro claras apareçam próximas aos campos.
- O botão de login esteja sempre visível e responsivo.

Teste enviando dados incorretos e depois corretos para observar o comportamento.

---

### Solução comentada

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Formulário de Login</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; background: #f9f9f9; }
    form { background: #fff; padding: 20px; border-radius: 6px; max-width: 350px; box-shadow: 0 0 10px rgba(0,0,0,0.1);}
    label { display: block; margin-bottom: 6px; font-weight: bold; }
    input[type="email"], input[type="password"] {
      width: 100%; padding: 8px; margin-bottom: 12px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;
    }
    .error { border-color: #e74c3c; background: #fceae9; }
    .error-message { color: #e74c3c; font-size: 0.9em; margin-top: -10px; margin-bottom: 10px; }
    button {
      background-color: #3498db; color: white; border: none; padding: 10px 16px; border-radius: 4px; cursor: pointer; font-size: 1em;
    }
    button:disabled { background-color: #95a5a6; cursor: not-allowed; }
    .success-message { color: #27ae60; font-weight: bold; margin-top: 16px; }
  </style>
</head>
<body>
  <h2>Login</h2>
  <form id="loginForm" novalidate>
    <label for="email">E-mail <span style="color:#e74c3c;">*</span></label>
    <input type="email" id="email" name="email" required />
    <div class="error-message" id="emailError"></div>

    <label for="password">Senha <span style="color:#e74c3c;">*</span></label>
    <input type="password" id="password" name="password" required />
    <div class="error-message" id="passwordError"></div>

    <button type="submit">Login</button>
    <div class="success-message" id="successMessage"></div>
  </form>

  <script>
    const form = document.getElementById('loginForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const emailError = document.getElementById('emailError');
    const passwordError = document.getElementById('passwordError');
    const successMessage = document.getElementById('successMessage');

    form.addEventListener('submit', event => {
      event.preventDefault();
      let isValid = true;

      emailError.textContent = '';
      passwordError.textContent = '';
      emailInput.classList.remove('error');
      passwordInput.classList.remove('error');
      successMessage.textContent = '';

      if (!emailInput.value.trim()) {
        emailError.textContent = 'Por favor, insira seu e-mail.';
        emailInput.classList.add('error');
        isValid = false;
      } else if (!emailInput.value.includes('@')) {
        emailError.textContent = 'E-mail inválido.';
        emailInput.classList.add('error');
        isValid = false;
      }

      if (!passwordInput.value) {
        passwordError.textContent = 'Por favor, insira sua senha.';
        passwordInput.classList.add('error');
        isValid = false;
      } else if (passwordInput.value.length < 6) {
        passwordError.textContent = 'A senha deve ter pelo menos 6 caracteres.';
        passwordInput.classList.add('error');
        isValid = false;
      }

      if (isValid) {
        successMessage.textContent = 'Login realizado com sucesso!';
        form.reset();
      }
    });
  </script>
</body>
</html>
```

**Comentários:**

- O formulário garante clareza das informações necessárias.
- As mensagens de erro aparecem imediatamente abaixo do campo problemático.
- O botão permanece visível e clicável o tempo todo.
- O usuário recebe feedback positivo após o envio correto, reforçando a boa experiência.

---