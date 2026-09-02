## Comunicação das melhorias para stakeholders

O documento está pronto, bem estruturado e sustentado por evidência. Agora ele precisa ser aprovado por pessoas que não leram nada disso, têm quinze minutos, e cujo critério não é usabilidade — é custo, risco e prioridade em relação a tudo o mais que está na fila.

Comunicar melhorias é uma habilidade distinta de encontrá-las, e é onde a maior parte do trabalho de UX se perde em organizações que não têm cultura de design. A boa notícia é que se trata de um problema com técnica conhecida.

### Quem está na sala e o que cada um quer

| Perfil | Pergunta principal | O que convence |
|---|---|---|
| Gestor de produto | Isto resolve um problema que importa agora? | Impacto quantificado, alinhamento com metas |
| Liderança técnica | Quanto custa e o que pode quebrar? | Escopo claro, risco declarado, estimativa acordada |
| Financeiro / diretoria | Qual o retorno? | Horas economizadas, chamados evitados, receita |
| Suporte / operação | Vai reduzir os meus problemas? | Chamados por assunto, tempo de atendimento |
| Usuário-chave | Vou ter que reaprender tudo? | O que muda, o que não muda, quando |

O erro de comunicação mais comum é apresentar a mesma coisa para todos — normalmente a versão que convence você, cheia de heurísticas violadas e princípios cognitivos, que não responde à pergunta principal de ninguém na sala.

### A estrutura de quinze minutos

**1. O problema, com número (2 min).**

> "Hoje, 14 chamados por trimestre chegam ao suporte com o assunto 'sumiram pedidos'. Em todos, o motivo é o mesmo: a pessoa aplicou um filtro e não sabe como removê-lo."

Um problema sem número é uma opinião. Com número, é um fato que alguém precisa refutar para descartar.

**2. A evidência, curta e concreta (3 min).**

Uma citação literal de usuário vale mais que um gráfico. Uma gravação de trinta segundos mostrando alguém travando vale mais que a citação. Se você tiver o vídeo, mostre o vídeo — ver um usuário real sofrendo tem um efeito sobre a sala que nenhum relatório reproduz.

**3. A proposta, percorrida como história (4 min).**

Não descreva a tela. Narre a pessoa resolvendo o problema: "a Ana aplica o filtro, e agora vê aqui as etiquetas do que está filtrando. Quando termina, clica no x e volta ao normal."

**4. O que isso custa e o que devolve (3 min).**

"Dois dias de frontend, sem mudança de API. Estimativa de 22 horas de trabalho recuperadas por mês entre os 40 atendentes, e a expectativa de eliminar aqueles 14 chamados."

**5. A decisão que você precisa hoje (3 min).**

Uma pergunta específica: "preciso saber se isso entra na sprint de abril ou fica para maio". Não "o que vocês acham?".

### Traduzindo para a linguagem de quem decide

Alguns pares de tradução que fazem diferença:

| Em vez de | Diga |
|---|---|
| "Viola a heurística de visibilidade de status" | "A pessoa não tem como saber que a lista está filtrada" |
| "A carga cognitiva é alta" | "São 28 campos numa tela; metade das pessoas desiste no meio" |
| "Falta hierarquia visual" | "Todas as colunas têm o mesmo peso, então o olho não sabe onde pousar" |
| "Melhora a experiência" | "Reduz o tempo de atendimento em cerca de 40 segundos por caso" |
| "Os usuários odeiam isso" | "Três dos cinco que observamos abandonaram nesta etapa" |

O padrão é sempre o mesmo: substituir o termo técnico pela consequência observável. Isso não é simplificação — é precisão. "Viola a heurística 1" é vago para quem não conhece a lista; "a pessoa não sabe que a lista está filtrada" é exato.

### Lidando com as três objeções previsíveis

**"Os usuários já estão acostumados."** É uma objeção legítima e merece resposta preparada. A resposta tem duas partes: reconhecer o custo de reaprendizado ("sim, há custo, e por isso propomos manter o caminho antigo funcionando por dois meses e avisar com antecedência") e apresentar a contraevidência ("nos chamados, quem reclama são usuários com mais de um ano de casa — o hábito não resolveu o problema, apenas o tornou tolerável").

**"Não temos tempo agora."** Aqui o formato de propostas independentes se paga. Se o pedido é um redesenho de três meses, "não temos tempo" encerra a conversa. Se são quinze itens dos quais seis custam meio dia cada, a resposta possível vira "podemos fazer os seis pequenos na próxima sprint?".

**"Isso é subjetivo."** A resposta é o número e o método: "seis pessoas fizeram a mesma tarefa nas duas versões; na atual, duas conseguiram remover o filtro sem ajuda; na proposta, seis". Se você não tiver esse dado, a resposta honesta é "ainda é uma hipótese, e um teste de meio dia com cinco pessoas resolveria" — o que transforma a objeção em um próximo passo barato em vez de um impasse.

### O erro que você vai cometer: apresentar tudo de uma vez

Você tem quinze melhorias bem documentadas e quinze minutos. A tentação é passar por todas, com um minuto cada.

O resultado é previsível: a sala não retém nada, discute a primeira em profundidade, o tempo acaba, e a reunião termina com "manda o documento que a gente vê depois" — que significa que ninguém vai ver.

A alternativa que funciona é apresentar **uma** proposta em profundidade, com problema, evidência, proposta e custo, e mencionar que há outras quatorze documentadas no mesmo formato. Escolha para a apresentação aquela com melhor razão entre impacto e esforço, e de preferência uma que já esteja validada.

O objetivo dessa primeira apresentação não é aprovar quinze itens. É estabelecer que o seu trabalho produz propostas com evidência e estimativa — e conseguir a aprovação de uma. Quando ela for implementada e o resultado se confirmar, as próximas quatorze passam a ser discutidas sob outra luz, e frequentemente sem apresentação.

### Exercício prático

**Objetivo:** preparar e ensaiar a comunicação de uma melhoria.

1. Escolha a melhoria com melhor razão entre impacto e esforço da sua lista.
2. Identifique quem decidiria sobre ela na organização e qual é a pergunta principal dessa pessoa.
3. Monte a apresentação de cinco partes, em no máximo seis slides.
4. Reescreva cada afirmação técnica na tabela de tradução — nenhum termo de UX deve sobrar sem sua consequência observável ao lado.
5. Escreva as respostas às três objeções previsíveis, com uma frase cada.
6. Apresente para alguém de fora da área, em quinze minutos, e peça que essa pessoa repita qual era o problema e o que você está pedindo.

### Solução comentada

O passo 6 é o teste real, e o padrão de falha é consistente: a pessoa consegue repetir a proposta ("você quer colocar umas etiquetas de filtro") e não consegue repetir o problema nem o pedido.

Isso acontece porque, ao ensaiar, você naturalmente dedica mais tempo à parte que construiu com carinho — a solução — e menos às partes que parecem óbvias, porque são óbvias **para você**. O problema já está tão claro na sua cabeça que uma frase parece suficiente; para quem ouve pela primeira vez, uma frase é um dado solto.

A correção é desproporcionalmente eficaz: gaste os dois primeiros minutos inteiros no problema, com o número repetido em voz alta e escrito no slide. Repetição que parece excessiva para quem apresenta é a quantidade certa para quem escuta uma vez.

O outro padrão de falha é o passo 5 não ter sido feito. As três objeções chegam em praticamente toda apresentação de melhoria — não são hostilidade, são as perguntas que qualquer gestor responsável faria. Chegar sem resposta preparada produz uma hesitação de cinco segundos que a sala interpreta como fragilidade da proposta, mesmo quando ela é sólida. Chegar com a resposta pronta produz o efeito oposto: a sensação de que o trabalho considerou o que precisava considerar.

Vale um último comentário sobre o passo 2, identificar quem decide. Em organizações sem cultura de design, essa pessoa raramente é quem você imagina. Frequentemente a decisão real sobre uma melhoria de interface é do líder técnico, que controla a agenda da equipe, e não do gestor de produto, que controla o roadmap. Apresentar para quem não decide gera concordância entusiasmada seguida de nada — e a lição, quando isso acontece, não é que a proposta era ruim, é que ela foi bem apresentada para a pessoa errada.

---
