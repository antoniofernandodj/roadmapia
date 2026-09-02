## Identificação de pontos de atrito na interface

Atrito é tudo o que fica entre a intenção da pessoa e o resultado que ela quer. Nem todo atrito é ruim — a confirmação antes de excluir algo é atrito deliberado e útil. O que se procura aqui é o atrito **acidental**: o passo que existe porque o sistema foi construído assim, não porque a tarefa exige.

A avaliação heurística, que você acabou de ver, encontra violações de princípio. Este trecho trata de um complemento: encontrar os pontos onde as pessoas efetivamente perdem tempo, erram ou desistem — o que nem sempre coincide com o que viola uma heurística.

### As quatro fontes de evidência

Cada uma enxerga uma parte diferente do problema, e usar apenas uma leva a conclusões enviesadas.

**1. Dados de uso.** Se houver instrumentação, ela mostra onde as pessoas param. Os sinais mais reveladores:

- **Taxa de abandono por etapa** em fluxos com várias telas. A etapa em que a queda salta é a suspeita principal.
- **Idas e voltas.** Uma sequência tela A → tela B → tela A indica que B não era o que se esperava.
- **Cliques repetidos no mesmo elemento** em poucos segundos: falta de feedback.
- **Cliques em elementos não clicáveis** — um título, um ícone decorativo. Indica que a pessoa esperava que aquilo fosse uma ação.
- **Tempo anormalmente longo** em uma tela simples.
- **Uso de busca a partir de uma tela específica**: sinal claro de que a navegação daquele ponto falhou.

**2. Chamados de suporte.** É a fonte mais subutilizada e a mais barata. Peça os últimos três meses de chamados, agrupe por assunto e conte. Os cinco assuntos mais frequentes são um mapa direto dos pontos de atrito — com a vantagem de virem com o custo já calculado, em horas de atendimento.

**3. Observação.** Vinte minutos vendo três pessoas trabalharem encontram o que nenhum dado mostra: as planilhas paralelas, os post-its no monitor, o passo que elas fazem duas vezes "porque às vezes não salva", o campo que preenchem com um valor qualquer porque é obrigatório e não se aplica.

**4. As adaptações.** Toda adaptação improvisada é a assinatura de um atrito. Se alguém mantém uma planilha à parte, o sistema não fornece aquela visão. Se anota o número do protocolo num papel, o sistema não o carrega entre telas. Procure por essas soluções paralelas — elas são o diagnóstico já pronto.

### Um instrumento simples: o mapa de atrito

Reúna as evidências em uma tabela única, por etapa da tarefa:

| Etapa | Sinal observado | Fonte | Frequência | Custo estimado |
|---|---|---|---|---|
| Buscar cliente | Busca só por CPF exato; sem CPF, não acha | Observação | 5 de 5 | ~40 s por atendimento |
| Preencher pedido | Campo "centro de custo" preenchido com "0000" | Observação | 4 de 5 | Dado inútil na base |
| Confirmar | Duplo clique frequente; pedidos duplicados | Log | 3% dos pedidos | 12 estornos/mês |
| Imprimir | Chamado "não sai a segunda via" | Suporte | 28 chamados/trimestre | ~9 h de atendimento |

A coluna de custo é a que transforma a lista em argumento. "A busca é ruim" não move ninguém; "40 segundos por atendimento, 200 atendimentos por dia, dá 2 horas de trabalho diárias" move.

### Atrito percebido e atrito real

Os dois divergem com frequência, e confundi-los leva a corrigir a coisa errada.

**Atrito real** é medido: passos, tempo, erros. **Atrito percebido** é sentido: irritação, insegurança, sensação de lentidão. Um formulário de três etapas pode ter mais passos e ser percebido como mais leve que um de tela única com trinta campos — porque cada etapa fecha um ciclo e o progresso é visível.

A consequência prática: reduzir o número de cliques nem sempre reduz o atrito. Um clique a mais que dá certeza pode ser preferível a um clique a menos que gera dúvida. Quando o dado quantitativo e a percepção divergem, ambos são verdadeiros — e a correção precisa levar os dois em conta.

### O erro que você vai cometer: confundir atrito com dificuldade da tarefa

Você mapeia a etapa em que as pessoas mais demoram e mais erram: a de classificação fiscal do produto. Quinze segundos por item, taxa de correção alta. Parece o campeão da lista.

Você redesenha: campo com busca, sugestões automáticas, ajuda contextual. E o tempo cai pouco.

O motivo é que classificação fiscal é **intrinsecamente difícil** — a pessoa precisa decidir algo que exige conhecimento, e o tempo é gasto pensando, não operando a interface. Esse é o mesmo par que você já viu na carga cognitiva: carga intrínseca é a dificuldade da tarefa; carga estranha é a que a interface adicionou. Interface só remove a segunda.

O teste que separa as duas: **onde o tempo é gasto?** Se a pessoa está olhando fixamente para a tela, imóvel, pensando, é carga intrínseca. Se está rolando, abrindo e fechando menus, procurando, digitando e apagando, é carga estranha. Observação resolve isso em dois minutos; dados de log, não.

Quando o problema é intrínseco, as saídas são diferentes: fornecer a informação necessária ali (histórico do que foi escolhido antes para produtos parecidos), pré-preencher com base em regra, ou tirar a decisão daquele momento e daquela pessoa.

### Priorizando o que atacar

Com o mapa pronto, três critérios ordenam a lista:

1. **Frequência × custo unitário.** Um atrito pequeno em uma tarefa feita duzentas vezes por dia supera um atrito grande em uma tarefa mensal.
2. **Custo de correção.** Alguns atritos se resolvem com uma mudança de texto; outros exigem refatoração. Comece pelos que têm melhor razão entre impacto e esforço.
3. **Risco.** Um atrito que leva a erro de dado — o "0000" no centro de custo — pode ter custo invisível e muito maior que o tempo perdido.

O item 3 merece atenção porque é o mais fácil de subestimar. Campos obrigatórios que não se aplicam produzem dados falsos que alimentam relatórios que sustentam decisões. O atrito percebido é de dois segundos; o custo real é a confiabilidade da base.

### Exercício prático

**Objetivo:** mapear os pontos de atrito de uma tarefa real, com evidência de mais de uma fonte.

1. Escolha uma tarefa frequente de um sistema que você conhece.
2. Colete evidência de pelo menos duas fontes: observe três pessoas executando a tarefa **e** consiga dados de uso ou uma lista de chamados de suporte.
3. Monte o mapa de atrito com as cinco colunas, uma linha por ponto encontrado.
4. Para cada linha, classifique: carga intrínseca (dificuldade da tarefa) ou carga estranha (a interface criou)?
5. Estime o custo anual dos três maiores, em horas ou em reais.
6. Ordene por frequência × custo e escolha o primeiro a atacar.

### Solução comentada

O passo 2 costuma produzir a descoberta mais valiosa do exercício, e ela é sobre a divergência entre as fontes.

O padrão que se repete: os dados de uso apontam a etapa X como a mais problemática, e a observação aponta a etapa Y. Ambos estão certos, e a explicação é instrutiva. Os dados mostram onde as pessoas **param**; a observação mostra onde elas **sofrem**. Uma etapa onde todo mundo perde quarenta segundos mas todo mundo conclui não aparece como problema em nenhum funil — o funil só vê quem desiste. E uma etapa onde 5% abandonam pode ser tranquila para os outros 95%.

A conclusão prática: dados de uso sozinhos priorizam o que causa abandono; observação sozinha prioriza o que causa irritação. As duas listas juntas são muito diferentes de qualquer uma delas isolada, e ignorar uma das fontes é a forma mais comum de gastar três semanas melhorando algo que quase ninguém sentia.

No passo 4, a proporção típica surpreende: a maioria dos pontos de atrito de sistemas internos é carga estranha, e boa parte se resolve com mudanças pequenas — um dado carregado entre telas, um campo pré-preenchido, um rótulo reescrito, um valor padrão sensato. Não é o redesenho que rende mais; é a lista de quinze correções pequenas, que cabe em uma sprint e devolve horas por semana a quem usa o sistema todo dia.

---
