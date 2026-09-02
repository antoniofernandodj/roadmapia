## Estruturação de conteúdo e hierarquia

Imagine que você está diante de uma página web ou aplicativo com uma quantidade enorme de informações, links, botões e textos, todos disputando sua atenção ao mesmo tempo. Sem uma organização clara, o usuário se sente perdido, frustrado e provavelmente abandona a navegação. A estruturação do conteúdo e a definição de uma hierarquia clara são as soluções para esse problema crítico na construção de interfaces: elas determinam o que deve ser percebido primeiro, o que é secundário e como o usuário deve navegar entre as informações de forma natural e eficiente.

### Por que a hierarquia é essencial para o usuário?

Nosso cérebro processa informações visuais de maneira seletiva, priorizando elementos que se destacam pela posição, tamanho, cor e proximidade. Quando o conteúdo está estruturado em níveis hierárquicos, o usuário entende rapidamente o que é mais importante, o que pode ser explorado depois e onde encontrar o que deseja. Isso reduz a sobrecarga cognitiva, diminui o tempo para encontrar informações e aumenta a satisfação na interação com a interface.

Sem essa organização, o usuário enfrenta um emaranhado de informações “iguais”, o que gera confusão e atrito. Por exemplo, uma página de notícias que apresenta todas as manchetes com o mesmo peso visual e sem agrupamento tem muito mais chances de frustrar o leitor do que uma que destaca as notícias principais e separa as seções temáticas.

### Como estruturar o conteúdo em níveis hierárquicos?

A estruturação do conteúdo começa pela identificação clara dos blocos de informação e sua importância relativa. Isso envolve três passos fundamentais:

1. **Mapear o conteúdo:** Liste todos os elementos que precisam estar presentes na interface — títulos, textos, imagens, botões, links, formulários, etc. Entenda o papel de cada um, sua finalidade e relevância para o usuário.

2. **Agrupar por afinidade:** Organize esses elementos em grupos lógicos que façam sentido para o usuário. Por exemplo, em um e-commerce, os produtos podem ser agrupados por categoria, preço ou avaliação. Essa organização ajuda a criar "blocos" de informação que facilitam a leitura e a navegação.

3. **Definir níveis de prioridade:** Dentro de cada grupo, determine quais informações são essenciais para captar a atenção imediata do usuário e quais são complementares ou secundárias. Essa priorização vai guiar o design visual posterior (tamanho, cor, posição).

### Exemplo prático: hierarquia em uma página de perfil de usuário

Suponha que você está estruturando o conteúdo para a página de perfil de um aplicativo social. Os dados disponíveis são:

- Nome do usuário
- Foto de perfil
- Status online
- Lista de amigos
- Publicações recentes
- Botão de seguir
- Informações de contato
- Biografia curta

**Passo 1: Mapeamento**

Todos esses elementos são importantes, mas possuem diferentes funções e níveis de importância para o usuário.

**Passo 2: Agrupamento**

- Informação principal: Nome, foto, status online, botão de seguir.
- Informação secundária: Biografia, informações de contato.
- Conteúdo dinâmico: Lista de amigos, publicações recentes.

**Passo 3: Prioridade e hierarquia**

- O nome e a foto do usuário devem ter maior destaque, pois identificam quem é o perfil.
- O botão de seguir precisa ser visível, mas não deve competir com o nome/foto.
- Status online é um indicador rápido, de baixa prioridade, pode ser representado por um ícone discreto.
- Biografia e informações de contato podem ocupar uma área abaixo, com menor destaque.
- Lista de amigos e publicações recentes são áreas que o usuário pode explorar depois, organizadas em seções separadas.

### O que acontece quando a hierarquia não é respeitada?

Vamos imaginar o que ocorre se todos os elementos acima forem apresentados com a mesma ênfase, em um bloco contínuo, sem divisão clara e com tamanhos de fonte iguais. O usuário terá dificuldade para identificar rapidamente quem é o dono do perfil, onde clicar para seguir, ou mesmo onde encontrar as publicações recentes. Isso pode gerar confusão e desmotivá-lo a continuar navegando.

### Construindo a hierarquia com base no conteúdo

A hierarquia não é uma regra fixa, mas um resultado da análise do conteúdo e dos objetivos do usuário. Por exemplo, em um site de notícias, a notícia principal do dia deve ter destaque máximo, enquanto notícias menos urgentes ficam em níveis inferiores.

Para materializar essa hierarquia, considere sempre:

- **Posição:** Elementos no topo ou centro da tela têm mais destaque.
- **Tamanho:** Use tamanhos maiores para títulos e informações prioritárias.
- **Contraste e cor:** Cores vibrantes ou contrastantes chamam mais atenção.
- **Espaçamento:** Separar grupos de informações ajuda o cérebro a agrupá-las mentalmente.
- **Repetição e consistência:** Padrões visuais ajudam o usuário a entender a estrutura.

### Código exemplo: estrutura HTML simples com hierarquia semântica

A hierarquia de conteúdo também deve estar refletida no código, usando tags semânticas que indicam a importância e o papel de cada elemento. Veja um exemplo mínimo para a página de perfil descrita:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Perfil do Usuário</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 600px;
      margin: 1rem auto;
      padding: 1rem;
      line-height: 1.5;
    }
    header {
      display: flex;
      align-items: center;
      gap: 1rem;
      border-bottom: 1px solid #ccc;
      padding-bottom: 1rem;
      margin-bottom: 1rem;
    }
    header img {
      width: 80px;
      height: 80px;
      border-radius: 50%;
    }
    header h1 {
      font-size: 1.8rem;
      margin: 0;
      flex-grow: 1;
    }
    #follow-button {
      background-color: #007bff;
      color: white;
      border: none;
      padding: 0.5rem 1rem;
      font-size: 1rem;
      cursor: pointer;
      border-radius: 4px;
    }
    #follow-button:hover {
      background-color: #0056b3;
    }
    section.bio, section.contact, section.friends, section.posts {
      margin-bottom: 1.5rem;
    }
    section h2 {
      font-size: 1.4rem;
      border-bottom: 1px solid #ddd;
      padding-bottom: 0.3rem;
      margin-bottom: 0.5rem;
    }
    .status {
      font-size: 0.9rem;
      color: green;
      margin-left: 0.5rem;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <header>
    <img src="https://via.placeholder.com/80" alt="Foto de perfil do usuário" />
    <h1>João Silva <span class="status">(online)</span></h1>
    <button id="follow-button">Seguir</button>
  </header>

  <section class="bio" aria-label="Biografia do usuário">
    <h2>Sobre João</h2>
    <p>Desenvolvedor front-end apaixonado por UX e design de interfaces intuitivas.</p>
  </section>

  <section class="contact" aria-label="Informações de contato">
    <h2>Contato</h2>
    <p>Email: joao.silva@email.com</p>
  </section>

  <section class="friends" aria-label="Lista de amigos">
    <h2>Amigos</h2>
    <ul>
      <li>Ana</li>
      <li>Bruno</li>
      <li>Carla</li>
    </ul>
  </section>

  <section class="posts" aria-label="Publicações recentes">
    <h2>Publicações Recentes</h2>
    <article>
      <h3>Meu primeiro projeto UX</h3>
      <p>Compartilhando minha experiência na criação de wireframes e protótipos.</p>
    </article>
    <article>
      <h3>Dicas para melhorar a usabilidade</h3>
      <p>Como organizar menus para facilitar a navegação em apps móveis.</p>
    </article>
  </section>
</body>
</html>
```

#### Saída visual esperada

- O nome e a foto do usuário aparecem em destaque no topo, alinhados horizontalmente.
- O botão "Seguir" está visível, porém não rouba o foco do nome.
- O status online é apresentado de forma discreta, mas perceptível.
- As seções de biografia, contato, amigos e publicações aparecem em blocos separados, com títulos que indicam claramente o conteúdo.
- O uso de tags semânticas (`header`, `section`, `article`, `h1` a `h3`) ajuda na estruturação lógica e acessibilidade.

### Erro comum: usar títulos de mesma importância para tudo

Um erro frequente é usar títulos do mesmo nível para todas as seções, sem definir níveis hierárquicos claros. Por exemplo:

```html
<h1>João Silva</h1>
<h1>Biografia</h1>
<h1>Contato</h1>
<h1>Amigos</h1>
<h1>Publicações</h1>
```

Isso gera confusão para leitores de tela e motores de busca, além de transmitir uma falsa sensação de que todos os conteúdos são igualmente prioritários. O correto é usar o `<h1>` para o nome do usuário, `<h2>` para as seções principais e `<h3>` para subtítulos dentro das seções.

### Exercício prático

Pegue a estrutura HTML abaixo, que apresenta uma página de produtos com título, descrição, preço, e avaliações, todos apresentados com o mesmo peso visual e sem agrupamentos:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Produtos</title>
</head>
<body>
  <h1>Produto A</h1>
  <p>Descrição do Produto A</p>
  <p>Preço: R$ 150</p>
  <p>Avaliação: 4 estrelas</p>

  <h1>Produto B</h1>
  <p>Descrição do Produto B</p>
  <p>Preço: R$ 200</p>
  <p>Avaliação: 5 estrelas</p>
</body>
</html>
```

Reestruture esse conteúdo para que:

- O título da página seja um `<h1>`.
- Cada produto seja uma seção com um título `<h2>`.
- A descrição, preço e avaliação fiquem agrupados dentro do produto, usando uma lista ou parágrafos, com hierarquia visual e semântica.
- Use CSS básico para diferenciar títulos e agrupar visualmente os produtos.

---

### Solução comentada

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Lista de Produtos</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 600px;
      margin: 1rem auto;
      padding: 1rem;
      line-height: 1.5;
    }
    section.product {
      border: 1px solid #ddd;
      padding: 1rem;
      margin-bottom: 1rem;
      border-radius: 6px;
      background-color: #fafafa;
    }
    h1 {
      font-size: 2rem;
      margin-bottom: 1rem;
      border-bottom: 2px solid #333;
      padding-bottom: 0.3rem;
    }
    h2 {
      font-size: 1.5rem;
      margin-top: 0;
      margin-bottom: 0.5rem;
    }
    ul {
      list-style: none;
      padding-left: 0;
      margin-top: 0;
    }
    ul li {
      margin-bottom: 0.3rem;
    }
  </style>
</head>
<body>
  <h1>Produtos Disponíveis</h1>

  <section class="product" aria-label="Produto A">
    <h2>Produto A</h2>
    <ul>
      <li><strong>Descrição:</strong> Descrição do Produto A</li>
      <li><strong>Preço:</strong> R$ 150</li>
      <li><strong>Avaliação:</strong> 4 estrelas</li>
    </ul>
  </section>

  <section class="product" aria-label="Produto B">
    <h2>Produto B</h2>
    <ul>
      <li><strong>Descrição:</strong> Descrição do Produto B</li>
      <li><strong>Preço:</strong> R$ 200</li>
      <li><strong>Avaliação:</strong> 5 estrelas</li>
    </ul>
  </section>
</body>
</html>
```

**Comentários:**

- O `<h1>` indica o título principal da página, importante para hierarquia e SEO.
- Cada produto é uma seção distinta (`<section class="product">`), que agrupa as informações relacionadas.
- O título do produto é `<h2>`, sinalizando a importância logo abaixo do título principal.
- A lista `<ul>` organiza os detalhes do produto, facilitando a leitura e separação visual.
- O CSS cria um agrupamento visual claro, com bordas e espaçamentos, reforçando a hierarquia.
- O uso de `aria-label` nas seções melhora a acessibilidade, descrevendo o conteúdo para leitores de tela.

---

A estruturação clara do conteúdo e a hierarquia pensada desde o início são fundamentais para criar interfaces que o usuário compreende e navega com facilidade, reduzindo o esforço cognitivo e aumentando a eficiência da interação.