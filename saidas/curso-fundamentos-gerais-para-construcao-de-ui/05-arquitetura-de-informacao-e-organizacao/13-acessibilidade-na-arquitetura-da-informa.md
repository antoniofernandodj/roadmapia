## Acessibilidade na arquitetura da informação

Imagine um site ou aplicativo repleto de conteúdo, menus, botões e informações, mas que se torna praticamente impossível de navegar para pessoas com deficiências visuais, motoras ou cognitivas. Sem uma arquitetura da informação acessível, estamos excluindo um grupo significativo de usuários, além de tornar a experiência ruim para todos. A acessibilidade na arquitetura da informação não é apenas uma questão de cumprir normas técnicas: é garantir que a estrutura e organização do conteúdo estejam ao alcance de qualquer pessoa, independentemente de suas condições físicas ou cognitivas.

### Por que a acessibilidade importa na arquitetura da informação?

A arquitetura da informação (AI) organiza e estrutura o conteúdo para facilitar a navegação e a compreensão. Quando essa organização desconsidera necessidades específicas, usuários com deficiências enfrentam barreiras que dificultam ou impedem o acesso à informação, gerando frustração, abandono e exclusão digital. Além disso, uma estrutura acessível melhora a usabilidade para todos, promovendo clareza, simplicidade e previsibilidade.

### O que torna a arquitetura da informação acessível?

Acessibilidade na AI começa na forma como o conteúdo é estruturado, rotulado e disponibilizado para diferentes usuários e tecnologias assistivas (como leitores de tela). Vamos detalhar os aspectos principais:

#### 1. Estrutura semântica clara e consistente

A organização do conteúdo deve usar elementos semânticos corretos para indicar hierarquia e relações entre informações, como títulos e listas. Por exemplo, usar `<h1>`, `<h2>`, `<h3>` de forma ordenada, sem pular níveis, ajuda leitores de tela a navegar entre seções com facilidade.

**Erro comum:**

```html
<h1>Produtos</h1>
<h3>Eletrônicos</h3> <!-- pular o h2 -->
<h2>Celulares</h2>
```

Esse salto confunde tecnologias assistivas, que esperam uma progressão hierárquica.

**Correção:**

```html
<h1>Produtos</h1>
<h2>Eletrônicos</h2>
<h3>Celulares</h3>
```

#### 2. Rótulos claros e descritivos

Menus, botões e links devem ter rótulos que expliquem exatamente o que fazem ou para onde levam, sem depender apenas do contexto visual. Para usuários que usam leitores de tela, rótulos genéricos como “Clique aqui” são inúteis.

**Exemplo ruim:**

```html
<a href="/contato">Clique aqui</a>
```

**Exemplo acessível:**

```html
<a href="/contato">Entre em contato conosco</a>
```

#### 3. Navegação lógica e previsível

A ordem da navegação deve seguir a lógica visual e semântica. Se a sequência dos itens na tela não coincide com a ordem do código (DOM), a experiência fica confusa para quem navega com teclado ou leitor de tela.

**Exemplo problemático (ordem confusa):**

```html
<nav>
  <a href="/sobre">Sobre</a>
  <a href="/produtos">Produtos</a>
  <a href="/inicio">Início</a> <!-- aparece por último no código, mas visualmente primeiro -->
</nav>
```

**Correção:**

Ordem do código deve refletir a ordem visual:

```html
<nav>
  <a href="/inicio">Início</a>
  <a href="/produtos">Produtos</a>
  <a href="/sobre">Sobre</a>
</nav>
```

#### 4. Uso de agrupamentos e divisões claras

Agrupar informações relacionadas dentro de contêineres semânticos (`<section>`, `<nav>`, `<article>`) ajuda tecnologias assistivas a identificar blocos de conteúdo e facilita a navegação rápida.

#### 5. Suporte ao teclado e tecnologias assistivas

Arquitetura da informação acessível pressupõe que toda navegação e interação possam ser feitas sem mouse, apenas pelo teclado. Desta forma, a organização deve respeitar a tabulação natural e evitar armadilhas (como links ou botões invisíveis ou fora da ordem lógica).

---

### Exemplo prático: menu acessível

Vamos construir um menu simples, acessível e semântico, com navegação clara e rótulos descritivos.

```html
<nav aria-label="Menu principal">
  <ul>
    <li><a href="/inicio">Início</a></li>
    <li><a href="/produtos">Produtos</a>
      <ul>
        <li><a href="/produtos/eletronicos">Eletrônicos</a></li>
        <li><a href="/produtos/vestuario">Vestuário</a></li>
      </ul>
    </li>
    <li><a href="/contato">Contato</a></li>
  </ul>
</nav>
```

- O uso do `<nav>` com `aria-label` indica a função do bloco.
- Listas aninhadas organizam categorias e subcategorias.
- Links têm rótulos claros e descritivos.
- A estrutura HTML respeita a hierarquia, facilitando a navegação com leitores de tela e teclado.

### Erro comum e mensagem típica

Um erro frequente é usar elementos visuais (como `<div>`, `<span>`) para menus sem indicar semântica, ou criar menus com JavaScript que bloqueiam o foco do teclado.

Por exemplo, um menu que não pode ser acessado via teclado pode gerar a mensagem no console do navegador:

```
[Accessibility] Element is not keyboard accessible.
```

Além disso, um leitor de tela pode anunciar:

> "Menu sem título, navegação confusa."

O ajuste para uma navegação acessível evita esses problemas.

### Como validar a acessibilidade na arquitetura da informação?

- Utilize ferramentas automáticas, como o [Lighthouse do Chrome](https://developers.google.com/web/tools/lighthouse), para detectar problemas básicos.
- Teste navegação apenas com teclado (Tab, Shift+Tab, Enter).
- Use leitores de tela básicos (NVDA, VoiceOver) para entender como o conteúdo é lido.
- Peça feedback a pessoas com necessidades especiais.

---

### Exercício prático

Dado o seguinte fragmento de código HTML de um site fictício, identifique problemas de acessibilidade na arquitetura da informação e proponha a correção:

```html
<div class="menu">
  <span>Home</span>
  <span>Services</span>
  <span>About</span>
</div>
<div class="submenu">
  <span>Consulting</span>
  <span>Support</span>
</div>
```

**Tente responder:**

1. Por que essa estrutura dificulta a navegação para usuários com leitores de tela?
2. Como você reestruturaria o código para melhorar a acessibilidade na arquitetura da informação?

---

### Solução comentada

1. **Problemas identificados:**
   - Uso de `<div>` e `<span>` sem semântica para menus e itens.
   - Ausência de links ou botões — elementos interativos esperados para navegação.
   - Falta de agrupamento claro entre menu e submenu.
   - Nenhum rótulo ou indicação para tecnologias assistivas.

2. **Correção acessível:**

```html
<nav aria-label="Menu principal">
  <ul>
    <li><a href="/home">Home</a></li>
    <li>
      <a href="/services" aria-haspopup="true" aria-expanded="false">Services</a>
      <ul>
        <li><a href="/services/consulting">Consulting</a></li>
        <li><a href="/services/support">Support</a></li>
      </ul>
    </li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>
```

**Comentários:**

- Substituímos `<div>` e `<span>` por `<nav>`, `<ul>`, `<li>` e `<a>`, fornecendo semântica clara.
- `aria-label` identifica o bloco como menu principal.
- `aria-haspopup` e `aria-expanded` indicam que "Services" abre um submenu, ajudando tecnologias assistivas.
- Links `<a>` tornam os itens interativos e navegáveis via teclado.
- Listas aninhadas representam hierarquia e agrupam logicamente o submenu.

Com essa estrutura, o menu fica acessível, semântico e fácil de navegar por qualquer usuário.

---

Garantir acessibilidade na arquitetura da informação é um passo fundamental para criar interfaces inclusivas, que respeitam a diversidade humana e promovem experiências mais claras e satisfatórias para todos.