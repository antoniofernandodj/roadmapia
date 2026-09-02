## Arquitetura de informação do projeto

Você tem a persona, o mapa de jornada e o vale identificado. Falta a decisão que precede qualquer wireframe: **quais telas existem, o que fica em cada uma e como se chega a elas**. Desenhar telas antes de responder isso é o caminho mais rápido para um protótipo em que cada tela é razoável e o conjunto não funciona.

Para um projeto deste tamanho, a arquitetura cabe em uma página e leva uma tarde. É a hora mais bem investida do projeto inteiro.

### Passo 1: inventário de conteúdo e ações

Liste tudo o que o produto precisa mostrar e tudo o que a pessoa precisa poder fazer. Sem organizar ainda — apenas listar, a partir da jornada e das entrevistas:

```
MOSTRAR
• próximos horários agendados
• data, hora e profissional de cada sessão
• horários disponíveis para remarcar
• confirmação de que a alteração deu certo
• histórico de sessões já feitas
• endereço e telefone da clínica

FAZER
• ver os próximos horários
• remarcar uma sessão
• cancelar uma sessão
• marcar uma sessão nova
• entrar (identificar-se)
```

Duas verificações imediatas. Cada item precisa ter origem na pesquisa — se você não consegue apontar qual entrevista ou qual etapa da jornada o exige, ele é suposição. E o que está no "fora do escopo" do documento inicial não pode reaparecer aqui.

### Passo 2: ordenar por frequência e importância

Nem tudo tem o mesmo peso. Classifique cada item:

| Item | Frequência | Criticidade |
|---|---|---|
| Ver próximos horários | Várias vezes por semana | Alta |
| Remarcar | ~1× por semana | Alta |
| Cancelar | Raro | Média |
| Marcar nova sessão | 1× por ciclo de tratamento | Média |
| Histórico | Raro | Baixa |
| Endereço e telefone | Raro | Baixa |

Essa tabela decide a hierarquia. O item mais frequente e mais crítico ocupa a posição mais acessível — e note que, no exemplo, isso **não** é "marcar sessão", que seria a escolha intuitiva para um produto de agendamento. É a jornada, e não a categoria do produto, que determina a resposta.

### Passo 3: agrupar em telas

Com o inventário ordenado, defina as telas. A regra: **uma tarefa por tela**, e o que a pessoa precisa ver simultaneamente fica junto.

```
T1 · Entrada / identificação
     → identificar-se

T2 · Próximas sessões          ← TELA INICIAL
     mostra: lista dos próximos horários, data, hora, profissional
     ações: remarcar (por sessão), cancelar (por sessão), marcar nova
     estados: vazio (sem sessões), carregando, erro

T3 · Escolher novo horário
     mostra: horários disponíveis, agrupados por dia
     ações: escolher, voltar
     estados: sem horários disponíveis, carregando

T4 · Confirmação
     mostra: o que mudou, de quando para quando
     ações: voltar às próximas sessões

T5 · Cancelar (sobreposição)
     mostra: qual sessão, aviso de política de cancelamento
     ações: confirmar, desistir
```

Repare no que está declarado além do conteúdo: as **ações** e os **estados**. Estados listados aqui são estados que você não vai esquecer de desenhar depois — e estado vazio esquecido é a falha mais comum em projetos de portfólio.

### Passo 4: o fluxo

Escreva as ligações em texto, antes de desenhar qualquer coisa:

```
T1 →  identificar-se           → T2
T2 →  "remarcar" numa sessão   → T3
T2 →  "cancelar" numa sessão   → T5
T2 →  "marcar nova"            → T3
T2 →  sem sessões              → T2-vazio
T3 →  escolher horário         → T4
T3 →  voltar                   → T2
T4 →  "ver minhas sessões"     → T2
T5 →  confirmar                → T2 (com aviso de cancelamento)
T5 →  desistir                 → fecha, volta a T2
```

Duas verificações que o texto permite e o desenho esconde: **toda tela tem pelo menos uma saída**, e **toda tela tem pelo menos uma entrada**. Uma tela sem entrada é órfã — foi planejada e ninguém chega nela.

### Passo 5: os rótulos

Agora, e não antes, escreva os nomes que aparecem na interface — usando o vocabulário coletado na pesquisa:

| Conceito | Rótulo | Rejeitados |
|---|---|---|
| Encontro com o fisioterapeuta | **Sessão** | Consulta, atendimento, horário marcado |
| Mudar a data de uma sessão | **Remarcar** | Reagendar, alterar, editar |
| Lista dos próximos | **Minhas sessões** | Agenda, meus agendamentos |

A coluna de rejeitados é o que impede, três semanas depois, que "reagendar" apareça em algum lugar. E ela também alimenta a busca, se houver.

### O erro que você vai cometer: estruturar pelo modelo de dados

Vindo do desenvolvimento, a organização que ocorre naturalmente é a das entidades: uma tela de sessões, uma de profissionais, uma de horários, uma de pacientes. É coerente, é limpa, e reflete como o sistema é construído — não como a tarefa é executada.

O sintoma: as telas do seu inventário têm nomes de entidades no plural, e a pessoa precisa passar por duas ou três delas para fazer uma coisa só.

A correção é estruturar por **tarefa**. A pergunta que resolve, aplicada a cada tela: "que tarefa termina aqui?". Se a resposta for "nenhuma, ela é um passo para outra", verifique se ela precisa existir — telas de passagem que só repetem informação costumam poder ser eliminadas.

No exemplo, a estrutura por dados produziria: "Sessões" (lista), "Horários" (disponibilidade), "Profissionais". A estrutura por tarefa produz: "Minhas sessões" (onde quase tudo acontece) e "Escolher horário" (o único passo intermediário necessário). Menos telas, menos navegação, e o mesmo conteúdo.

### Validar antes de desenhar

Duas verificações rápidas, ambas de meia hora:

**Teste de rótulo.** Mostre a lista de nomes de tela a três pessoas do perfil e pergunte o que cada uma faria. Se "Minhas sessões" for interpretada como o histórico e não como os próximos horários, o rótulo está errado — e descobrir isso agora custa uma linha.

**Percurso da jornada.** Pegue o mapa de jornada e percorra-o na estrutura que você definiu. Cada momento tem uma tela? O vale da curva foi atacado? Se o pior momento da jornada não corresponde à tela mais acessível, algo está fora de lugar.

### Exercício prático

**Objetivo:** produzir a arquitetura de informação do seu projeto final.

1. Faça o inventário de conteúdo e ações, marcando a origem de cada item na pesquisa.
2. Classifique cada um por frequência e criticidade.
3. Agrupe em telas, declarando conteúdo, ações e estados de cada uma.
4. Escreva o fluxo em texto, e verifique entradas e saídas de todas as telas.
5. Escreva a tabela de rótulos, com os termos rejeitados.
6. Valide os rótulos com três pessoas do perfil.
7. Percorra o mapa de jornada na estrutura definida e verifique se o vale foi atacado.

### Solução comentada

O passo 4 encontra, com regularidade, pelo menos um problema estrutural — e a natureza dele varia entre dois tipos.

**A tela sem saída.** Quase sempre é a de confirmação. Você escreve T4 e percebe que não definiu para onde a pessoa vai depois. É o mesmo beco sem saída que aparece em produtos reais, com aquela tela de "Pronto!" que não tem botão. Descoberto no texto, custa uma linha; descoberto no teste, interrompe a sessão.

**A tela órfã.** Você planejou uma tela — o histórico, por exemplo — e, ao escrever o fluxo, não há nenhuma ligação que leve até ela. Isso significa uma de duas coisas: falta um caminho, ou a tela não é necessária. As duas conclusões são úteis, e a segunda é mais frequente do que se espera em projetos de portfólio, onde telas costumam ser adicionadas por parecerem completar o produto.

O passo 6, validar rótulos, é o de melhor retorno por minuto de todo este trecho. Meia hora com três pessoas, mostrando apenas uma lista de nomes, encontra os rótulos ambíguos antes de qualquer tela existir. E o padrão de erro é previsível: os termos que você importou do domínio técnico ou do produto de referência são os que falham, enquanto os que vieram das falas literais dos participantes passam sem problema. É a confirmação prática de que a seção de vocabulário da pesquisa valia o esforço.

Sobre o passo 7: se o vale da jornada não foi atacado pela estrutura, não avance para os wireframes. Reordene a arquitetura primeiro. Desenhar telas bonitas para uma estrutura que não resolve o problema principal é o desperdício mais caro que este projeto pode ter — e é exatamente o que a próxima etapa, os wireframes iniciais, vai transformar em algo difícil de reverter.

---
