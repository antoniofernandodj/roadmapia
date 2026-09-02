## Exemplos práticos de prototipagem

Os trechos anteriores tratam de técnicas isoladas. Aqui elas aparecem juntas, em três casos completos, com as decisões que foram tomadas em cada um e o motivo. Os casos são de escopos bem diferentes de propósito — o que muda entre eles não é a ferramenta, é quanta prototipagem o problema merecia.

---

### Caso 1: o filtro que ninguém usava

**Situação.** Um sistema interno de gestão de chamados, usado por 40 atendentes. Reclamação recorrente: "demoro demais para achar os chamados do meu setor". O sistema já tinha filtros, numa barra lateral à direita.

**Pergunta do protótipo.** As pessoas não encontram os filtros, ou os encontram e não conseguem usá-los?

**O que foi feito.** Nada de protótipo, no começo. Cinco sessões de observação de dez minutos, com os atendentes usando o sistema real. Resultado: três dos cinco nunca abriram a barra lateral; dois abriram, aplicaram um filtro, e não conseguiram removê-lo depois — recarregavam a página inteira para "limpar".

Isso mudou a pergunta. O problema não era um só: havia descoberta (não sabem que existe) e reversibilidade (não sabem desfazer).

**O protótipo.** Três telas, baixa fidelidade, feitas em 40 minutos:

- Versão A: filtros na barra lateral (atual).
- Versão B: filtros em uma linha horizontal acima da tabela, sempre visíveis.
- Versão C: como B, mais uma faixa de etiquetas removíveis mostrando os filtros ativos.

**O teste.** Cinco atendentes, tarefa única: "mostre apenas os chamados abertos do seu setor, e depois volte a ver todos". Cinco minutos cada.

**Resultado.** Na versão A, dois de cinco concluíram. Na B, cinco de cinco encontraram o filtro; três não conseguiram removê-lo. Na C, cinco de cinco fizeram as duas coisas, e quatro clicaram no "x" da etiqueta sem hesitar.

**Custo total.** Uma tarde de observação, 40 minutos de protótipo, uma manhã de testes. A implementação levou dois dias.

**A lição.** O protótipo mais barato do caso resolveu o problema porque a pergunta estava certa — e a pergunta certa só apareceu depois da observação. Se o time tivesse partido direto para prototipar "filtros melhores", teria produzido a versão B, que resolvia metade do problema.

---

### Caso 2: o cadastro em cinco etapas

**Situação.** Formulário de abertura de conta em um serviço financeiro. Vinte e três campos, taxa de abandono de 61%, concentrada — segundo o analytics — na segunda metade do formulário.

**Pergunta do protótipo.** Dividir o formulário em etapas reduz o abandono? E quantas etapas?

**Por que prototipar em vez de testar em produção.** Aqui houve uma decisão consciente: um teste A/B em produção daria a resposta mais confiável, mas exigiria implementar duas versões completas — três semanas de trabalho — para descobrir que uma delas não funciona. O protótipo custou dois dias.

**O que foi construído.** Três variações, em média fidelidade, com dados reais de exemplo:

- **V1:** formulário único, como está, com melhor agrupamento visual.
- **V2:** três etapas (identificação, endereço, dados financeiros), com indicador de progresso.
- **V3:** cinco etapas curtas, uma pergunta por tela, estilo conversacional.

Cada variação incluiu: estado de campo com erro, estado de campo preenchido corretamente, tela de revisão final e o comportamento do botão "voltar".

**O teste.** Seis participantes, dois por variação, com dados fictícios impressos em papel para digitar — o que resolve o problema de o protótipo não guardar entrada.

**Resultado.** V3 teve a melhor primeira impressão e o pior desempenho: os participantes se irritaram por volta da terceira tela, porque não conseguiam ver quanto faltava e sentiam que "estava demorando". V2 teve o melhor desempenho, e o indicador de progresso foi mencionado espontaneamente por três dos seis. V1 melhorou em relação ao original, mas os participantes ainda paravam no meio para "ver quanto falta", rolando a página inteira.

**A decisão.** V2, com um detalhe extraído do teste: o indicador de progresso mostra as etapas nomeadas, não "2 de 3" — porque dois participantes perguntaram "o que vem depois?".

**A lição.** A variação mais elaborada perdeu. Uma pergunta por tela é uma técnica legítima, mas custa a percepção de progresso, e essa troca só apareceu porque as três foram testadas com a mesma tarefa.

---

### Caso 3: o painel que não precisava de protótipo

**Situação.** Pedido para redesenhar o painel inicial de um sistema de logística: "está poluído, tem informação demais".

**O que foi feito primeiro.** Antes de desenhar qualquer coisa, três perguntas aos seis usuários principais: quais dos catorze blocos do painel você olha todo dia? Quais você nunca olhou? O que você abre logo depois de entrar no sistema?

**Resultado.** Dois blocos eram olhados diariamente por todos. Nove nunca tinham sido olhados por ninguém. E cinco dos seis usuários faziam a mesma coisa nos primeiros dez segundos: ignoravam o painel e clicavam direto em "Entregas do dia".

**A conclusão.** O painel não precisava de redesenho. Precisava de exclusão. A proposta final foi: manter os dois blocos usados, remover os nove, e transformar "Entregas do dia" na tela inicial.

**O protótipo.** Uma tela, feita em vinte minutos, apenas para mostrar o resultado à liderança — porque "vamos apagar nove blocos" é uma frase que assusta em reunião e uma imagem que convence.

**A lição.** Nem todo problema de interface é um problema de design de interface. Aqui a pesquisa custou uma hora e evitou duas semanas de trabalho de redesenho que não teria resolvido nada. Prototipar teria sido a resposta certa para a pergunta errada.

---

### O que os três casos têm em comum

**A pergunta veio antes do protótipo.** Nos três, houve uma etapa de entendimento — observação, analytics, conversa — antes de qualquer tela. O protótipo respondeu a uma pergunta específica, formulada de antemão.

**A fidelidade foi proporcional.** Baixa quando a dúvida era de estrutura, média quando envolvia leitura e preenchimento, quase nenhuma quando o problema não era de desenho.

**O teste usou a mesma tarefa em todas as variações.** É o que permitiu comparar.

**O custo do protótipo foi uma fração do custo de implementar.** Quando essa proporção se inverte — e ela se inverte, em mudanças pequenas —, prototipar deixa de fazer sentido.

### Exercício prático

**Objetivo:** replicar a estrutura do Caso 1 em um problema seu.

1. Escolha uma funcionalidade de um sistema que você conhece e que "parece pouco usada".
2. Antes de desenhar, observe três pessoas usando o sistema por dez minutos, com uma tarefa que exija aquela funcionalidade. Anote o que elas fizeram, não o que disseram.
3. Formule a pergunta com base no que observou — e não com base no que você suspeitava antes.
4. Construa duas ou três variações de baixa fidelidade que respondam a essa pergunta. Limite: uma hora no total.
5. Teste as variações com três pessoas novas, mesma tarefa.
6. Escreva o caso no formato usado aqui: situação, pergunta, o que foi feito, resultado, custo, lição.

### Solução comentada

O passo 3 é onde o exercício costuma virar. A pergunta que você formularia antes da observação e a que você formula depois raramente são a mesma — e essa diferença é o resultado mais valioso.

O padrão que se repete: você suspeitava de um problema de aparência ("o botão não chama atenção") e descobre um problema de modelo mental ("as pessoas não sabem que essa funcionalidade existe" ou "elas acham que ela faz outra coisa"). Problemas de aparência se resolvem com destaque; problemas de modelo mental não — aumentar o botão de algo que a pessoa não sabe para que serve não aumenta o uso.

O passo 6, escrever o caso, tem um propósito que vai além do exercício. Esse formato — situação, pergunta, método, resultado, custo, lição — é exatamente a estrutura de um estudo de caso de portfólio, e escrevê-lo enquanto o trabalho está fresco leva vinte minutos. Reconstruí-lo seis meses depois, a partir de arquivos e memória, leva uma tarde e sai pior, porque os números e as falas literais dos usuários já terão se perdido.

Um último comentário sobre o limite de uma hora no passo 4. Ele é deliberado e costuma incomodar. A restrição força a escolher o que realmente diferencia as variações e a abandonar o refinamento — que é a parte do trabalho que consome tempo sem responder à pergunta. Protótipos de exploração devem ser rápidos e descartáveis; refinamento vem depois, sobre a alternativa escolhida, e não sobre as três.

---
