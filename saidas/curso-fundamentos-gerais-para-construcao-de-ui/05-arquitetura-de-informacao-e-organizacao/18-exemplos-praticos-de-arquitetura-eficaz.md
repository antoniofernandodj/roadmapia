## Exemplos práticos de arquitetura eficaz

Imagine que você está projetando a interface de um aplicativo simples de receitas culinárias. A arquitetura da informação precisa organizar o conteúdo para que o usuário encontre facilmente as receitas, aprenda sobre os ingredientes e métodos, e navegue sem frustrações. Vamos ver como aplicar esses princípios em exemplos práticos que demonstram organização clara, hierarquia visual e navegação eficiente.

### Exemplo 1: Organização clara com categorias e hierarquia

Um erro comum é apresentar uma lista extensa e desorganizada de receitas, como nesta estrutura:

```
Receitas:
- Bolo de Chocolate
- Frango Assado
- Salada Caesar
- Lasanha
- Sopa de Legumes
- Omelete
- Panqueca
- Torta de Maçã
- Risoto de Cogumelos
...
```

Aqui, o usuário recebe uma lista plana que não ajuda na navegação, especialmente se há dezenas ou centenas de receitas. A ausência de agrupamento dificulta a localização rápida e aumenta a carga cognitiva.

#### Correção: Agrupamento por categorias e uso de títulos hierárquicos

Organize as receitas em categorias lógicas, como "Doces", "Carnes", "Saladas", "Massas" e "Sopas". A estrutura semântica em HTML ficaria assim:

```html
<h1>Receitas</h1>

<section>
  <h2>Doces</h2>
  <ul>
    <li>Bolo de Chocolate</li>
    <li>Panqueca</li>
    <li>Torta de Maçã</li>
  </ul>
</section>

<section>
  <h2>Carnes</h2>
  <ul>
    <li>Frango Assado</li>
    <li>Omelete</li>
  </ul>
</section>

<section>
  <h2>Saladas</h2>
  <ul>
    <li>Salada Caesar</li>
  </ul>
</section>

<section>
  <h2>Massas</h2>
  <ul>
    <li>Lasanha</li>
    <li>Risoto de Cogumelos</li>
  </ul>
</section>

<section>
  <h2>Sopas</h2>
  <ul>
    <li>Sopa de Legumes</li>
  </ul>
</section>
```

Esse agrupamento cria blocos visuais claros, que facilitam a navegação e o entendimento imediato do conteúdo disponível. O uso correto dos títulos `<h1>`, `<h2>`, e listas `<ul><li>` reforça a hierarquia e melhora a acessibilidade.

### Exemplo 2: Navegação global e local combinadas

Imagine que, além da lista de receitas, o aplicativo tenha áreas para "Favoritos", "Minhas Receitas" e "Configurações". Uma navegação eficaz mantém estas opções sempre acessíveis, com menus que se adaptam ao contexto.

#### Navegação global (menu principal fixo)

```html
<nav aria-label="Menu principal">
  <ul>
    <li><a href="#receitas">Receitas</a></li>
    <li><a href="#favoritos">Favoritos</a></li>
    <li><a href="#minhas-receitas">Minhas Receitas</a></li>
    <li><a href="#configuracoes">Configurações</a></li>
  </ul>
</nav>
```

Este menu permanece visível em todas as telas, garantindo acesso rápido às seções principais.

#### Navegação local/contextual (submenu em "Receitas")

Quando o usuário está na seção "Receitas", um submenu lateral pode listar as categorias para facilitar a exploração.

```html
<nav aria-label="Categorias de receitas">
  <ul>
    <li><a href="#doces">Doces</a></li>
    <li><a href="#carnes">Carnes</a></li>
    <li><a href="#saladas">Saladas</a></li>
    <li><a href="#massas">Massas</a></li>
    <li><a href="#sopas">Sopas</a></li>
  </ul>
</nav>
```

Assim, a navegação local complementa a global, oferecendo caminhos rápidos dentro do contexto atual.

### Exemplo 3: Uso de grids para organizar visualmente o conteúdo

Uma página de receitas pode ser dividida visualmente em áreas, usando um grid para alinhar títulos, imagens e descrições.

```html
<style>
  .grid-receita {
    display: grid;
    grid-template-columns: 150px 1fr;
    grid-gap: 16px;
    align-items: start;
  }
  .imagem-receita {
    width: 150px;
    height: 150px;
    object-fit: cover;
  }
</style>

<div class="grid-receita">
  <img src="bolo-chocolate.jpg" alt="Bolo de Chocolate" class="imagem-receita" />
  <div>
    <h2>Bolo de Chocolate</h2>
    <p>Delicioso bolo com cobertura de chocolate e recheio cremoso.</p>
  </div>
</div>
```

O grid cria uma estrutura visual que guia o olhar, mantém alinhamento consistente e facilita a leitura. Sem essa organização, o conteúdo pode parecer desordenado e cansativo.

### Exemplo 4: Consistência visual em botões e links

Suponha que a interface tenha botões para "Ver Receita", "Adicionar aos Favoritos" e "Compartilhar". Se cada botão tiver estilos diferentes, o usuário pode ficar confuso sobre quais ações são possíveis ou importantes.

#### Erro comum:

```html
<button style="background-color: blue;">Ver Receita</button>
<button style="background-color: green;">Adicionar aos Favoritos</button>
<button style="background-color: red;">Compartilhar</button>
```

Esse uso indiscriminado de cores e estilos distintos gera inconsistência visual.

#### Correção com padrão e hierarquia

Defina estilos padronizados para botões principais e secundários, por exemplo:

```html
<style>
  .btn {
    padding: 10px 16px;
    border: none;
    border-radius: 4px;
    font-weight: bold;
    cursor: pointer;
  }
  .btn-primary {
    background-color: #007bff;
    color: white;
  }
  .btn-secondary {
    background-color: #6c757d;
    color: white;
  }
</style>

<button class="btn btn-primary">Ver Receita</button>
<button class="btn btn-secondary">Adicionar aos Favoritos</button>
<button class="btn btn-secondary">Compartilhar</button>
```

Assim, o usuário reconhece facilmente que "Ver Receita" é a ação principal, enquanto as outras são secundárias, facilitando a tomada de decisão.

### Exemplo 5: Feedback visual para ações do usuário

Em uma interface de receitas, quando o usuário adiciona uma receita aos favoritos, deve haver uma resposta imediata e clara.

#### Exemplo funcional em JavaScript

```html
<button id="btn-favorito" aria-pressed="false" class="btn btn-secondary">
  Adicionar aos Favoritos
</button>

<script>
  const btnFavorito = document.getElementById('btn-favorito');

  btnFavorito.addEventListener('click', () => {
    const pressed = btnFavorito.getAttribute('aria-pressed') === 'true';
    btnFavorito.setAttribute('aria-pressed', String(!pressed));
    btnFavorito.textContent = pressed ? 'Adicionar aos Favoritos' : 'Remover dos Favoritos';
    btnFavorito.classList.toggle('btn-primary');
    btnFavorito.classList.toggle('btn-secondary');
  });
</script>
```

Esse código alterna o estado do botão, atualiza o texto e altera o estilo visual, além de usar o atributo `aria-pressed` para acessibilidade.

#### Saída visual e funcional

- Antes do clique: botão cinza com texto "Adicionar aos Favoritos".
- Após o clique: botão azul com texto "Remover dos Favoritos".
- O usuário recebe feedback claro do estado atual.

### Exercício prático

Crie uma página HTML simples que liste pelo menos dez receitas agrupadas em três categorias, com navegação global para "Receitas", "Favoritos" e "Configurações". Inclua um submenu local para as categorias dentro de "Receitas". Utilize grids para organizar as informações de cada receita, e implemente botões consistentes para "Ver Receita" e "Adicionar aos Favoritos" com feedback visual ao clicar.

#### Solução comentada (trecho principal)

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Receitas Fáceis</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 20px;
    }
    nav[aria-label="Menu principal"] ul,
    nav[aria-label="Categorias de receitas"] ul {
      list-style: none;
      padding: 0;
      margin: 0 0 20px 0;
      display: flex;
      gap: 12px;
    }
    nav[aria-label="Menu principal"] ul li a,
    nav[aria-label="Categorias de receitas"] ul li a {
      text-decoration: none;
      color: #007bff;
      font-weight: bold;
    }
    .grid-receita {
      display: grid;
      grid-template-columns: 150px 1fr 150px;
      grid-gap: 16px;
      align-items: center;
      margin-bottom: 24px;
      border-bottom: 1px solid #ddd;
      padding-bottom: 16px;
    }
    .imagem-receita {
      width: 150px;
      height: 150px;
      object-fit: cover;
      border-radius: 8px;
    }
    .btn {
      padding: 10px 16px;
      border: none;
      border-radius: 4px;
      font-weight: bold;
      cursor: pointer;
      user-select: none;
    }
    .btn-primary {
      background-color: #007bff;
      color: white;
    }
    .btn-secondary {
      background-color: #6c757d;
      color: white;
    }
  </style>
</head>
<body>

  <!-- Navegação Global -->
  <nav aria-label="Menu principal">
    <ul>
      <li><a href="#receitas">Receitas</a></li>
      <li><a href="#favoritos">Favoritos</a></li>
      <li><a href="#configuracoes">Configurações</a></li>
    </ul>
  </nav>

  <!-- Conteúdo Receitas -->
  <main id="receitas">
    <h1>Receitas</h1>

    <!-- Navegação Local -->
    <nav aria-label="Categorias de receitas">
      <ul>
        <li><a href="#doces">Doces</a></li>
        <li><a href="#salgadas">Salgadas</a></li>
        <li><a href="#vegetarianas">Vegetarianas</a></li>
      </ul>
    </nav>

    <!-- Categoria Doces -->
    <section id="doces">
      <h2>Doces</h2>

      <article class="grid-receita">
        <img src="bolo-chocolate.jpg" alt="Bolo de Chocolate" class="imagem-receita" />
        <div>
          <h3>Bolo de Chocolate</h3>
          <p>Delicioso bolo com cobertura de chocolate e recheio cremoso.</p>
        </div>
        <div>
          <button class="btn btn-primary">Ver Receita</button>
          <button class="btn btn-secondary btn-favorito" aria-pressed="false">Adicionar aos Favoritos</button>
        </div>
      </article>

      <article class="grid-receita">
        <img src="panqueca.jpg" alt="Panqueca" class="imagem-receita" />
        <div>
          <h3>Panqueca</h3>
          <p>Panquecas leves e fofas para o café da manhã.</p>
        </div>
        <div>
          <button class="btn btn-primary">Ver Receita</button>
          <button class="btn btn-secondary btn-favorito" aria-pressed="false">Adicionar aos Favoritos</button>
        </div>
      </article>
    </section>

    <!-- Categoria Salgadas -->
    <section id="salgadas">
      <h2>Salgadas</h2>

      <article class="grid-receita">
        <img src="frango-assado.jpg" alt="Frango Assado" class="imagem-receita" />
        <div>
          <h3>Frango Assado</h3>
          <p>Frango temperado e assado até ficar dourado e suculento.</p>
        </div>
        <div>
          <button class="btn btn-primary">Ver Receita</button>
          <button class="btn btn-secondary btn-favorito" aria-pressed="false">Adicionar aos Favoritos</button>
        </div>
      </article>

      <article class="grid-receita">
        <img src="lasanha.jpg" alt="Lasanha" class="imagem-receita" />
        <div>
          <h3>Lasanha</h3>
          <p>Camadas de massa, molho e queijo para uma refeição completa.</p>
        </div>
        <div>
          <button class="btn btn-primary">Ver Receita</button>
          <button class="btn btn-secondary btn-favorito" aria-pressed="false">Adicionar aos Favoritos</button>
        </div>
      </article>
    </section>

    <!-- Categoria Vegetarianas -->
    <section id="vegetarianas">
      <h2>Vegetarianas</h2>

      <article class="grid-receita">
        <img src="salada-caesar.jpg" alt="Salada Caesar" class="imagem-receita" />
        <div>
          <h3>Salada Caesar</h3>
          <p>Salada fresca com molho Caesar e croutons crocantes.</p>
        </div>
        <div>
          <button class="btn btn-primary">Ver Receita</button>
          <button class="btn btn-secondary btn-favorito" aria-pressed="false">Adicionar aos Favoritos</button>
        </div>
      </article>

      <article class="grid-receita">
        <img src="sopa-legumes.jpg" alt="Sopa de Legumes" class="imagem-receita" />
        <div>
          <h3>Sopa de Legumes</h3>
          <p>Reconfortante sopa feita com variedade de legumes frescos.</p>
        </div>
        <div>
          <button class="btn btn-primary">Ver Receita</button>
          <button class="btn btn-secondary btn-favorito" aria-pressed="false">Adicionar aos Favoritos</button>
        </div>
      </article>
    </section>
  </main>

  <script>
    // Feedback visual para botões de favoritos
    document.querySelectorAll('.btn-favorito').forEach(button => {
      button.addEventListener('click', () => {
        const pressed = button.getAttribute('aria-pressed') === 'true';
        button.setAttribute('aria-pressed', String(!pressed));
        button.textContent = pressed ? 'Adicionar aos Favoritos' : 'Remover dos Favoritos';
        button.classList.toggle('btn-primary');
        button.classList.toggle('btn-secondary');
      });
    });
  </script>

</body>
</html>
```

**Comentários:**

- A navegação global oferece acesso constante às principais áreas.
- O submenu local permite navegação rápida pelas categorias dentro de "Receitas".
- O grid organiza imagem, texto e botões, mantendo alinhamento e espaçamento consistentes.
- Botões usam estilos padronizados e mudam visualmente ao serem clicados, com atributos ARIA para acessibilidade.
- A hierarquia semântica com títulos `<h1>`, `<h2>`, `<h3>` delimita claramente seções e subitens.

---