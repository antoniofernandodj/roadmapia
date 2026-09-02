## Uso de padrões e consistência para melhorias

Em um sistema com cinco anos e quatro equipes, existem três estilos de botão, dois jeitos de mostrar erro, quatro variações de tabela e duas convenções opostas para a posição de "Salvar" e "Cancelar". Cada uma dessas divergências nasceu de uma decisão razoável, tomada por alguém que não tinha como saber o que os outros tinham feito.

O custo não aparece em nenhuma métrica isolada. Ele aparece na soma: cada inconsistência obriga a pessoa a reavaliar uma tela que deveria reconhecer, e cada reavaliação consome atenção que deveria estar na tarefa. Padronizar é a intervenção que devolve isso — e, diferente de um redesenho, ela pode ser feita aos poucos, sem parar nada.

### O inventário de inconsistências

O trabalho começa por um levantamento, e ele é mecânico. Percorra as telas principais do sistema anotando, para cada categoria, quantas variações existem:

| Categoria | O que contar |
|---|---|
| Botões | Estilos, alturas, raios, cores, posições de primário/secundário |
| Formulários | Posição do rótulo, formato de obrigatoriedade, exibição de erro |
| Tabelas | Alinhamento, cabeçalho, zebra, ações por linha |
| Mensagens | Sucesso, erro, aviso: onde aparecem, quanto tempo duram |
| Modais | Tamanho, posição dos botões, forma de fechar |
| Vocabulário | Termos que significam a mesma coisa |
| Datas e números | Formatos usados |
| Estados vazios | Existem? São iguais? |

O resultado é uma planilha desconfortável e extremamente útil. Ela transforma "o sistema está inconsistente" — que é opinião — em "existem quatro formas de exibir erro de validação, e duas delas não são acessíveis por leitor de tela" — que é uma lista de tarefas.

### Escolher o padrão: critérios, não gosto

Com as variações mapeadas, é preciso eleger uma. Três critérios, em ordem:

1. **A mais usada.** Se três telas fazem de um jeito e uma de outro, padronize pelo jeito das três — a migração é menor e o reaprendizado também.
2. **A que segue a convenção externa.** Entre duas alternativas igualmente frequentes, vence a que corresponde ao que as pessoas encontram em outros sistemas. A lei de Jakob resume: as pessoas passam a maior parte do tempo em outros produtos, e esperam que o seu funcione como eles.
3. **A que é acessível.** Se uma variação tem contraste insuficiente ou não funciona por teclado, ela está fora, independente da frequência.

O que não é critério: qual é mais bonita, qual foi feita pela equipe mais próxima, ou qual é a mais recente.

### Padrões que rendem mais quando unificados

Nem toda inconsistência custa o mesmo. Estas são as que mais pesam:

**Posição e ordem dos botões de ação.** Se em algumas telas "Salvar" está à direita e em outras à esquerda, o erro é inevitável — e é um erro que a pessoa comete justamente quando está agindo rápido, por automatismo. Unificar isso é barato e elimina uma classe inteira de deslizes.

**Forma de exibir erro de validação.** A mensagem aparece acima do formulário, abaixo do campo, em um balão, ou em um alerta no topo? Cada variação exige que a pessoa procure em um lugar diferente. A convenção que funciona melhor: mensagem junto ao campo, mais um resumo no topo quando há vários erros.

**Vocabulário.** Dois nomes para a mesma coisa é a inconsistência mais cara, porque contamina a busca, a documentação, o treinamento e as conversas do suporte. É também a mais barata de corrigir.

**Comportamento de ações destrutivas.** Algumas telas pedem confirmação, outras não; algumas oferecem desfazer, outras não. A pessoa não sabe quanto cuidado ter, então tem cuidado sempre — o que torna todas as operações mais lentas.

**Estados vazios e de carregamento.** Se algumas telas mostram esqueleto e outras ficam em branco, a pessoa não sabe distinguir "carregando" de "não há nada". É uma ambiguidade que gera recarregamentos e chamados.

### Migrando sem parar o mundo

Padronizar um sistema em produção não se faz de uma vez. A estratégia que funciona tem quatro etapas:

**1. Documente o padrão escolhido** antes de mudar qualquer coisa. Uma página com o que é, quando usar e um exemplo. Sem isso, a padronização vira uma refatoração sem destino.

**2. Aplique o padrão a tudo o que for novo.** A partir de hoje, nada entra fora do padrão. Isso estanca o crescimento do problema e não custa nada.

**3. Migre por proximidade, não por varredura.** Quando alguém mexer numa tela por outro motivo, ela sai do padrão antigo. Isso distribui o custo e mantém a mudança dentro de trabalho já planejado.

**4. Faça mutirões apenas para o que é sistêmico.** Trocar o componente de botão em cinquenta telas vale um esforço concentrado, porque é mecânico e de baixo risco. Redesenhar cinquenta formulários, não.

### O erro que você vai cometer: padronizar o que precisava ser diferente

Na cruzada por consistência, é fácil unificar coisas que eram diferentes de propósito. Dois exemplos frequentes:

**A ação destrutiva que virou igual às outras.** Ao padronizar botões, o "Excluir" ganha o mesmo estilo dos demais. Consistência perfeita, e agora nada distingue visualmente a ação que apaga dados das que não apagam. Diferença deliberada é informação; apagá-la em nome do padrão é perda.

**A tela de exceção que virou igual às normais.** Um fluxo crítico — aprovação de pagamento, por exemplo — tinha uma tela deliberadamente mais austera, com menos opções e mais confirmação. Padronizada, ela ganha a mesma densidade das outras, e a pausa que protegia contra o erro desaparece.

A regra que separa: **consistência é para o que é igual; diferença é para o que é diferente**. Antes de unificar, pergunte se a divergência carrega significado. Se carregar, documente-a como uma exceção intencional, com a razão escrita — porque a próxima pessoa a padronizar vai encontrá-la e, sem a nota, vai "corrigir".

Há um segundo erro relacionado, mais sutil: padronizar **para dentro** ignorando o mundo. Um sistema internamente consistente que contraria todas as convenções externas — checkbox que se comporta como rádio, botão de fechar à esquerda, `Enter` que não confirma — é coerente e confuso. Consistência externa costuma valer mais que a interna, porque a pessoa passa muito mais tempo fora do seu sistema do que dentro dele.

### Exercício prático

**Objetivo:** inventariar inconsistências e propor um padrão migrável.

1. Escolha oito a dez telas representativas de um sistema real.
2. Preencha o inventário das oito categorias, contando as variações de cada uma.
3. Para as três categorias com mais variações, escolha um padrão aplicando os três critérios em ordem, e escreva a justificativa de cada escolha.
4. Documente cada padrão escolhido em uma página curta: o que é, quando usar, exemplo, e uma lista de exceções intencionais.
5. Estime o custo de migração: quantas telas precisam mudar para cada padrão?
6. Proponha a ordem de migração, separando o que é mecânico (mutirão) do que exige decisão caso a caso (por proximidade).

### Solução comentada

O passo 2 costuma produzir números que a equipe não acredita — cinco estilos de botão, três formatos de data, quatro maneiras de mostrar erro. Vale registrar por que isso acontece, porque a explicação evita que o inventário vire acusação: ninguém decidiu criar cinco botões. Cada um foi criado por alguém que precisava de um botão, não encontrou um componente reutilizável, e fez o seu. A inconsistência é sintoma de ausência de biblioteca, não de descuido.

Essa leitura muda a proposta. Em vez de "vamos corrigir as telas", que soa como culpa e é trabalho sem fim, a proposta vira "vamos criar o componente que faltava e migrar as telas quando tocarmos nelas" — que é sustentável e atrai apoio de quem programa, porque também resolve um problema deles.

O passo 5 produz o outro achado útil: a distribuição do custo é sempre desigual. Tipicamente, uma das três categorias tem migração barata e mecânica (trocar o componente de botão), e as outras duas exigem decisão em cada tela. A recomendação prática é começar pela barata, mesmo que ela não seja a mais importante. O motivo é político, não técnico: uma padronização concluída e visível constrói a confiança necessária para propor a próxima, que é mais cara. Começar pela mais difícil produz um trabalho longo, sem resultado visível por semanas, que é o primeiro a ser cortado quando surge uma prioridade nova.

Sobre o passo 4 e a lista de exceções intencionais: é a parte que parece burocrática e é a que dá durabilidade ao trabalho. Sem ela, a padronização se degrada da mesma forma que a arquitetura de informação — não por decisão, mas por acúmulo de casos que ninguém soube classificar.

---
