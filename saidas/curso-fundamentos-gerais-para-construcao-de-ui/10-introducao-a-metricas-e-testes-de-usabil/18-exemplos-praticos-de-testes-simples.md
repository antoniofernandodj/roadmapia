## Exemplos práticos de testes simples

Imagine que você acabou de criar um protótipo interativo para uma página de cadastro de usuários em um aplicativo móvel. Antes de avançar para o desenvolvimento, é essencial validar se os usuários realmente conseguem completar essa tarefa com facilidade e sem erros. Um teste simples de usabilidade pode ser aplicado para responder perguntas concretas, como: “Os usuários entendem quais informações devem preencher?”, “Conseguem finalizar o cadastro sem dúvidas?” e “Quanto tempo levam para concluir a tarefa?”.

### Exemplo 1: Teste de tarefa única — cadastro de usuário

**Objetivo:** Avaliar se o usuário consegue completar o cadastro.

**Procedimento:**

1. Apresente o protótipo da tela de cadastro.
2. Dê a tarefa: “Por favor, cadastre-se no aplicativo usando este formulário.”
3. Observe o usuário realizando a tarefa, anotando:
   - Tempo gasto desde o início até a finalização.
   - Dificuldades ou dúvidas expressas.
   - Erros cometidos (como preencher campo errado ou pular algum).
4. Pergunte ao final: “Como você avaliaria a facilidade de usar esta tela de 1 a 5?”

**Exemplo prático em texto:**

Imagine que um usuário levou 3 minutos para concluir, hesitou ao preencher o campo “Senha” porque não viu um indicativo dos requisitos mínimos, e ao final deu nota 3 pela dificuldade. Esse dado qualitativo e quantitativo já aponta para melhorias claras: adicionar instruções visíveis para senha e simplificar o fluxo.

---

### Exemplo 2: Teste de navegação — encontrar informações em um site

Suponha que você projetou um menu para um site de notícias. Quer saber se os usuários conseguem encontrar a seção “Tecnologia” rapidamente.

**Procedimento:**

1. Apresente o protótipo da página inicial.
2. Dê a tarefa: “Encontre a seção de notícias sobre tecnologia.”
3. Cronometre o tempo desde o início até o clique correto.
4. Observe se o usuário tenta clicar em outras áreas antes de achar o menu correto.
5. Pergunte qual foi a dificuldade e se a navegação pareceu intuitiva.

**Erro comum:** Usuários demoram mais de 1 minuto ou clicam vários links errados.

**O que isso significa:** O menu está pouco claro ou mal posicionado. Talvez o nome “Tecnologia” precise ser mais destacado ou agrupado em categorias melhores.

---

### Exemplo 3: Teste A/B simples — botão com cores diferentes

Você quer saber qual cor de botão gera mais cliques na tela de confirmação.

**Versão A:** botão verde com texto “Confirmar”.

**Versão B:** botão azul com texto “Confirmar”.

**Procedimento:**

1. Divida os usuários em dois grupos.
2. Apresente para cada grupo uma versão do protótipo.
3. Conte quantos usuários clicam no botão em um tempo máximo.
4. Compare as taxas de clique.

**Resultado hipotético:**

- Grupo A: 8 de 10 usuários clicaram.
- Grupo B: 5 de 10 usuários clicaram.

**Interpretação:** O botão verde é mais eficaz para chamar atenção e incentivar a ação.

---

### Como evitar erros comuns em testes simples

- **Não oriente demais o usuário:** Diga apenas a tarefa, não como fazer.
- **Não interrompa o usuário durante a tarefa:** Observe, anote e só pergunte depois.
- **Evite tarefas irreais:** Use cenários próximos do uso real para obter dados relevantes.
- **Não colete só números:** Anote comentários e reações — a satisfação e dificuldades são valiosas.

---

### Código para medir tempo em teste presencial com JavaScript

Se o protótipo for web e você quiser medir o tempo que o usuário leva para completar uma tarefa simples, pode usar um pequeno script:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Teste de Tempo</title>
</head>
<body>
  <h1>Cadastro Simples</h1>
  <form id="cadastroForm">
    <label for="email">Email:</label><br />
    <input type="email" id="email" required /><br /><br />
    <label for="senha">Senha:</label><br />
    <input type="password" id="senha" required /><br /><br />
    <button type="submit">Cadastrar</button>
  </form>

  <script>
    const form = document.getElementById('cadastroForm');
    const startTime = Date.now();

    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const endTime = Date.now();
      const durationSeconds = ((endTime - startTime) / 1000).toFixed(2);
      alert(`Cadastro concluído em ${durationSeconds} segundos.`);
      // Aqui você pode enviar o tempo para um servidor ou armazenar localmente
    });
  </script>
</body>
</html>
```

**Como usar:** Abra o arquivo em um navegador, peça ao usuário para preencher o formulário e enviar. O alerta mostrará quanto tempo ele levou para completar a tarefa. Essa métrica simples ajuda a identificar se o fluxo está rápido ou lento demais.

---

### Exercício prático

Construa um protótipo simples de uma tela de login (email e senha) usando qualquer ferramenta que preferir (Figma, Lunacy, papel+caneta digitalizado). Depois, aplique um teste simples com pelo menos um usuário (pode ser um colega ou amigo):

- Defina a tarefa: “Faça login na conta.”
- Observe:
  - Se o usuário entende onde clicar e o que preencher.
  - Quanto tempo leva até clicar no botão de login.
  - Se reclama de algum detalhe na interface.
- Anote o feedback qualitativo e quantitativo.
- Identifique pelo menos duas melhorias com base nas observações.

---

### Solução comentada do exercício

Suponha que seu usuário demorou 1 minuto para encontrar o campo “Senha” porque ele está logo abaixo do botão “Login”, o que confundiu a ordem natural do preenchimento. Além disso, ele clicou no botão “Esqueci a senha” por engano.

**Melhorias recomendadas:**

1. Reorganizar a ordem dos campos para que “Email” e “Senha” fiquem juntos, com o botão “Login” abaixo deles.
2. Destacar visualmente o botão “Esqueci a senha” para que pareça menos um botão principal, evitando cliques errados.

Esse tipo de teste simples, mesmo sem ferramentas sofisticadas, já entrega insights valiosos para aprimorar a interface antes do desenvolvimento.

---

Testes simples e rápidos são poderosas ferramentas que permitem validar hipóteses, identificar problemas de usabilidade e guiar melhorias iterativas em UI/UX. Eles não precisam ser complexos ou caros para gerar resultados relevantes, desde que planejados com clareza e foco nas tarefas reais dos usuários. A prática constante desses testes ajuda a criar produtos mais intuitivos, eficientes e agradáveis.