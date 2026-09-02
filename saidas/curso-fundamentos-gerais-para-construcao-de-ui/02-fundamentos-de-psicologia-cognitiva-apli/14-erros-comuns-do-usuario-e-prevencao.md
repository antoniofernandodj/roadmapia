## Erros comuns do usuário e prevenção

No design de interfaces, erros do usuário são inevitáveis, mas muitos deles decorrem de limitações cognitivas e da forma como a informação é apresentada. Entender os tipos mais comuns desses erros e como o design pode preveni-los é fundamental para criar experiências mais fluidas e satisfatórias.

### 1. Erros de reconhecimento e recordação

Usuários frequentemente confundem ou esquecem informações essenciais para a tarefa, especialmente quando a interface exige que eles recordem dados da memória sem pistas visuais. Por exemplo, um formulário que pede para o usuário digitar um código que recebeu por e-mail, mas não oferece um campo para copiar e colar, aumenta a chance de erro.

**Erro frequente:** o usuário digita o código errado, gerando mensagens de erro frustrantes.

**Mensagem típica do sistema:**

```
Código inválido. Por favor, tente novamente.
```

Esse erro acontece porque a memória de trabalho é limitada e a recordação é mais difícil que o reconhecimento. Interfaces que favorecem o reconhecimento — exibindo informações relevantes, opções visíveis e pistas contextuais — reduzem essa incidência.

**Prevenção pelo design:**

- Mostrar sugestões ou preenchimento automático.
- Permitir copiar e colar.
- Apresentar exemplos ou formatos esperados (como máscaras para telefones).
- Usar listas e menus ao invés de exigir digitação livre.

---

### 2. Erros de seleção ou clique acidental

Interfaces com elementos pequenos, próximos demais ou pouco espaçados aumentam a chance de o usuário clicar no item errado. Isso ocorre devido à limitação física da precisão motora, que a Lei de Fitts explica: quanto menor a área e maior a distância, maior o esforço e o erro.

**Erro frequente:** clicar em um botão “Excluir” em vez de “Salvar” por estarem muito próximos.

**Mensagem típica do sistema:**

```
Tem certeza que deseja excluir este arquivo? Essa ação não pode ser desfeita.
```

Embora o sistema tente prevenir com confirmação, isso gera atrito e frustração.

**Prevenção pelo design:**

- Aumentar o tamanho dos botões e áreas clicáveis.
- Separar visualmente ações críticas das comuns.
- Posicionar botões de confirmação longe dos botões de ação rápida.
- Usar cores contrastantes para indicar funções diferentes (ex.: vermelho para ações perigosas).

---

### 3. Erros por sobrecarga cognitiva e complexidade

Quando o usuário é exposto a muitas opções ou informações ao mesmo tempo, a tomada de decisão fica lenta e suscetível a erros — fenômeno explicado pela Lei de Hick. Isso acontece frequentemente em menus longos, formulários extensos ou interfaces desorganizadas.

**Erro frequente:** o usuário escolhe a opção errada, abandona o processo ou fica confuso.

**Exemplo prático:**

Um menu com 20 opções diretas causa demora no clique e escolhas erradas.

**Prevenção pelo design:**

- Agrupar opções em categorias lógicas.
- Utilizar submenus ou filtros progressivos para reduzir a quantidade visível.
- Destacar as opções mais usadas.
- Simplificar o processo, dividindo-o em etapas.

---

### 4. Erros devido a modelos mentais desalinhados

Quando a interface não corresponde ao modelo mental do usuário, ele tenta aplicar experiências anteriores que não funcionam, causando confusão e erros.

**Erro frequente:** o usuário tenta “voltar” clicando em um botão que, na interface, executa outra função.

**Exemplo prático:**

Um botão com ícone pouco reconhecível que não indica claramente sua função.

**Mensagem de erro comum:** “Não foi possível executar a ação solicitada.”

**Prevenção pelo design:**

- Usar padrões e convenções familiares.
- Aplicar rótulos claros e ícones conhecidos.
- Testar se as ações correspondem às expectativas do público-alvo.
- Evitar inovações que alterem funções básicas sem explicação clara.

---

### 5. Erros por falta de feedback ou feedback inadequado

Usuários cometem erros por não saberem se a ação foi realizada ou está em progresso. A ausência de feedback imediato gera incerteza, levando a repetições ou abandono.

**Erro frequente:** o usuário clica várias vezes no botão “Enviar” porque não vê confirmação.

**Prevenção pelo design:**

- Mostrar mudança visual no botão ao clicar (ex.: desabilitar e alterar texto para “Enviando…”).
- Exibir mensagens claras e temporárias de sucesso ou erro.
- Fornecer indicadores de carregamento para processos demorados.

---

### 6. Erros por distração e perda de foco

Interfaces com muitos elementos concorrendo pela atenção, como animações desnecessárias ou propagandas, podem desviar a atenção da tarefa principal, causando erros.

**Erro frequente:** o usuário tenta clicar em um botão de ação, mas a atenção foi desviada para um elemento visual chamativo, causando atrasos ou ações erradas.

**Prevenção pelo design:**

- Minimizar elementos animados ou visuais que não contribuem para a tarefa.
- Posicionar elementos secundários longe da área principal de interação.
- Utilizar contraste e hierarquia visual para guiar o olhar.

---

## Código exemplo: formulário simples prevendo erros comuns

Abaixo, um formulário HTML com boas práticas para prevenir erros comuns, incluindo:

- Máscara para telefone (ajuda no formato correto).
- Feedback visual imediato ao enviar.
- Botão de envio desabilitado após clique para evitar múltiplos envios.
- Agrupamento claro dos campos.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Formulário Seguro</title>
<style>
  body {
    font-family: Arial, sans-serif;
    padding: 20px;
    max-width: 400px;
    margin: auto;
  }
  label {
    display: block;
    margin-top: 15px;
  }
  input[type="text"], input[type="tel"], input[type="email"] {
    width: 100%;
    padding: 8px;
    margin-top: 5px;
    box-sizing: border-box;
  }
  button {
    margin-top: 20px;
    padding: 10px;
    width: 100%;
    background-color: #007BFF;
    border: none;
    color: white;
    font-size: 16px;
    cursor: pointer;
  }
  button:disabled {
    background-color: #aaa;
    cursor: not-allowed;
  }
  .feedback {
    margin-top: 10px;
    font-weight: bold;
  }
  .error {
    color: red;
  }
  .success {
    color: green;
  }
</style>
</head>
<body>

<h2>Formulário de Contato</h2>

<form id="contactForm" novalidate>
  <label for="name">Nome completo</label>
  <input type="text" id="name" name="name" autocomplete="name" required placeholder="Digite seu nome" />

  <label for="email">E-mail</label>
  <input type="email" id="email" name="email" autocomplete="email" required placeholder="exemplo@dominio.com" />

  <label for="phone">Telefone</label>
  <input type="tel" id="phone" name="phone" required placeholder="(99) 99999-9999" pattern="\(\d{2}\) \d{4,5}-\d{4}" />

  <button type="submit">Enviar</button>
  <div id="feedback" class="feedback" aria-live="polite"></div>
</form>

<script>
  const form = document.getElementById('contactForm');
  const feedback = document.getElementById('feedback');
  const button = form.querySelector('button');
  const phoneInput = form.phone;

  // Aplica máscara simples para telefone
  phoneInput.addEventListener('input', e => {
    let v = e.target.value.replace(/\D/g, '');
    if (v.length > 11) v = v.slice(0, 11);
    if (v.length <= 10) {
      v = v.replace(/^(\d{2})(\d{4})(\d{0,4})/, '($1) $2-$3');
    } else {
      v = v.replace(/^(\d{2})(\d{5})(\d{0,4})/, '($1) $2-$3');
    }
    e.target.value = v.trim();
  });

  form.addEventListener('submit', e => {
    e.preventDefault();
    feedback.textContent = '';
    feedback.className = 'feedback';

    if (!form.checkValidity()) {
      feedback.textContent = 'Por favor, preencha todos os campos corretamente.';
      feedback.classList.add('error');
      return;
    }

    // Simula envio
    button.disabled = true;
    button.textContent = 'Enviando...';

    setTimeout(() => {
      button.textContent = 'Enviar';
      button.disabled = false;
      form.reset();
      feedback.textContent = 'Formulário enviado com sucesso!';
      feedback.classList.add('success');
    }, 2000);
  });
</script>

</body>
</html>
```

#### Saída e comportamento esperado:

- O campo telefone aceita apenas números e formata automaticamente no padrão brasileiro.
- O botão muda o texto para "Enviando..." e fica desabilitado ao ser clicado, evitando múltiplos envios.
- Feedback visual e textual é exibido para informar o sucesso ou erro da validação.
- Campos obrigatórios e padrões são validados pelo navegador e pelo script.
- A interface é simples, organizada e dá pistas claras para o usuário, reduzindo erros de preenchimento e envio.

---

## Exercício prático

Projete uma tela de login que evite os seguintes erros comuns:

1. O usuário esquecer a senha e não conseguir recuperá-la facilmente.
2. Digitar o nome de usuário ou e-mail incorretamente sem saber o que corrigir.
3. Tentar enviar o formulário múltiplas vezes sem feedback.
4. Confundir o botão de login com outros botões (como cadastro ou ajuda).

**Requisitos:**

- Inclua dicas visuais ou links para recuperação de senha.
- Utilize placeholders e validações que indiquem erros específicos (ex.: “Email inválido”).
- Desabilite o botão de login após o clique e mostre feedback.
- Use cores e posicionamento que distingam claramente os botões.

---

## Solução comentada (exemplo simplificado)

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Tela de Login Segura</title>
<style>
  body {
    font-family: Arial, sans-serif;
    max-width: 360px;
    margin: 40px auto;
    padding: 20px;
    box-sizing: border-box;
  }
  label, input, button, a {
    display: block;
    width: 100%;
    margin-top: 12px;
  }
  input {
    padding: 10px;
    font-size: 16px;
  }
  button {
    background-color: #28a745;
    color: white;
    border: none;
    padding: 12px;
    font-size: 18px;
    cursor: pointer;
  }
  button:disabled {
    background-color: #94d3a2;
    cursor: not-allowed;
  }
  a {
    color: #007bff;
    text-align: right;
    text-decoration: none;
    margin-top: 8px;
    font-size: 14px;
  }
  .feedback {
    margin-top: 10px;
    font-weight: bold;
  }
  .error {
    color: red;
  }
</style>
</head>
<body>

<h2>Login</h2>

<form id="loginForm" novalidate>
  <label for="user">E-mail ou nome de usuário</label>
  <input type="text" id="user" name="user" placeholder="Digite seu e-mail ou usuário" required />

  <label for="password">Senha</label>
  <input type="password" id="password" name="password" placeholder="Sua senha" required minlength="6" />

  <a href="#" tabindex="0">Esqueceu a senha?</a>

  <button type="submit">Entrar</button>

  <div id="feedback" class="feedback" aria-live="polite"></div>
</form>

<script>
  const form = document.getElementById('loginForm');
  const feedback = document.getElementById('feedback');
  const button = form.querySelector('button');

  form.addEventListener('submit', e => {
    e.preventDefault();
    feedback.textContent = '';
    feedback.className = 'feedback';

    const userVal = form.user.value.trim();
    const passVal = form.password.value;

    if (!userVal) {
      feedback.textContent = 'Por favor, informe seu e-mail ou nome de usuário.';
      feedback.classList.add('error');
      return;
    }
    if (!passVal || passVal.length < 6) {
      feedback.textContent = 'A senha deve ter pelo menos 6 caracteres.';
      feedback.classList.add('error');
      return;
    }

    // Simula envio
    button.disabled = true;
    button.textContent = 'Entrando...';

    setTimeout(() => {
      // Simula erro de autenticação
      feedback.textContent = 'Usuário ou senha incorretos.';
      feedback.classList.add('error');
      button.disabled = false;
      button.textContent = 'Entrar';
    }, 1500);
  });
</script>

</body>
</html>
```

**Comentários da solução:**

- O formulário valida campos obrigatórios e tamanho mínimo da senha para evitar erros básicos.
- O link "Esqueceu a senha?" está destacado e acessível para recuperação.
- Feedback textual claro informa o usuário sobre o erro específico.
- O botão muda o texto e é desabilitado ao enviar para prevenir múltiplos envios.
- A cor verde do botão de login contrasta com o azul do link, distinguindo ações.

---

Prevenir erros do usuário pelo design não elimina completamente os enganos, mas reduz drasticamente sua frequência e impacto, melhorando a fluidez e satisfação na interação. Compreender as limitações cognitivas e as causas comuns desses erros facilita criar interfaces mais humanas, acessíveis e seguras.