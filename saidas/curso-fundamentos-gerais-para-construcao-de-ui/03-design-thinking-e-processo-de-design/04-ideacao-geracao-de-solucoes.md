## Ideação: geração de soluções

Depois de identificar e definir claramente o problema do usuário, o próximo passo no processo de design thinking é a ideação: a geração de soluções criativas e práticas para resolver esse problema. Muitas vezes, desenvolvedores e iniciantes em UX cometem o erro de saltar direto para a solução técnica, ignorando essa etapa fundamental. A ideação não é sobre encontrar a resposta perfeita imediatamente, mas sim explorar possibilidades, ampliar o leque de opções e estimular o pensamento inovador.

### Por que a ideação é essencial?

Quando nos concentramos em uma única solução logo de início, corremos o risco de criar algo limitado, que não atende às reais necessidades do usuário ou que simplesmente repete o que já existe. A ideação amplia o horizonte, permitindo que várias alternativas sejam consideradas, mesmo aquelas que parecem improváveis à primeira vista. Além disso, ajuda a evitar o viés do projeto, onde o designer pode estar preso a uma ideia inicial sem questionar se ela é realmente a melhor.

### Técnicas simples para gerar ideias

Aqui apresentamos três técnicas práticas, fáceis de aplicar e que não exigem grandes equipes ou sessões complexas:

---

#### 1. Escrita livre (Free writing)

Funciona assim: você pega o problema definido e escreve, sem parar, tudo o que vier à mente sobre possíveis soluções, funcionalidades, melhorias, ou até mesmo perguntas relacionadas. O objetivo é não julgar ou editar nada durante a escrita. Esta técnica estimula a criatividade e pode revelar ideias que estavam “travadas” pela autocensura.

**Exemplo prático**:

Suponha que o problema definido seja: “Usuários têm dificuldade em encontrar documentos importantes no app de gestão pessoal”.

Faça assim:

```plaintext
Como tornar a busca mais rápida? Talvez uma barra de busca inteligente que sugira documentos... Ou filtros por data, tipo, prioridade... Será que um sistema de tags personalizáveis ajudaria? E se o app mostrasse os documentos usados recentemente logo na tela inicial? Talvez um tutorial rápido para ensinar a usar a busca... E se tivesse integração com voz para buscar documentos falando?...
```

Ao final, você terá uma lista inicial de ideias que podem ser organizadas e refinadas.

---

#### 2. Mapa mental simples

Um mapa mental é um diagrama que parte do problema central e ramifica ideias relacionadas. Ele ajuda a visualizar conexões entre pensamentos que, isoladamente, não seriam tão evidentes.

**Como fazer:**

- No centro da página, escreva o problema.
- Ao redor, desenhe linhas para ideias que surgirem.
- De cada ideia, ramifique outras ideias relacionadas.
- Use palavras-chave, desenhos simples, ou ícones para representar conceitos.

**Exemplo**:

Para o mesmo problema “Dificuldade em encontrar documentos”, o mapa pode ter ramos como:

- Busca  
  - Inteligente  
  - Filtros  
  - Voz  
- Organização  
  - Tags  
  - Favoritos  
- Visualização  
  - Documentos recentes  
  - Categorias  

Esse método ajuda a estruturar ideias e identificar áreas que merecem mais atenção.

---

#### 3. Perguntas “E se...”

Essa técnica consiste em formular perguntas começando com “E se...”, que provocam o pensamento fora do padrão e incentivam soluções inovadoras.

**Exemplos de perguntas para o problema citado:**

- E se o app pudesse prever quais documentos o usuário vai precisar hoje?  
- E se ele enviasse notificações para revisar documentos antigos?  
- E se o usuário pudesse compartilhar documentos diretamente da busca?  
- E se houvesse um modo “rápido” para acessar os documentos mais usados?

Responder a essas perguntas pode levar a funcionalidades interessantes que nem sempre aparecem no pensamento linear.

---

### Erro comum: pular direto para a solução técnica

Imagine um desenvolvedor que, após definir o problema, já começa a programar uma tela de busca simples, sem explorar alternativas. O resultado pode ser uma interface pouco intuitiva, que não resolve o problema real do usuário.

**Mensagem típica de feedback negativo:**

```plaintext
“Não consegui encontrar os documentos que precisava rapidamente. A busca não entende o que quero e não tem filtros úteis.”
```

Esse feedback evidencia que a solução foi limitada por não ter passado pela etapa de ideação, onde outras possibilidades poderiam ter sido consideradas.

### Organizando as ideias para avançar

Após gerar diversas ideias usando as técnicas acima, é importante organizá-las:

- Liste todas as ideias, sem excluir nenhuma inicialmente.
- Agrupe ideias similares.
- Identifique quais respondem diretamente ao problema do usuário.
- Priorize ideias que sejam viáveis e de maior impacto para prototipar.

Esse agrupamento já prepara o terreno para a próxima etapa do processo: a prototipagem rápida.

---

### Código para organizar ideias em Python

Para quem quer automatizar a organização das ideias, segue um exemplo simples em Python que lê uma lista de ideias e as agrupa por palavras-chave:

```python
from collections import defaultdict

ideias = [
    "barra de busca inteligente",
    "filtros por data",
    "filtros por tipo",
    "tags personalizáveis",
    "documentos usados recentemente",
    "tutorial para busca",
    "busca por voz"
]

# Palavras-chave para agrupar ideias
palavras_chave = {
    "busca": ["busca", "barra", "voz", "tutorial"],
    "filtros": ["filtros", "data", "tipo"],
    "organização": ["tags", "favoritos", "recentemente"]
}

agrupadas = defaultdict(list)

for ideia in ideias:
    adicionada = False
    for categoria, chaves in palavras_chave.items():
        if any(chave in ideia for chave in chaves):
            agrupadas[categoria].append(ideia)
            adicionada = True
            break
    if not adicionada:
        agrupadas["outras"].append(ideia)

for categoria, itens in agrupadas.items():
    print(f"{categoria.capitalize()}:")
    for item in itens:
        print(f" - {item}")
```

**Saída:**

```plaintext
Busca:
 - barra de busca inteligente
 - tutorial para busca
 - busca por voz
Filtros:
 - filtros por data
 - filtros por tipo
Organização:
 - tags personalizáveis
 - documentos usados recentemente
Outras:
```

Esse script simples ajuda a organizar brainstorming inicial e facilita a análise.

---

### Exercício prático

Considere o seguinte problema definido:

> “Usuários têm dificuldade para acompanhar prazos de tarefas em um aplicativo de produtividade.”

1. Use a técnica de escrita livre para anotar pelo menos 10 ideias de soluções possíveis para esse problema, sem se preocupar com julgamento ou filtragem.  
2. A partir das ideias geradas, crie um mapa mental simples (pode ser feito no papel ou digitalmente) para organizar as ideias em categorias relacionadas.  
3. Formule 5 perguntas “E se...” para estimular soluções inovadoras.  

**Solução comentada** (exemplo):

1. Ideias geradas com escrita livre:

```plaintext
- Alertas de prazo por notificação
- Calendário integrado ao app
- Prioridade visual para tarefas próximas do prazo
- Resumo semanal por e-mail
- Modo foco para visualizar só tarefas urgentes
- Compartilhamento de tarefas com colegas
- Histórico de tarefas concluídas
- Sugestão automática de adiamento
- Relatório de produtividade mensal
- Widget de prazos na tela inicial do celular
```

2. Exemplo de mapa mental (em texto simples):

- Notificações  
  - Alertas de prazo  
  - Resumo semanal  
- Visualização  
  - Calendário integrado  
  - Prioridade visual  
  - Widget na tela inicial  
- Organização  
  - Modo foco  
  - Compartilhamento  
  - Histórico  
- Automação  
  - Sugestão de adiamento  
  - Relatório de produtividade  

3. Perguntas “E se...”:

- E se o app detectasse automaticamente tarefas não iniciadas próximas do prazo e sugerisse ação?  
- E se o usuário pudesse personalizar os tipos de alerta que recebe?  
- E se fosse possível delegar tarefas diretamente pelo app?  
- E se o app integrasse com assistentes de voz para lembrar prazos?  
- E se o app exibisse um gráfico visual do progresso semanal?

---

A etapa de ideação é uma ponte entre entender o problema e criar soluções concretas. Usando técnicas simples e estruturadas, você amplia o leque de possibilidades e prepara ideias sólidas para prototipagem, evitando o erro de partir para a implementação sem explorar alternativas criativas.