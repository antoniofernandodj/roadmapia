## Criando interações simples

Você já tem as telas desenhadas e a ferramenta escolhida. Falta a parte que separa um conjunto de imagens de um protótipo: fazer com que clicar em algo produza uma consequência. E aqui aparece a primeira surpresa para quem vem do desenvolvimento — em uma ferramenta de prototipagem não existe estado, não existe variável, não existe condicional no sentido em que você conhece. Existe apenas uma máquina de estados desenhada à mão, onde cada estado é uma tela e cada interação é uma aresta entre duas telas.

Entender isso muda tudo. Prototipar deixa de ser "programar sem código" e passa a ser um exercício de enumerar estados visíveis e ligá-los. É menos poderoso do que programar, e muito mais rápido — desde que você aceite as regras do jogo.

### A anatomia de uma interação

Toda interação, em qualquer ferramenta, é definida por quatro partes:

| Parte | O que é | Exemplos |
|---|---|---|
| **Origem** | O elemento que recebe a ação | Um botão, um campo, um frame inteiro |
| **Gatilho** | O que a pessoa faz | Clique/toque, hover, pressionar, arrastar, tecla, atraso |
| **Ação** | O que o protótipo faz | Ir para outro frame, abrir sobreposição, voltar, rolar até |
| **Transição** | Como a mudança acontece | Instantânea, dissolver, deslizar, "smart animate" |

A confusão mais frequente está entre **origem** e **destino**: em Figma, a linha de interação é puxada do elemento de origem para o frame de destino. Se você puxar a partir do frame inteiro, qualquer clique em qualquer lugar dispara a navegação — que é útil em protótipos de baixa fidelidade e desastroso quando você quer testar se as pessoas acham o botão certo.

### Interação 1: navegação entre telas

É a mais básica e resolve talvez 70% de um protótipo típico.

**Passo a passo no Figma:**

1. Selecione o botão "Entrar" na tela de login.
2. Abra o painel **Prototype** (canto superior direito).
3. Arraste o círculo azul que aparece na borda direita da seleção até o frame "Painel inicial".
4. No painel que se abre, confirme: `On click` → `Navigate to` → `Painel inicial`.
5. Escolha a transição: `Instant` para testar fluxo puro, `Smart animate` se houver elementos comuns entre as telas.
6. Aperte `Shift + Space` (ou o botão de play) para testar.

**No Lunacy**, o mesmo resultado se obtém desenhando um retângulo transparente sobre o botão e definindo o link para a outra prancheta — a ferramenta trabalha com hotspots em vez de interações ligadas ao elemento.

Uma regra prática: crie a interação a partir do **componente do botão**, não de um retângulo invisível sobre ele. Assim, quando o botão for movido, a interação vai junto.

### Interação 2: sobreposições (modais, menus, tooltips)

A diferença fundamental entre `Navigate to` e `Open overlay` é que a sobreposição preserva a tela de baixo. É o que você quer para um modal de confirmação, um menu suspenso ou uma dica flutuante.

Para criar um modal de confirmação de exclusão:

1. Crie um frame separado, do tamanho apenas do modal (por exemplo, 400 × 220), fora do fluxo principal. Chame-o de `modal-confirmar-exclusao`.
2. No botão "Excluir" da tela principal: `On click` → `Open overlay` → `modal-confirmar-exclusao`.
3. Nas opções da sobreposição, marque **Centered**, ative **Add background** com preto a 40% de opacidade, e marque **Close when clicking outside**.
4. Dentro do modal, no botão "Cancelar": `On click` → `Close overlay`.
5. No botão "Excluir definitivamente": `On click` → `Navigate to` → tela de lista já sem o item (uma cópia da lista com uma linha a menos).

O passo 5 é onde o modelo mental de máquina de estados aparece: não existe "remover o item". Existe uma segunda tela desenhada sem ele.

### Interação 3: mudança de estado sem trocar de tela

É a que dá vida a um protótipo, e a que mais confunde quem começa. Você quer que um campo mostre uma mensagem de erro, ou que um checkbox fique marcado, sem sair da tela.

A ferramenta para isso são **variantes de componente**. Crie um componente `Campo de senha` com três variantes: `padrao`, `foco` e `erro`. Cada variante é um desenho diferente do mesmo elemento. Depois, dentro do componente, defina interações entre variantes:

- Variante `padrao`, no gatilho `On click` → `Change to` → `foco`.
- Variante `foco`, no gatilho `On click` fora — que não existe — não funciona; use um clique no botão "Entrar" da tela para levar à variante `erro`.

Isso revela um limite importante e vale dizer com todas as letras: **a ferramenta não sabe se a senha está errada**. Ela apenas mostra o estado de erro porque você mandou. O protótipo simula a aparência da validação, não a validação.

### O erro que você vai cometer: prototipar a árvore inteira

O impulso natural de quem programa é cobrir todos os caminhos. Você começa pela tela de login, faz o caminho de sucesso, e então pensa: "e se a senha estiver errada? E se o e-mail não existir? E se a conta estiver bloqueada?". Três horas depois, há 40 frames, 60 interações, e ninguém consegue mais achar nada no arquivo.

O sintoma da doença é o arquivo de protótipo que demora mais para ser mantido do que a tela levaria para ser implementada. Quando isso acontece, o protótipo perdeu a razão de existir — ele era para ser mais barato que o código.

A correção é decidir, **antes de começar**, qual pergunta o protótipo responde. "As pessoas encontram a opção de recuperar a senha?" exige três telas. "O fluxo de cadastro completo é compreensível?" exige oito. Nenhuma pergunta razoável exige quarenta.

Uma regra que funciona bem: prototipe o caminho principal completo e, dos caminhos alternativos, apenas aquele sobre o qual você tem dúvida real. Os outros ficam como anotação em texto ao lado do frame.

### Exercício prático

**Objetivo:** construir um protótipo navegável de um fluxo de busca com resultado vazio.

Monte, na ferramenta de sua preferência, quatro telas:

1. `busca-inicial` — campo de busca vazio e um botão "Buscar".
2. `busca-resultados` — a mesma tela com cinco resultados listados.
3. `busca-vazia` — a mesma tela com a mensagem de nenhum resultado e uma sugestão de ação.
4. `detalhe-item` — a tela de um resultado individual, com um botão "Voltar".

Crie as interações:

- Do botão "Buscar" em `busca-inicial` para `busca-resultados`, com transição instantânea.
- De um segundo botão ou atalho (pode ser um retângulo invisível no canto, só para teste) de `busca-inicial` para `busca-vazia`.
- Do primeiro resultado em `busca-resultados` para `detalhe-item`.
- Do botão "Voltar" em `detalhe-item`, usando a ação `Back` em vez de navegar para um frame específico.
- Um modal de "filtros" sobreposto a `busca-resultados`, com botões "Aplicar" e "Cancelar" que fecham a sobreposição.

Teste o fluxo inteiro no modo de apresentação, do início ao fim, sem tocar no editor.

### Solução comentada

Três pontos costumam dar trabalho neste exercício, e cada um ensina algo sobre o modelo da ferramenta.

**O botão "Voltar" com `Back` em vez de `Navigate to`.** Se você ligar o "Voltar" diretamente a `busca-resultados`, o protótipo funciona — até a pessoa chegar em `detalhe-item` vindo de `busca-vazia` ou de outro caminho, e ser jogada num lugar onde nunca esteve. A ação `Back` usa o histórico de navegação do próprio protótipo e resolve isso de uma vez. É o análogo mais próximo de um `history.back()` que a ferramenta oferece, e é quase sempre a escolha certa para botões de retorno.

**O acesso à tela de resultado vazio.** O exercício pede um "atalho para teste" de propósito. No produto real, chegar ao estado vazio depende do que foi digitado — e a ferramenta não sabe ler o campo. Prototipadores experientes resolvem isso de duas maneiras: ou colocam um gatilho escondido (um retângulo transparente no canto, que só o facilitador conhece) ou usam o gatilho de tecla, ligando uma tecla específica ao frame de estado vazio. Em uma sessão de teste com usuário, o facilitador dispara o estado no momento adequado. Isso é normal e não invalida o teste — desde que o participante não perceba a manipulação.

**O modal que não fecha.** O esquecimento clássico é criar a sobreposição e não definir nenhuma interação de fechamento, nem marcar `Close when clicking outside`. O resultado é um protótipo em que a pessoa entra nos filtros e fica presa — e, curiosamente, esse é um bug que também acontece em produção com frequência. Se aconteceu no seu protótipo, aconteceu porque você pensou no caminho de entrada e não no de saída; vale checar se a mesma omissão não está no código.

---
