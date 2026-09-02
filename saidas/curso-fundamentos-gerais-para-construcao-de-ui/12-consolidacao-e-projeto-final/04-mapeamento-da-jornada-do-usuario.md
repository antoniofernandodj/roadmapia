## Mapeamento da jornada do usuário

Persona diz **para quem** você projeta. Jornada diz **onde**, no tempo, a experiência acontece — e é aí que costuma aparecer a descoberta mais útil de um projeto: o pior momento da experiência raramente está na tela que você planejava desenhar.

O mapa de jornada é o artefato que expõe isso, porque força a olhar o que acontece antes e depois do produto.

### O que um mapa de jornada mostra

Uma tabela em que as colunas são os momentos, na ordem em que acontecem, e as linhas são as camadas do que está acontecendo:

| | Perceber | Decidir | Contatar | Aguardar | Confirmar | Comparecer |
|---|---|---|---|---|---|---|
| **O que faz** | Vê que precisa mudar o horário | Escolhe outro dia | Liga na clínica | Espera atendimento | Anota o novo horário | Vai à sessão |
| **Onde / quando** | No trabalho, de manhã | Mentalmente | Intervalo do almoço | 3 tentativas | Papel ou memória | 3× por semana |
| **O que pensa** | "Preciso avisar" | "Quinta serve?" | "Será que atende?" | "Vou perder o horário" | "Anotei certo?" | — |
| **Como se sente** | 😐 | 😐 | 😟 | 😖 | 😟 | 🙂 |
| **Atrito** | — | Não sabe quais horários há | Só funciona no horário comercial | Linha ocupada; até desiste | Sem registro confiável | — |
| **Oportunidade** | Lembrete | Ver horários disponíveis | Canal fora do horário | Eliminar a espera | Registro no próprio sistema | — |

Repare que a coluna com pior sentimento — "Aguardar" — não corresponde a nenhuma tela que existiria em um sistema de agendamento convencional. É exatamente esse tipo de achado que justifica o mapa.

### As camadas, e por que cada uma

**O que faz.** Ações observáveis, na ordem. Vem direto das entrevistas.

**Onde e quando.** O contexto físico e temporal. Decide restrições de design: se acontece no intervalo do almoço, em pé, com uma mão, isso muda a interface.

**O que pensa.** Falas literais das entrevistas, sempre que possível. É a camada que dá voz ao mapa e a que mais convence quem o lê.

**Como se sente.** Uma escala simples basta — três ou cinco níveis. O objetivo não é precisão emocional; é desenhar a **curva** e localizar o vale.

**Atrito.** O que dá errado, com evidência. Quantos participantes relataram?

**Oportunidade.** O que poderia ser feito. Não é a solução ainda — é o espaço onde ela caberia.

### Como construir, na prática

**1. Defina o recorte.** Uma jornada específica, com começo e fim claros: "remarcar uma sessão", da percepção da necessidade até comparecer. Não "a experiência do paciente na clínica", que é grande demais para ser útil.

**2. Liste os momentos a partir das entrevistas.** Não invente etapas: use as que apareceram nos relatos. Se ninguém mencionou uma etapa que você esperava, isso é informação.

**3. Preencha as camadas, uma linha de cada vez.** Horizontalmente, não verticalmente — completar "o que faz" para todos os momentos antes de passar a "o que pensa" mantém a consistência.

**4. Marque a evidência.** Cada célula de atrito ganha a contagem: "(4 de 6)". Sem isso, o mapa vira ficção plausível.

**5. Desenhe a curva emocional** e olhe onde está o vale.

### O que fazer com o achado

O vale da curva emocional aponta onde investir, e a resposta nem sempre é uma tela:

- Se o vale está em uma etapa **dentro** do produto, é ali que o design precisa concentrar esforço.
- Se está em uma etapa **fora** — esperando ao telefone, aguardando confirmação —, a solução pode ser eliminar a etapa, e não melhorá-la.
- Se está **antes** do produto — a pessoa nem sabe que precisa agir —, a oportunidade é um lembrete, uma notificação, uma mudança no momento anterior.

No exemplo acima, o vale está em "Aguardar", uma etapa que existe apenas porque o único canal é o telefone. A melhor solução de design não é uma tela de espera bonita: é fazer a etapa desaparecer.

### O erro que você vai cometer: mapear a jornada ideal

O mapa fica pronto rapidamente e descreve uma sequência limpa: a pessoa percebe, acessa, escolhe, confirma, comparece. Curva emocional estável. Nenhum atrito relevante.

Isso aconteceu porque você mapeou a jornada **que a sua solução vai proporcionar**, e não a que existe hoje. É um erro fácil de cometer, porque a solução já está na sua cabeça — e um mapa assim não descobre nada: ele apenas ilustra o que você já tinha decidido.

O sintoma diagnóstico: **se o mapa não tem nenhum vale, ele está errado**. Jornadas reais têm vales; é por isso que há um problema a resolver.

A correção é ancorar cada célula em evidência. Se você não consegue apontar qual participante relatou aquele momento, aquela emoção ou aquele atrito, a célula é invenção. Um mapa com quatro colunas bem documentadas vale mais que um com dez colunas plausíveis.

Vale também um segundo mapa, depois: a jornada **futura**, com a solução proposta. Mas ele é um artefato de comunicação — mostra a intenção —, e não pode ser confundido com o diagnóstico. São dois documentos, com propósitos diferentes, e o primeiro precisa existir antes.

### Exercício prático

**Objetivo:** mapear a jornada atual do seu projeto, com evidência.

1. Defina o recorte: uma jornada específica, com início e fim, ligada à tarefa central do escopo.
2. Liste os momentos a partir dos relatos das entrevistas, sem acrescentar etapas que ninguém mencionou.
3. Preencha as seis camadas, horizontalmente.
4. Em cada célula de "o que pensa", use uma fala literal, com o participante entre parênteses.
5. Em cada célula de atrito, anote quantos participantes relataram.
6. Desenhe a curva emocional e identifique o vale.
7. Responda: o vale está dentro do escopo que você definiu? Se não está, o que muda?

### Solução comentada

O passo 7 é o que faz o mapa valer o esforço, e a resposta costuma exigir um ajuste no projeto.

O padrão mais frequente: o vale está em uma etapa que o escopo original não cobria. No exemplo da clínica, o escopo dizia "marcar, ver e remarcar", e o mapa mostra que a pior parte é a espera pelo telefone e a insegurança sobre o registro — o que sugere que a tela mais importante do produto não é a de escolher horário, é a de **confirmação visível e permanente** dos próximos horários.

Isso não significa reabrir o escopo inteiro. Significa **reordenar a prioridade dentro dele**: a tela de próximos horários passa a ser a tela inicial, e não uma tela secundária. Uma mudança pequena de decisão, com efeito grande, que só apareceu porque o mapa forçou a olhar o tempo inteiro em vez das telas isoladas.

O passo 4, usar falas literais, tem um efeito adicional na apresentação do caso. Um mapa de jornada com falas reais é uma das peças mais persuasivas que um portfólio pode ter, porque demonstra simultaneamente que houve pesquisa, que houve síntese, e que a solução responde a algo que alguém disse. Um mapa com pensamentos inventados — "quero praticidade" — não demonstra nada, e é reconhecível à distância.

Uma dificuldade prática que costuma aparecer no passo 2: os relatos das entrevistas não vêm em ordem, e cada participante conta uma sequência ligeiramente diferente. Isso é normal. A jornada mapeada é a sequência **comum** — os momentos que apareceram na maioria dos relatos, na ordem em que a maioria os descreveu. As variações individuais viram uma nota abaixo do mapa, e algumas delas indicam a segunda persona.

---
