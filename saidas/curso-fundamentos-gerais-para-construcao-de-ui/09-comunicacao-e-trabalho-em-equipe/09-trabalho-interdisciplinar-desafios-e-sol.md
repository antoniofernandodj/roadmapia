## Trabalho interdisciplinar: desafios e soluções

Um projeto de interface reúne pessoas que foram treinadas para valorizar coisas diferentes. Quem desenvolve otimiza previsibilidade e custo de manutenção. Quem cuida de produto otimiza impacto no negócio e velocidade de entrega. Quem faz design otimiza a experiência de quem usa. Quem responde pelo suporte otimiza a redução de chamados. Quem responde pelo jurídico ou pela conformidade otimiza a ausência de risco.

Nenhuma dessas prioridades está errada, e elas entram em conflito com frequência. Trabalho interdisciplinar bem-feito não é o que elimina o conflito — é o que o torna explícito e resolvível.

### Os quatro atritos previsíveis

**1. Prioridades legitimamente diferentes.** A melhoria de usabilidade compete com a funcionalidade nova pelo mesmo tempo de equipe, e o benefício dela é mais difuso. Isso não é resistência a design; é aritmética de capacidade.

*O que ajuda:* quantificar o impacto, mesmo aproximadamente, e propor em unidades pequenas e independentes que possam entrar sem disputar um bloco grande de agenda.

**2. Restrições invisíveis de cada lado.** Você propõe uma tela; ela exige três chamadas novas de API e uma migração de dados. Ou o contrário: a equipe implementa algo tecnicamente elegante que quebra uma convenção que os usuários dominam.

*O que ajuda:* envolver quem implementa **antes** de a proposta ficar pronta. Quinze minutos com um wireframe recolhem a restrição enquanto ela ainda é premissa de projeto e não retrabalho.

**3. Vocabulário divergente.** "Componente", "estado", "protótipo" significam coisas diferentes em cada disciplina, e conversas inteiras acontecem em falso.

*O que ajuda:* o glossário compartilhado, e o hábito de apontar para a tela: "quando você diz componente, é o quê exatamente?".

**4. Diferença de ritmo.** Design explora divergindo, o que parece indecisão para quem precisa estimar. Desenvolvimento converge para uma implementação, o que parece rigidez para quem ainda está explorando.

*O que ajuda:* declarar em que fase o trabalho está. "Estamos explorando três alternativas, ainda não estime nada" e "esta é a proposta fechada, pode estimar" são frases que evitam a maior parte do desencontro.

### Envolver cedo, e a forma certa de fazê-lo

O princípio mais eficaz do trecho: **envolva quem implementa na ideação, não na entrega**.

O erro na aplicação é convidar para a sessão de ideação e pedir a opinião de design da pessoa. Não é isso que ela tem de mais valioso a oferecer. O que ela tem é o conhecimento do custo e das restrições — e a pergunta que aproveita isso é:

> "Destas três alternativas, qual é a mais barata? E existe alguma coisa aqui que é dez vezes mais cara do que parece?"

Essa segunda pergunta é a que mais rende. Quase sempre existe um elemento aparentemente trivial — uma ordenação, um filtro combinado, uma atualização em tempo real — que custa desproporcionalmente. Descobrir isso na ideação permite escolher outra alternativa; descobrir na entrega significa refazer.

E a recíproca: quem propõe design deve estar presente no refinamento das tarefas técnicas, pelo mesmo motivo. É lá que se decide, muitas vezes sem perceber, que o estado vazio não será implementado nesta entrega.

### O papel de quem vem do desenvolvimento

Você tem uma posição incomum nesse arranjo, e vale usá-la deliberadamente.

**A vantagem:** credibilidade com a equipe técnica que designers de formação levam anos para construir, capacidade de avaliar o custo real do que propõe, e de traduzir nas duas direções.

**O risco:** ser tratado como "o designer que entende de código" e acabar aceitando restrições técnicas cedo demais, por conhecê-las bem. Saber que algo é caro não é razão suficiente para não propor — é razão para propor com o custo declarado e deixar a decisão para quem prioriza.

A frase que resolve essa tensão: **"tecnicamente isto é caro; a decisão de pagar ou não é de produto, não minha nem da engenharia"**. Ela devolve a decisão a quem tem o mandato e evita tanto a proposta ingênua quanto a autocensura.

### Trabalhar com quem não é técnico nem de design

Suporte, comercial, operação, jurídico. Três coisas que essas áreas oferecem e que ninguém mais oferece:

**Suporte tem o mapa dos problemas, já quantificado.** Os chamados agrupados por assunto são a lista de atritos com custo calculado. Uma conversa de trinta minutos com quem atende costuma render mais que uma semana de análise.

**Comercial e operação conhecem os casos extremos.** O cliente com quarenta mil registros, o processo que roda uma vez por ano e não pode falhar, a exceção contratual.

**Jurídico e conformidade conhecem os limites não negociáveis.** Descobrir na véspera que um fluxo exige consentimento explícito é falha de mapeamento de stakeholders, e é evitável com uma pergunta feita no início.

### O erro que você vai cometer: tratar restrição como oposição

A engenharia diz que a proposta é inviável no prazo. O produto diz que a prioridade é outra. O jurídico diz que aquele campo é obrigatório.

A leitura fácil é que essas pessoas estão contra o trabalho. A leitura correta, quase sempre, é que elas estão otimizando outra coisa — e cada uma tem razões que você não conhece.

O que muda a conversa é uma única pergunta, feita com sinceridade:

> "O que precisaria ser verdade para isso ser possível?"

As respostas costumam ser específicas e acionáveis: "se não precisasse ser em tempo real, cai para dois dias de trabalho"; "se entrasse depois do fechamento do trimestre, dá"; "se o consentimento for coletado uma vez no cadastro, o campo sai da tela".

Cada uma dessas respostas é uma proposta alternativa que você não teria formulado sozinho, porque depende de conhecimento que a outra pessoa tem. É por isso que a pergunta funciona melhor que qualquer argumento: ela transforma a restrição em uma condição, e condições podem ser negociadas.

### Exercício prático

**Objetivo:** mapear e ativar as disciplinas envolvidas em um projeto.

1. Escolha um projeto ou proposta em andamento.
2. Liste todas as áreas afetadas — incluindo as que só aparecem no fim, como suporte e conformidade.
3. Para cada uma, escreva o que ela otimiza e qual restrição ela pode trazer.
4. Identifique quais dessas áreas já foram consultadas e quais você descobriria tarde.
5. Faça uma conversa de vinte minutos com a mais negligenciada, fazendo duas perguntas: "o que costuma dar errado nesse fluxo?" e "o que precisaria ser verdade para isso funcionar melhor?".
6. Registre o que descobriu e o que muda na sua proposta.

### Solução comentada

O passo 5, quando a área escolhida é o **suporte**, produz o melhor retorno por minuto investido de todo este capítulo.

O motivo é estrutural: quem atende chamados vê o sistema falhando o dia inteiro, tem os problemas já agrupados por frequência, e raramente é consultado sobre design. A conversa costuma render uma lista de cinco a dez problemas concretos, com estimativa de volume, que teria custado semanas de pesquisa para levantar de outra forma.

Há um efeito adicional que vale antecipar: a área consultada tende a virar aliada da proposta. Não por gentileza — porque a proposta passa a conter algo que resolve um problema dela. Numa reunião de priorização, ter o suporte dizendo "isso reduziria os nossos chamados" muda a conversa de forma que nenhum argumento de usabilidade consegue.

O passo 3, escrever o que cada área otimiza, tem uma função menos óbvia: ele reduz a personalização do conflito. Quando a objeção da engenharia é lida como "eles não querem fazer", a resposta é defensiva. Quando é lida como "eles estão otimizando previsibilidade e custo de manutenção, que é o trabalho deles", a resposta vira uma pergunta sobre condições — e a conversa fica produtiva.

Vale uma ressalva honesta: nem todo conflito é mal-entendido. Às vezes as prioridades são genuinamente incompatíveis, e alguém precisa decidir. Nesses casos, o trabalho interdisciplinar não é convencer — é apresentar o trade-off com clareza para quem tem o mandato de decidir, e aceitar a decisão. Insistir depois dela é o caminho mais rápido para perder o espaço nas próximas conversas.

---
