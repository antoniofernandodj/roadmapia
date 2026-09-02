## Avaliação heurística: conceitos básicos

Você recebe um sistema pronto, com usuários reais, e a tarefa de "melhorar a usabilidade". Não há orçamento para pesquisa, não há acesso fácil aos usuários, e a expectativa é de uma lista de problemas até sexta-feira. Este é o cenário mais comum na vida profissional, e é exatamente para ele que a avaliação heurística existe.

Ela é um método de inspeção: um pequeno grupo de avaliadores percorre a interface confrontando-a com um conjunto de princípios estabelecidos, e registra cada violação encontrada. Não substitui teste com usuário — inspeção encontra problemas potenciais, teste encontra problemas reais. Mas custa uma fração do tempo e pode ser feita hoje.

### As dez heurísticas de Nielsen

O conjunto mais usado foi formulado por Jakob Nielsen e Rolf Molich e continua sendo a referência da área. Não são regras rígidas — são princípios amplos, e o "heurísticas" no nome é literal.

**1. Visibilidade do status do sistema.** A interface informa o que está acontecendo, em tempo razoável. Onde estou, o que foi salvo, o que está processando.

**2. Correspondência entre o sistema e o mundo real.** A linguagem é a do usuário, não a do banco de dados. "Pedido cancelado", não "Status = 7".

**3. Controle e liberdade do usuário.** Há saída clara de qualquer estado, e desfazer para o que foi feito por engano.

**4. Consistência e padrões.** A mesma coisa se chama da mesma forma, fica no mesmo lugar e se comporta do mesmo jeito — dentro do sistema e em relação às convenções da plataforma.

**5. Prevenção de erros.** Melhor que uma boa mensagem de erro é a impossibilidade de cometê-lo: restrições, valores padrão sensatos, confirmação para ações destrutivas.

**6. Reconhecer em vez de lembrar.** Opções e informações visíveis, não guardadas na memória do usuário entre telas.

**7. Flexibilidade e eficiência de uso.** Atalhos para o experiente sem atrapalhar o novato.

**8. Design estético e minimalista.** Cada elemento a mais compete por atenção com os que importam.

**9. Ajudar a reconhecer, diagnosticar e recuperar-se de erros.** Mensagem em linguagem clara, que diz o que aconteceu e o que fazer.

**10. Ajuda e documentação.** Quando necessária, encontrável e orientada à tarefa.

### Como conduzir a avaliação

O método tem uma estrutura que faz diferença nos resultados.

**Passo 1 — Defina os cenários.** Não avalie "o sistema". Avalie três a cinco tarefas concretas, as mais frequentes ou mais críticas. Sem cenários, a avaliação vira um passeio e encontra apenas o que salta aos olhos.

**Passo 2 — Percorra duas vezes.** Na primeira passagem, execute a tarefa como um usuário faria, sem parar para anotar. É o que dá a noção do fluxo. Na segunda, percorra devagar, tela por tela, confrontando com as dez heurísticas.

**Passo 3 — Registre cada problema separadamente**, com quatro campos:

```
PROBLEMA #7
Onde: Tela de listagem de pedidos, ao aplicar filtro
Heurística violada: 1 (visibilidade do status) e 3 (controle e liberdade)
Descrição: Após aplicar um filtro, nada na tela indica que a lista está
  filtrada. O contador continua mostrando o total geral. Não há forma
  de limpar o filtro além de recarregar a página.
Severidade: 3 (grave)
Sugestão: Exibir etiquetas removíveis dos filtros ativos acima da lista,
  e ajustar o contador para "23 de 1.847 pedidos".
```

**Passo 4 — Classifique a severidade.** A escala usual vai de 0 a 4:

| Nível | Significado |
|---|---|
| 0 | Não é um problema de usabilidade |
| 1 | Cosmético — corrija se sobrar tempo |
| 2 | Menor — baixa prioridade |
| 3 | Grave — alta prioridade, corrija antes de lançar |
| 4 | Catastrófico — impede a tarefa, obrigatório corrigir |

A severidade combina três fatores: frequência com que ocorre, impacto quando ocorre, e persistência (é um obstáculo que se supera uma vez e se aprende, ou que incomoda em todas as vezes?).

**Passo 5 — Consolide.** Se houve mais de um avaliador, junte as listas, mescle os duplicados e recalcule a severidade em conjunto.

### Por que três a cinco avaliadores

Um avaliador sozinho encontra tipicamente uma parte modesta dos problemas — as estimativas clássicas ficam em torno de um terço. A razão é banal: cada pessoa tem pontos cegos diferentes, e a familiaridade com o sistema apaga problemas que um olhar novo enxerga.

Três a cinco avaliadores independentes, cujas listas são consolidadas depois, elevam substancialmente a cobertura. O detalhe que importa: **independentes**. Se avaliarem juntos, conversando, o grupo converge cedo e produz a lista de uma pessoa só, mais longa.

Se você está sozinho — o caso mais comum —, duas compensações ajudam: percorra o sistema em dias diferentes, e recrute um colega de qualquer área para uma passagem rápida. Alguém do financeiro percorrendo o sistema por vinte minutos encontra problemas que você deixou de ver por conhecê-lo demais.

### O erro que você vai cometer: listar preferências como violações

A lista fica pronta com 43 itens. Entre eles: "o azul do botão está saturado demais", "eu usaria uma fonte sem serifa", "os cards ficariam melhores com sombra mais suave".

Nenhum desses é um problema de usabilidade. São preferências estéticas, e misturá-las na lista tem duas consequências ruins. Primeiro, dilui: o desenvolvedor que recebe 43 itens e percebe que os primeiros são questão de gosto passa a duvidar dos outros. Segundo, custa credibilidade — a avaliação heurística apoia-se em princípios estabelecidos, e assim que ela vira opinião pessoal, perde a autoridade que a fazia útil.

O teste que separa: **para cada item, nomeie a heurística violada e descreva a consequência para o usuário**. Se você não consegue nomear a heurística, ou se a consequência que você escreve é "fica menos bonito", não é achado de avaliação heurística. Pode ir para uma lista separada, de sugestões visuais — o que é honesto e útil, desde que separado.

### Os limites do método

Vale saber o que ele não faz, para não prometer demais:

- **Encontra problemas potenciais, não confirmados.** Alguns achados de severidade 3 se revelam irrelevantes no uso real, e alguns problemas graves para os usuários não violam heurística nenhuma.
- **Não descobre necessidades.** Se a funcionalidade certa não existe, a heurística não aponta. Ela avalia o que está lá.
- **É sensível à experiência do avaliador.** Um avaliador experiente encontra mais e classifica melhor.
- **Tende a superestimar problemas de novato.** O avaliador percorre o sistema sem a familiaridade que o usuário diário tem, e alguns "problemas" desaparecem depois da terceira vez.

### Exercício prático

**Objetivo:** conduzir uma avaliação heurística completa.

1. Escolha um sistema que você usa, mas não construiu.
2. Defina três cenários de tarefa concretos, escritos como situações.
3. Percorra cada um duas vezes, registrando os problemas no formato de quatro campos.
4. Classifique a severidade de 0 a 4, justificando com frequência, impacto e persistência.
5. Separe a lista em dois documentos: violações de heurística (com a heurística nomeada) e sugestões estéticas.
6. Ordene o primeiro documento por severidade e conte quantos itens ficaram em cada nível.

### Solução comentada

A distribuição do passo 6 é diagnóstica, e três padrões são comuns.

**Muitos itens em severidade 1 e 2, poucos em 3 e 4.** O sistema está funcionalmente correto e falta polimento. É o caso de produtos maduros. A lista tem valor, mas dificilmente justifica prioridade — e apresentá-la como urgente prejudica a credibilidade da próxima.

**Concentração em 3 e 4, quase nada em 1 e 2.** Duas leituras possíveis. Ou o sistema tem problemas estruturais sérios, ou você inflacionou a severidade — o que é comum em quem está começando, porque cada problema encontrado parece grave no momento em que se tropeça nele. O teste de calibragem: um problema de nível 4 impede a conclusão da tarefa; se a pessoa consegue concluir, ainda que com dificuldade, não é 4.

**Concentração em uma única heurística.** Se doze dos quinze achados são da heurística 1 (visibilidade de status), isso não é uma lista de quinze problemas — é um problema sistêmico com quinze manifestações. A correção certa é uma decisão de projeto ("todo elemento que muda de estado precisa confirmar visivelmente"), não quinze correções pontuais. Reconhecer isso muda completamente a conversa com a equipe: em vez de uma lista de tarefas, você apresenta um padrão ausente.

O passo 5, a separação em dois documentos, costuma revelar algo desconfortável na primeira vez: uma parte considerável da lista original não sobrevive ao teste de nomear a heurística. Isso é o método funcionando. A lista menor e defensável vale muito mais que a longa e discutível.

---
