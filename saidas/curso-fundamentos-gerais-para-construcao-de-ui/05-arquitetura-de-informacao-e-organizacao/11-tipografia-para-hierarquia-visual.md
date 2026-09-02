## Tipografia para hierarquia visual

Imagine que você está diante de uma página cheia de informações: títulos, parágrafos, botões, menus. Se todos esses elementos usarem o mesmo tamanho, peso e estilo de fonte, o usuário terá dificuldade para entender o que é mais importante, onde começa um novo tópico ou qual ação deve tomar primeiro. A tipografia, portanto, é uma poderosa ferramenta para criar hierarquia visual — ela organiza o conteúdo textual para guiar a atenção do usuário de forma intuitiva e eficiente.

### Por que a tipografia é fundamental para hierarquia?

A hierarquia visual é o modo como o cérebro percebe a importância relativa dos elementos na interface. Diferentes estilos de texto — tamanhos, pesos, espaçamentos — funcionam como sinais visuais que indicam o que o usuário deve notar primeiro, o que é secundário e o que é apenas complemento. Sem essa diferenciação, toda a informação se mistura, causando confusão e sobrecarga cognitiva.

A tipografia, especificamente, atua nesse sentido porque o texto é o principal meio pelo qual transmitimos informações. Ao variar propriedades tipográficas, conseguimos:

- **Destacar títulos e subtítulos**, para que o usuário identifique rapidamente a estrutura do conteúdo.
- **Separar blocos de texto**, facilitando a leitura e compreensão.
- **Guiar o olhar**, criando um fluxo natural de leitura.
- **Sinalizar ações e chamadas importantes**, como botões ou links.

### Propriedades tipográficas que criam hierarquia

Vamos explorar as principais propriedades que influenciam a hierarquia visual através da tipografia.

#### 1. Tamanho da fonte

O tamanho é o sinal mais imediato de importância. Elementos maiores indicam maior relevância.

**Exemplo prático:**

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Exemplo de Tipografia para Hierarquia</title>
<style>
  body {
    font-family: Arial, sans-serif;
    margin: 40px;
  }
  h1 {
    font-size: 36px;
    font-weight: bold;
  }
  h2 {
    font-size: 28px;
    font-weight: bold;
  }
  p {
    font-size: 16px;
  }
</style>
</head>
<body>
  <h1>Como organizar seu conteúdo</h1>
  <h2>Importância do título principal</h2>
  <p>Este parágrafo explica o conteúdo da seção, com tamanho menor para facilitar a leitura contínua.</p>
</body>
</html>
```

Se abrir essa página em um navegador, verá claramente que o título principal (h1) é o maior e mais destacado, seguido pelo subtítulo (h2) e pelo texto do parágrafo, criando uma hierarquia visual simples e intuitiva.

#### 2. Peso da fonte (bold, normal, light)

O peso da fonte influencia a percepção de força e destaque sem alterar o tamanho. Um texto em negrito (bold) chama mais atenção que o mesmo texto em peso normal.

```html
<p><strong>Importante:</strong> Sempre use pesos diferentes para destacar elementos-chave.</p>
<p>Texto normal para o corpo do conteúdo.</p>
```

O uso combinado de tamanho e peso ajuda a reforçar a hierarquia, como em títulos grandes e em negrito versus texto comum para leitura.

#### 3. Espaçamento entre letras (tracking) e entre linhas (leading)

Espaçar as letras ou as linhas pode facilitar a leitura e criar blocos visuais distintos.

- **Tracking aumentado** para títulos pode dar sensação de abertura e importância.
- **Leading adequado** evita que o texto fique “apertado”, melhorando a legibilidade.

```css
h1 {
  letter-spacing: 2px;
  line-height: 1.2;
}
p {
  line-height: 1.6;
}
```

#### 4. Caixa (maiúsculas, minúsculas)

Usar texto em caixa alta (maiúsculas) pode dar ênfase ou sinalizar categorias, mas deve ser usado com moderação pois dificulta a leitura de textos longos.

```html
<h3 style="text-transform: uppercase;">SEÇÃO IMPORTANTÍSSIMA</h3>
```

#### 5. Cor do texto

Embora a cor tenha sido abordada no capítulo anterior, vale lembrar que o contraste entre o texto e o fundo é essencial para legibilidade e também pode reforçar a hierarquia.

### Erro comum: hierarquia tipográfica insuficiente

Um erro frequente é usar tamanhos e pesos iguais para todos os textos, como neste exemplo:

```html
<p style="font-size: 16px; font-weight: normal;">Título Principal</p>
<p style="font-size: 16px; font-weight: normal;">Subtítulo</p>
<p style="font-size: 16px; font-weight: normal;">Parágrafo explicativo</p>
```

O resultado é que o usuário não sabe o que é título, subtítulo ou texto comum. A mensagem fica confusa, e ele pode perder tempo tentando identificar a estrutura.

Você verá visualmente tudo igual, sem guias visuais para hierarquia.

### Como aplicar hierarquia tipográfica de forma eficiente?

1. **Defina uma escala tipográfica:** uma progressão de tamanhos de fonte que reflita a importância relativa dos elementos (exemplo: 36px para h1, 28px para h2, 20px para h3, 16px para parágrafos).

2. **Use pesos para reforçar a prioridade:** títulos em negrito, texto comum em peso normal.

3. **Combine espaçamentos para criar blocos visuais claros:** mais espaço antes de um título para separar seções.

4. **Mantenha a consistência:** títulos do mesmo nível devem ter o mesmo estilo. Isso ajuda o usuário a entender a estrutura.

5. **Teste o contraste e legibilidade:** mesmo dentro da hierarquia, o texto deve ser fácil de ler.

### Exemplo prático completo

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Hierarquia Tipográfica Completa</title>
<style>
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 40px;
    color: #222;
  }
  h1 {
    font-size: 40px;
    font-weight: 700;
    margin-bottom: 0.3em;
    letter-spacing: 1.5px;
  }
  h2 {
    font-size: 28px;
    font-weight: 600;
    margin-top: 1.5em;
    margin-bottom: 0.4em;
    letter-spacing: 0.5px;
  }
  h3 {
    font-size: 20px;
    font-weight: 600;
    margin-top: 1.2em;
    margin-bottom: 0.3em;
    text-transform: uppercase;
    letter-spacing: 2px;
    color: #555;
  }
  p {
    font-size: 16px;
    font-weight: 400;
    line-height: 1.6;
    margin-bottom: 1em;
  }
  .important {
    font-weight: 700;
  }
</style>
</head>
<body>
  <h1>Guia de Estilo da Interface</h1>
  <p>Este documento esclarece como aplicar a hierarquia tipográfica para facilitar a leitura e navegação.</p>

  <h2>Princípios Básicos</h2>
  <p>A hierarquia visual orienta o usuário, destacando o que é mais importante e criando um fluxo natural de leitura.</p>

  <h3>Uso de tamanhos</h3>
  <p>Os títulos principais usam tamanhos maiores para serem rapidamente identificados. Subtítulos têm tamanhos intermediários.</p>

  <h3>Peso e espaçamento</h3>
  <p>Negrito destaca informações chave, enquanto o espaçamento entre parágrafos e títulos cria blocos visuais claros.</p>

  <h2>Aplicação prática</h2>
  <p>Consistência e clareza são essenciais. Use estilos uniformes para elementos do mesmo nível hierárquico.</p>
  <p class="important">Lembre-se: hierarquia tipográfica não é decoração, mas ferramenta funcional.</p>
</body>
</html>
```

### Exercício

Crie uma página simples com a seguinte estrutura tipográfica:

- Um título principal (h1) que seja o maior e mais pesado.
- Dois subtítulos (h2), menores que o título, mas ainda destacados.
- Um parágrafo explicativo embaixo de cada subtítulo.
- Um texto de aviso ou chamada importante, que deve ser destacado por peso e cor.

Aplique tamanhos, pesos e espaçamentos para que a hierarquia fique clara e fácil de seguir.

#### Solução comentada (HTML + CSS)

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8" />
<title>Exercício de Hierarquia Tipográfica</title>
<style>
  body {
    font-family: 'Arial', sans-serif;
    margin: 40px;
    color: #333;
  }
  h1 {
    font-size: 38px;
    font-weight: 700;
    margin-bottom: 0.4em;
  }
  h2 {
    font-size: 26px;
    font-weight: 600;
    margin-top: 1.5em;
    margin-bottom: 0.3em;
  }
  p {
    font-size: 17px;
    font-weight: 400;
    line-height: 1.5;
    margin-bottom: 1em;
  }
  .alert {
    font-weight: 700;
    color: #b22222; /* vermelho escuro para chamar atenção */
    margin-top: 1em;
    margin-bottom: 1em;
  }
</style>
</head>
<body>
  <h1>Planejamento de Conteúdo para o Usuário</h1>

  <h2>Entenda seu público</h2>
  <p>Conhecer as necessidades e expectativas do usuário ajuda a definir prioridades e organizar o conteúdo de forma eficaz.</p>

  <h2>Organize a informação</h2>
  <p>Use títulos e subtítulos claros para dividir o conteúdo em blocos lógicos, facilitando a leitura e navegação.</p>

  <p class="alert">Atenção: evite excesso de estilos diferentes para não confundir o usuário.</p>
</body>
</html>
```

**Comentários:**

- O título principal está grande e em negrito, imediatamente chamando atenção.
- Os subtítulos são menores, mas ainda destacados, separando as seções.
- Os parágrafos têm tamanho confortável para leitura contínua.
- O texto de aviso tem peso maior e cor contrastante, destacando-o sem exagero.

---

Com essa prática, você verá como a tipografia, usada de forma consciente, cria uma hierarquia visual que facilita o entendimento, reduz o esforço do usuário e melhora significativamente a experiência na interface.