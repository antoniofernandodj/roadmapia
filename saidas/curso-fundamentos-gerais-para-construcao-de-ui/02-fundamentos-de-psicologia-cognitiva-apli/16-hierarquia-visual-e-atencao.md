## Hierarquia visual e atenção

Abra qualquer tela de um sistema interno mal resolvido e você verá o mesmo sintoma: tudo tem o mesmo peso. Vinte campos com o mesmo tamanho de fonte, seis botões cinza idênticos, três blocos de texto separados por linhas iguais. O usuário não consegue errar de propósito — ele simplesmente não sabe por onde começar, e a tela inteira vira uma parede. O problema aqui não é estético. É que a interface não disse ao olho o que olhar primeiro.

Hierarquia visual é o conjunto de decisões que responde a essa pergunta: dado que o olho só consegue focar num ponto de cada vez, em que ordem os elementos serão vistos? Quem decide essa ordem é você, com contraste, tamanho, posição e espaço. Se você não decidir, a ordem acontece mesmo assim — só que por acidente, e normalmente pelo elemento mais berrante da tela, que quase nunca é o mais importante.

### O mecanismo: o olho varre antes de ler

A leitura de uma interface tem duas fases muito diferentes. Na primeira, que dura entre 200 e 500 milissegundos, o sistema visual faz uma varredura pré-atentiva: ele não lê palavras, ele detecta diferenças brutas de luminosidade, tamanho, cor e orientação. É a mesma detecção automática de contraste que você já viu em percepção visual e atenção. Só na segunda fase, se algo prendeu o olhar, o cérebro aloca atenção consciente e começa a decodificar texto.

A consequência prática é dura: **um elemento que não se destaca na varredura pré-atentiva pode não existir**. Ele está na tela, tem contraste suficiente para ser lido, passa em qualquer verificação de acessibilidade de cor — e ainda assim ninguém o encontra, porque ninguém chegou a olhar para ele.

Hierarquia visual funciona explorando essa primeira fase. Você cria diferenças grandes o bastante para serem detectadas pré-atentivamente, e as organiza em degraus: o primeiro degrau captura o olhar, o segundo o recebe, o terceiro sustenta a leitura.

### Os quatro instrumentos, em ordem de força

Nem todos os recursos de destaque têm o mesmo poder. Na prática, esta é a ordem aproximada de força perceptiva:

| Instrumento | Como age | Força relativa |
|---|---|---|
| Tamanho | Diferença de área do elemento | Muito alta |
| Contraste de luminosidade | Claro sobre escuro, ou o inverso | Muito alta |
| Espaço em volta | Isolamento separa do resto | Alta |
| Cor (matiz) | Um tom fora da paleta dominante | Média, e cai se houver muitas cores |
| Peso tipográfico | Negrito, semibold | Média |
| Posição | Alto e à esquerda, em leitura ocidental | Média |

Duas regras derivam disso. A primeira: **destaque é relativo, não absoluto**. Um botão azul só chama atenção numa tela onde o azul é raro; numa tela azul, ele desaparece. A segunda: **força se gasta**. Se você destacar seis coisas, nenhuma está destacada — o contraste que sobra entre elas é zero.

### Construindo três degraus explícitos

Uma hierarquia utilizável quase nunca precisa de mais de três ou quatro níveis. Vamos montar um, numa tela de confirmação de pedido:

**Nível 1 — a âncora.** Um elemento só. É o que a pessoa precisa ver em meio segundo. Aqui, o título "Confirmar pedido — R$ 248,90", em 28px, negrito, com 32px de espaço acima e nada competindo na mesma faixa horizontal.

**Nível 2 — a ação e o conteúdo principal.** O botão primário "Confirmar" (fundo sólido, cor de destaque, 48px de altura) e a lista dos itens em 16px. Note que o botão e a lista estão no mesmo nível de importância, mas se destacam por instrumentos diferentes: o botão por cor e área preenchida, a lista por ocupar o centro do bloco de conteúdo.

**Nível 3 — o apoio.** Prazo de entrega, endereço, forma de pagamento, em 14px, cinza médio. Legíveis, procuráveis, mas fora do caminho.

**Nível 4 — o silêncio.** "Cancelar" como texto simples sublinhado, sem fundo. Termos de uso em 12px. Existem porque precisam existir, e não disputam nada.

A distância entre os degraus precisa ser grande. Um título de 17px sobre corpo de 16px não é hierarquia, é ruído: a diferença fica abaixo do limiar de detecção pré-atentiva. Uma progressão que funciona é multiplicar por volta de 1,25 a 1,5 a cada nível — 14, 18, 24, 32 — em vez de somar um ponto.

### O erro que você vai cometer: hierarquia por cor sozinha

O caso típico: a tela tem um botão "Salvar" verde e um "Excluir" vermelho, ambos do mesmo tamanho, lado a lado, mesmo peso. O designer considera a hierarquia resolvida — afinal, as cores são diferentes e chamativas.

O que acontece no teste: usuários clicam em "Excluir" achando que era "Salvar". Duas causas somadas. Primeiro, na varredura pré-atentiva, dois blocos de mesma área e mesma luminosidade lidos como **um par equivalente** — a mente registra "há duas opções aqui", não "há uma ação principal". Segundo, cerca de 8% dos homens têm alguma deficiência de visão de cores no eixo vermelho-verde: para eles os dois botões são literalmente o mesmo botão duplicado.

A correção não é trocar as cores. É criar diferença de **forma e peso**: "Salvar" vira um botão sólido, cheio; "Excluir" vira texto com borda fina, ou sai da linha principal e vai para um menu secundário. A cor passa a ser reforço, não o único sinal.

### Fluxo de leitura: a hierarquia também é sequência

Hierarquia não é só "o que é maior". É também **em que ordem os degraus aparecem no caminho do olho**. Em interfaces com muito texto, o olhar tende a percorrer um padrão em F: varre a primeira linha, desce, varre uma segunda linha mais curta, e depois desliza pela margem esquerda. Em telas mais visuais e com poucos elementos, o padrão se aproxima de um Z: canto superior esquerdo, superior direito, diagonal, inferior direito.

Isso tem uma implicação direta: **o canto inferior direito é o lugar mais caro da tela para informação, e o melhor para a ação final**. É onde o olho chega por último, depois de ter lido o contexto. Por isso o botão de confirmação de formulários longos costuma morar lá, e por isso enfiar um aviso crítico nesse canto é quase garantir que ninguém o leia antes de agir.

### Exercício prático

**Objetivo:** diagnosticar e corrigir uma hierarquia quebrada.

Pegue uma tela real que você já construiu como desenvolvedor — um formulário de cadastro, um painel administrativo, uma tela de listagem. Faça o seguinte, nesta ordem:

1. Aperte os olhos até a tela ficar desfocada (ou aplique um desfoque de 6 a 8 pixels numa captura de tela). Anote, em ordem, os três primeiros blocos que ainda assim se destacam.
2. Escreva, sem olhar a tela, quais são os três elementos **mais importantes** para a tarefa principal do usuário.
3. Compare as duas listas.
4. Reescreva a tela em três níveis, atribuindo a cada elemento um dos rótulos: âncora, principal, apoio ou silêncio. Um único elemento pode ser âncora.
5. Aplique as mudanças usando tamanho e espaço primeiro, cor só depois.

### Solução comentada

Na esmagadora maioria dos casos, as duas listas do passo 3 não batem. O padrão mais comum em telas feitas por desenvolvedores é que o que se destaca no desfoque são elementos de **navegação e estrutura** — a barra lateral colorida, o cabeçalho escuro, as bordas da tabela — enquanto a tarefa real do usuário (encontrar um registro, preencher três campos, confirmar) fica em cinza uniforme no meio.

A razão é estrutural: navegação e chrome são construídos uma vez, com atenção e capricho, e o conteúdo é gerado dinamicamente com estilos padrão. O resultado é uma interface que destaca a moldura e apaga o quadro.

A correção mais eficiente quase nunca é adicionar destaque ao conteúdo — é **remover destaque da moldura**. Baixe a saturação da barra lateral, reduza o peso do cabeçalho, apague as bordas da tabela e substitua-as por espaçamento. Sem tocar em uma linha do conteúdo, a tarefa principal sobe um degrau na hierarquia, porque a hierarquia é relativa: diminuir o vizinho tem o mesmo efeito que crescer.

No passo 4, se você não conseguir eleger uma âncora única, isso é um diagnóstico e não um impasse: significa que a tela está tentando fazer duas tarefas ao mesmo tempo, e o problema não é de hierarquia visual, é de escopo. Duas âncoras pedem duas telas.

---
