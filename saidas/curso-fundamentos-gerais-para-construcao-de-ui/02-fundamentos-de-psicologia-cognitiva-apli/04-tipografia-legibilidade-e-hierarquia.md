## Tipografia: legibilidade e hierarquia

Imagine que você abriu uma página de um aplicativo ou site e, ao invés de conseguir ler facilmente o conteúdo, seus olhos ficam cansados, confundidos, ou você simplesmente não sabe onde começar. Isso acontece frequentemente quando a tipografia não é bem planejada. A tipografia — o uso de fontes, tamanhos, espaçamentos e estilos — não é apenas uma questão estética; ela é essencial para a legibilidade do texto e para guiar o olhar do usuário pela interface, criando uma hierarquia visual clara.

### Por que a tipografia afeta a legibilidade?

A legibilidade é a facilidade com que o usuário consegue reconhecer as letras e as palavras. Se o texto for difícil de decifrar, o usuário vai se frustrar, perder atenção e provavelmente abandonar a tarefa. O cérebro humano, que já tem capacidade limitada para processar informações (como vimos na psicologia cognitiva), não pode gastar esforço extra para interpretar letras confusas.

Vejamos o que realmente impacta a legibilidade:

- **Tamanho da fonte:** Fontes muito pequenas exigem esforço visual e aumentam a carga cognitiva. Fontes muito grandes podem quebrar o fluxo da leitura.
- **Espaçamento entre letras (tracking) e entre linhas (leading):** Letras muito juntas ou muito afastadas dificultam a leitura fluida. Espaçamento adequado ajuda o cérebro a distinguir cada palavra sem esforço.
- **Contraste:** Texto deve se destacar do fundo, com contraste suficiente para ser lido sem esforço. Texto cinza claro em fundo branco é um erro comum que prejudica a leitura.
- **Tipo de fonte:** Fontes com formas claras e sem muitos detalhes são mais legíveis, especialmente em tamanhos pequenos. Fontes serifadas podem ser elegantes, mas em telas pequenas, fontes sem serifa têm melhor legibilidade.
- **Comprimento da linha:** Linhas muito longas ou muito curtas dificultam o acompanhamento do texto. O ideal é que o comprimento da linha permita que os olhos descansem ao final de cada linha e encontrem facilmente o início da próxima.

### Hierarquia tipográfica: organizar visualmente para facilitar a compreensão

A hierarquia tipográfica é o uso intencional de variações na tipografia para indicar a importância relativa das informações, orientar o olhar do usuário e criar uma estrutura mental clara. Sem hierarquia, tudo parece igual, e o usuário não sabe por onde começar ou o que é mais relevante.

Considere uma página com título, subtítulo, texto principal e legenda. Se tudo estiver no mesmo tamanho e estilo, o usuário perde tempo tentando entender onde está o foco da informação.

Exemplos de elementos que criam hierarquia:

- **Tamanho:** Títulos são maiores que subtítulos, que são maiores que o corpo do texto.
- **Peso:** Negrito para destacar palavras ou frases importantes.
- **Estilo:** Itálico pode indicar exemplos ou citações.
- **Cor:** Usar cor com bom contraste para chamar atenção, sem exageros.
- **Maiúsculas/minúsculas:** Texto todo em maiúsculas pode servir para chamar atenção, mas é mais difícil de ler se usado em blocos grandes.
- **Espaçamento:** Espaços maiores antes e depois de títulos ajudam a separar visualmente as seções.

### Exemplo prático com erro comum e correção

Veja este código HTML e CSS que exemplifica uma interface simples com tipografia ruim:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Exemplo Ruim de Tipografia</title>
<style>
  body {
    font-family: 'Arial', sans-serif;
    font-size: 10px;
    color: #888888;
    background-color: #ffffff;
    line-height: 1.0;
    margin: 40px;
  }
  h1, h2 {
    font-weight: normal;
  }
  p {
    margin: 0 0 5px 0;
  }
</style>
</head>
<body>
  <h1>Bem-vindo ao nosso site</h1>
  <h2>Conheça nossos serviços</h2>
  <p>Oferecemos uma ampla gama de soluções para atender suas necessidades.</p>
  <p>Entre em contato conosco para saber mais.</p>
</body>
</html>
```

**Problemas identificados:**

- Fonte muito pequena (10px), o que dificulta a leitura.
- Cor do texto (#888888) tem pouco contraste com o fundo branco, causando cansaço visual.
- `line-height` (altura da linha) muito apertado (1.0), dificultando a separação entre linhas.
- Títulos `h1` e `h2` sem negrito nem variação de tamanho significativa, não criam hierarquia.
- Margens dos parágrafos muito pequenas, dificultando a separação visual dos blocos de texto.

Como resultado, o texto é pouco legível e o usuário não sabe onde focar.

### Correção aplicada:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Exemplo Corrigido de Tipografia</title>
<style>
  body {
    font-family: 'Arial', sans-serif;
    font-size: 16px;
    color: #222222;
    background-color: #ffffff;
    line-height: 1.5;
    margin: 40px;
  }
  h1 {
    font-weight: bold;
    font-size: 2em;
    margin-bottom: 0.5em;
  }
  h2 {
    font-weight: bold;
    font-size: 1.5em;
    margin-bottom: 0.75em;
  }
  p {
    margin: 0 0 1em 0;
  }
</style>
</head>
<body>
  <h1>Bem-vindo ao nosso site</h1>
  <h2>Conheça nossos serviços</h2>
  <p>Oferecemos uma ampla gama de soluções para atender suas necessidades.</p>
  <p>Entre em contato conosco para saber mais.</p>
</body>
</html>
```

### O que mudou e por quê:

- **Aumentamos a fonte para 16px**, padrão que oferece boa legibilidade em telas comuns.
- **Cor do texto para #222222**, que proporciona contraste alto com o fundo branco.
- **`line-height` para 1.5**, melhorando o espaçamento entre linhas e facilitando o acompanhamento visual.
- **Títulos com tamanho maior e negrito**, criando uma clara hierarquia e direcionando a atenção.
- **Margens maiores entre parágrafos**, ajudando o cérebro a separar blocos de informação com menos esforço.

### Saída visual (texto renderizado do código corrigido):

```
Bem-vindo ao nosso site

Conheça nossos serviços

Oferecemos uma ampla gama de soluções para atender suas necessidades.

Entre em contato conosco para saber mais.
```

Visualmente, o texto agora é confortável para leitura e a hierarquia está clara: primeiro o título, depois o subtítulo, seguido dos parágrafos.

### Erro comum que você pode cometer

Um erro frequente é pensar que quanto mais "bonito" ou diferenciado for o texto, melhor será a experiência. Mas usar fontes decorativas, tamanhos minúsculos, pouco contraste ou misturar muitos estilos atrapalha muito a legibilidade e aumenta a carga cognitiva — o que vai contra os princípios psicológicos que norteiam o design intuitivo.

Outro erro típico é usar tudo em caixa alta (maiúsculas), achando que vai destacar, mas isso dificulta a leitura porque as formas das palavras ficam menos distintas.

### Dicas práticas para aplicar tipografia eficiente em UI/UX

- Priorize sempre a legibilidade. Se tiver dúvida, teste com usuários reais ou em diferentes dispositivos.
- Use uma ou duas famílias de fontes no máximo para manter a consistência.
- Estabeleça uma escala tipográfica clara: por exemplo, corpo de texto 16px, subtítulo 24px, título 32px, com espaçamentos proporcionais.
- Evite cores de texto com baixo contraste, especialmente para textos longos.
- Ajuste o espaçamento entre linhas para evitar quebras visuais difíceis de acompanhar.
- Use o peso e o tamanho para criar hierarquia, não apenas cores ou estilos decorativos.

### Exercício prático

Pegue um texto de um artigo ou uma tela simples que você desenvolveu e siga estes passos:

1. Ajuste o tamanho da fonte para algo entre 14px e 18px.
2. Verifique o contraste entre texto e fundo usando ferramentas online (ex: Contrast Checker).
3. Aplique `line-height` entre 1.4 e 1.6.
4. Crie pelo menos dois níveis de título com tamanhos e pesos diferentes.
5. Aplique margens para separar visualmente os blocos de texto.
6. Teste a leitura em um dispositivo móvel e em um desktop.

---

**Solução comentada do exercício:**

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Exercício Tipografia</title>
<style>
  body {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    font-size: 16px;
    line-height: 1.5;
    color: #222222;
    background-color: #ffffff;
    margin: 20px 40px;
  }
  h1 {
    font-size: 2.5em;
    font-weight: 700;
    margin-bottom: 0.6em;
  }
  h2 {
    font-size: 1.8em;
    font-weight: 600;
    margin-bottom: 0.5em;
  }
  p {
    margin-bottom: 1em;
  }
</style>
</head>
<body>
  <h1>Importância da Tipografia no Design</h1>
  <h2>Legibilidade e Hierarquia</h2>
  <p>A tipografia correta melhora a experiência do usuário, reduzindo a carga cognitiva e facilitando o entendimento rápido das informações.</p>
  <p>Use variações de tamanho e peso para guiar o olhar e destacar o que é mais importante.</p>
</body>
</html>
```

- O tamanho da fonte (16px) garante boa leitura.
- `line-height` 1.5 promove espaçamento confortável entre linhas.
- Títulos `h1` e `h2` têm pesos e tamanhos distintos, estabelecendo hierarquia clara.
- Margens entre parágrafos facilitam a separação visual dos blocos.
- Cor do texto tem alto contraste com o fundo branco.

Teste essa página em diferentes telas para sentir a diferença que a tipografia faz na experiência do usuário.

---

Ter uma tipografia planejada não é luxo, é necessidade para criar interfaces acessíveis, intuitivas e que respeitam os limites cognitivos do usuário. Ao controlar legibilidade e hierarquia, você facilita a percepção, reduz a carga cognitiva e torna a navegação mais eficiente e agradável.