## Pesquisa e entendimento do usuário para o projeto

Com o escopo definido, o projeto entra na fase que mais determina a qualidade de tudo o que vem depois — e que mais frequentemente é atropelada, porque desenhar telas é mais agradável do que conversar com pessoas.

A regra que vale para este projeto: **você não desenha nada antes de ter falado com cinco pessoas**. Não é rigor acadêmico; é que cada hora de conversa nesta fase economiza vários dias de desenho na direção errada.

### O que descobrir, e o que não perguntar

O objetivo desta fase é entender três coisas:

1. **Como o problema é resolvido hoje**, com todos os contornos e improvisos.
2. **O que exatamente dói**, e quanto — em tempo, erro, frustração.
3. **O vocabulário real** das pessoas para as coisas do domínio.

O terceiro item é frequentemente subestimado e é o que mais afeta o desenho: os rótulos da sua interface saem daqui, e rótulos errados são a causa mais comum de fluxos que não funcionam.

O que **não** perguntar: o que a pessoa gostaria que existisse, se ela usaria um aplicativo para isso, ou qual funcionalidade ela acha importante. As respostas são educadas, otimistas e péssimas como base de projeto — as pessoas são ruins em prever o próprio comportamento futuro.

### O roteiro de entrevista, para este projeto

Vinte a trinta minutos, cinco a oito pessoas. A estrutura:

**Abertura (2 min).** "Estou estudando como as pessoas fazem X. Não tem resposta certa, quero entender como funciona hoje. Posso gravar só o áudio, para não perder nada? Só eu vou ouvir, e você pode parar quando quiser."

**Contexto (5 min).**
- "Me conta como é a sua rotina em relação a isso."
- "Com que frequência você precisa fazer X?"

**O último caso concreto (12 min) — o coração da entrevista.**
- "Me conta sobre a última vez que você precisou fazer X. Começa do começo."
- "E aí, o que aconteceu?" (repetir, deixando a pessoa narrar)
- "Nesse momento, o que você fez?"
- "Isso costuma acontecer?"

**Dor e contorno (8 min).**
- "O que costuma dar errado?"
- "Quando dá errado, o que você faz?"
- "Tem alguma coisa que você faz por fora para se organizar?" (esta pergunta encontra as planilhas paralelas)

**Fechamento (3 min).**
- "Tem alguma coisa que eu não perguntei e que você acha importante?"
- "Você conhece mais alguém que passa por isso e que eu poderia conversar?"

A pergunta central — "me conta sobre a última vez" — é a que faz a entrevista render. Ela substitui opinião por relato de comportamento concreto, que é o dado confiável.

### Observação, quando possível

Se o problema acontece em um lugar onde você pode estar, vá. Vinte minutos observando valem mais que duas entrevistas, porque as pessoas não sabem descrever o que fazem automaticamente.

O que procurar:

- **Os improvisos.** Papéis, planilhas paralelas, mensagens de WhatsApp usadas como registro, post-its no monitor. Cada improviso é a assinatura de uma falha do sistema atual.
- **As interrupções.** Com que frequência a tarefa é interrompida, e o que acontece quando volta.
- **Os passos duplicados.** O que a pessoa faz duas vezes "porque às vezes não salva".
- **O ambiente.** Em pé ou sentada, com uma mão ou duas, com pressa ou com calma.

### O registro

Sem registro estruturado, cinco entrevistas viram uma impressão geral. Para cada uma, uma folha:

```
P3 · paciente, 42 anos, 3 sessões/semana há 4 meses · 18/04

COMO FAZ HOJE
Liga na recepção. "Sempre no intervalo do almoço, senão não consigo."
Guarda os horários numa foto do papelzinho que a clínica dá.

ÚLTIMO CASO
Precisou remarcar na segunda. Ligou 3 vezes, ocupado. Foi pessoalmente
no dia seguinte. Perdeu a sessão de terça.

DOR
"O ruim é quando preciso mudar. Marcar é fácil, mudar é que é o problema."

CONTORNO
Foto do papel no celular. Alarme no dia anterior.

VOCABULÁRIO
Chama de "sessão", não "consulta". "Remarcar", não "reagendar".
"A ficha" = o papel com os horários.
```

A seção de vocabulário parece detalhe e é o que vai evitar que a sua interface use "reagendar" quando todo mundo diz "remarcar".

### A síntese

Terminadas as entrevistas, três produtos, nesta ordem:

**1. Os padrões.** O que apareceu em três ou mais pessoas. Liste como afirmações: "a remarcação é mais dolorosa que a marcação (5 de 6)"; "todos guardam o horário fora do sistema (6 de 6)".

**2. As contradições.** Onde as pessoas divergem, e por quê. Frequentemente revelam dois perfis diferentes — e isso decide se você projeta para um ou para os dois.

**3. A reformulação do problema.** Compare com o que você escreveu no documento de escopo. Mudou?

O terceiro item costuma ser a maior descoberta desta fase, e é o que justifica ter feito a pesquisa antes de desenhar.

### O erro que você vai cometer: entrevistar procurando confirmação

Você já tem uma ideia do que vai construir. A entrevista, sem que você perceba, vira uma busca por validação: as perguntas se inclinam, os relatos que confirmam ganham destaque nas anotações, e os que contrariam viram "aquele caso específico".

O sintoma é claro e vale monitorar: **se nenhuma das cinco entrevistas te surpreendeu, você provavelmente não estava ouvindo**. Cinco pessoas reais sempre trazem algo que não estava previsto.

Três defesas concretas:

1. **Não descreva a sua ideia antes da entrevista.** Assim que a pessoa souber o que você pretende construir, ela passa a responder sobre isso, por gentileza.
2. **Anote as falas literais**, entre aspas, antes de interpretar. É o que permite reler depois com outra hipótese.
3. **Procure ativamente o que contraria.** Ao consolidar, pergunte-se: "o que nas entrevistas sugere que a minha ideia está errada?". Se não houver nada, releia — provavelmente há e você não registrou.

### Exercício prático

**Objetivo:** conduzir e sintetizar a pesquisa do seu projeto final.

1. Recrute cinco a oito participantes do perfil definido no escopo.
2. Adapte o roteiro de cinco blocos ao seu domínio, sem incluir a sua ideia de solução.
3. Conduza as entrevistas, gravando o áudio com consentimento, e preencha a folha de registro de cada uma nos dez minutos seguintes.
4. Se possível, faça pelo menos uma observação direta.
5. Sintetize: padrões (com contagem), contradições, e a reformulação do problema.
6. Liste o vocabulário: os termos que as pessoas usam, e os que você usava e elas não usam.
7. Reescreva o documento de escopo com o que aprendeu.

### Solução comentada

O passo 7 é o que dá sentido a toda a fase, e a reescrita costuma ser substancial. Os dois padrões mais comuns:

**O problema principal muda de lugar.** Você planejou resolver a marcação e descobriu que a dor está na remarcação. As telas são parecidas; o fluxo, a hierarquia e a mensagem principal são completamente diferentes. Descobrir isso depois de desenhar significaria refazer.

**Aparece uma restrição que você não conhecia.** A recepcionista precisa confirmar manualmente porque o fisioterapeuta remaneja a agenda; um agendamento totalmente automático quebraria o funcionamento real da clínica. Restrições assim só aparecem em conversa, e são exatamente o que torna o caso de portfólio convincente — porque demonstram que você projetou dentro do mundo real e não em um vazio.

O passo 6, o vocabulário, tem um retorno desproporcional ao esforço. A lista de termos que **você** usava e as pessoas não é a mais valiosa: ela costuma conter as palavras que você importou do domínio técnico ou do produto que serviu de referência, e que teriam ido direto para os rótulos da interface. Trocá-las agora custa nada; descobrir no teste que ninguém entende "reagendar" custa uma rodada.

Uma nota sobre o passo 1, que é onde os projetos travam: recrutar cinco pessoas é a parte mais difícil e a mais adiável. Duas estratégias que funcionam — pedir indicação ao fim de cada entrevista ("você conhece mais alguém?"), o que costuma render metade da amostra, e aceitar entrevistas curtas: quinze minutos bem conduzidos valem mais que uma hora agendada que nunca acontece.

---
