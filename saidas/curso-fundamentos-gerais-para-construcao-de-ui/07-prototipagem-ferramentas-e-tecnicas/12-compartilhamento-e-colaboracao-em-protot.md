## Compartilhamento e colaboração em protótipos

Um protótipo que só existe no seu computador resolve as suas dúvidas. Para resolver as da equipe, ele precisa chegar às pessoas em uma forma que elas consigam abrir, entender e comentar — sem instalar nada, sem conta, e sem que você precise estar presente explicando.

É aqui que a maioria dos protótipos falha, e a falha é silenciosa: o link é enviado, ninguém abre, e a ausência de comentários é interpretada como aprovação. Duas semanas depois, na revisão, aparecem as objeções que deveriam ter aparecido no primeiro dia.

### Os três tipos de link, e quem recebe cada um

Ferramentas como o Figma distinguem modos de compartilhamento que fazem diferença prática:

| Modo | O que a pessoa vê | Para quem |
|---|---|---|
| Visualizar arquivo | O canvas com todos os frames, camadas, versões | Designers, quem vai implementar |
| Modo protótipo | Apenas o fluxo navegável, em tela cheia | Stakeholders, participantes de teste |
| Inspecionar / Dev Mode | Medidas, cores, tipografia, tokens, ativos | Quem vai codificar |

O erro clássico é mandar o link do canvas para um stakeholder não técnico. Ele abre, vê cinquenta frames espalhados, não sabe por onde começar e fecha. Mande o link do modo protótipo, apontando para o frame inicial correto — e confira antes que o frame inicial é mesmo o começo do fluxo, porque a ferramenta usa por padrão o primeiro frame da página, que muitas vezes é um rascunho antigo.

Sobre permissões: para teste com usuário, o link deve permitir visualização sem exigir conta. Um participante que precisa criar login antes de começar já perdeu três minutos e alguma paciência, e você acabou de introduzir uma variável na sessão.

### O que enviar junto com o link

Um link sozinho não pede o feedback certo. O que funciona é uma mensagem curta com quatro elementos:

> **O que é:** protótipo do novo fluxo de devolução, telas 1 a 6.
> **O que já está decidido:** a estrutura de menu e os nomes das seções, validados em card sorting semana passada — não precisamos rediscutir.
> **O que eu preciso de vocês:** se a sequência de passos faz sentido e se falta alguma informação para decidir em cada tela.
> **O que ainda não está no protótipo:** cores finais, textos definitivos, estados de erro.
> **Até quando:** sexta, 14h.

O terceiro item é o que muda a qualidade do retorno. Sem ele, você recebe comentários sobre cor, fonte e espaçamento — porque é o que salta aos olhos — quando precisava de opinião sobre a sequência. O quarto item previne a metade dos comentários inúteis, dizendo de antemão que aquilo é conhecido.

### Comentários dentro do protótipo

Comentários ancorados ao ponto exato da tela são muito superiores a uma lista em outro canal. Quando alguém escreve "o botão está confuso" no chat, começa a arqueologia: qual botão, em qual tela, em qual versão. Ancorado, o contexto vem junto.

Três hábitos que fazem essa funcionalidade render:

1. **Responder a todos, mesmo os que você não vai atender.** Um "não vamos mudar isso agora porque X" fecha o assunto. Um comentário sem resposta reaparece na reunião seguinte.
2. **Resolver, não apagar.** Comentários resolvidos ficam acessíveis, e o histórico de por que algo foi decidido é justamente o que ninguém lembra depois.
3. **Marcar pessoas específicas** com menção quando a decisão depende delas. Um comentário endereçado a todos não é endereçado a ninguém.

### Colaboração simultânea: o que funciona e o que não

Várias pessoas editando o mesmo arquivo ao mesmo tempo é possível, e nem sempre é bom. O que funciona bem:

- **Sessões de revisão ao vivo**, com todo mundo no modo de observação seguindo o cursor de quem apresenta. Elimina a confusão de "qual tela você está vendo".
- **Workshops de ideação** em quadro compartilhado, com cada participante colocando post-its digitais em paralelo.
- **Divisão por página ou por fluxo**, com cada pessoa dona de uma área.

O que costuma dar errado:

- **Duas pessoas mexendo nos mesmos componentes.** Não há conflito explícito como em `git` — a última alteração simplesmente vence, sem aviso, e a outra desaparece.
- **Edição durante uma apresentação.** Alguém arrasta um frame sem querer e todos veem o layout mudar ao vivo.
- **Ausência de dono.** Um arquivo que é de todos vira um arquivo que ninguém arruma.

### Versões e histórico

Ferramentas de design salvam continuamente, o que é ótimo até você precisar voltar. O histórico automático existe, mas é uma sequência de estados sem nome — encontrar "a versão que mostramos ao cliente na terça" nele é penoso.

A prática que resolve custa dez segundos: sempre que o protótipo for compartilhado ou apresentado, crie uma **versão nomeada** no histórico (`Arquivo → Histórico de versões → Salvar versão`), com um nome que diga o contexto: `v2 — apresentado ao comercial 12/03`. A partir daí, "voltar ao que o comercial viu" é um clique.

Isso resolve também um problema recorrente de comunicação: o stakeholder que viu a versão de terça e comenta na sexta sobre algo que já mudou. Com versões nomeadas, você consegue mostrar as duas e explicar a diferença, em vez de discutir de memória.

### O erro que você vai cometer: compartilhar o arquivo de trabalho

Você manda o link do arquivo em que está trabalhando. No dia seguinte, continua mexendo: reorganiza frames, apaga rascunhos, experimenta uma alternativa. O stakeholder abre o link à noite, encontra um estado intermediário — meio layout novo, meio antigo — e conclui que o trabalho está confuso.

Pior: alguém abre o link durante uma reunião externa e você está no arquivo naquele momento, arrastando coisas.

A separação que evita isso é elementar e quase ninguém faz na primeira vez: **uma página de trabalho e uma página de apresentação**. A de trabalho tem tudo — rascunhos, alternativas descartadas, componentes, anotações. A de apresentação tem apenas os frames do fluxo, na ordem, com o frame inicial correto. O link compartilhado aponta sempre para a segunda.

Custa cinco minutos organizar, e elimina de uma vez a exposição de trabalho em andamento e a confusão sobre o que é a proposta.

### Exercício prático

**Objetivo:** preparar um protótipo para circulação real.

Sobre um protótipo que você já construiu:

1. Crie uma página `Apresentação` e mova para lá apenas os frames do fluxo principal, na ordem, alinhados horizontalmente.
2. Defina explicitamente o frame inicial do protótipo.
3. Percorra o fluxo inteiro pelo link, em uma janela anônima do navegador, como se você não tivesse acesso ao arquivo. Corrija tudo que não funcionar.
4. Salve uma versão nomeada no histórico.
5. Escreva a mensagem de acompanhamento com os cinco elementos (o que é, o que está decidido, o que você precisa, o que falta, até quando).
6. Envie para duas pessoas com perfis diferentes — uma técnica e uma não técnica — e compare o tipo de comentário que cada uma faz.

### Solução comentada

O passo 3 é o que mais surpreende, e é por isso que a janela anônima é obrigatória. Coisas que costumam aparecer só nesse teste:

- O link exige login, porque a permissão está como "somente convidados".
- O protótipo abre em um frame de rascunho, não no início do fluxo.
- Uma interação aponta para um frame que ficou na página de trabalho, e o clique não faz nada.
- A escala de visualização está configurada de um jeito que corta as bordas em telas menores que a sua.

Nenhum desses problemas é visível para você, dono do arquivo, com sessão iniciada e o canvas aberto ao lado. Todos são fatais para quem recebe o link, e todos custam a você a impressão de descuido.

O passo 6 costuma produzir uma diferença nítida e útil de perceber. A pessoa técnica comenta sobre comportamento, casos limite e viabilidade: "e se a lista estiver vazia?", "isso exige uma chamada nova?". A não técnica comenta sobre linguagem, expectativa e propósito: "não entendi o que significa 'conciliar'", "achei que ia poder cancelar aqui".

Os dois tipos são valiosos e nenhum substitui o outro. O que a diferença ensina é sobre a mensagem de acompanhamento: ela precisa ser diferente para cada perfil. Pedir à pessoa não técnica que avalie casos limite não vai funcionar, e pedir à técnica que avalie clareza de linguagem desperdiça o olhar dela. Direcionar a pergunta certa a cada um dobra a qualidade do retorno sem custar nenhum tempo a mais.

---
