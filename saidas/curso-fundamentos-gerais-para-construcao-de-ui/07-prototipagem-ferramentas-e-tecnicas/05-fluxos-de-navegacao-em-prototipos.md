## Fluxos de navegação em protótipos

Uma interação isolada funciona. Vinte interações isoladas viram um emaranhado onde ninguém — nem você, três semanas depois — consegue dizer se é possível sair de uma tela específica. O que separa os dois casos não é a quantidade de ligações, é a existência de um fluxo pensado como fluxo: um percurso com começo, meio, fim e saídas declaradas.

Esta é a parte da prototipagem que mais se parece com projetar um sistema. Você já ligou botões a telas; agora precisa garantir que o conjunto dessas ligações forme um grafo navegável, sem becos sem saída, sem estados órfãos e sem ciclos que prendem a pessoa.

### O fluxo antes das interações

O erro de sequência mais caro é começar ligando botões e descobrir a estrutura depois. O caminho inverso custa dez minutos e evita o retrabalho: escreva o fluxo em texto antes de tocar na ferramenta.

Um formato que funciona, para um fluxo de compra:

```
1. Catálogo
   → clique no produto        → 2. Detalhe do produto
   → clique no carrinho       → 4. Carrinho

2. Detalhe do produto
   → "Adicionar ao carrinho"  → 3. Confirmação (sobreposição)
   → voltar                   → 1. Catálogo

3. Confirmação (sobreposição sobre 2)
   → "Continuar comprando"    → fecha, volta a 2
   → "Ir para o carrinho"     → 4. Carrinho

4. Carrinho
   → "Finalizar"              → 5. Endereço e pagamento
   → "Continuar comprando"    → 1. Catálogo
   → carrinho vazio           → 4b. Carrinho vazio

4b. Carrinho vazio
   → "Ver produtos"           → 1. Catálogo

5. Endereço e pagamento
   → "Confirmar pedido"       → 6. Pedido concluído
   → voltar                   → 4. Carrinho

6. Pedido concluído
   → "Ver meus pedidos"       → 7. Lista de pedidos
   → "Voltar à loja"          → 1. Catálogo
```

Duas coisas ficam visíveis nessa lista que não ficariam no canvas. Primeiro: **toda tela tem pelo menos uma saída**. Segundo: a tela `4b` existe — o estado vazio apareceu porque a lista força você a perguntar "e se não houver nada aqui?".

### Os três defeitos estruturais de um fluxo

**Beco sem saída.** Uma tela para onde se pode ir e de onde não se pode voltar. Em protótipo, isso trava a sessão de teste: a pessoa fica presa, o facilitador precisa intervir, e o dado daquela tarefa se perde. O caso mais frequente é a tela de sucesso — "Pedido concluído!" com um belo ícone verde e nenhum botão.

**Estado órfão.** Um frame que existe no arquivo e para o qual nenhuma interação aponta. Normalmente é uma tela que foi desenhada, considerada importante, e esquecida na hora de ligar. Como ninguém chega nela, ela não é testada, e o problema só aparece na implementação.

**Ciclo sem progresso.** A pessoa navega de A para B, de B para C, e de C volta para A sem ter avançado. Acontece muito em fluxos de configuração com abas: cada aba leva às outras, nenhuma leva à conclusão.

Os três se detectam com a mesma varredura: liste todos os frames, marque quais têm entrada e quais têm saída, e olhe as células vazias.

### Fluxos lineares, ramificados e livres

A estrutura do fluxo deve espelhar a natureza da tarefa, e escolher errado é um problema de projeto, não de prototipagem.

**Linear** — passo 1, 2, 3, sem desvios. Adequado a tarefas que precisam ser concluídas de uma vez: checkout, onboarding, um formulário longo dividido em etapas. O protótipo deve deixar claro em que passo se está e quantos faltam; sem esse indicador, o teste vai revelar ansiedade que não existiria no produto real.

**Ramificado** — um ponto de decisão que leva a caminhos diferentes. "Pessoa física ou jurídica?" abre dois formulários distintos. No protótipo, isso significa duplicar telas, e é onde o arquivo cresce rápido. A economia possível: prototipe um ramo completo e o outro apenas até a tela onde os caminhos se reencontram.

**Livre** — a pessoa navega como quiser, sem sequência imposta. É a estrutura de um painel administrativo ou de um catálogo. Aqui o protótipo precisa da navegação global funcionando em todas as telas, o que é trabalhoso e resolve-se com um componente de menu único aplicado a todos os frames.

### O erro que você vai cometer: prototipar a navegação global em cada tela

Você desenha o menu lateral, liga cada item ao seu destino, e fica satisfeito. Depois duplica a tela para criar a próxima — e agora há dois menus, com dois conjuntos de interações. Na décima tela, há dez cópias do menu, e trocar o nome de um item significa trocar em dez lugares.

O sintoma aparece quando alguém pede uma alteração simples e você percebe que vai levar quarenta minutos.

A correção é usar um **componente único** para a navegação, com as interações definidas dentro dele. Em Figma, interações definidas dentro de um componente são herdadas por todas as instâncias: você liga "Pedidos" ao frame de pedidos uma vez, e todas as telas passam a ter esse link funcionando. Se você já duplicou dez vezes, o conserto é criar o componente a partir de uma das cópias e substituir as demais — chato, mas feito uma vez.

Um detalhe que costuma escapar: dentro do componente, o item correspondente à tela atual deveria aparecer destacado. Com um componente único, o destaque fica igual em todas as telas. A solução é criar variantes do menu — uma por seção ativa — e usar a variante certa em cada tela. Custa alguns minutos e evita a confusão em teste, onde a pessoa pergunta "mas eu estou em qual parte mesmo?".

### Testando o fluxo antes de mostrar a alguém

Antes de qualquer sessão com usuário, faça você mesmo três percursos:

1. **O caminho feliz completo**, do primeiro ao último frame, sem tocar no editor. Se travar, corrija antes.
2. **O caminho do arrependimento**: em cada tela, use o botão de voltar. Verifique se você chega onde faz sentido.
3. **O caminho aleatório**: clique em coisas fora de ordem, como uma pessoa desorientada faria. É esse percurso que encontra os becos sem saída.

O terceiro é o que mais rende, e o que quase ninguém faz.

### Exercício prático

**Objetivo:** mapear e implementar um fluxo com ramificação e estados alternativos.

Tome o fluxo de recuperação de senha, que parece trivial e não é:

1. Escreva o fluxo em texto, no formato mostrado acima, incluindo: tela de login, solicitação de recuperação, confirmação de envio, e-mail não encontrado, nova senha, senha alterada com sucesso e senha que não atende aos requisitos.
2. Marque, para cada tela, todas as saídas possíveis.
3. Implemente na ferramenta, usando `Back` para os retornos e sobreposições para as mensagens.
4. Faça os três percursos de verificação.
5. Anote quantos frames o fluxo exigiu e compare com a sua estimativa inicial.

### Solução comentada

A estimativa do passo 5 quase sempre erra para baixo, e por uma razão instrutiva: recuperação de senha é percebida como "três telas" porque o caminho feliz tem três telas. O fluxo completo tem sete ou oito, e a diferença inteira está nos estados de exceção.

Isso importa além do protótipo. Se a sua estimativa mental de esforço para essa funcionalidade era de três telas, a estimativa de implementação também era — e o desenvolvedor que a receber vai gastar mais que o dobro do previsto. O protótipo, aqui, funciona como instrumento de estimativa: contar frames do fluxo completo dá um número muito mais honesto do que contar as telas do caminho principal.

Duas armadilhas específicas deste fluxo:

**A tela de "e-mail não encontrado" não deveria existir.** Por segurança, a maioria dos sistemas responde a mesma coisa para e-mail existente e inexistente — "se este e-mail estiver cadastrado, enviamos as instruções" — justamente para não permitir que alguém descubra quais e-mails estão na base. Se você desenhou uma tela de erro específica, o protótipo acabou de revelar uma decisão de segurança que a equipe ainda não tinha discutido. Esse é o tipo de coisa que sai barato descobrir em um esboço.

**O retorno depois da senha alterada.** Levar a pessoa de volta ao login, forçando-a a digitar a senha que acabou de criar, é o comportamento mais comum e o mais irritante. Se o sistema pode autenticá-la automaticamente, o fluxo termina no painel inicial. Se não pode — e há razões legítimas para isso —, ao menos o campo de e-mail deveria vir preenchido. As duas alternativas aparecem naturalmente quando você desenha o último frame e pergunta "e agora, para onde?".

---
