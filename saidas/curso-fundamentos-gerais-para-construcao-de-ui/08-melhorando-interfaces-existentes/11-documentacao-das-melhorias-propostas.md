## Documentação das melhorias propostas

Você tem quinze correções, cada uma com diagnóstico, princípio que a sustenta e — para as que envolviam troca — evidência de teste. Falta transformar isso em um documento que sobreviva à reunião de priorização, que possa ser implementado por alguém que não participou da análise, e que ainda faça sentido daqui a seis meses.

O formato importa mais do que parece. Uma lista de quinze itens em prosa é lida por ninguém. Uma apresentação de quarenta slides é aprovada e esquecida. O que circula, é discutido e vira tarefa é um documento curto, com uma estrutura previsível e uma unidade de proposta bem definida.

### A unidade: uma proposta, um problema

Cada melhoria deve ser documentada como uma unidade independente, que possa ser aprovada, adiada ou recusada sem arrastar as outras. Isso é o oposto do "projeto de redesenho", que é aprovado ou rejeitado em bloco — e que, na prática, é adiado indefinidamente porque nunca há espaço para um bloco grande.

O formato de uma unidade:

```
MELHORIA #4 — Filtros ativos invisíveis na listagem de pedidos

PROBLEMA
Após aplicar um filtro, nada indica que a lista está filtrada: o contador
continua exibindo o total geral e não há forma de limpar a seleção além de
recarregar a página.

EVIDÊNCIA
• Observação: 2 de 5 atendentes recarregaram a página para "limpar"
• Suporte: 14 chamados no trimestre com o assunto "sumiram pedidos"
• Heurísticas violadas: 1 (visibilidade de status), 3 (controle e liberdade)

IMPACTO ESTIMADO
~40 s por ocorrência · ~3 ocorrências/dia/atendente · 40 atendentes
≈ 22 h de trabalho por mês

PROPOSTA
Exibir os filtros ativos como etiquetas removíveis acima da lista, e ajustar
o contador para o formato "23 de 1.847 pedidos". Botão "Limpar filtros"
quando houver mais de um ativo.

VALIDAÇÃO
Comparação moderada com 6 participantes: 6/6 removeram o filtro sem ajuda
na versão proposta, contra 2/6 na atual.

ESFORÇO ESTIMADO
Frontend apenas; sem mudança de API. Estimativa da equipe: 2 dias.

RISCO
Baixo. Não altera comportamento existente, apenas adiciona informação.

DEPENDÊNCIAS
Nenhuma.
```

Nove campos, cabe em uma página, e cada um responde a uma pergunta que alguém vai fazer. Retirar qualquer um deles gera uma pergunta na reunião.

### Os campos que as pessoas pulam e não deveriam

**Impacto estimado.** É o campo que decide a prioridade, e o mais frequentemente omitido porque "não dá para calcular com precisão". Não precisa de precisão — precisa de ordem de grandeza. Uma estimativa declarada como estimativa, com os números que a compõem visíveis, é infinitamente melhor que nenhuma. E se alguém discordar dos números, a discussão será sobre os números, que é onde ela deve estar.

**Risco.** Toda mudança em sistema com usuários tem risco de reaprendizado. Declará-lo demonstra que você o considerou, e evita a objeção "mas os usuários já estão acostumados" — que virá de qualquer forma, e é melhor que venha já respondida.

**Esforço.** Você provavelmente não consegue estimar sozinho, e não deve. Peça a estimativa a quem vai implementar, antes da reunião de priorização. Uma proposta com estimativa acordada tem uma chance de ser priorizada que uma sem estimativa não tem.

### Agrupando para a decisão

Com dez a vinte unidades documentadas, a decisão precisa de uma visão de conjunto. Uma tabela ordenada por razão entre impacto e esforço:

| # | Melhoria | Impacto | Esforço | Risco | Validado? |
|---|---|---|---|---|---|
| 4 | Filtros ativos visíveis | 22 h/mês | 2 d | Baixo | Sim |
| 7 | Carregar nº do protocolo entre telas | 8 h/mês | 0,5 d | Nenhum | Não precisa |
| 2 | Hierarquia na tabela de pedidos | ~30% no tempo de busca | 1 d | Baixo | Sim |
| 11 | Renomear "Conciliar" → "Conferir" | 9 chamados/mês | 0,5 d | Médio | Sim |
| 15 | Reestruturar menu principal | Indireto | 15 d | Alto | Parcial |

Três coisas essa tabela faz que a lista de propostas não faz: mostra que existem ganhos grandes com esforço pequeno (linha 7), permite decidir sem ler tudo, e coloca a reestruturação cara no lugar dela — no fim, com risco alto e validação parcial declarada.

### Separando o que precisa de decisão do que não precisa

Uma distinção que economiza reuniões: nem toda melhoria precisa ser aprovada.

**Não precisam de decisão** — correções de acessibilidade obrigatórias, rótulos objetivamente errados, valores fora da escala de estilo, estados ausentes. Documente e coloque no backlog como manutenção. Levá-las a uma reunião de priorização é gastar o capital político em coisas que não estavam em disputa.

**Precisam de decisão** — mudanças que envolvem troca (densidade, número de passos), que alteram algo que os usuários já aprenderam, ou que custam mais de um ou dois dias.

Misturar as duas categorias tem um efeito ruim: a reunião discute as três primeiras correções óbvias, o tempo acaba, e as que precisavam de decisão ficam para a próxima.

### O erro que você vai cometer: documentar a solução sem o problema

O documento chega assim: "Proposta de melhoria da tela de pedidos", seguido de uma imagem do novo desenho e uma lista de mudanças — nova hierarquia, filtros no topo, contador ajustado.

O que acontece na reunião: a discussão vai direto para as decisões visuais. Alguém prefere os filtros à esquerda. Alguém acha o cinza claro demais. Ninguém questiona se o problema existe, porque o problema nunca foi apresentado — e, sem ele, não há critério para julgar a solução. A reunião vira uma sessão de opinião estética, e a proposta sai de lá modificada por preferências.

A ordem correta é rígida: **problema, evidência, impacto, e só então proposta**. Quando as três primeiras partes são apresentadas primeiro, a conversa muda de natureza — as pessoas passam a avaliar se a proposta resolve o problema apresentado, que é uma pergunta com resposta, em vez de discutir se gostam do desenho.

Há um teste simples para saber se o documento está na ordem certa: cubra a parte da proposta e leia o que sobrou. Se o que sobrou já convence alguém de que há um problema que vale resolver, o documento está pronto.

### Exercício prático

**Objetivo:** documentar um conjunto de melhorias em formato decidível.

1. Pegue oito problemas encontrados nas suas análises anteriores.
2. Documente cada um no formato de nove campos. Onde faltar evidência, escreva "não medido" em vez de inventar.
3. Consiga a estimativa de esforço com alguém que implementaria.
4. Classifique cada um: precisa de decisão ou é manutenção?
5. Monte a tabela de conjunto, ordenada por impacto sobre esforço.
6. Aplique o teste da ordem: cubra as propostas e verifique se os problemas se sustentam sozinhos.

### Solução comentada

O passo 2, com a instrução de escrever "não medido", costuma ser o mais revelador. Ao preencher os oito documentos, é comum descobrir que metade das propostas tem evidência sólida e a outra metade tem apenas a sua percepção — o que é legítimo como ponto de partida e frágil como argumento.

A tentação nesse momento é preencher o campo com algo plausível: "os usuários reclamam disso". Não faça. Um único número inventado que seja contestado em reunião derruba a credibilidade do documento inteiro, incluindo as partes bem fundamentadas. "Não medido — proponho um teste de primeiro clique com cinco pessoas antes de decidir" é uma frase forte, não fraca: mostra que você distingue o que sabe do que supõe, e transforma a lacuna em um próximo passo barato.

O passo 3 produz frequentemente uma reordenação completa da tabela. Propostas que pareciam grandes revelam-se de meio dia, porque a mudança é só de estilo; propostas que pareciam triviais revelam-se caras, porque aquele campo alimenta três relatórios e uma integração. Sem conversar com quem implementa, a priorização é feita sobre esforço imaginado — e a lista resultante é rejeitada na primeira reunião com a equipe técnica.

Sobre o passo 4: a proporção típica é de dois terços de manutenção e um terço precisando de decisão. Reconhecer isso muda a estratégia inteira. Os dois terços não precisam de reunião, não precisam de apresentação e não competem com prioridades de produto — vão para o backlog como dívida de qualidade e são resolvidos aos poucos. A reunião fica reservada ao terço que de fato exige uma escolha, e dura vinte minutos em vez de duas horas. É a diferença entre uma proposta que avança e uma que fica esperando espaço na agenda.

---
