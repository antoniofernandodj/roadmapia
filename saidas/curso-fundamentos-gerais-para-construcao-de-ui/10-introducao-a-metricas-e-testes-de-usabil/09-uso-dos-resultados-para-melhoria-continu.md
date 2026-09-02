## Uso dos resultados para melhoria contínua

Um relatório de teste bem feito, arquivado e não implementado, custou o mesmo que um mal feito. A pergunta que importa depois da análise não é "o que descobrimos?", é "o que muda por causa disso, e como saberemos se funcionou?".

Fechar esse ciclo é o que transforma testes esporádicos em melhoria contínua — e o que faz a organização financiar o próximo teste.

### O ciclo completo

```
   ┌──────────────────────────────────────────┐
   │                                          │
   ▼                                          │
 Medir linha de base                          │
   │                                          │
 Testar → Analisar → Priorizar → Corrigir     │
   │                                 │        │
   │                            Entregar      │
   │                                 │        │
   │                          Medir de novo   │
   │                                 │        │
   └──── Comunicar o resultado ──────┘        │
                    │                         │
                    └─────────────────────────┘
```

Os dois elos que mais se rompem são o último — comunicar o resultado — e o primeiro — medir antes. Sem o primeiro, não há comparação; sem o último, não há crédito para a rodada seguinte.

### Da lista priorizada às tarefas

O relatório não entra no backlog; tarefas entram. A conversão precisa acontecer, e o formato importa:

```
Título: Permitir busca de pedido por nome do cliente
Problema: 4 de 5 atendentes buscaram pelo nome; a busca só aceita número.
          Todos rolaram a lista manualmente depois (26–31 s).
Correção: Busca aceita nome, número e CPF, com resultados parciais.
Como saberemos: taxa de sucesso na tarefa "localizar pedido" em nova rodada;
          hoje é 5/5 com contorno manual, mediana 28 s.
Esforço: estimado com a equipe — 3 dias (índice no banco)
```

O campo "como saberemos" é o que mantém o ciclo vivo. Sem ele, a tarefa é entregue e ninguém volta a olhar.

E vale a distinção já vista: nem toda correção precisa de decisão de produto. Rótulos errados, estados ausentes, contraste insuficiente entram como manutenção, sem competir por prioridade. Reservar a discussão para o que envolve trade-off real economiza capital político.

### O tamanho certo do ciclo

Testes grandes e raros perdem para testes pequenos e frequentes, por três razões:

**Chegam a tempo.** Três participantes por sprint influenciam o que está sendo construído. Trinta participantes uma vez por ano chegam depois de tudo decidido.

**Custam menos por rodada**, o que os torna sustentáveis quando o orçamento aperta.

**Permitem atribuir causa.** Uma rodada com três a cinco correções e um novo teste diz o que funcionou. Vinte correções de uma vez não dizem.

O ritmo que funciona na maioria das equipes: uma rodada de três a cinco participantes a cada duas semanas, sempre com a mesma tarefa enquanto estiver medindo o efeito de uma mudança.

### Quando o reteste não confirma

Acontece com frequência, e a leitura correta depende de qual dos três casos ocorreu:

**O problema sumiu.** Correção certa. Registre e passe ao próximo.

**O problema persiste.** Quase sempre significa **diagnóstico errado**, não correção insuficiente. Se você aumentou o botão e as pessoas continuam não o encontrando, o problema nunca foi tamanho. Volte à causa, com outra hipótese. O sinal claro: se a correção "óbvia" falhou duas vezes, pare de aplicar mais da mesma coisa.

**Apareceu um problema novo.** É o custo real de qualquer mudança, e a razão de limitar as correções por rodada. Com quatro mudanças, você identifica a causa em minutos; com quinze, você tem um produto diferente e nenhuma explicação.

### Comunicar o resultado

O elo que quase todos pulam, e o que determina se haverá próxima rodada. Uma mensagem de três a cinco linhas, para as mesmas pessoas que aprovaram:

> "A busca por nome entrou há três semanas. Na nova rodada com cinco atendentes, todos localizaram o pedido pela busca — antes, os cinco rolavam a lista manualmente. Mediana do tempo caiu de 28 s para 6 s. Os chamados com o assunto 'não acho o pedido' caíram de 9 para 1 no período."

Curto, com números, sem pedir nada. Uma mensagem dessas por mês faz mais pelo espaço do trabalho de UX na organização do que qualquer apresentação.

E quando o resultado **não** foi bom, comunique também. "A mudança nos filtros não reduziu os chamados como esperávamos; investigando por quê" custa menos credibilidade do que o silêncio, e muito menos do que alguém descobrir sozinho.

### O erro que você vai cometer: tratar o relatório como entrega

O relatório fica pronto, bem estruturado, com matriz, severidade e recomendações. Você envia, apresenta, e considera o trabalho concluído.

Três semanas depois, nada mudou. Não por má vontade: o relatório não é acionável no formato em que está. Ninguém sabe qual item entra primeiro, quanto custa cada um, nem quem decide. Ele fica no canal, é elogiado, e afunda.

A correção tem três partes, todas feitas por você:

1. **Converter em tarefas**, no sistema onde a equipe trabalha, no formato da equipe.
2. **Conseguir a estimativa** com quem implementa, antes de qualquer reunião de priorização.
3. **Identificar as que entram de carona** no trabalho já planejado para as próximas semanas.

A terceira é a de melhor retorno e a menos intuitiva. Uma correção de impacto médio que aproveita uma tela que a equipe já vai abrir custa muito menos que uma de impacto alto que exige agendamento próprio. Isso significa que a ordem de execução não vai coincidir com a ordem de prioridade do seu relatório — e aceitar isso é a diferença entre uma lista que avança e uma perfeitamente priorizada que não sai do lugar.

### Exercício prático

**Objetivo:** fechar um ciclo completo, do teste ao resultado comunicado.

1. Use a lista priorizada da sua última análise.
2. Converta os três primeiros itens em tarefas, no formato de cinco campos, com o "como saberemos" preenchido.
3. Consiga a estimativa de esforço com quem implementaria.
4. Descubra o que a equipe já vai fazer nas próximas duas semanas e identifique quais dos seus itens tocam nas mesmas telas.
5. Implemente ou prototipe as correções, no máximo quatro.
6. Reteste com três participantes novos, com a **mesma** tarefa.
7. Escreva a mensagem de resultado, com números, em cinco linhas.

### Solução comentada

O passo 6 e a insistência na mesma tarefa merecem explicação, porque a tentação de ampliar é grande — você tem participantes disponíveis, por que não testar mais coisas?

Mudar a tarefa entre rodadas destrói a comparação. Se o desempenho melhorou, você não sabe se foi pela correção ou porque a nova tarefa é mais fácil. Mantenha a tarefa fixa enquanto estiver medindo o efeito de uma mudança, e reserve tarefas novas para uma rodada exploratória própria, com esse propósito declarado.

O passo 7 é o mais fácil de pular e o que mais afeta o longo prazo. Vale entender o mecanismo: uma organização decide financiar trabalho de UX com base em resultados percebidos, não em relatórios produzidos. Se ninguém sabe que a mudança anterior funcionou, cada nova proposta parte do zero em termos de credibilidade — e você continua gastando a mesma energia para aprovar melhorias equivalentes, indefinidamente.

Uma nota sobre o que fazer quando o resultado é ambíguo, que é o caso mais comum na prática. O problema principal sumiu, um persiste, um novo apareceu. A tentação é esperar até ter uma história limpa para contar. Não espere: comunique o resultado misto, com as três partes. "Dois dos três problemas resolvidos; o terceiro persiste, e o diagnóstico estava errado — nova hipótese sendo testada" é uma mensagem que constrói confiança, porque demonstra que o processo detecta os próprios erros. Uma sequência de resultados sempre positivos, curiosamente, gera mais desconfiança do que uma com percalços declarados.

---
