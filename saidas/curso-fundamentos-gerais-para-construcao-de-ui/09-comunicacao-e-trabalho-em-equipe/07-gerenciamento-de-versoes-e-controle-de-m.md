## Gerenciamento de versões e controle de mudanças

Quem vem do desenvolvimento chega ao design com um instinto que é ao mesmo tempo uma vantagem e uma fonte de frustração: a expectativa de que exista algo como `git`. Existe, mas com um modelo diferente — e entender essa diferença evita tanto a frustração quanto os acidentes que ela produz.

A diferença fundamental: ferramentas de design salvam **continuamente e sem conflito**. Não há commit, não há merge, não há resolução de divergência. Duas pessoas editando o mesmo elemento não geram conflito — a última alteração simplesmente vence, silenciosamente. Isso torna a colaboração fluida e torna a disciplina de versionamento uma responsabilidade das pessoas, não da ferramenta.

### Versões nomeadas: o commit manual

O histórico automático existe e é uma sequência de estados sem rótulo. Encontrar nele "a versão que mostramos ao cliente na terça" é penoso e frequentemente impossível.

A prática que resolve custa dez segundos: sempre que o arquivo for **compartilhado, apresentado ou entregue**, crie uma versão nomeada (`Arquivo → Histórico de versões → Salvar versão`) com um nome que diga o contexto:

```
v1 — estrutura inicial, antes do card sorting
v2 — pós card sorting, 8 participantes, 18/03
v3 — apresentado ao comercial 25/03
v4 — pós teste com 6 atendentes, antes das correções
v5 — entregue para desenvolvimento 02/04
```

Repare no padrão: cada nome contém **o que aconteceu** e, quando relevante, **quando**. "v3" sozinho não ajuda; "v3 — apresentado ao comercial 25/03" transforma "voltar ao que o comercial viu" em um clique.

Isso resolve também o problema recorrente do stakeholder que viu a versão de terça e comenta na sexta sobre algo que já mudou. Com versões nomeadas, você mostra as duas e explica a diferença, em vez de discutir de memória.

### Um registro de mudanças que cabe em uma página

O histórico da ferramenta diz o que o arquivo era. Não diz por que mudou. Um registro paralelo, curto, resolve:

| Data | Versão | O que mudou | Por quê |
|---|---|---|---|
| 18/03 | v2 | "Relatórios" → "Análises"; Devoluções movido para Pedidos | Card sorting: 6/8 procuraram devoluções dentro de pedidos |
| 25/03 | v3 | Filtros movidos para o topo | Observação: 3/5 não abriram a barra lateral |
| 02/04 | v5 | Etiquetas de filtro ativo adicionadas | Teste: 4/6 não conseguiram remover o filtro |

Três a cinco linhas por mudança, e a coluna do "por quê" contendo evidência, não opinião. Esse registro tem três usos que se pagam:

1. Impede que a mesma discussão seja reaberta a cada dois meses.
2. É a defesa quando alguém propõe reverter uma decisão sem conhecer a razão dela.
3. É, praticamente pronto, o material que o portfólio vai pedir — a sequência de versões com justificativa e dado.

### Convivendo com o código

Se o arquivo de design e o código evoluem em paralelo, é preciso decidir qual é a fonte de verdade — e a resposta muda ao longo do tempo.

**Antes da implementação:** o arquivo de design é a fonte. Ele descreve o que será construído.

**Depois da implementação:** o produto é a fonte. Tentar manter o arquivo espelhando o que já existe é trabalho contínuo sem retorno, e produz o arquivo desatualizado no qual ninguém confia — que é pior que nenhum arquivo.

O que continua vivo depois da implementação são os artefatos transversais: a biblioteca de componentes, os tokens e o glossário. Esses devem estar versionados junto com o código, mudando por revisão como qualquer outra coisa. O resto — os fluxos específicos, as alternativas, as iterações — é arquivado com uma nota: "Implementado em 04/2026; comportamento atual no produto. Este arquivo registra as decisões originais."

### Nomear e organizar para encontrar depois

Duas convenções que evitam o problema do sexto mês, quando existem onze arquivos e ninguém sabe qual é o vigente:

**Um arquivo por projeto ou fluxo**, não um por versão. Versões vivem no histórico, não no nome do arquivo. `Checkout v2 final FINAL revisado.fig` é o sintoma de que o histórico não está sendo usado.

**Prefixo de estado no nome**, quando o arquivo é compartilhado: `[Ativo] Fluxo de devolução`, `[Arquivado] Redesenho 2024`. Quem chega de fora identifica em um segundo o que ainda vale.

### O erro que você vai cometer: duplicar em vez de versionar

Você vai testar uma alternativa e não quer perder o que já existe. O reflexo é duplicar a página: `Fluxo` vira `Fluxo` e `Fluxo cópia`. Dois dias depois há `Fluxo cópia 2` e `Fluxo — nova ideia`.

O problema não é a duplicação em si — duplicar para explorar uma alternativa é legítimo e recomendável. O problema é não fechar o ciclo: as cópias ficam, ninguém sabe qual é a boa, e quem abre o arquivo pela primeira vez encontra quatro versões de tudo.

A disciplina que resolve tem duas partes:

**Antes de duplicar, salve uma versão nomeada.** Isso torna a cópia desnecessária como rede de segurança — o estado anterior está garantido no histórico.

**Depois de decidir, apague as cópias descartadas** ou mova-as para uma página `Descartados`, com uma linha dizendo por que caíram. A informação valiosa da alternativa descartada é a razão do descarte, não o desenho — e essa razão cabe no registro de mudanças.

Sem esse fechamento, o arquivo acumula estados intermediários indefinidamente, e a diferença entre um arquivo de projeto e um depósito é justamente essa: no primeiro, alguém decidiu o que fica.

### Exercício prático

**Objetivo:** organizar o versionamento de um projeto em andamento.

1. Abra um arquivo seu com pelo menos duas semanas de trabalho.
2. Percorra o histórico automático e identifique os três ou quatro momentos que mereceriam nome. Você não pode renomear o passado, mas vai perceber o que teria sido útil.
3. Salve uma versão nomeada agora, com o estado atual bem descrito.
4. Monte o registro de mudanças em tabela, reconstruindo o que conseguir das últimas semanas — e note quanta informação já se perdeu.
5. Limpe: apague ou mova para `Descartados` as páginas duplicadas, anotando a razão do descarte de cada uma.
6. Escreva a regra que você vai seguir daqui em diante, em uma frase, e coloque-a como texto no canto da página inicial do arquivo.

### Solução comentada

O passo 4 é o que ensina, e o desconforto que ele causa é o ponto: reconstruir duas semanas de decisões costuma resultar em uma tabela com metade das células vazias ou preenchidas com "acho que foi porque…".

O que se perde primeiro, sempre, são os **números** e as **falas literais**. Você lembra que mudou os filtros de lugar depois de observar usuários; não lembra que foram três de cinco, nem a frase que alguém disse ao não encontrar. E são exatamente esses dois elementos que sustentam a decisão quando alguém a questiona, e que fazem um estudo de caso ser convincente.

A conclusão prática é a mesma de outros pontos deste curso, com uma diferença de custo importante: anotar no momento leva dois minutos e produz o registro completo; reconstruir depois leva uma hora e produz um registro parcial. A economia não é de tempo — é de informação.

O passo 6, a regra escrita no canto do arquivo, tem uma função específica: torná-la visível para quem mais precisa dela, que é você em três semanas, no meio de uma entrega apertada, quando a tentação de duplicar a página e seguir em frente for maior. Uma frase como "salvar versão antes de qualquer mudança estrutural; sem páginas 'cópia'" custa nada e funciona pelo mesmo motivo que qualquer convenção de equipe funciona — porque está escrita onde é consultada.

---
