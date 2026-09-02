## Cuidados ao modificar interfaces legadas

Um sistema legado tem uma propriedade que o torna diferente de tudo o mais neste capítulo: ele funciona. Pode ser feio, lento e cheio de problemas de usabilidade — e ainda assim, todos os dias, centenas de pessoas concluem o trabalho delas nele. Isso significa que qualquer alteração parte de um patamar de sucesso, e que uma mudança que piore alguma coisa tem consequência imediata e visível.

Melhorar sob essa condição exige um conjunto de cuidados que não se aplicam a produtos novos.

### O usuário fluente é quem paga a conta

Quem mais sofre com uma mudança de interface é quem melhor sabia usar a versão anterior. A pessoa que executava a tarefa por automatismo — sem ler os rótulos, movendo o mouse por memória muscular — perde exatamente isso, e volta a operar conscientemente. Ela fica mais lenta, comete erros que não cometia, e a experiência dela piora antes de melhorar.

Isso tem duas implicações práticas.

**A reclamação inicial não é o veredito.** Toda mudança de interface produz um pico de reclamação nos primeiros dias, mesmo quando a mudança é boa. Reverter no terceiro dia por causa do volume de queixas é abandonar antes de saber. A avaliação honesta vem depois de duas a quatro semanas, quando o reaprendizado já aconteceu.

**Mas a reclamação também não é ruído.** Se, passado um mês, as queixas continuam, a mudança piorou algo de fato. A distinção entre as duas situações depende de medir, não de opinar — tempo de tarefa e taxa de erro antes e depois, ou o volume de chamados por assunto.

### A regra de uma mudança por vez

O princípio mais útil deste trecho: **não mude posição e comportamento ao mesmo tempo**.

Se um botão mudou de lugar e passou a fazer algo levemente diferente, a pessoa erra duas vezes — procura no lugar antigo e, quando encontra, obtém um resultado inesperado. Se apenas a posição mudou, ela erra uma vez e aprende. Se apenas o comportamento mudou, ela encontra o botão no lugar de sempre e recebe o feedback do novo comportamento.

O mesmo vale para nome e função, para estrutura e visual, para fluxo e vocabulário. Fatiar as mudanças por dimensão — e não por tela — é o que torna o reaprendizado administrável.

### Compatibilidade com o que já existe fora do sistema

Um sistema com anos de uso tem raízes fora dele, e essas raízes quebram silenciosamente:

- **Links salvos** em favoritos, blocos de notas e e-mails antigos.
- **Documentação e material de treinamento** com capturas de tela e instruções passo a passo.
- **Procedimentos escritos** que dizem "clique no botão azul no canto superior direito".
- **Macros e automações** que os próprios usuários criaram.
- **Integrações** que dependem de uma URL ou de um formato de exportação.

Antes de qualquer mudança de estrutura ou de nomenclatura, essa lista precisa ser levantada. As correções são conhecidas: redirecionar endereços antigos em vez de removê-los, avisar quem mantém a documentação com antecedência, e verificar com o suporte quais procedimentos escritos mencionam a tela que vai mudar.

### O que o legado esconde

Sistemas antigos guardam decisões cuja razão se perdeu, e algumas delas são importantes. Antes de remover algo que "obviamente não serve para nada", vale uma investigação de dez minutos:

**O campo obrigatório que ninguém preenche direito.** Pode ser inútil — ou pode alimentar uma obrigação fiscal, um relatório mensal ou uma integração. Descubra quem consome o dado antes de removê-lo.

**A tela feia que uma pessoa usa.** Baixa frequência não significa baixa importância. Uma tela acessada duas vezes por mês pode ser o fechamento contábil.

**O passo redundante.** Aquela confirmação que parece excessiva pode ter sido adicionada depois de um incidente. Procure no histórico do repositório ou pergunte a alguém antigo: "por que existe essa confirmação?" costuma ter uma resposta específica e boa.

**O comportamento estranho que virou apoio.** Se uma listagem sempre ordenou por data decrescente por acidente, e a operação inteira se organizou em torno disso, "corrigir" a ordenação quebra um fluxo de trabalho.

A regra prática, emprestada de uma velha analogia de engenharia: antes de remover uma cerca no meio do campo, descubra por que ela foi posta ali.

### Como reduzir o risco de cada entrega

Cinco práticas que tornam a mudança reversível e observável:

**1. Entregue atrás de uma chave.** Uma flag que permite ligar e desligar a mudança sem novo deploy. Se algo der errado, a reversão leva segundos.

**2. Comece por um grupo pequeno.** Uma equipe, uma filial, 5% dos usuários. O que passa despercebido em revisão aparece em uso real.

**3. Meça antes.** Sem a linha de base — tempo de tarefa, taxa de erro, chamados por assunto — não há como saber se melhorou. Colete a medição na semana anterior à mudança, não depois.

**4. Avise antes.** Para sistemas de uso profissional, duas linhas na semana anterior, dizendo o que muda e o que não muda, eliminam a maior parte dos chamados.

**5. Deixe o caminho antigo por um tempo.** Quando possível, a alternativa anterior continua funcionando por algumas semanas, ainda que menos visível.

### O erro que você vai cometer: o redesenho completo

A proposta é sedutora e aparece cedo: em vez de quinze correções pontuais, refazer a interface inteira, com padrões consistentes, arquitetura revisada e visual atualizado. Resolve tudo de uma vez.

O que acontece com projetos assim, com uma regularidade que já é folclore da área:

- O escopo cresce, porque cada tela revela mais problemas.
- Durante meses, nada é entregue, e o sistema atual segue com os problemas antigos.
- O redesenho chega junto, e todos os usuários reaprendem tudo ao mesmo tempo.
- Problemas que existiam e ninguém sabia — a tela obscura que uma pessoa usava — aparecem simultaneamente.
- A comparação com a versão anterior é impossível, porque mudou tudo ao mesmo tempo.

A alternativa incremental entrega valor desde a segunda semana, distribui o reaprendizado, permite atribuir causa a cada mudança e pode ser interrompida a qualquer momento sem perder o que já foi feito.

Isso não significa que redesenho nunca se justifica. Ele se justifica quando o problema é genuinamente estrutural — quando a arquitetura da informação está errada de forma irrecuperável, ou quando a base técnica impede qualquer melhoria incremental. Mas essa conclusão precisa vir de um diagnóstico, e não do desconforto de olhar para uma tela feia.

### Exercício prático

**Objetivo:** planejar uma mudança em sistema legado, com plano de risco.

1. Escolha uma melhoria sua que altere algo que os usuários já aprenderam.
2. Levante as raízes externas: quem tem links salvos, que documentação menciona essa tela, existe procedimento escrito ou automação envolvida?
3. Investigue o legado: existe algum elemento que você pretende remover cuja razão você não conhece? Descubra a razão antes.
4. Defina a linha de base: quais três números você vai medir antes da mudança, e como?
5. Escreva o plano de entrega: com chave de ativação? grupo piloto? aviso prévio? caminho antigo mantido por quanto tempo?
6. Escreva o critério de reversão: que número, medido quando, faria você desligar a mudança?

### Solução comentada

O passo 6 é o mais importante e o quase sempre esquecido. Definir o critério de reversão **antes** de entregar muda completamente a discussão que acontecerá depois.

Sem critério definido, o que decide a reversão é o volume de reclamação nos primeiros dias — que, como já visto, aparece em qualquer mudança, inclusive nas boas. A decisão acaba sendo tomada sob pressão, por quem grita mais alto, no terceiro dia, quando o reaprendizado mal começou.

Com critério definido de antemão — por exemplo, "se depois de três semanas os chamados sobre esta tela não voltarem ao patamar anterior, ou se o tempo médio da tarefa não tiver caído, revertemos" —, a conversa do terceiro dia tem uma resposta pronta: "combinamos avaliar em três semanas; até lá, vamos acompanhar os números". Isso protege a mudança do pânico inicial e, igualmente importante, protege os usuários de uma mudança ruim que seria defendida indefinidamente por orgulho.

O passo 3 costuma render pelo menos uma surpresa. A pergunta "por que isto existe?" feita sobre um elemento aparentemente inútil encontra, com frequência razoável, uma razão específica e ainda válida — um requisito de auditoria, uma exigência de um cliente grande, uma proteção adicionada depois de um incidente caro. Descobrir isso antes custa dez minutos de conversa; descobrir depois de remover custa um incidente.

E vale notar o caso oposto, também comum: a investigação revela que a razão **existia** e não existe mais. Aí a remoção deixa de ser um risco e passa a ser uma correção bem fundamentada, com a história documentada — o que é um argumento muito mais forte do que "isso não parece necessário".

---
