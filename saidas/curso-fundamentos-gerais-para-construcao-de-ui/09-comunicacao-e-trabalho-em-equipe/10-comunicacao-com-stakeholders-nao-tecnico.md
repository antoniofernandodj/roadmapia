## Comunicação com stakeholders não técnicos

O diretor comercial vai decidir se o projeto entra no trimestre. Ele não sabe o que é wireframe, não vai abrir o link do protótipo, e tem sete minutos entre duas reuniões. A qualidade do seu trabalho é irrelevante nessa conversa se você não conseguir traduzi-lo para o que ele mede.

Isso não é uma concessão nem simplificação para leigos. É reconhecer que cada pessoa avalia propostas com o critério que domina — e que a tradução é responsabilidade de quem propõe, não de quem escuta.

### O que cada perfil realmente pergunta

| Perfil | Pergunta que não é dita | O que responde |
|---|---|---|
| Diretoria / financeiro | "Isso dá ou economiza dinheiro?" | Horas, chamados, conversão, receita |
| Comercial | "Isso me ajuda a vender ou me atrapalha?" | Objeções de cliente, tempo de demonstração |
| Operação | "Vou ter que retreinar minha equipe?" | O que muda, quando, e o plano de transição |
| Jurídico / conformidade | "Isso me expõe a risco?" | Consentimento, dados, rastreabilidade |
| Suporte | "Isso reduz meus chamados?" | Chamados por assunto, antes e depois |
| Diretoria de tecnologia | "Isso cria dívida?" | Escopo, reversibilidade, manutenção |

A pergunta não dita é a que decide. Uma apresentação que responde brilhantemente a "isso melhora a experiência?" e não toca em nenhuma dessas seis não convence ninguém — porque não era isso que estava sendo perguntado.

### Traduzir sem perder precisão

O erro comum é achar que traduzir significa simplificar. É o contrário: a tradução costuma ser **mais** precisa que o termo técnico, porque nomeia a consequência específica em vez da categoria do problema.

| Em vez de | Diga |
|---|---|
| "Melhora a usabilidade" | "Reduz o tempo de atendimento em cerca de 40 segundos por caso" |
| "A carga cognitiva está alta" | "São 28 campos numa tela só; 61% das pessoas desistem no meio" |
| "Falta feedback visual" | "A pessoa não sabe se o pedido foi registrado, e clica de novo — geramos 12 pedidos duplicados por mês" |
| "Testamos com usuários" | "Seis atendentes fizeram a mesma tarefa; quatro não conseguiram concluir na versão atual" |
| "Precisamos iterar" | "Vamos ajustar e medir de novo em duas semanas" |
| "Não é responsivo" | "No celular, o botão de confirmar fica escondido atrás do teclado" |

O padrão: substituir o nome do conceito pela situação observável. Se você não consegue fazer essa substituição para alguma afirmação sua, provavelmente ela ainda não está clara nem para você.

### Achar o número quando não parece haver um

A objeção previsível é que nem toda melhoria tem métrica. Quase sempre tem — o que falta é procurar. Quatro caminhos:

**Tempo × frequência × pessoas.** O mais universal. Quarenta segundos por atendimento, três vezes ao dia, quarenta atendentes: cerca de 22 horas por mês. Não precisa de precisão; precisa de ordem de grandeza e dos componentes visíveis, para que quem discordar discuta os números.

**Chamados de suporte por assunto.** Já vêm quantificados e já têm custo conhecido pela organização.

**Erros e retrabalho.** Pedidos duplicados, estornos, correções manuais, dados inválidos na base. Cada um tem um custo que alguém já calcula.

**Abandono.** Onde há funil instrumentado, a taxa de conclusão por etapa é o argumento mais direto que existe.

Quando realmente não houver número, seja explícito sobre isso em vez de inventar: "não temos medição desse fluxo; proponho instrumentar antes de decidir" é uma frase forte, e cria a base para a próxima proposta.

### O formato que sobrevive a sete minutos

Uma página, ou três slides. Nada mais.

```
O PROBLEMA
14 chamados por trimestre com o assunto "sumiram pedidos". Em todos, a pessoa
aplicou um filtro e não sabe como remover.

O QUE ISSO CUSTA
~9 horas de atendimento por trimestre, mais o tempo dos 40 atendentes
(~22 h/mês).

A PROPOSTA
Mostrar quais filtros estão ativos, com um "x" para remover cada um.
[imagem: antes e depois]

O QUE JÁ SABEMOS
Testado com 6 atendentes: 6 removeram o filtro sem ajuda na versão nova,
2 na atual.

CUSTO E PRAZO
2 dias de trabalho, sem mudança no sistema de dados. Reversível.

O QUE PRECISO
Aprovação para entrar na sprint de abril.
```

Note o que **não** está aí: heurísticas, princípios cognitivos, o processo de descoberta, as alternativas consideradas. Tudo isso existe e fica disponível se alguém perguntar — mas não ocupa os sete minutos.

### As objeções e como respondê-las

**"Os usuários já estão acostumados."** Reconheça o custo e apresente a contraevidência: "há custo de reaprendizado, por isso mantemos o caminho antigo por dois meses e avisamos antes. Mas quem reclama nos chamados são usuários com mais de um ano de casa — o hábito não resolveu, só tornou tolerável."

**"Não temos tempo agora."** Fatie: "são seis itens de meio dia cada; podemos fazer três na próxima sprint?"

**"Isso é subjetivo."** Método e número: "seis pessoas fizeram a mesma tarefa nas duas versões; duas concluíram na atual, seis na proposta."

**"Por que não fazemos algo maior de uma vez?"** Risco e retorno: "um redesenho leva três meses sem entregar nada e faz todos reaprenderem ao mesmo tempo. Estes seis itens entregam a maior parte do ganho em duas semanas."

### O erro que você vai cometer: mostrar o processo

Depois de semanas de trabalho cuidadoso — pesquisa, personas, jornada, três alternativas, testes —, a tentação de mostrar tudo é enorme. O trabalho foi bom, e mostrar apenas a conclusão parece desperdiçar o esforço.

O que acontece na sala: você gasta cinco dos sete minutos no processo, a audiência não sabe onde a apresentação vai chegar, e a decisão fica para "quando tivermos mais tempo".

Há um mal-entendido por trás disso. Mostrar o processo é essencial em **portfólio**, onde se avalia como você pensa. Em uma reunião de decisão, avalia-se se vale fazer — e o processo é a garantia de qualidade, não o produto.

A forma de não desperdiçar o trabalho é comprimi-lo em uma linha de credibilidade: "chegamos a isso depois de observar cinco atendentes e testar três alternativas". Uma frase estabelece que houve método, e libera os minutos para o que decide.

Se alguém quiser o detalhe, vai perguntar — e aí você tem tudo pronto.

### Exercício prático

**Objetivo:** traduzir uma proposta técnica para três públicos diferentes.

1. Pegue uma proposta sua já documentada.
2. Identifique três stakeholders reais de perfis diferentes, e escreva a pergunta não dita de cada um.
3. Escreva o número que responde a cada pergunta — se não houver, escreva como você o obteria.
4. Produza a página única para o perfil mais decisivo, no formato de seis blocos.
5. Percorra o texto eliminando todo termo técnico sem consequência observável ao lado.
6. Apresente em sete minutos, cronometrados, a alguém de fora da área, e peça que repita: qual o problema, quanto custa, e o que você está pedindo.

### Solução comentada

O passo 3 é onde o exercício costuma travar, e a dificuldade é informativa: se você não consegue escrever o número, é provável que ainda não saiba o tamanho do problema — e uma proposta sem tamanho não pode ser priorizada contra outras.

A saída não é inventar. É escolher o caminho de estimativa mais barato e declarar as premissas: "estimo 40 segundos por ocorrência com base em três medições; se a frequência real for metade da que assumi, o ganho ainda seria de 11 horas por mês". Uma estimativa com premissas visíveis convida à correção; um número sem origem convida à desconfiança, e um único número contestado derruba a credibilidade do documento inteiro.

O passo 5 costuma eliminar mais texto do que se espera, e o resultado é quase sempre mais forte. Frases como "melhora significativamente a experiência do usuário" desaparecem sem deixar falta, porque não diziam nada verificável. O que sobra são afirmações que podem ser contestadas — e afirmações contestáveis são as únicas que convencem.

Sobre o passo 6 e a terceira pergunta: o pedido é a parte que mais falha, com uma regularidade que vale antecipar. Ele costuma ser dito de passagem no último minuto, quando a atenção já migrou. A correção é dizê-lo **duas vezes**: no início, para que a audiência escute o resto sabendo o que será perguntado, e no fim, como fechamento. Parece redundante para quem apresenta e é a quantidade certa para quem ouve uma vez só.

---
