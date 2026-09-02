## Documentação clara e acessível

Documentação de design tem uma taxa de leitura próxima de zero, e a culpa raramente é de quem deveria ler. Documentos longos, escritos depois do fato, guardados longe de onde a decisão acontece, sem estrutura previsível — esses não são lidos por ninguém, e a conclusão de que "ninguém lê documentação" é tirada do material errado.

O que é lido: documentos curtos, com estrutura repetida, localizados onde o trabalho acontece, escritos enquanto o assunto está fresco. Este trecho trata de produzir esses.

### O critério de proximidade

A regra que determina se algo será lido: **a documentação precisa estar a menos de um clique daquilo que ela descreve**.

Uma anotação ao lado do frame vence um documento no wiki. Um comentário ancorado no elemento vence uma mensagem no chat. Um `README.md` no repositório vence uma pasta compartilhada. Não porque o conteúdo seja melhor, mas porque o custo de consultar é menor no momento exato em que a dúvida aparece — e é só nesse momento que documentação é procurada.

Três camadas que funcionam juntas:

| Camada | Onde | O quê |
|---|---|---|
| Anotação no canvas | Ao lado do frame | Regras específicas daquela tela |
| Comentário ancorado | No elemento | Observação pontual, que se resolve |
| Documento de referência | No repositório | O que atravessa telas: padrões, tokens, glossário |

A primeira é a mais eficaz e a mais negligenciada.

### Estrutura previsível vence prosa

Documentação de design não é lida do começo ao fim. É consultada em busca de uma resposta específica, sob pressão de tempo. Isso favorece um formato: blocos com títulos fixos, sempre os mesmos, sempre na mesma ordem.

```
TELA: Carrinho — finalizar compra

INTERAÇÕES
• "Finalizar" → tela Endereço
  Habilitado apenas se: carrinho tem ≥ 1 item E todos com estoque
• "Remover item" → remove a linha, atualiza total
  Sem confirmação. Mostra "Item removido — Desfazer" por 5 s

DADOS
• Subtotal = soma (preço × quantidade), sem frete

ESTADOS
• Vazio: ilustração + "Seu carrinho está vazio" + botão "Ver produtos"
• Carregando: esqueleto de 3 linhas
• Erro: "Não foi possível carregar" + "Tentar novamente"

LIMITES
• Nome do produto: 2 linhas, depois reticências
• Máximo de 50 itens distintos

PERMISSÕES
• Visitante: vê o carrinho; "Finalizar" leva ao login
```

Cada linha é verificável — quem implementa marca item por item, e quem testa transforma cada linha em caso de teste. Um parágrafo em prosa com a mesma informação não permite nem uma coisa nem outra.

### Escrever para quem chega depois

Documentação tem dois públicos: quem vai implementar agora, e quem vai encontrar isso daqui a um ano sem contexto nenhum. O segundo é frequentemente você.

Três hábitos que atendem ao segundo público sem custar nada ao primeiro:

**Registre o porquê, não só o quê.** "Botão de exclusão fora da linha principal, em menu secundário" é a decisão. "…porque três de cinco participantes clicaram nele por engano ao tentar editar" é o que impede a decisão de ser revertida por alguém que acha o menu inconveniente.

**Registre as alternativas descartadas.** Uma linha cada. Sem isso, a mesma alternativa será proposta de novo, discutida de novo e descartada de novo.

**Converta datas relativas em absolutas.** "Validado no teste da semana passada" é inútil daqui a seis meses. "Validado em 12/03/2026, com seis participantes" não.

### Linguagem: as mesmas regras da interface

A documentação de design costuma ser escrita em um registro estranhamente formal, cheio de voz passiva e substantivos abstratos. As mesmas regras que valem para o texto da interface valem aqui:

| Em vez de | Escreva |
|---|---|
| "A validação dos campos deverá ser realizada" | "Valide os campos ao sair de cada um" |
| "É necessário que seja apresentado feedback" | "Mostre o estado de carregamento" |
| "Poderá ocorrer a situação em que" | "Se" |
| "Realizar o preenchimento" | "Preencher" |

Frases curtas, voz ativa, verbo no imperativo para instrução. Não é questão de estilo: uma instrução em voz passiva não diz quem faz o quê, e quem implementa precisa saber exatamente isso.

### Manter, ou deixar morrer explicitamente

Documentação desatualizada é pior que documentação ausente, porque induz ao erro com aparência de autoridade. Duas decisões que resolvem:

**O que se mantém.** Glossário, tokens, padrões de componente, regras que atravessam o produto. Esses vivem enquanto o produto viver, e devem estar versionados junto com o código, mudando por revisão como qualquer outra coisa.

**O que se arquiva.** Documentação de uma tela específica, depois que a tela foi implementada. O produto passa a ser a fonte de verdade. Tentar manter um espelho atualizado do que já existe é trabalho contínuo sem retorno — e produz justamente o documento no qual ninguém confia.

Quando algo é arquivado, marque: "Implementado em 04/2026 — o comportamento atual está no produto; este documento registra as decisões originais."

### O erro que você vai cometer: documentar depois

O trabalho fica pronto na quinta. A entrega é sexta. A documentação fica para segunda, e na segunda há outra prioridade.

O que acontece: as dúvidas chegam durante três semanas, uma a uma, sempre quando você está em outra coisa. As respostas ficam espalhadas em conversas de chat que ninguém mais encontra. E daqui a seis meses todas as regras terão que ser redescobertas por engenharia reversa do código.

A correção é de ordem, não de esforço: **anote enquanto decide**. No momento em que você desenha o estado desabilitado do botão, a condição que o desabilita está clara na sua cabeça — escreva ali. Uma semana depois, a mesma frase exige reconstruir o raciocínio e leva três ou quatro vezes mais tempo.

Vale medir isso uma vez para acreditar: cronometre a anotação de uma tela feita durante a construção e a de outra feita sete dias depois. A diferença costuma ser de cinco minutos contra vinte — e a versão tardia é pior, porque detalhes se perderam.

### Exercício prático

**Objetivo:** produzir documentação que passe no teste de outra pessoa.

1. Escolha três telas de um projeto seu.
2. Escreva o bloco de seis seções para cada uma, em formato de lista verificável.
3. Para cada decisão não óbvia, acrescente uma linha de "por quê" e uma de "alternativa descartada".
4. Coloque as anotações ao lado dos frames, no canvas.
5. Entregue a alguém que não participou — de preferência quem programa — e peça que liste todas as perguntas que faria antes de implementar.
6. Classifique cada pergunta: era para estar documentado, é decisão em aberto, ou revela um erro no design?

### Solução comentada

O passo 5 produz, mesmo com documentação cuidadosa, entre cinco e dez perguntas. Isso é o valor do exercício aparecendo, não uma falha.

A distribuição é consistente. As perguntas do primeiro tipo — que deveriam estar documentadas — giram quase sempre em torno de **comportamento assíncrono e erro**: o que acontece se a requisição falhar, se o botão trava enquanto salva, se a pessoa clicar duas vezes. Como elas se repetem em todo fluxo, a solução econômica não é escrevê-las em cada tela: é um documento único de padrões globais — carregamento, erro de rede, timeout, duplo clique — e a anotação da tela mencionando apenas o que foge do padrão.

O segundo tipo, decisões genuinamente em aberto, é o achado mais valioso. "Se o produto ficar sem estoque enquanto está no carrinho, avisamos na hora ou na finalização?" não é omissão sua — é uma regra de negócio que ninguém definiu. Descobrir isso agora, e não na terça da sprint, é uma das principais razões de a documentação existir. Registre como pergunta em aberto, com responsável e prazo.

O terceiro tipo é o mais desconfortável e o mais útil: a pergunta que revela uma incoerência no próprio design — "por que essa tela tem dois botões que fazem a mesma coisa?". O olhar de fora encontra o que o autor não vê, e é por isso que o passo 5 não pode ser substituído por autoavaliação.

Um subproduto que vale registrar: a lista de perguntas respondida e organizada é, na prática, o documento de requisitos daquele fluxo — produzido em uma hora, por duas pessoas, a partir de um protótipo, em vez de em uma reunião de especificação de três horas com seis participantes.

---
