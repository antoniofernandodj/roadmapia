## Uso de ferramentas colaborativas (Figma e Lunacy)

Uma ferramenta colaborativa resolve um problema específico: quantas pessoas conseguem participar do trabalho de design sem precisar saber usar a ferramenta. É uma questão de acesso, não de recursos — e ela decide se as decisões acontecem dentro do arquivo, onde ficam registradas, ou em conversas paralelas que se perdem.

Este trecho trata do uso das duas ferramentas como instrumento de equipe, e não como editor gráfico: permissões, comentários, bibliotecas compartilhadas, modo de inspeção e as armadilhas de colaboração simultânea.

### Os papéis dentro de um arquivo

Antes de qualquer recurso, a decisão que mais afeta a colaboração é quem tem qual acesso:

| Papel | O que faz | Quem deve ter |
|---|---|---|
| Editor | Altera qualquer coisa | Quem trabalha no arquivo |
| Visualizador com comentário | Vê e comenta | Equipe, stakeholders |
| Visualizador do modo protótipo | Vê o fluxo navegável | Participantes de teste, apresentações |
| Modo de inspeção | Vê medidas, cores, tokens, ativos | Quem implementa |

O erro mais comum é dar acesso de edição a todos "para facilitar". O resultado é o arquivo que ninguém sabe em que estado está: frames movidos sem querer, componentes alterados por engano, e um histórico impossível de auditar. Comentar resolve 95% da participação necessária, e não quebra nada.

### Comentários: onde as decisões ficam registradas

Comentário ancorado ao ponto exato vence qualquer lista em outro canal. Quando alguém escreve "o botão está confuso" no chat, começa a arqueologia — qual botão, qual tela, qual versão. Ancorado, o contexto vem junto e permanece.

Quatro hábitos que fazem esse recurso render:

**Responder a todos, inclusive aos que você não vai atender.** Um "não vamos mudar isso agora porque X" fecha o assunto. Um comentário sem resposta volta na reunião seguinte, com mais energia.

**Resolver, não apagar.** Comentários resolvidos permanecem consultáveis, e o histórico de por que algo foi decidido é justamente o que ninguém lembra depois.

**Mencionar pessoas específicas** quando a decisão depende delas. Comentário endereçado a todos não é endereçado a ninguém.

**Levar decisões do chat para o arquivo.** Se algo importante foi decidido numa conversa, cole a decisão como comentário no lugar correspondente. Custa trinta segundos e evita que a decisão desapareça junto com o histórico do chat.

### Bibliotecas compartilhadas

O recurso que mais economiza trabalho de equipe é a biblioteca publicada: componentes e estilos que vivem em um arquivo e são consumidos pelos demais. Alterar a definição atualiza todos os arquivos que a usam.

O que colocar nela: tokens de cor, espaçamento e tipografia; os componentes de base (botão, campo, item de lista, mensagem, modal); e os padrões de layout recorrentes.

Duas regras que evitam o caos:

**Uma pessoa (ou um par) é responsável pela biblioteca.** Sem dono, ela recebe contribuições incoerentes e vira um depósito. Com dono, mudanças passam por revisão como código.

**Publicar é um evento, não um reflexo.** Quando você publica uma atualização, ela chega a todos os arquivos, inclusive os que estão no meio de uma apresentação. Publique com descrição do que mudou, e evite publicar no meio do dia de uma entrega.

Em Lunacy, o equivalente são os arquivos de biblioteca compartilhados em rede ou em nuvem, com um funcionamento mais próximo de arquivo referenciado que de biblioteca viva. Funciona bem para equipes pequenas e para quem precisa trabalhar offline, com a ressalva de que a atualização não é automática — alguém precisa avisar.

### Modo de inspeção: a fronteira com o código

O modo de inspeção — Dev Mode no Figma, o painel de propriedades no Lunacy — dá a quem implementa medidas, cores, tipografia, tokens e a exportação de ativos. É a camada que reduz a conversa sobre valores.

Três cuidados que fazem diferença do lado de quem consome:

**Nomes iguais nos dois lados.** Se o estilo se chama `cor/texto/secundario` no arquivo e `--cor-texto-secundario` no CSS, a tradução é mecânica. Se for `Cinza 3` e `--text-muted`, cada tela vira adivinhação.

**Marque o que está pronto.** O Figma permite marcar seções como prontas para desenvolvimento. Sem isso, quem implementa não distingue o frame aprovado do rascunho ao lado.

**Exporte os ativos com nome útil.** `icone-filtro.svg` e não `Vector 47.svg`.

E o que o modo de inspeção **não** resolve: comportamento, condição, estado de erro, permissão, limite. Isso continua sendo texto escrito por você.

### O erro que você vai cometer: usar o arquivo de trabalho como arquivo de apresentação

Você manda o link do arquivo em que está trabalhando. No dia seguinte, continua mexendo — reorganiza frames, apaga rascunhos, testa uma alternativa. O stakeholder abre à noite, encontra um estado intermediário e conclui que o trabalho está confuso.

Pior: alguém abre o link durante uma reunião externa e você está no arquivo naquele momento, arrastando coisas.

A separação que resolve leva cinco minutos: **uma página de trabalho e uma página de apresentação**. A de trabalho tem tudo — rascunhos, alternativas descartadas, componentes, anotações. A de apresentação tem só os frames do fluxo, na ordem, com o frame inicial correto. O link compartilhado aponta sempre para a segunda.

E, sempre que o arquivo for apresentado ou compartilhado, **salve uma versão nomeada** no histórico: `v3 — apresentado ao comercial 12/03`. Dez segundos que resolvem a discussão do mês seguinte, quando alguém comenta algo que já mudou.

### Colaboração simultânea: o que funciona e o que não

**Funciona bem:** sessões de revisão ao vivo com todos seguindo o cursor de quem apresenta; workshops de ideação com cada um contribuindo em paralelo; divisão por página ou por fluxo, com dono definido para cada área.

**Costuma dar errado:** duas pessoas editando os mesmos componentes — não há conflito explícito como em `git`, a última alteração simplesmente vence sem aviso; edição durante apresentação; e o arquivo que é de todos, que acaba não sendo arrumado por ninguém.

### Exercício prático

**Objetivo:** preparar um arquivo para colaboração real.

1. Pegue um arquivo de projeto seu e crie três páginas: `Trabalho`, `Apresentação` e `Componentes`.
2. Mova os componentes principais para a terceira e verifique que nenhuma instância ficou órfã.
3. Monte a página de apresentação com o fluxo na ordem e defina o frame inicial.
4. Nomeie todos os estilos de cor, texto e espaçamento com a mesma convenção usada no código do projeto.
5. Percorra o link em uma janela anônima, sem sessão iniciada, como quem recebe.
6. Salve uma versão nomeada.
7. Peça a três pessoas de perfis diferentes — quem implementa, quem decide, quem usa — que comentem, dizendo a cada uma o que você precisa dela.

### Solução comentada

O passo 5 é o que mais surpreende, e a janela anônima é obrigatória porque nenhum desses problemas é visível para quem tem o arquivo aberto e sessão iniciada:

- O link exige login, porque a permissão está em "somente convidados".
- O protótipo abre num rascunho, não no início do fluxo.
- Uma interação aponta para um frame que ficou na página de trabalho.
- A escala de visualização corta as bordas em telas menores que a sua.

Todos são fatais para quem recebe, e todos custam a impressão de descuido.

O passo 7 costuma produzir uma diferença nítida entre os perfis, e essa diferença é a lição prática. Quem implementa comenta sobre comportamento, casos limite e viabilidade. Quem decide comenta sobre prioridade, custo e alinhamento com metas. Quem usa comenta sobre linguagem, expectativa e o que falta.

Os três tipos são valiosos e nenhum substitui os outros — mas o retorno só vem completo se a pergunta for direcionada. Pedir a quem decide que avalie casos limite desperdiça o tempo dessa pessoa; pedir a quem implementa que avalie clareza de linguagem desperdiça o olhar dela. Uma frase diferente para cada um dobra a qualidade do retorno sem custar tempo algum.

Sobre o passo 4: adotar a convenção de nomes do código no arquivo de design parece detalhe e é a mudança que mais reduz atrito na fronteira entre as duas disciplinas. Ela transforma cada consulta ao modo de inspeção de uma tradução em uma leitura — e, com o tempo, faz com que discussões sobre valores desapareçam, porque os dois lados passam a falar do mesmo nome.

---
