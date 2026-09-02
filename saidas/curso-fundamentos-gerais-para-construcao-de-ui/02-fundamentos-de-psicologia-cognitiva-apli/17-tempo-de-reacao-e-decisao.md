## Tempo de reação e decisão

Um botão que responde em 80 milissegundos e um que responde em 800 fazem exatamente a mesma coisa do ponto de vista funcional. Para quem usa, são produtos diferentes: o primeiro parece uma ferramenta, o segundo parece um site. E o mais desconfortável é que a diferença raramente vem do servidor — vem de quanto tempo a interface leva para *admitir* que ouviu o clique.

Este trecho trata de duas grandezas que costumam ser confundidas. **Tempo de resposta** é quanto o sistema demora para reagir. **Tempo de decisão** é quanto a pessoa demora para escolher o que fazer. As duas se somam na percepção de lentidão, mas se corrigem de maneiras opostas: a primeira com engenharia e feedback, a segunda com redução de alternativas — a mesma lógica que você já viu na lei de Hick e no custo de mira da lei de Fitts.

### Os três limiares de percepção temporal

A pesquisa em fatores humanos converge há décadas para três faixas, e elas são a régua com que se projeta qualquer resposta de interface:

| Faixa | O que a pessoa sente | O que a interface deve fazer |
|---|---|---|
| até ~100 ms | Reação instantânea; ação e efeito parecem a mesma coisa | Nada além de responder |
| ~100 ms a 1 s | Percebe a demora, mas o fluxo de pensamento continua | Mudar o estado do elemento (pressionado, desabilitado) |
| 1 s a 10 s | A atenção começa a vagar; a pessoa duvida se funcionou | Indicador de progresso; se possível, determinado |
| acima de 10 s | A tarefa é abandonada mentalmente; a pessoa troca de aba | Progresso com estimativa, e liberdade para sair e voltar |

O limiar de 100 ms é o mais importante e o mais mal compreendido. Ele não exige que a operação termine em 100 ms — exige que **alguma coisa visível mude** em 100 ms. Um botão que fica pressionado imediatamente enquanto a requisição leva 900 ms é percebido como rápido. Um botão que não muda em nada durante 300 ms e depois abre a tela pronta é percebido como travado, ainda que seja três vezes mais veloz.

### O clique fantasma: o custo de não confirmar

O caso é banal e acontece em produção todo dia. Um formulário com botão "Enviar" que dispara uma requisição de 1,5 segundo sem alterar o botão. O que se observa nos logs:

```
POST /pedidos  201  1487ms  user=8821
POST /pedidos  201  1502ms  user=8821
POST /pedidos  201  1341ms  user=8821
```

Três pedidos idênticos, do mesmo usuário, em quatro segundos. A pessoa não é distraída: ela clicou, esperou o intervalo que o cérebro considera razoável para uma confirmação, não viu nada, concluiu que o clique não pegou, e clicou de novo. Duas vezes.

A correção tem três camadas, e as três importam:

1. **Feedback imediato** (< 100 ms): o botão muda de estado no `mousedown`, não na resposta do servidor.
2. **Bloqueio da repetição**: o botão fica desabilitado enquanto a operação está em voo — isso resolve o dado duplicado, mas sozinho não resolve a percepção.
3. **Progresso**, se a operação passar de 1 segundo: um indicador que se move, e um rótulo que diz o que está acontecendo ("Registrando pedido…").

Note que o item 2 sem o item 1 produz um efeito ainda pior: o botão fica inerte e não clicável, e a pessoa interpreta como uma tela quebrada.

### Tempo de decisão: onde os milissegundos viram segundos

Se o tempo de resposta se mede em milissegundos, o tempo de decisão se mede em segundos inteiros — e é aí que está o desperdício maior. Escolher entre duas opções claramente rotuladas custa perto de meio segundo. Escolher entre doze itens de um menu com rótulos parecidos custa vários segundos, e frequentemente termina numa escolha errada seguida de um retorno.

Três fatores dominam esse tempo:

**Número de alternativas.** O crescimento é logarítmico, não linear: dobrar as opções não dobra o tempo, mas o acréscimo é real e cumulativo em telas que se repetem centenas de vezes por dia.

**Semelhança entre alternativas.** "Salvar" e "Salvar e continuar" custam mais caro que "Salvar" e "Descartar", porque exigem leitura completa em vez de reconhecimento de forma. Rótulos que compartilham a primeira palavra forçam a leitura até a diferença.

**Consequência do erro.** Diante de uma ação irreversível, a pessoa relê, hesita e confere. Esse tempo extra é útil e não deve ser eliminado — mas se toda ação da tela parece irreversível, a hesitação se espalha para onde não precisava.

### O erro que você vai cometer: acelerar a máquina e ignorar a hesitação

O padrão é conhecido em qualquer time que mede performance: reduz-se a latência da API de 600 ms para 180 ms, comemora-se o ganho, e a métrica de tempo médio de conclusão da tarefa não se move. A razão é aritmética simples. Se a tarefa leva 14 segundos e apenas 0,6 deles eram espera de servidor, cortar dois terços dessa espera devolve 0,4 segundo — 3% do total. Os outros 13 segundos são leitura, procura e hesitação.

O diagnóstico correto exige separar as duas grandezas. Instrumente a tarefa e registre, para cada etapa, dois carimbos de tempo: quando a tela ficou pronta para receber a ação, e quando a ação chegou. A diferença é tempo de decisão puro, sem servidor no meio. É comum descobrir que uma única tela — normalmente uma com muitas opções parecidas — concentra metade do tempo total.

### Exercício prático

**Objetivo:** medir e reduzir o tempo de decisão de uma tela real.

1. Escolha uma tela com pelo menos seis ações possíveis (um painel administrativo serve bem).
2. Peça a três pessoas que ainda não conhecem a tela para executar uma tarefa específica. Cronometre desde o momento em que a tela aparece completa até o primeiro clique **na direção certa**.
3. Anote também quantos cliques exploratórios (abrir e fechar menus, entrar e voltar) aconteceram antes do primeiro acerto.
4. Reduza a tela: mova para um menu secundário tudo o que não pertence à tarefa mais frequente, e reescreva os rótulos das opções restantes para que nenhum par comece com a mesma palavra.
5. Repita a medição com outras três pessoas.

### Solução comentada

Duas coisas costumam aparecer nos números.

A primeira: o tempo até o primeiro clique certo cai bem mais do que a redução de opções sugeriria pela lei de Hick isolada. O motivo é que a reescrita dos rótulos ataca o segundo fator — semelhança — que a lei de Hick pura não captura. Menos opções e opções mais distinguíveis compõem; e o ganho de distinguibilidade costuma ser maior que o de quantidade.

A segunda: os cliques exploratórios caem antes do tempo cair. Isso é um sinal valioso. Exploração é a pessoa comprando informação porque a tela não a deu de graça; quando os rótulos passam a dizer o que fazem, a compra deixa de ser necessária. Se você só medisse o tempo total, veria uma melhora modesta; medindo a exploração, vê a causa.

Um resultado que às vezes surpreende: esconder opções raras em um menu secundário **não piora** o tempo de quem precisa delas tanto quanto se teme. Quem procura uma função rara já está em modo de busca deliberada e tolera um passo a mais. Quem executa a tarefa frequente ganha em todas as repetições. A troca é quase sempre favorável — e é uma decisão que se toma com dados de frequência de uso, não com opinião.

---
