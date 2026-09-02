## Introdução à usabilidade

Imagine que você precise preencher um formulário online para reservar uma pizza no app que você já conhece. Se os campos estiverem confusos, os botões difíceis de identificar ou as instruções pouco claras, a experiência rapidamente se transforma em frustração. Talvez você até desista do pedido. Mas por que isso acontece? A resposta está na usabilidade da interface.

**Usabilidade** é a qualidade que determina o quão fácil, eficiente e satisfatório é para um usuário alcançar seus objetivos ao interagir com um produto digital. Ela não se limita à beleza visual da interface ou à complexidade técnica do sistema, mas foca em garantir que o usuário consiga usar o produto sem esforço desnecessário, confusão ou erros.

### O que a usabilidade resolve na prática?

Quando uma interface tem boa usabilidade, o usuário:

- Compreende rapidamente como realizar as tarefas desejadas, sem precisar de manual ou ajuda externa.
- Consegue completar ações com o mínimo de passos e esforço mental.
- Evita cometer erros ou sabe como corrigi-los facilmente.
- Sente-se confortável e confiante durante a interação, o que gera satisfação e fidelização.

Por outro lado, uma interface mal-usável gera dúvidas, erros, retrabalho e, muitas vezes, abandono do produto, mesmo que ele tecnicamente funcione bem. A usabilidade é o elo entre o design da interface (UI) e a experiência total do usuário (UX), garantindo que a jornada do usuário seja fluida e livre de obstáculos.

### Como a usabilidade atua no dia a dia do usuário?

Considere o fluxo de fazer um pedido pelo app de pizza:

1. **Localizar o cardápio:** Se os itens estiverem organizados de forma lógica e clara, o usuário encontra rapidamente o que deseja.
2. **Personalizar o pedido:** Botões e menus devem ser intuitivos para escolher tamanho, ingredientes e quantidade, sem confusão.
3. **Finalizar a compra:** O processo de pagamento precisa ser direto, com feedback claro sobre o status da transação.
4. **Confirmação e acompanhamento:** Informações sobre o pedido e tempo de entrega devem estar visíveis e compreensíveis.

Cada uma dessas etapas exige que a interface seja desenhada para facilitar a interação, minimizando o tempo e o esforço do usuário. Se qualquer passo for complicado, ele impacta negativamente a usabilidade e, consequentemente, a experiência completa.

### Usabilidade não é apenas "facilidade" visual

É comum pensar que uma interface bonita é automaticamente usável, mas isso não é verdade. Um botão pode ser atraente, mas se não estiver onde o usuário espera ou não indicar claramente sua função, ele falha em usabilidade. Por exemplo, um botão "Enviar" escondido ou com rótulo ambíguo causa confusão e erros.

Por isso, usabilidade envolve aspectos como:

- **Clareza:** o usuário entende o que deve fazer sem dúvidas.
- **Consistência:** elementos similares funcionam e aparecem da mesma forma em toda a interface.
- **Feedback:** a interface informa o que está acontecendo após uma ação do usuário.
- **Prevenção de erros:** minimiza a chance de o usuário errar e facilita a correção.
- **Controle e liberdade:** o usuário pode desfazer ações facilmente e navegar conforme sua vontade.

### Erro comum: confundir usabilidade com funcionalidades

Às vezes, desenvolvedores ou designers adicionam muitas funcionalidades para “enriquecer” o produto, mas isso pode prejudicar a usabilidade. Imagine um formulário com dezenas de campos obrigatórios, opções desnecessárias e informações confusas. Apesar de ser “completo”, ele será um desafio para o usuário.

Melhor do que ter muitas funcionalidades é garantir que as funções essenciais estejam simples e acessíveis. Usabilidade prioriza a experiência de uso e o sucesso do usuário, não só o número de recursos.

### Exemplo prático: formulário de cadastro com baixa usabilidade

Veja este código HTML simples de um formulário de cadastro:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Formulário de Cadastro</title>
</head>
<body>
  <form action="/submit" method="POST">
    <label for="nome">Nome completo</label><br />
    <input type="text" id="nome" name="nome" /><br /><br />

    <label for="email">E-mail</label><br />
    <input type="text" id="email" name="email" /><br /><br />

    <label for="senha">Senha (mínimo 8 caracteres)</label><br />
    <input type="password" id="senha" name="senha" /><br /><br />

    <button type="submit">Enviar</button>
  </form>
</body>
</html>
```

**Problemas de usabilidade neste formulário:**

- O campo de e-mail é do tipo `text`, não `email`, o que impede validação automática no navegador.
- A senha não possui indicação visual clara de erro se for muito curta.
- O botão "Enviar" está genérico, sem feedback visual ao clicar.
- Não há mensagens de erro ou ajuda para o usuário.

Se o usuário preencher o e-mail incorretamente, o formulário será enviado e o sistema pode rejeitar o cadastro, gerando frustração sem explicar o motivo.

### Melhorando a usabilidade do formulário

Vamos corrigir os problemas para tornar o formulário mais usável:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Formulário de Cadastro</title>
<style>
  .erro {
    color: red;
    font-size: 0.9em;
  }
  input:invalid {
    border-color: red;
  }
</style>
</head>
<body>
  <form id="cadastro" action="/submit" method="POST" novalidate>
    <label for="nome">Nome completo</label><br />
    <input type="text" id="nome" name="nome" required /><br /><br />

    <label for="email">E-mail</label><br />
    <input type="email" id="email" name="email" required /><br /><br />

    <label for="senha">Senha (mínimo 8 caracteres)</label><br />
    <input type="password" id="senha" name="senha" minlength="8" required /><br /><br />

    <button type="submit">Cadastrar</button>
    <p id="msgErro" class="erro" aria-live="polite"></p>
  </form>

  <script>
    const form = document.getElementById('cadastro');
    const msgErro = document.getElementById('msgErro');

    form.addEventListener('submit', function(event) {
      msgErro.textContent = '';
      if (!form.checkValidity()) {
        event.preventDefault();
        if (!form.nome.validity.valid) {
          msgErro.textContent = 'Por favor, preencha seu nome completo.';
          form.nome.focus();
        } else if (!form.email.validity.valid) {
          msgErro.textContent = 'Por favor, informe um e-mail válido.';
          form.email.focus();
        } else if (!form.senha.validity.valid) {
          msgErro.textContent = 'A senha deve ter pelo menos 8 caracteres.';
          form.senha.focus();
        }
      }
    });
  </script>
</body>
</html>
```

**O que mudou para melhorar a usabilidade?**

- Campos `required` para garantir preenchimento obrigatório.
- Tipo `email` para validação automática do e-mail.
- `minlength` para a senha, com verificação e mensagem de erro.
- Feedback claro e acessível (mensagem exibida e foco no campo com problema).
- Botão com texto mais específico ("Cadastrar") para indicar ação.

### Saída e comportamento esperado

Ao tentar enviar o formulário vazio, o usuário verá:

```
Por favor, preencha seu nome completo.
```

Ao inserir um nome, mas e-mail inválido, verá:

```
Por favor, informe um e-mail válido.
```

Se a senha for curta, a mensagem será:

```
A senha deve ter pelo menos 8 caracteres.
```

Esse feedback imediato e direcionado evita frustrações e orienta o usuário a concluir a tarefa com sucesso.

### Relação da usabilidade com UI e UX

- A **UI** fornece os elementos visuais e interativos (campos, botões, cores).
- A **usabilidade** garante que esses elementos funcionem de forma intuitiva, clara e eficiente.
- A **UX** engloba a usabilidade e tudo o que envolve a experiência emocional e contextual do usuário.

Sem usabilidade, a interface, por mais bonita, se torna inútil ou irritante, prejudicando toda a experiência.

### Exercício prático

Pegue um formulário que você já tenha criado ou use o exemplo acima. Tente identificar pelo menos três problemas de usabilidade que um usuário iniciante poderia enfrentar. Depois, implemente melhorias para resolver essas falhas e teste com alguém que não conheça o formulário. Observe as dificuldades reais e ajuste o design conforme o feedback.

### Solução comentada do exercício

Suponha que você tenha um formulário de contato com estes problemas:

1. Campo de telefone sem máscara ou validação, dificultando o preenchimento correto.
2. Botão de envio com texto genérico "OK", que não indica a ação.
3. Ausência de mensagens de erro quando campos obrigatórios ficam vazios.

Para melhorar:

- Use input com tipo `tel` e máscara para orientar a digitação.
- Altere o texto do botão para "Enviar Mensagem" para maior clareza.
- Implemente validação com mensagens amigáveis, usando `required` e indicadores visuais.

Assim, o formulário fica mais acessível, claro e eficiente, elevando a usabilidade e melhorando a experiência do usuário.

---