## Prototipagem para web

Web é a plataforma em que o protótipo mais facilmente mente. Em desktop você conhece a tela; em mobile você conhece o dispositivo; na web, a mesma página será vista em um monitor ultrawide, em um notebook antigo, em um tablet deitado e em um celular — com zoom de 125%, com bloqueador de anúncios, com a fonte padrão aumentada, e com o navegador que a empresa do usuário congelou em uma versão de três anos atrás.

Prototipar para web é, principalmente, decidir o que acontece entre os tamanhos e nos estados que só o navegador produz.

### Os pontos de quebra, e por que não são três

A prática corrente fala em "mobile, tablet e desktop", e isso é uma simplificação que custa caro. Pontos de quebra não devem sair de uma lista de dispositivos — devem sair do **conteúdo**: o layout quebra onde ele para de funcionar, e isso depende do que há na página.

Ainda assim, é preciso escolher larguras concretas para prototipar. Um conjunto que cobre bem:

| Frame | Largura | O que ele testa |
|---|---|---|
| Celular | 375 | O caso mais apertado; coluna única |
| Tablet retrato | 768 | O ponto onde duas colunas passam a caber |
| Notebook | 1280 | O caso mais comum de trabalho |
| Monitor amplo | 1600+ | O que fazer com o espaço sobrando |

O último é o mais negligenciado. Uma página que apenas estica até 1920 pixels produz linhas de texto com 200 caracteres, ilegíveis. A decisão — limitar a largura do conteúdo, ou usar o espaço para uma coluna adicional — precisa ser tomada, e o protótipo é onde ela aparece.

Prototipar os quatro frames não significa desenhar quatro páginas do zero. A técnica é usar **auto layout** com restrições, criar o layout de 1280 primeiro, e derivar os outros ajustando. O que se busca não é pixel-perfeição em cada largura, é **declarar as regras**: esta coluna vira linha, esta imagem some, este menu vira ícone.

### Estados que o navegador impõe

Estes não existem em aplicação nativa e precisam estar no protótipo:

**Foco visível.** Quem navega por teclado precisa ver onde está. O anel de foco padrão do navegador é feio e quase sempre removido no CSS — e removê-lo sem substituir por outro é uma falha de acessibilidade grave. Prototipe o estado de foco de todos os elementos interativos, com um estilo próprio se você não quiser o padrão.

**Link visitado.** Ainda existe, ainda ajuda, e quase todo design moderno esqueceu.

**Carregamento progressivo.** A página aparece antes de estar pronta. Se o layout se desloca quando as imagens carregam, a pessoa clica no lugar errado. Prototipar um frame de "carregando" com esqueletos de conteúdo comunica a intenção de reservar o espaço.

**Rolagem e cabeçalho fixo.** O cabeçalho acompanha a rolagem, some ao descer e volta ao subir, ou fica parado? Cada opção tem custo de espaço vertical, e em telas pequenas isso decide se cabem quatro ou cinco linhas de conteúdo. Em Figma, um elemento com posição fixa dentro de um frame com rolagem simula bem esse comportamento.

**Voltar do navegador.** É o botão mais usado da web, e é o que mais quebra aplicações de página única. Se o seu fluxo tem etapas, o voltar precisa levar à etapa anterior — e não sair da aplicação inteira. Prototipar isso com a ação `Back` e testá-la explicitamente evita a descoberta tardia.

### Simulando rolagem e conteúdo longo

Web tem páginas longas, e isso é difícil de representar em uma ferramenta de tela fixa. Duas técnicas:

**Frame alto com rolagem.** Crie o frame com a altura da janela (por exemplo, 1280 × 800), coloque o conteúdo excedendo essa altura, e ative `Clip content` com `Vertical scrolling`. No modo de apresentação, a rolagem funciona. É a representação mais fiel.

**Frame inteiro visível.** Desenhe a página completa, com 3000 pixels de altura, sem rolagem. Serve para discutir a composição com a equipe, e mente sobre a experiência real — ninguém vê a página assim. Use para conversa interna, nunca para teste com usuário.

A diferença entre as duas explica um mal-entendido comum: a "dobra" (o limite do que aparece sem rolar) não existe no arquivo do designer e existe muito na tela do usuário. Testar com o frame com rolagem é o que revela se a ação principal ficou abaixo dela.

### O erro que você vai cometer: prototipar apenas o caminho com dados

A página do produto com foto bonita, três avaliações e preço promocional. A listagem com doze resultados perfeitamente distribuídos. O painel com o gráfico cheio.

O que a web entrega de verdade: o produto sem foto, cujo card fica com um buraco; a busca sem resultados; o gráfico do usuário que se cadastrou ontem e não tem histórico; o texto do parceiro que escreveu um título com 180 caracteres.

Esses não são casos raros — em um catálogo real, dados incompletos são a norma, não a exceção. E cada um deles produz um layout que ninguém desenhou, montado na hora pelo CSS, normalmente feio e às vezes quebrado.

A correção é adotar uma disciplina simples e aplicá-la a toda tela do protótipo: para cada componente que exibe dados, desenhe **quatro versões** — vazio, mínimo (um item, texto curto), típico e extremo (texto longo, muitos itens, valores grandes). Não precisa prototipar as quatro em todas as telas; precisa fazer isso nos três ou quatro componentes que se repetem por toda a aplicação. É o investimento de uma hora que elimina metade das surpresas de implementação.

### Exercício prático

**Objetivo:** prototipar uma página web responsiva com estados reais.

Construa uma página de listagem de produtos com busca e filtros:

1. Três frames de largura: 375, 768 e 1280.
2. Em 1280: filtros em coluna lateral, grade de produtos em três colunas, cabeçalho fixo.
3. Em 768: filtros em painel recolhível acionado por botão, grade em duas colunas.
4. Em 375: filtros em painel de tela cheia, grade em coluna única, menu principal em ícone.
5. Estados adicionais: busca sem resultados, carregando (com esqueletos) e um card de produto sem imagem.
6. Interações: rolagem vertical funcional nos três frames, cabeçalho fixo em 1280, abertura e fechamento dos filtros, e `Back` funcionando no fluxo de detalhe do produto.

### Solução comentada

O item 3 é onde a maioria trava, e o motivo é interessante: **não existe uma resposta certa para o que fazer com os filtros em tela média**, e por isso a decisão precisa ser deliberada.

Recolher os filtros atrás de um botão libera espaço para os produtos, e é o que quase todo mundo faz. O custo é que os filtros deixam de ser descobertos: quem não sabe que eles existem não clica no botão, e a taxa de uso de filtro despenca em telas menores. Isso é mensurável e conhecido — sistemas de comércio eletrônico veem uso de filtros muito menor no celular, e parte disso é do design, não do contexto.

As alternativas: manter uma linha horizontal com os dois ou três filtros mais usados sempre visíveis, e esconder o resto; ou mostrar os filtros aplicados como etiquetas removíveis logo acima da lista, o que ao menos ensina que o recurso existe. A escolha depende de quanto o filtro importa para a tarefa — em um catálogo com 40 itens, pouco; em um com 40 mil, é a única forma de encontrar algo.

Sobre o item 5, o card sem imagem: a maneira como você o resolve revela uma regra de layout que precisa ser explicitada para quem implementa. Se o card mantém a mesma altura, com um espaço cinza no lugar da foto, a grade permanece alinhada — e é quase sempre a escolha certa, porque uma grade desalinhada é muito mais perturbadora do que um espaço vazio. Se o card encolhe, as linhas da grade ficam irregulares e o olho perde a referência. Essa decisão precisa estar anotada no protótipo, porque ela não é visível no frame "normal" e o desenvolvedor vai implementar o que for mais fácil.

Por fim, o cabeçalho fixo em 1280: ao testá-lo com rolagem, verifique quanto espaço vertical ele consome. Um cabeçalho de 80 pixels em uma janela de 800 é 10% da tela permanentemente ocupado. Vale? Depende de quantas vezes por sessão a pessoa usa a navegação do cabeçalho. Se for uma, o custo é alto demais — e o protótipo, com a rolagem funcionando, é onde essa conta fica visível.

---
