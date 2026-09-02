## Uso de componentes reutilizáveis

Na quinta tela do protótipo, você já duplicou o mesmo botão nove vezes. Aí o time decide que o botão primário terá cantos menos arredondados. São nove edições — ou, mais realisticamente, sete edições e dois botões que ficam para trás e ninguém percebe até alguém apontar na apresentação.

O conceito que resolve isso é o mesmo que você já usa em código, com outro nome. Um componente em ferramenta de design é uma definição única com instâncias que a referenciam. Alterar a definição altera todas as instâncias. A diferença em relação ao código é o que uma instância pode sobrescrever — e é exatamente aí que mora o aprendizado deste trecho.

### Componente, instância e sobrescrita

Três termos, e vale fixá-los com precisão:

- **Componente principal** (*main component*): a definição. Existe em um lugar só, idealmente numa página separada do arquivo.
- **Instância**: uma cópia ligada à definição. Herda tudo o que não foi sobrescrito.
- **Sobrescrita** (*override*): uma propriedade alterada localmente numa instância. Textos, cores, visibilidade de camadas e conteúdo de imagens podem ser sobrescritos; estrutura, não.

A regra que decide quase tudo: **mudanças estruturais fluem da definição para as instâncias; mudanças de conteúdo ficam na instância**. Se você adiciona um ícone ao componente principal, todas as instâncias ganham o ícone. Se você troca o texto de uma instância, essa mudança fica só ali — e, importante, sobrevive a atualizações posteriores da definição.

### O que deve virar componente

Nem tudo compensa. O critério prático tem três perguntas:

1. **Aparece três ou mais vezes?** Menos que isso, o custo de criar e manter não se paga.
2. **Vai mudar junto?** Se dois elementos parecidos precisam poder evoluir separadamente, são dois componentes, não um com variantes.
3. **É uma decisão de design, ou um acaso?** Dois blocos com a mesma altura por coincidência não são o mesmo componente.

O conjunto que cobre a maior parte de um protótipo típico:

| Componente | Variantes típicas |
|---|---|
| Botão | primário / secundário / texto × padrão / hover / desabilitado / carregando |
| Campo de formulário | vazio / preenchido / foco / erro / desabilitado |
| Item de lista | padrão / selecionado / hover |
| Cabeçalho de página | com busca / sem busca |
| Navegação lateral | uma variante por seção ativa |
| Modal | uma / duas ações |
| Mensagem de estado | sucesso / aviso / erro / informação |

### Variantes: a máquina de estados dentro do componente

Variantes são o recurso que transforma componentes de uma economia de manutenção em uma ferramenta de prototipagem. Um componente com variantes agrupa versões alternativas do mesmo elemento sob propriedades nomeadas.

Para criar um botão completo no Figma:

1. Desenhe o botão no estado padrão e transforme em componente (`Ctrl/Cmd + Alt + K`).
2. No painel direito, clique em **Add variant** (o sinal de mais ao lado de "Variants"). Uma segunda cópia aparece dentro de um contêiner tracejado.
3. Renomeie as propriedades. Em vez do padrão `Property 1 = Default`, use nomes com significado: `tipo = primario` e `estado = padrao`.
4. Adicione variantes para cada combinação necessária. Com `tipo` (3 valores) e `estado` (4 valores), são 12 variantes — o que já sugere cautela: a explosão combinatória é real.
5. Dentro do conjunto, crie interações entre variantes: de `estado=padrao`, `On hover` → `Change to` → `estado=hover`.

Feito isso, todo botão do protótipo inteiro reage ao mouse, sem que você configure nada tela a tela. É o maior ganho de realismo por unidade de esforço em toda a prototipagem.

### Propriedades de componente: menos variantes, mais controle

Quando o número de variantes começa a crescer demais, o recurso certo não é mais variantes — são **propriedades de componente**. Elas permitem expor, na instância, controles para trocar texto, mostrar ou esconder uma camada, ou trocar um componente aninhado.

Um botão bem construído tem:

- Uma propriedade de **texto** para o rótulo (em vez de uma variante por rótulo, o que seria absurdo).
- Uma propriedade **booleana** para a presença do ícone.
- Uma propriedade de **troca de instância** para qual ícone.
- Variantes apenas para o que muda visualmente de forma estrutural: tipo e estado.

Com isso, um único componente cobre "Salvar", "Cancelar", "Excluir com ícone de lixeira" e "Enviando…" sem multiplicar definições.

### O erro que você vai cometer: desanexar a instância

Você precisa que um botão específico tenha uma borda tracejada. A ferramenta não deixa alterar isso numa instância. A saída óbvia — e errada — é clicar em **Detach instance**, que quebra o vínculo e devolve um grupo de formas comuns.

O que acontece depois: três semanas mais tarde, o design system muda a altura de todos os botões. Todas as instâncias se atualizam, menos aquela. Ela agora está dois pixels mais baixa que as vizinhas, e ninguém lembra por quê. Como não há nada que a marque visualmente como desanexada, o defeito só aparece quando alguém compara lado a lado.

Existem três saídas melhores, em ordem de preferência:

1. **Adicionar uma variante** ao componente principal, se o caso for legítimo e recorrente.
2. **Expor a propriedade** que você precisa mudar, se a ferramenta permitir.
3. **Criar um segundo componente** que compartilhe os mesmos tokens de cor e espaçamento, se o elemento for de fato outro.

E se você realmente desanexar, deixe um rastro: renomeie a camada com um prefixo claro, como `⚠ desanexado — botão tracejado`. O custo é zero e o próximo a abrir o arquivo entende o que aconteceu.

### Nomenclatura e organização

Componentes mal nomeados são componentes não encontrados, e componente não encontrado vira componente duplicado. Duas convenções que se pagam rápido:

**Hierarquia com barra.** O nome `Botao/Primario` faz a ferramenta agrupar automaticamente na lista de inserção. Com dezenas de componentes, isso é a diferença entre encontrar em dois segundos e rolar uma lista.

**Uma página só para as definições.** Todos os componentes principais numa página chamada `Componentes` ou `Base`, separada das telas. Isso impede o acidente clássico: apagar uma tela e, com ela, o componente principal que estava ali dentro — o que transforma todas as instâncias em órfãs.

### Exercício prático

**Objetivo:** construir uma biblioteca mínima e refazer um protótipo com ela.

1. Crie uma página `Componentes` no seu arquivo.
2. Construa quatro componentes com variantes: botão (3 tipos × 3 estados), campo de texto (4 estados), item de lista (2 estados) e mensagem de estado (4 tipos).
3. No botão e no campo, defina interações entre variantes para `hover` e `foco`.
4. No botão, exponha o rótulo como propriedade de texto e o ícone como propriedade booleana.
5. Refaça duas telas do protótipo do exercício anterior usando apenas instâncias desses componentes.
6. Agora mude, no componente principal do botão, o raio de canto de 8 para 4 pixels. Verifique quantas telas se atualizaram sozinhas.

### Solução comentada

O passo 6 é a demonstração, e costuma produzir uma reação de "por que eu não fiz isso desde o começo". Mas o exercício tem duas descobertas menos óbvias.

A primeira aparece no passo 2: ao listar 3 tipos × 3 estados, você chega a 9 variantes e provavelmente percebe que algumas combinações não fazem sentido — um botão de texto em estado "carregando" talvez nunca ocorra no seu produto. Componentes forçam essa clareza. Em código, estados impossíveis costumam existir silenciosamente porque ninguém enumerou o produto cartesiano; ao desenhar as variantes uma a uma, você é obrigado a enumerar, e as combinações inúteis ficam evidentes. Não crie variantes para elas — se alguém precisar depois, cria-se na hora.

A segunda aparece no passo 5, e é a mais valiosa: refazer telas com componentes prontos leva uma fração do tempo, e o resultado fica **mais consistente do que o original**. Espaçamentos que variavam entre 12 e 16 pixels por descuido passam a ser sempre 16. Não porque você teve mais cuidado, mas porque a decisão foi tomada uma vez, na definição, e não trinta vezes ao longo do arquivo. É o mesmo argumento que sustenta funções em vez de código copiado — e a analogia vale inteira, incluindo o risco: um componente com abstração errada engessa tanto quanto uma função com a assinatura errada, e é igualmente doloroso de corrigir depois que há cinquenta instâncias.

---
