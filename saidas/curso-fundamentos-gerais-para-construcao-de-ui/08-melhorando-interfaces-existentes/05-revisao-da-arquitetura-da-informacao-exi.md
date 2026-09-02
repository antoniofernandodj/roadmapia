## Revisão da arquitetura da informação existente

Corrigir rótulos, hierarquia e feedback resolve muita coisa dentro de uma tela. Quando o problema é que as pessoas não sabem em qual tela procurar, nenhuma dessas correções ajuda — a falha está um nível acima, na estrutura.

Revisar a arquitetura de um sistema em produção é diferente de projetá-la do zero. Há usuários que já aprenderam onde as coisas ficam, há links salvos, há treinamento dado, há documentação escrita. Cada mudança tem um custo de reaprendizado que recai justamente sobre quem usa mais. O trabalho, portanto, não é "qual seria a estrutura ideal?", e sim "quais mudanças rendem mais do que custam?".

### Diagnóstico: quatro medições antes de propor

**1. Inventário completo.** Liste todas as telas e todos os rótulos de navegação, em uma planilha. Ordene alfabeticamente. Só esse passo já revela sinônimos convivendo, itens duplicados e nomes inconsistentes.

**2. Frequência de uso.** Se houver analytics, extraia a contagem de acessos por seção nos últimos noventa dias. Se não houver, pergunte a seis usuários: "quais destas seções você abriu na última semana?".

**3. Tree testing.** É a medição mais direta e a mais subutilizada. Apresente **apenas a estrutura de menus**, sem interface, sem visual, e peça: "onde você clicaria para fazer X?". Ferramentas gratuitas fazem isso remotamente, com quinze a vinte participantes, em uma tarde.

O tree testing produz três números por tarefa: taxa de acerto, taxa de acerto direto (sem idas e voltas) e onde as pessoas foram quando erraram. O terceiro é o mais útil — se metade dos participantes procura "Devoluções" dentro de "Pedidos", o problema não é o rótulo de Devoluções, é a expectativa de onde ele deveria estar.

**4. Origem do tráfego interno.** De onde as pessoas chegam a cada tela? Se uma seção só é alcançada pela busca, e quase nunca pela navegação, a navegação falhou para ela.

### Interpretando os números

| Achado | Leitura |
|---|---|
| Seção com acesso próximo de zero | Ou é desnecessária, ou é invisível — o tree testing separa os dois casos |
| Alta taxa de erro no tree testing, mas as pessoas conseguem no sistema real | O visual está compensando uma estrutura ruim; funciona, mas é frágil |
| Muita busca originada de uma tela específica | A navegação a partir dali não oferece o próximo passo esperado |
| Idas e voltas entre duas seções | As duas competem pelo mesmo conceito na cabeça do usuário |
| Item acessado sempre pelo mesmo caminho, nunca por outro | O segundo caminho é supérfluo e pode ser removido |

### Escolhendo o tipo de intervenção

Com o diagnóstico na mão, há quatro níveis de intervenção, em ordem crescente de custo e de risco:

**Nível 1 — Renomear.** Trocar rótulos que o tree testing mostrou serem mal compreendidos. Custo baixíssimo, risco baixo, e frequentemente resolve a maior parte dos erros de localização. Comece sempre por aqui.

**Nível 2 — Reordenar.** Mudar a ordem dos itens dentro de um menu, colocando os mais usados no topo. A posição inicial e a final de uma lista são as mais lembradas, então itens raros no meio somem — o que às vezes é desejável.

**Nível 3 — Reagrupar.** Mover itens entre seções, sem criar nem eliminar seções. Custo médio, e é onde o reaprendizado começa a doer.

**Nível 4 — Reestruturar.** Criar, fundir ou eliminar seções de primeiro nível. Alto custo, alto risco, e só se justifica quando o diagnóstico mostra falha estrutural — não quando a estrutura apenas parece feia para quem trabalha nela.

A tentação, sempre, é ir direto ao nível 4, porque é o que produz um "antes e depois" impressionante. A prática recomenda o contrário: aplique os níveis 1 e 2, meça de novo, e só suba se os números não melhorarem.

### O que fazer com o que já existe

Duas decisões de compatibilidade que precisam ser tomadas explicitamente, e que costumam ser esquecidas até alguém reclamar:

**Endereços antigos.** Links salvos, favoritos, URLs em e-mails, itens em documentação e material de treinamento. Todo caminho antigo deve continuar funcionando e levar ao novo lugar — um redirecionamento, não uma página de erro. Isso vale mesmo em sistemas internos, onde as pessoas guardam links no bloco de notas.

**Sinalização temporária.** No lugar antigo, uma linha discreta por algumas semanas: "Relatórios agora fica em Análises". Custa uma linha de código e elimina a maior parte dos chamados de suporte de uma reorganização.

E a decisão que precede as duas: mudar tudo de uma vez ou aos poucos? Fatiar parece mais gentil e normalmente custa mais no total — cada fatia é um novo período de reaprendizado, e no meio do caminho a estrutura fica incoerente, com metade dos itens no lugar novo e metade no antigo. Quando a mudança é coerente e bem comunicada, uma transição única costuma sair mais barata.

### O erro que você vai cometer: reorganizar segundo a sua própria lógica

Você olha a estrutura, percebe imediatamente que "Configurações" e "Preferências" são a mesma coisa, que "Relatórios" deveria estar dentro de "Análises" e que a ordem dos menus não faz sentido nenhum. Em uma tarde, produz uma estrutura limpa, coerente e elegante.

E ela pode estar completamente errada, por um motivo específico: você conhece o sistema por dentro. A sua organização mental reflete o modelo de dados, os módulos do código e o vocabulário da equipe — que é exatamente o que o usuário não tem.

O antídoto custa uma tarde e é o mesmo de sempre: **card sorting** com seis a oito usuários reais. Escreva cada item em um cartão, peça que os agrupem livremente e depois que nomeiem os grupos. Os agrupamentos costumam coincidir entre os participantes em boa parte dos itens, e essa parte vira estrutura sem discussão. Os itens em que eles divergem são precisamente os difíceis — e agora a equipe discute apenas esses, com dados sobre por que são difíceis.

Há uma variação especialmente útil para sistemas existentes: o **card sorting fechado**, em que você fornece as categorias já definidas e pede apenas que os itens sejam distribuídos. Ele não ajuda a descobrir categorias novas, mas mede diretamente se a estrutura proposta é compreensível — e é mais rápido de conduzir e de analisar.

### Exercício prático

**Objetivo:** diagnosticar e propor uma revisão de arquitetura com evidência.

1. Escolha um sistema em produção que você conheça.
2. Faça o inventário completo de rótulos de navegação, ordenado alfabeticamente. Anote os pares suspeitos de sinonímia.
3. Escreva cinco tarefas comuns e faça um tree testing com pelo menos oito pessoas — pode ser em papel, com a estrutura impressa, se não tiver ferramenta.
4. Registre, por tarefa: acertos, acertos diretos e para onde foram os que erraram.
5. Proponha intervenções de nível 1 e 2 apenas (renomear e reordenar) que ataquem os piores resultados.
6. Refaça o tree testing com a nova estrutura e outras oito pessoas.

### Solução comentada

A restrição do passo 5 — apenas renomear e reordenar — costuma frustrar e é o ponto do exercício.

O resultado típico é que essas duas intervenções, sozinhas, melhoram substancialmente as taxas de acerto. A razão é que a maior parte dos erros de localização em sistemas maduros não vem da estrutura estar errada; vem de os nomes não corresponderem ao vocabulário de quem procura. A estrutura pode ser perfeitamente razoável e ainda assim inutilizável se as etiquetas estiverem no idioma da empresa.

Isso tem uma consequência prática importante para a sua carreira: a proposta que você leva à equipe muda completamente de natureza. "Precisamos reestruturar a navegação" é um projeto de meses, disputa política e reaprendizado para todos os usuários. "Precisamos renomear seis itens de menu, e aqui estão os números de antes e depois com dezesseis participantes" é uma tarefa de uma sprint, com evidência, que ninguém tem motivo para recusar.

Uma nota sobre o passo 4, especificamente sobre a diferença entre acerto e acerto direto. Uma tarefa com 90% de acerto e 45% de acerto direto está dizendo algo específico: as pessoas chegam lá, mas depois de tentar em outro lugar primeiro. Isso não aparece como problema em nenhuma métrica de produção — todo mundo conclui a tarefa — e no entanto representa tempo perdido em cada uma das centenas de repetições diárias. É exatamente o tipo de atrito invisível que a revisão de arquitetura existe para encontrar.

---
