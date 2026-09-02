## Planejamento básico de testes de usabilidade

Um teste de usabilidade mal planejado consome o mesmo tempo que um bem planejado e produz dados que não sustentam decisão nenhuma. E o planejamento inteiro cabe em uma página — o que torna o descuido especialmente caro, porque a economia é de trinta minutos.

Esta é a lista do que precisa estar decidido antes de a primeira pessoa entrar na sala.

### 1. A pergunta

Um teste responde a uma pergunta específica. Sem ela, você observa cinco pessoas usando o sistema e sai com impressões dispersas.

> ❌ "Testar a nova tela de pedidos."
> ✅ "As pessoas conseguem localizar um pedido específico e solicitar a devolução dele sem ajuda?"

A pergunta define tudo o mais: quem recrutar, que tarefa dar, o que medir. Se você não consegue formulá-la, o problema não é de planejamento — é que ainda não está claro o que se quer descobrir.

### 2. Quem participa

**Quantos:** cinco a seis para um teste qualitativo de um fluxo. O retorno por participante adicional cai rapidamente, e a diferença entre testar com cinco agora e vinte em três meses é imensa a favor dos cinco.

**Quem:** pessoas que correspondem ao perfil de quem usa — ou usaria — o sistema. Se há perfis muito distintos (o operador diário e o gestor eventual), teste três de cada em vez de misturar seis sem critério.

**Quem não:** quem participou do projeto, quem trabalha na mesma equipe, e você. O dado de alguém que já conhece a proposta mede familiaridade, não usabilidade.

Quando não há acesso a usuários reais — situação comum —, recrute de outras áreas da empresa e declare a limitação ao apresentar: "testado com cinco pessoas de outras áreas, não com operadores". Encontra a maior parte dos problemas de descoberta e rótulo, e não substitui o conhecimento de domínio.

### 3. As tarefas

A qualidade do teste se decide aqui. Três regras:

**Escreva como situação, não como instrução.**

> ❌ "Clique em Pedidos e depois em Devoluções."
> ❌ "Encontre a opção de devolução."
> ✅ "Você comprou um par de tênis e ele veio no tamanho errado. Resolva isso."

A primeira testa a sua capacidade de dar instruções. A segunda entrega o vocabulário da interface de bandeja — se o menu se chama "Devoluções", você deu a resposta. A terceira testa o que acontece na vida real.

**Não use nenhuma palavra que apareça na interface.** É mais difícil do que parece, e a dificuldade é informativa: se você não consegue descrever a situação sem usar o rótulo do menu, é provável que o rótulo esteja no vocabulário do sistema e não no do usuário.

**Uma a três tarefas por sessão de vinte minutos.** Mais que isso e a pessoa cansa, e as últimas tarefas medem fadiga.

### 4. O que medir

Defina antes, e escreva na folha de registro:

| Métrica | Como coletar |
|---|---|
| Concluiu sem ajuda? | Sim / não / com ajuda |
| Tempo até a conclusão | Cronômetro, da tela pronta ao término |
| Onde clicou primeiro | Anotação por tela |
| Hesitações | Contagem de pausas maiores que 3 segundos |
| Erros e retornos | Contagem |
| Frase dita ao travar | Transcrição literal |

A última linha é a que mais rende na apresentação dos resultados: uma frase literal de usuário convence mais que qualquer média.

### 5. O roteiro da sessão

Vinte minutos, quatro blocos:

**Enquadramento (2 min).** Três frases obrigatórias: "isto é um protótipo, nem tudo funciona"; "estamos testando o desenho, não você — se algo der errado, o problema é nosso"; "pense em voz alta enquanto usa".

**Contexto e tarefa (1 min).** A situação, lida em voz alta e também entregue por escrito.

**Observação (12–15 min).** Silêncio. Quando a pessoa travar e olhar para você, devolva a pergunta: "o que você acha que aconteceria se clicasse aí?".

**Fechamento (3 min).** Uma pergunta aberta e uma específica sobre o momento de maior hesitação.

### 6. A logística

O item mais chato e o que mais estraga sessões:

- **Consentimento** assinado ou registrado, dizendo o que será gravado, quem verá, por quanto tempo será guardado, e que a pessoa pode parar quando quiser sem consequência.
- **Ambiente** sem interrupção, sem o gestor da pessoa presente.
- **Protótipo testado** de ponta a ponta, no equipamento da sessão, antes.
- **Plano B**: capturas estáticas se o link falhar.
- **Sessão piloto** com um colega, para validar tarefa, roteiro e tempo.

A sessão piloto é a que mais se ganha e a mais pulada. Ela sempre revela algo: a tarefa é ambígua, o tempo não fecha, o protótipo trava num caminho que você não tinha percorrido.

### O erro que você vai cometer: testar tudo de uma vez

Você conseguiu cinco participantes com dificuldade. É tentador aproveitar e cobrir o máximo: cadastro, busca, devolução, configurações, relatórios. Seis tarefas em quarenta minutos.

O que acontece: as duas primeiras tarefas produzem dados bons; da terceira em diante, a pessoa está cansada, já aprendeu a navegação, e o desempenho reflete isso. Você não sabe se a tarefa 5 foi fácil porque a tela é boa ou porque a pessoa já entendeu o sistema. E a sessão estoura, o que corta o fechamento — que é onde vêm as observações mais ricas.

A alternativa é aceitar o escopo menor: **uma pergunta, uma a três tarefas, e profundidade**. Se há muito a testar, faça duas rodadas com participantes diferentes em vez de uma rodada longa. Cinco pessoas × duas tarefas, duas vezes, produzem dados muito melhores que cinco pessoas × seis tarefas uma vez.

### Exercício prático

**Objetivo:** produzir o plano de teste completo em uma página.

1. Escolha um fluxo seu, prototipado ou em produção.
2. Escreva a pergunta do teste, em uma frase.
3. Defina o perfil dos participantes e onde você vai recrutá-los.
4. Escreva duas tarefas como situação, sem nenhuma palavra da interface.
5. Monte a folha de registro com as seis métricas.
6. Escreva o roteiro de quatro blocos, com as três frases do enquadramento literais.
7. Faça a sessão piloto com um colega e ajuste o que não funcionou.
8. Só então conduza as sessões reais.

### Solução comentada

O passo 4 é onde o exercício revela mais, e a dificuldade é sempre a mesma: a tarefa escrita sem palavras da interface exige descrever a **situação de vida** da pessoa, e não a operação no sistema. "Você precisa saber quanto vendeu no mês passado" em vez de "gere o relatório de vendas mensais".

Quando não é possível escrever sem usar o rótulo, você acabou de descobrir algo antes de testar: o conceito da tela só existe no vocabulário do sistema. Isso é um achado, e vale registrar.

O passo 7, a sessão piloto, produz correções em praticamente todos os casos. As três mais frequentes: a tarefa é interpretada de forma diferente da pretendida (o colega faz outra coisa, corretamente, porque a redação permitia); o tempo estoura em cinco minutos; e o protótipo trava num caminho que você nunca percorreu porque sempre segue o mesmo.

Vale insistir num ponto do passo 3, sobre onde recrutar. Essa é a parte que mais atrasa testes na prática — não a análise, não o roteiro, mas encontrar cinco pessoas. Duas soluções que funcionam: pedir ao suporte que indique usuários que já entraram em contato (costumam aceitar, e conhecem o problema), e reservar a última segunda-feira do mês para sessões, com convite enviado com antecedência. Testes que dependem de disponibilidade espontânea acabam não acontecendo.

---
