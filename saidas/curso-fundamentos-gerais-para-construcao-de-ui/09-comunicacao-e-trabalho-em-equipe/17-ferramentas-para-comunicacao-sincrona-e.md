## Ferramentas para comunicação síncrona e assíncrona

A escolha entre uma reunião e uma mensagem não é uma preferência de estilo. É uma decisão sobre o custo do canal e sobre o que aquele canal preserva. Uma decisão tomada em conversa de corredor não existe daqui a duas semanas; uma discussão de vinte mensagens sobre algo que se resolveria em três minutos de conversa consome uma tarde de todo mundo.

### O critério: quantas voltas a conversa precisa

A pergunta que decide o canal não é a urgência — é a quantidade de idas e vindas necessária.

| Voltas esperadas | Canal | Exemplo |
|---|---|---|
| Zero — só informar | Mensagem escrita | "A versão 3 está no link, entrega quinta" |
| Uma ou duas | Mensagem ou comentário | "Este rótulo está ambíguo?" |
| Três a cinco | Vídeo curto gravado, ou mensagem de voz | Explicar um fluxo com nuances |
| Muitas, com divergência | Conversa síncrona | Decidir entre duas estruturas |
| Muitas, com pessoas novas | Reunião, com registro escrito | Alinhamento inicial de projeto |

O erro caro é usar canal de zero voltas para conversas de muitas voltas. Uma discussão de design com divergência real, conduzida por mensagens, dura dias, esfria e frequentemente termina sem decisão — porque texto escrito é lento para explorar alternativas e rápido para endurecer posições.

O erro oposto — reunião para algo de zero voltas — é mais visível e menos custoso: consome trinta minutos de várias pessoas para transmitir o que caberia em três linhas.

### O que cada canal preserva

Além do custo, cada canal deixa um rastro diferente, e isso importa mais do que costuma ser considerado:

**Mensagem escrita** preserva o texto, e o perde no volume. Uma decisão importante tomada em um canal ativo desaparece em dois dias.

**Comentário ancorado no arquivo** preserva o contexto junto com o texto, e permanece localizável. É o melhor canal para decisões sobre uma tela específica.

**Documento** preserva de forma consultável e estruturada, e exige manutenção.

**Reunião** não preserva nada. É por isso que a regra de "registro de cinco linhas no mesmo dia" não é burocracia: sem ela, a reunião produziu apenas a memória divergente de cada participante.

**Vídeo gravado** preserva o raciocínio completo e é péssimo para consulta — ninguém volta ao minuto 4:30 para conferir um detalhe. Serve para explicar uma vez, e deve vir acompanhado de um resumo escrito.

### O vídeo curto: o canal subutilizado

Para trabalho de interface, existe um formato que resolve uma faixa inteira de situações e que a maior parte das equipes não usa: a gravação de tela de três a cinco minutos, percorrendo o protótipo e narrando o raciocínio.

Ele funciona bem para:

- Apresentar uma proposta a pessoas em fusos ou agendas diferentes.
- Explicar um fluxo com nuances que o texto tornaria longo.
- Mostrar um problema — trinta segundos de um usuário travando comunicam mais que qualquer descrição.
- Substituir uma reunião de status.

Três regras para que renda: **menos de cinco minutos**, **um assunto por vídeo**, e **um resumo escrito de três linhas junto com o link**, com a pergunta específica que você quer responder. Sem o resumo, o vídeo é assistido por metade das pessoas e consultado por ninguém.

### Assíncrono por padrão, síncrono por exceção

Para equipes distribuídas — e, cada vez mais, para todas —, a regra que produz melhor resultado é inverter o padrão: escrever primeiro, conversar quando o escrito travar.

Isso tem duas vantagens que não são óbvias. A primeira é que escrever obriga a organizar o pensamento; uma parte das reuniões existe porque quem convocou ainda não pensou o problema até o fim, e usa a sala para fazer isso com a atenção de cinco pessoas. A segunda é que o assíncrono é mais inclusivo — quem pensa devagar, quem não fala inglês como primeira língua, quem tem fuso diferente participa em igualdade.

A exceção legítima ao assíncrono: quando há divergência real, quando o assunto é sensível, ou quando o custo do mal-entendido é alto. Aí a conversa síncrona é mais barata, e o registro escrito vem depois.

### Higiene de canal

Quatro convenções que reduzem ruído sem custar nada:

**Um canal por assunto, não por pessoa.** Decisões sobre o projeto ficam no canal do projeto, mesmo quando a conversa começa em mensagem direta. A conversa privada que decide algo é a forma mais comum de a equipe descobrir a decisão tarde.

**Assunto no primeiro parágrafo.** Mensagens longas que só revelam o pedido no fim são lidas em diagonal e respondidas errado.

**Prazo explícito quando há pedido.** "Preciso disso até quinta" evita a espera indefinida e a cobrança constrangida.

**Decisão por silêncio, com prazo.** "Se ninguém discordar até quinta, seguimos com isto" resolve uma quantidade grande de aprovações que hoje ocupam agenda. Funciona com duas condições: prazo declarado e destinatários nomeados.

### O erro que você vai cometer: decidir em conversa privada

O desenvolvedor te chama em mensagem direta com uma dúvida sobre a tela. Você responde, ele propõe uma alternativa, você concorda. Decisão tomada, em três minutos, sem reunião. Eficiente.

Duas semanas depois: o designer que trabalhou na estrutura não sabe da mudança. O suporte não foi avisado. A documentação continua descrevendo o comportamento antigo. E ninguém consegue reconstruir por que aquilo foi decidido, porque a conversa está em um histórico privado que só duas pessoas veem.

O problema não é a conversa privada — ela é rápida e útil. É não fechar o ciclo. A correção custa trinta segundos: **leve a decisão para onde ela pertence**. Um comentário no arquivo, no lugar exato, ou uma linha no canal do projeto: "conversamos e decidimos X por causa de Y".

Vale a mesma disciplina para decisões tomadas em corredor, em call rápida, ou em almoço. A regra prática: se alguém que não estava presente vai ser afetado, a decisão precisa aparecer em algum lugar que essa pessoa consulte.

### Exercício prático

**Objetivo:** auditar e ajustar os canais de um projeto.

1. Durante uma semana, anote todas as comunicações relevantes do seu projeto: canal usado, assunto, número de idas e vindas, e se houve decisão.
2. Classifique cada uma: o canal foi adequado ao número de voltas?
3. Identifique as decisões tomadas em canal que não as preserva — conversa privada, reunião sem registro, corredor.
4. Para cada uma, escreva onde ela deveria ter sido registrada, e registre-a agora.
5. Escolha uma comunicação recorrente que hoje é reunião e converta-a em vídeo curto ou mensagem estruturada.
6. Depois de duas semanas, compare: a conversão funcionou ou gerou mais idas e vindas?

### Solução comentada

O passo 3 costuma revelar um número desconfortável: uma parcela significativa das decisões da semana foi tomada em canais que não as preservam, e boa parte delas em conversas privadas.

Isso não é desorganização — é a consequência natural de a conversa privada ser o canal mais rápido e mais confortável. O ponto não é evitá-la, é fechar o ciclo. O hábito que resolve é uma pergunta ao fim de qualquer conversa que decidiu algo: **"quem mais precisa saber disso?"**. Se a resposta não for "ninguém", a decisão precisa aparecer em outro lugar antes de você mudar de assunto.

O passo 6 produz resultados que dependem do tipo de comunicação convertida, e a distinção é útil. Reuniões de **informação** — status, atualizações, avisos — convertem bem para assíncrono e quase sempre economizam tempo. Reuniões de **decisão com divergência** convertem mal: o que era uma discussão de vinte minutos vira uma sequência de mensagens que dura três dias, com posições que endurecem a cada volta, porque texto escrito é ruim para negociar e ótimo para registrar posição.

Se a conversão gerou mais idas e vindas do que a reunião teria consumido, isso é o próprio critério funcionando — e a resposta certa é voltar ao síncrono para aquele tipo específico, mantendo o registro escrito depois. A meta não é eliminar reuniões; é usar cada canal para o que ele faz bem.

---
