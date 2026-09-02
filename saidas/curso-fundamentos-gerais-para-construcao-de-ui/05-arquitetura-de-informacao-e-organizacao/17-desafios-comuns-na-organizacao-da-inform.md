## Desafios comuns na organização da informação

Toda arquitetura de informação começa razoável. Os problemas aparecem depois — quando o produto cresce, quando a empresa se reorganiza, quando três equipes diferentes adicionam funcionalidades ao mesmo menu sem falar entre si. Este trecho é sobre os padrões de falha que se repetem em praticamente todo sistema com mais de dois anos de vida, e sobre o que fazer com cada um.

### Desafio 1: a estrutura reflete a empresa, não o usuário

É o problema mais comum e o mais difícil de enxergar de dentro. O menu de primeiro nível de um sistema bancário tem "Produtos", "Serviços", "Canais" e "Atendimento" — as quatro diretorias da instituição. Para quem usa, essas palavras não distinguem nada: pagar um boleto pode estar em qualquer uma das quatro.

O sintoma diagnóstico é claro: se você consegue mapear as seções de primeiro nível para o organograma, a arquitetura está espelhando a organização. Isso acontece porque cada área quis "ter o seu lugar" no produto, e porque a estrutura foi negociada em reunião em vez de testada com usuários.

A correção é politicamente difícil e tecnicamente simples: nomear as seções pelas **tarefas** que as pessoas realizam, não pelas áreas que as executam. "Pagar", "Transferir", "Investir", "Meus dados" resolvem o problema do usuário e não pertencem a ninguém — o que, aliás, é parte da dificuldade de aprová-las.

### Desafio 2: o crescimento por acúmulo

A funcionalidade nova precisa aparecer em algum lugar. Ninguém quer reabrir a discussão da estrutura, então ela é encaixada onde couber. Repetido cinquenta vezes ao longo de anos, o resultado é um menu com dezessete itens de primeiro nível, três dos quais fazem quase a mesma coisa, e um chamado "Outros" ou "Mais".

O item "Outros" é o marcador oficial do fracasso: ele significa que a equipe não conseguiu classificar e desistiu. Vale como sinal de alerta, nunca como solução.

O contorno prático não é redesenhar tudo — quase nunca há orçamento para isso. É estabelecer uma regra de teto: **o primeiro nível tem N itens, e adicionar um exige remover ou fundir outro**. A restrição obriga a discussão a acontecer no momento certo, que é quando o item novo está entrando, e não dois anos depois.

### Desafio 3: a mesma coisa com dois nomes

Um sistema tem "Relatórios" e "Análises". Outro tem "Clientes" e "Contatos". Um terceiro tem "Arquivar" e "Concluir" como ações distintas cujo efeito real é idêntico. Cada par nasceu de um contexto diferente, em momentos diferentes, e ambos são defendidos por alguém.

Aqui o problema não é de estrutura, é de vocabulário — e é por isso que o dicionário de rótulos, com sua coluna de termos rejeitados, é o antídoto. Quando não existe dicionário, a única forma de detectar o problema é fazer um inventário completo de rótulos e ordená-lo alfabeticamente: os duplicados saltam da lista.

A fusão de dois termos costuma esbarrar num argumento legítimo: "mas eles são diferentes". O teste que resolve é operacional — peça a três pessoas que usam o sistema que expliquem a diferença, separadamente. Se as três explicações não coincidirem, a distinção existe só na cabeça de quem a criou.

### Desafio 4: profundidade demais ou largura demais

Uma estrutura precisa distribuir N itens em uma árvore. Colocá-los todos no primeiro nível cria uma lista impossível de varrer; enterrá-los em seis níveis cria um labirinto onde cada clique é uma aposta.

A evidência de pesquisa é razoavelmente consistente e contraria a intuição de muitos desenvolvedores: **estruturas mais largas e rasas superam estruturas estreitas e profundas**, desde que os rótulos sejam claros. Uma lista de doze opções bem nomeadas é percorrida com o olho em poucos segundos; três níveis de quatro opções cada exigem três decisões sequenciais, e um erro em qualquer uma delas custa um retorno.

A faixa que funciona na prática, para menus de navegação: **de dois a três níveis de profundidade**, com cinco a doze itens por nível. Fora dessa faixa, algo precisa de justificativa.

### Desafio 5: itens que pertencem a dois lugares

"Nota fiscal" pertence a Financeiro ou a Pedidos? "Usuário inativo" está em Usuários ou em Arquivo? Toda taxonomia real encontra itens que resistem à classificação única, e a tentação é resolvê-los duplicando o item nos dois lugares.

Duplicar navegação tem um custo específico: destrói a capacidade da pessoa de aprender onde as coisas ficam. Se um item aparece em dois caminhos, o modelo mental de "cada coisa tem um lugar" quebra, e a busca vira o único recurso confiável.

As saídas melhores, em ordem de preferência:

1. **Um lar canônico e atalhos contextuais.** O item mora em um só lugar na navegação; nos outros contextos onde é relevante, aparece um link direto para ele — visivelmente um link, não uma segunda cópia do menu.
2. **Facetas em vez de hierarquia.** Se os itens têm múltiplos atributos igualmente importantes, uma listagem única com filtros resolve melhor que uma árvore. É a diferença entre navegar pastas e filtrar uma tabela.
3. **Busca com sinônimos.** Aceita-se que a pessoa não vai adivinhar a categoria, e garante-se que ela encontre pelo nome — inclusive pelos nomes rejeitados do dicionário.

### O erro que você vai cometer: resolver por votação interna

A cena é frequente. A equipe se reúne, projeta o menu na parede, discute por uma hora, e decide por consenso ou pela opinião de quem tem mais senioridade. O resultado tem uma propriedade previsível: reflete o modelo mental de quem construiu o sistema, que é a única pessoa no mundo que não precisa da navegação para encontrar as coisas.

A alternativa custa pouco e é desproporcionalmente eficaz: um **card sorting** com seis a oito usuários reais. Escreva cada item em um cartão, peça que os agrupem como fizer sentido, e depois que nomeiem os grupos. Meia hora por participante, feito remotamente com uma ferramenta gratuita ou presencialmente com papel.

O que costuma acontecer é que os agrupamentos dos usuários coincidem entre si em uns 70% dos itens — e esses 70% viram a estrutura sem discussão. Os 30% restantes são precisamente os itens difíceis, e agora a equipe discute apenas eles, com dados sobre por que são difíceis. A reunião de uma hora vira uma de vinte minutos, e a decisão deixa de ser opinião.

### Exercício prático

**Objetivo:** diagnosticar os cinco desafios em um sistema real.

Escolha um sistema que você use com frequência e responda:

1. As seções de primeiro nível correspondem a áreas da empresa que o produz? Quais?
2. Existe um item chamado "Outros", "Mais", "Diversos" ou "Ferramentas"? O que há dentro dele?
3. Liste todos os rótulos de navegação em ordem alfabética. Há pares que significam a mesma coisa?
4. Qual é o caminho mais profundo do sistema? Conte os cliques a partir da tela inicial.
5. Existe algum item acessível por dois caminhos diferentes na navegação principal?

Para o problema mais grave que encontrar, escreva uma proposta de correção em cinco linhas: o que muda, o que quebra, e como avisar quem já usava.

### Solução comentada

O item 5 da proposta — como avisar quem já usava — é o que separa uma correção de arquitetura de uma que causa mais dano do que o problema original.

Mudanças de estrutura punem exatamente os usuários mais valiosos: os fluentes, que tinham automatizado o caminho e agora precisam reaprender. É por isso que reorganizações silenciosas geram picos de chamados de suporte de pessoas que "não acham mais" algo que está a um clique de distância.

O tratamento padrão tem três partes. Primeiro, **redirecionar** em vez de quebrar: o caminho antigo continua funcionando e leva ao novo lugar. Segundo, **sinalizar no lugar antigo** por um período — uma linha discreta dizendo "Relatórios agora está em Análises", que some depois de algumas semanas. Terceiro, **avisar antes**, não depois, para quem usa o sistema profissionalmente todos os dias.

E há uma decisão que precede todas: mudar de uma vez ou aos poucos? Reorganizações fatiadas em pequenas mudanças mensais parecem mais gentis, mas somam vários períodos de reaprendizado e deixam a estrutura incoerente no meio do caminho. Quando a mudança é grande e coerente, uma única transição bem comunicada costuma custar menos, no total, do que seis pequenas.

---
