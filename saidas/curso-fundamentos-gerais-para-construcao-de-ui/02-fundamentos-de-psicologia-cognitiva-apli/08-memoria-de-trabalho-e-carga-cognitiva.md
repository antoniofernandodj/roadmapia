## Memória de trabalho e carga cognitiva

Imagine que você está usando um aplicativo para preencher um formulário complexo, mas, enquanto tenta lembrar os dados que precisa inserir, começa a se sentir perdido, confuso e cansado. Esse desconforto não é acaso: ele tem origem nas limitações da **memória de trabalho** e no excesso de **carga cognitiva** imposto pela interface. Entender essas duas noções é fundamental para criar designs que não sobrecarreguem o usuário, facilitando a interação e aumentando a eficiência da interface.

### O que é memória de trabalho e por que ela importa no design?

A memória de trabalho é a capacidade temporária e limitada do cérebro para manter e manipular informações durante a execução de tarefas. Diferente da memória de longo prazo, que armazena vastos dados por tempo indefinido, a memória de trabalho é de curto prazo e suporta apenas cerca de 4 a 7 itens simultaneamente, dependendo da complexidade. Por exemplo, ao copiar um número de telefone, você o segura na memória de trabalho até digitá-lo.

No contexto do design de interfaces, a memória de trabalho é crucial porque o usuário precisa constantemente reter informações, entender instruções, lembrar o que já fez e o que falta fazer. Se a interface exigir que ele tenha muitos detalhes na cabeça ao mesmo tempo, ele pode cometer erros, esquecer passos ou se sentir frustrado.

### Carga cognitiva: o peso mental da interação

**Carga cognitiva** refere-se ao esforço mental necessário para processar informações em um dado momento. Cada decisão, leitura, interpretação, navegação ou ação consome parte da capacidade da memória de trabalho. Se a carga for muito alta — por exemplo, se o usuário precisar lembrar de várias opções, decifrar instruções confusas ou realizar múltiplas ações simultaneamente — o desempenho cai e a experiência se torna negativa.

Na prática, a carga cognitiva é influenciada por:

- Quantidade de informações apresentadas ao mesmo tempo.
- Complexidade dos termos ou instruções.
- Necessidade de lembrar dados de etapas anteriores.
- Layout confuso que dificulta encontrar o que se busca.

### Por que ignorar essas limitações atrapalha o design?

Considere um exemplo simples: um formulário de cadastro com vários campos, instruções detalhadas embutidas e múltiplas opções para selecionar. Se o usuário precisa lembrar exatamente o formato do telefone, o número do documento, a senha e ainda interpretar instruções vagas, ele vai sobrecarregar a memória de trabalho.

O erro comum é confiar que o usuário será capaz de "guardar na cabeça" tudo isso e navegar pela interface sem se perder. Quando isso acontece, a interface se torna cansativa, gera erros e aumenta a taxa de abandono.

Por exemplo, imagine o seguinte trecho de formulário:

```html
<form>
  <label for="cpf">CPF (somente números, sem pontos ou traços):</label>
  <input type="text" id="cpf" name="cpf" />
  
  <label for="telefone">Telefone (DDD + número, ex: 11999999999):</label>
  <input type="text" id="telefone" name="telefone" />
  
  <label for="senha">Senha (mínimo 8 caracteres, uma letra maiúscula, um número e um símbolo):</label>
  <input type="password" id="senha" name="senha" />
  
  <button type="submit">Enviar</button>
</form>
```

Esse formulário exige que o usuário memorize ou consulte as regras de formato para preencher corretamente, o que pode gerar erros e frustração.

### Como entender a memória de trabalho ajuda a reduzir a carga cognitiva?

Ao entender que a memória de trabalho é limitada e que a carga cognitiva deve ser controlada, o designer pode criar interfaces que:

- Apresentam informações em pedaços pequenos e gerenciáveis.
- Fornecem instruções claras e visíveis no momento da ação — não em um texto longo ou escondido.
- Evitam exigir que o usuário memorize dados ou regras complexas.
- Organizam o conteúdo para que o cérebro possa processar e reconhecer padrões rapidamente.

Por exemplo, no formulário acima, uma solução para reduzir carga cognitiva seria:

```html
<form>
  <label for="cpf">CPF:</label>
  <input type="text" id="cpf" name="cpf" placeholder="Ex: 12345678900" />
  <small>Digite apenas números, sem pontos ou traços.</small>
  
  <label for="telefone">Telefone:</label>
  <input type="text" id="telefone" name="telefone" placeholder="Ex: 11999999999" />
  <small>Inclua DDD e número, sem espaços ou símbolos.</small>
  
  <label for="senha">Senha:</label>
  <input type="password" id="senha" name="senha" />
  <small>Mínimo 8 caracteres, inclua maiúscula, número e símbolo.</small>
  
  <button type="submit">Enviar</button>
</form>
```

Aqui, as instruções são curtas, colocadas próximas do campo e com exemplos práticos. O usuário não precisa guardar na cabeça as regras: elas estão ali, na hora certa, reduzindo a carga cognitiva.

### O impacto da carga cognitiva no fluxo de interação

Quando a carga cognitiva é alta, o usuário:

- Comete mais erros por esquecer passos ou regras.
- Demora mais tempo para completar tarefas.
- Se sente cansado e frustrado.
- Pode abandonar o uso da interface.

Ao contrário, interfaces que respeitam a capacidade da memória de trabalho tornam a interação mais fluida, intuitiva e satisfatória.

### O que não é reduzir carga cognitiva

Reduzir carga cognitiva não significa simplificar demais ou remover opções importantes. O desafio é organizar e apresentar a complexidade de forma que o cérebro consiga processar sem esforço extra. Por exemplo, esconder informações essenciais para simplificar visualmente pode gerar confusão, pois o usuário terá que buscar ou lembrar dados que não estão acessíveis.

Também não é apenas diminuir o número de elementos visuais, mas criar um equilíbrio entre clareza, hierarquia e quantidade de informações.

### Exercício prático

Crie uma pequena interface web com um formulário para cadastro de usuário que contenha os seguintes campos: nome, e-mail, senha e confirmação de senha. Apresente instruções explícitas para cada campo, de forma clara e visível no momento do preenchimento, evitando que o usuário tenha que memorizar regras.

Depois, simule um erro comum: coloque as instruções apenas em um texto longo no topo do formulário, sem exemplos próximos aos campos. Tente preencher o formulário e observe a experiência.

**Solução comentada:**

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Formulário de Cadastro</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; }
    label { display: block; margin-top: 1rem; font-weight: bold; }
    input { width: 300px; padding: 0.4rem; margin-top: 0.2rem; }
    small { display: block; color: #555; font-size: 0.85rem; }
    .instructions { background: #f0f0f0; padding: 1rem; border-radius: 5px; margin-bottom: 1rem; }
  </style>
</head>
<body>
  <h1>Cadastro de Usuário</h1>

  <!-- Erro comum: instruções longe dos campos -->
  <!--
  <div class="instructions">
    <p><strong>Instruções:</strong></p>
    <ul>
      <li>Nome: preencha seu nome completo.</li>
      <li>E-mail: deve conter um "@" e domínio válido.</li>
      <li>Senha: mínimo 8 caracteres, ao menos uma letra maiúscula e um número.</li>
      <li>Confirmação de senha: deve ser igual à senha.</li>
    </ul>
  </div>
  -->

  <form>
    <label for="nome">Nome:</label>
    <input type="text" id="nome" name="nome" placeholder="Seu nome completo" />
    <small>Digite seu nome completo, com espaços.</small>

    <label for="email">E-mail:</label>
    <input type="email" id="email" name="email" placeholder="exemplo@dominio.com" />
    <small>Inclua "@" e domínio válido, ex: usuario@exemplo.com</small>

    <label for="senha">Senha:</label>
    <input type="password" id="senha" name="senha" />
    <small>Mínimo 8 caracteres, inclua maiúscula e número.</small>

    <label for="confirmaSenha">Confirme sua senha:</label>
    <input type="password" id="confirmaSenha" name="confirmaSenha" />
    <small>Digite a mesma senha para confirmar.</small>

    <button type="submit" style="margin-top:1rem;">Cadastrar</button>
  </form>
</body>
</html>
```

**Comentário:**  
Aqui, as instruções estão diretamente abaixo de cada campo, em texto curto e claro, com exemplos quando necessário. Isso facilita o processamento imediato, evita que o usuário tenha que rolar a página para lembrar as regras ou memorizar informações, reduzindo a carga cognitiva.

Já a versão com as instruções agrupadas no topo (comentada no código) força o usuário a lembrar tudo e buscar a informação no texto, aumentando a carga cognitiva e o risco de erro.

---

Entender e respeitar as limitações da memória de trabalho e a carga cognitiva é essencial para criar interfaces que o usuário consiga usar com facilidade, mesmo em tarefas complexas. O design deve facilitar o fluxo mental, não dificultá-lo.