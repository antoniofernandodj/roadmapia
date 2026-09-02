## Aplicando princípios de psicologia cognitiva para melhorias

Você tem a lista de problemas: a avaliação heurística apontou violações, o mapa de atrito mostrou onde as pessoas perdem tempo, e o feedback trouxe as reclamações recorrentes. Falta a parte que transforma diagnóstico em correção — e é aqui que a psicologia cognitiva deixa de ser teoria e vira ferramenta de decisão.

A vantagem prática é a seguinte: em vez de propor mudanças por intuição e defendê-las por gosto, você propõe mudanças com uma explicação de mecanismo. "Vamos aumentar o botão" é opinião. "Este alvo tem 22 pixels e está a 400 pixels do ponto onde o olhar termina; pela lei de Fitts, cada acionamento custa aproximadamente o dobro do que custaria com 44 pixels e metade da distância" é argumento.

### Um catálogo de correções por princípio

Cada princípio que você já conhece aponta um tipo específico de correção. A tabela abaixo é o mapa entre sintoma e mecanismo:

| Sintoma observado | Princípio envolvido | Correção típica |
|---|---|---|
| "Não vi que tinha esse botão" | Varredura pré-atentiva; hierarquia visual | Aumentar contraste de tamanho/luminosidade, isolar com espaço |
| Erra o alvo, clica no vizinho | Lei de Fitts | Aumentar alvo, afastar do vizinho, aproximar do fluxo |
| Demora para escolher no menu | Lei de Hick; semelhança de rótulos | Agrupar, reduzir opções visíveis, diferenciar rótulos |
| Anota número num papel | Memória de trabalho | Carregar o dado entre telas |
| Não lembra o que cada ícone faz | Reconhecimento vs. recordação | Rótulo permanente ao lado do ícone |
| Clica duas vezes no "Enviar" | Feedback; tempo de resposta | Estado pressionado em < 100 ms; desabilitar durante o envio |
| "Achei que ia salvar" | Modelo mental | Renomear a ação; alinhar com a convenção conhecida |
| Perde-se em tela cheia de campos | Carga cognitiva; Gestalt | Agrupar por proximidade, dividir em etapas |
| Confunde duas telas parecidas | Consistência; figura-fundo | Diferenciar títulos e âncoras visuais |
| Desfaz por engano e perde trabalho | Prevenção de erro; controle | Desfazer em vez de confirmação; salvamento automático |

Essa tabela não é uma receita mecânica — o mesmo sintoma pode ter causas diferentes, e é por isso que o diagnóstico vem antes. Mas ela encurta o caminho entre observar e propor.

### Três correções detalhadas

**Caso A: o formulário que ninguém termina.**

Sintoma: 28 campos numa tela só, abandono na metade. Diagnóstico: carga de memória de trabalho e ausência de percepção de progresso — a pessoa não sabe quanto falta e não consegue fechar nenhum ciclo.

Correção pelo princípio: dividir em etapas, cada uma com um agrupamento semântico coerente (identificação, endereço, dados fiscais), com indicador de progresso **nomeado**. Cada etapa fecha um ciclo e libera memória de trabalho.

O que não fazer: reduzir o número de campos sem critério. Se os 28 dados são necessários, eliminar cinco cria um problema em outro lugar. A carga intrínseca é dada pelo negócio; o que se corrige é a estranha.

**Caso B: a lista onde ninguém acha nada.**

Sintoma: 40 linhas, colunas de mesmo peso, pessoas usam `Ctrl+F` do navegador em vez da busca do sistema.

Diagnóstico: ausência de hierarquia visual dentro da linha. Todas as colunas têm o mesmo tamanho e cor, então a varredura pré-atentiva não tem âncora — não há onde o olho pousar.

Correção: identificar a **coluna de identidade** (aquela pela qual a pessoa reconhece a linha, normalmente nome ou número) e dar-lhe peso maior; reduzir as demais a cinza secundário; alinhar números à direita; e usar espaçamento em vez de linhas divisórias para separar. A alteração é apenas de estilo, não muda uma linha de lógica, e costuma cortar pela metade o tempo de localização.

**Caso C: o botão que ninguém encontra.**

Sintoma: a ação principal da tela é usada por 8% dos usuários; suporte recebe pedidos para fazê-la manualmente.

Diagnóstico possível — e é aqui que se erra com frequência. Pode ser hierarquia (o botão não se destaca), pode ser posição (está fora do padrão de leitura), pode ser rótulo (o nome não corresponde ao que a pessoa procura), ou pode ser modelo mental (ela não sabe que isso é possível ali).

O teste que separa: mostre a tela a cinco pessoas por cinco segundos e pergunte o que se pode fazer nela. Se ninguém menciona a ação, é descoberta. Se mencionam com outro nome, é rótulo. Se dizem "tem um botão ali mas não sei o que faz", é rótulo também. Só se o problema for de destaque a correção é aumentar contraste.

### O erro que você vai cometer: aplicar o princípio sem verificar a causa

A lei de Hick diz que menos opções significam decisão mais rápida. Você tem um menu com quatorze itens e as pessoas demoram para escolher. A correção parece óbvia: agrupar em quatro categorias com submenus.

O resultado no teste: o tempo aumentou. E a explicação também está na literatura — você trocou uma decisão entre quatorze itens visíveis por três decisões em sequência, cada uma com incerteza sobre qual categoria contém o que se procura. Estruturas mais rasas e largas costumam superar as estreitas e profundas, e a lei de Hick isolada não captura isso.

O que provavelmente causava a demora não era a quantidade, e sim a **semelhança dos rótulos** — quatro itens começando com a mesma palavra forçam leitura completa em vez de reconhecimento de forma. Reescrever os rótulos resolveria mantendo os quatorze visíveis.

A lição geral: princípios cognitivos descrevem mecanismos, não prescrevem soluções. Cada um vale sob condições específicas, e aplicá-lo sem confirmar que a condição existe produz correções que pioram. A verificação custa pouco — cinco minutos observando alguém usar — e evita semanas de trabalho na direção errada.

### Priorizando com base em custo cognitivo

Nem toda correção rende igual. Uma ordem que funciona bem:

1. **O que elimina exigência de memória.** Carregar um dado entre telas, mostrar o que estava selecionado, preencher automaticamente. Custo de implementação quase sempre baixo, ganho imediato e permanente.
2. **O que reduz busca visual.** Hierarquia dentro de listas e formulários. Mudança apenas de estilo, sem risco funcional.
3. **O que adiciona feedback.** Estado pressionado, indicador de progresso, confirmação. Barato, e resolve a classe inteira de problemas de ação duplicada e insegurança.
4. **O que corrige rótulos.** Mudança de texto, risco praticamente zero, e frequentemente o maior ganho por linha alterada.
5. **O que reestrutura fluxo.** Alto impacto e alto custo, inclusive de reaprendizado. Deixe por último e valide antes.

Repare que os quatro primeiros itens não exigem mudança de arquitetura e cabem em uma sprint. Essa é a razão pela qual melhorar interfaces existentes costuma ter retorno melhor que redesenhá-las.

### Exercício prático

**Objetivo:** propor correções fundamentadas em princípio, e verificar a causa antes.

1. Pegue cinco problemas do seu mapa de atrito ou da sua avaliação heurística.
2. Para cada um, escreva o **mecanismo cognitivo** envolvido — não o nome da lei, mas o que acontece na cabeça da pessoa.
3. Formule uma hipótese de causa e desenhe um teste de cinco minutos que a confirme ou refute (teste dos cinco segundos, primeiro clique, ou uma pergunta a três pessoas).
4. Execute os testes.
5. Para as causas confirmadas, escreva a correção e o princípio que a sustenta.
6. Para as refutadas, formule uma nova hipótese.

### Solução comentada

O passo 6 é o que dá valor ao exercício, e a taxa de refutação costuma ser alta — em torno de metade das hipóteses iniciais não se confirma. Isso não é sinal de despreparo; é o resultado esperado quando se testa em vez de supor.

O padrão mais frequente de refutação: o problema que parecia de **destaque visual** revela-se de **vocabulário**. A pessoa viu o botão, leu o rótulo, e seguiu adiante porque a palavra não correspondia ao que ela procurava. Isso é praticamente indistinguível de "não viu o botão" quando se olha apenas para o resultado — em ambos os casos a pessoa não clica. Só o teste dos cinco segundos separa: se ela menciona ter visto o botão mas não sabe o que ele faz, o destaque está funcionando e o texto não.

A consequência prática é grande, porque as duas correções custam coisas muito diferentes. Redesenhar a hierarquia visual de uma tela é trabalho de horas ou dias, envolve decisões de estilo e discussão. Trocar uma palavra é uma linha, sai na próxima entrega e pode ser revertida em segundos se não funcionar.

Uma observação sobre o passo 2, escrever o mecanismo em vez do nome da lei. Isso parece formalidade e não é: quem escreve "lei de Fitts" muitas vezes está apenas rotulando o problema, enquanto quem escreve "o alvo é pequeno e está longe de onde a mão já estava, então cada acionamento exige mirar" está de fato raciocinando sobre a causa. A diferença aparece na qualidade das correções propostas — e, mais tarde, na capacidade de defendê-las numa reunião em que alguém discorda.

---
