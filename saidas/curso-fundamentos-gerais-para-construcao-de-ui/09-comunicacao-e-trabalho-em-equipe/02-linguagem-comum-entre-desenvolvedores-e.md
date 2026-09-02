## Linguagem comum entre desenvolvedores e designers

Duas pessoas olham a mesma tela. Uma diz "esse componente precisa de um estado de loading". A outra entende "aquele bloco todo, com a tabela dentro". A conversa segue por dez minutos, ambas concordando, até que a implementação revela que "componente" significava coisas diferentes.

Esse tipo de desencontro é responsável por uma parcela grande do retrabalho em projetos de interface, e ele não se resolve com boa vontade. Resolve-se com vocabulário compartilhado — e, onde o vocabulário diverge legitimamente, com a consciência de que ele diverge.

### As palavras que significam coisas diferentes

| Palavra | Para quem desenha | Para quem implementa |
|---|---|---|
| **Componente** | Um elemento reutilizável na biblioteca de design | Uma unidade de código com props e estado |
| **Estado** | A aparência do elemento (hover, erro, vazio) | O dado que a aplicação guarda |
| **Página / Tela** | Um frame no arquivo | Uma rota, ou um componente de topo |
| **Layout** | A composição visual | O sistema de posicionamento (grid, flex) |
| **Protótipo** | Um arquivo navegável | Uma versão descartável em código |
| **Espaçamento** | O respiro entre elementos | Margin, padding, gap — três coisas diferentes |
| **Responsivo** | Funciona em telas diferentes | Adapta-se por media query, sem recarregar |

A tabela não existe para ser decorada. Existe para que, ao perceber uma conversa girando em falso, a primeira hipótese seja "estamos usando a mesma palavra para coisas diferentes" — que é acertada com uma frequência surpreendente.

A frase que resolve: **"quando você diz componente, você está falando do quê exatamente? Mostra?"** Apontar para a tela custa cinco segundos e elimina a ambiguidade inteira.

### O vocabulário que vale de fato compartilhar

Alguns termos precisam significar a mesma coisa para os dois lados, porque são a interface entre as duas disciplinas:

**Tokens.** Nomes para valores de cor, espaçamento, tipografia e raio. Quando `espaco-md` significa 16 no arquivo de design e `--espaco-md: 16px` no CSS, a transferência é mecânica. Quando um lado diz "Cinza 3" e o outro `--text-muted`, cada tela exige uma tradução por adivinhação.

**Os estados de um elemento.** Padrão, hover, foco, pressionado, carregando, desabilitado, erro. São sete palavras que descrevem exatamente a mesma coisa nos dois mundos, e nomear cada um pelo nome evita "aquele estado meio apagado".

**Os estados de conteúdo.** Vazio, carregando, erro de carregamento, resultado único, resultado longo. É a lista que mais falta em implementações — e ter um nome para cada um transforma "faltam estados" em cinco itens verificáveis.

**Breakpoints.** Se a equipe chama de `sm`, `md`, `lg`, o arquivo de design deve usar os mesmos nomes e as mesmas larguras. Falar em "tablet" quando o código tem `md: 768px` cria uma tradução desnecessária a cada conversa.

### Falar de comportamento, não de aparência

A mudança mais produtiva de vocabulário, para quem vem do desenvolvimento, é aprender a descrever a **intenção** em vez do resultado visual. Compare:

> ❌ "Coloca 24 pixels aqui e 16 ali."
> ✅ "Estes três campos são um grupo; o próximo bloco é separado. Use a escala: 16 dentro do grupo, 24 entre grupos."

A primeira formulação transfere valores e não sobrevive a nenhuma tela nova. A segunda transfere a regra, e o desenvolvedor consegue aplicá-la em situações que você não desenhou.

Outro par:

> ❌ "Esse botão fica cinza."
> ✅ "Esse botão fica desabilitado enquanto não houver pelo menos um item selecionado, e ao lado dele aparece o texto dizendo o que falta."

A segunda é implementável sem perguntas. A primeira gera três.

### O glossário do domínio

Além do vocabulário técnico, há o vocabulário do negócio — e ele costuma ser a fonte de confusão mais cara, porque envolve mais gente: design, desenvolvimento, produto, suporte e usuários.

O sintoma clássico é o termo que significa uma coisa no banco de dados, outra na interface e uma terceira na boca do usuário. "Pedido" pode ser o registro na tabela `orders`, o que aparece na tela como "Solicitação", e o que o cliente chama de "compra".

A ferramenta é o dicionário de rótulos que você já conhece da arquitetura de informação, com uma coluna adicional para quem trabalha com código:

| Termo na interface | Definição | Entidade no código | Não usar |
|---|---|---|---|
| Pedido | Solicitação de compra ainda não faturada | `Order` (status ≠ invoiced) | Ordem, solicitação, compra |
| Devolução | Retorno de item já entregue | `Return` | Estorno, cancelamento, troca |

A coluna do meio é a que faz esse documento ser lido pela equipe técnica — ela conecta o vocabulário da tela ao vocabulário do sistema, que é onde a ambiguidade se manifesta em bug.

### O erro que você vai cometer: usar jargão de UX para ganhar autoridade

É uma tentação compreensível em quem está mudando de área: usar os termos certos demonstra domínio. "Isso viola a heurística de visibilidade de status", "a affordance não está clara", "precisamos reduzir a carga cognitiva".

O que acontece na sala: quem não conhece os termos não discorda — apenas não entende, e a proposta passa sem convencimento real ou é adiada por segurança. E quem conhece percebe que o termo foi usado como escudo, não como argumento.

A tradução para consequência observável é sempre mais forte:

> "Viola a heurística de visibilidade de status" → "a pessoa não tem como saber que a lista está filtrada"
> "A affordance não está clara" → "esse elemento é clicável e não parece"
> "Reduzir a carga cognitiva" → "são 28 campos numa tela; metade desiste no meio"

Nenhuma dessas traduções é menos precisa. São mais precisas — dizem exatamente o que acontece, em vez de nomear a categoria do problema. O jargão é útil entre pares que compartilham a definição; fora disso, é ruído.

Vale a inversão também: quando alguém da equipe técnica usa jargão que você não domina — "isso exige mudar o contrato da API", "vai quebrar a hidratação" —, peça a tradução em vez de assentir. A mesma cortesia, na direção contrária, e pelo mesmo motivo.

### Exercício prático

**Objetivo:** construir e testar um vocabulário compartilhado.

1. Pegue uma tela de um sistema real e liste dez elementos ou conceitos dela.
2. Escreva, para cada um, o nome que você usaria.
3. Peça a alguém que implementa o mesmo sistema que faça a lista independentemente, com os nomes que essa pessoa usa.
4. Compare. Onde os nomes divergem?
5. Para cada divergência, decida: é a mesma coisa com dois nomes (escolha um) ou são coisas diferentes que precisam de nomes distintos?
6. Monte o glossário com as quatro colunas, incluindo a entidade no código.
7. Teste: peça a uma terceira pessoa que, lendo apenas o glossário, aponte na tela os dez itens.

### Solução comentada

O passo 4 produz, tipicamente, divergência em quase metade dos itens — e a natureza das divergências é instrutiva.

As mais comuns não são desacordos, são **granularidades diferentes**. Você chama de "card de pedido" o bloco inteiro; quem implementa chama a mesma coisa de "OrderSummary" e tem, dentro dele, três componentes que você nunca nomeou porque visualmente são um só. Nenhum dos dois está errado: a decomposição do código não precisa espelhar a percepção visual, e forçar isso costuma piorar os dois lados.

A saída correta não é unificar tudo — é saber que a correspondência não é de um para um e, nos pontos de contato, usar o nome do outro lado. Quando você pede "muda o espaçamento do card de pedido", vale acrescentar "que acho que é o OrderSummary de vocês". Meia frase que economiza um mal-entendido.

O passo 7 é o teste real do glossário. Se uma terceira pessoa consegue apontar os dez itens lendo apenas as definições, o documento funciona. O padrão de falha é a definição circular — "Pedido: um pedido do cliente" — que parece definição e não define nada. Uma definição útil diz o que **inclui** e, principalmente, o que **exclui**: "solicitação de compra ainda não faturada" é útil porque separa pedido de fatura.

Uma nota sobre o passo 3: pedir a lista independentemente, sem conversar antes, é essencial. Feita em conjunto, a lista converge para o vocabulário de quem falou primeiro, e a divergência real — que é o objeto do exercício — fica escondida.

---
