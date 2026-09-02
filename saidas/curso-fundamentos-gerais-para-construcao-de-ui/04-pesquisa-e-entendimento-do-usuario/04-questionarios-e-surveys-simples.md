## Questionários e surveys simples

Na pesquisa em UX, um dos métodos mais acessíveis e eficientes para coletar dados quantitativos e qualitativos rapidamente são os questionários ou surveys simples. Eles possibilitam alcançar um número maior de usuários, capturando informações objetivas sobre comportamentos, preferências e opiniões, essenciais para embasar decisões de design.

### Por que criar questionários objetivos?

Imagine que você quer entender como os usuários interagem com um aplicativo de finanças pessoais, mas não sabe exatamente quais aspectos do app causam frustração ou satisfação. Entrevistas individuais, embora detalhadas, demandam muito tempo e esforço, limitando a quantidade de pessoas alcançadas. Já um questionário online pode coletar dados de 100, 200 ou até milhares de usuários em poucas horas.

Porém, um erro comum na criação de questionários é formular perguntas vagas, longas ou ambíguas, que geram respostas inconsistentes ou difíceis de analisar. Isso compromete a qualidade dos dados e pode levar a conclusões equivocadas — exatamente o que queremos evitar com a pesquisa.

### Como criar questionários efetivos

Para obter respostas úteis, o questionário deve ser:

- **Claro e objetivo:** cada pergunta deve ser fácil de entender, sem jargões ou termos técnicos complexos.
- **Curto:** idealmente, não ultrapassar 10 a 15 perguntas para evitar desistência.
- **Direto ao ponto:** perguntas com foco em um único tema, evitando ambiguidades.
- **Com tipos variados de perguntas:** use perguntas fechadas (escolha múltipla, escala Likert) para dados quantitativos e algumas abertas para insights qualitativos.

### Tipos principais de perguntas em surveys simples

- **Alternativas múltiplas:** o usuário escolhe uma ou mais opções. Exemplo:  
  _“Com que frequência você utiliza o recurso X do aplicativo?”_  
  ( ) Nunca  
  ( ) Raramente  
  ( ) Às vezes  
  ( ) Frequentemente  
  ( ) Sempre  

- **Escalas Likert:** medem intensidade de opinião, por exemplo, de 1 a 5, onde 1 = discordo totalmente e 5 = concordo totalmente. Exemplo:  
  _“Eu acho a navegação do aplicativo intuitiva.”_  
  (1) (2) (3) (4) (5)  

- **Perguntas abertas:** permitem respostas livres, úteis para captar sentimentos ou sugestões. Exemplo:  
  _“O que você mudaria na interface do aplicativo?”_

### Exemplo prático: criando um questionário para avaliar um app de receitas

Suponha que você esteja projetando um app de receitas e quer entender a satisfação do usuário com a funcionalidade de busca.

```python
# Exemplo de questionário simples em texto para enviar por e-mail ou plataforma online:
questionario = """
1. Com que frequência você usa a função de busca no app de receitas?
   ( ) Nunca
   ( ) Raramente
   ( ) Às vezes
   ( ) Frequentemente
   ( ) Sempre

2. A função de busca encontra os resultados que você espera?
   (1) Discordo totalmente
   (2) Discordo parcialmente
   (3) Neutro
   (4) Concordo parcialmente
   (5) Concordo totalmente

3. Qual sua principal dificuldade ao usar a busca no app?
   (Resposta aberta)

4. Você recomendaria o app para amigos interessados em cozinhar?
   ( ) Sim
   ( ) Não
"""

print(questionario)
```

Saída:

```
1. Com que frequência você usa a função de busca no app de receitas?
   ( ) Nunca
   ( ) Raramente
   ( ) Às vezes
   ( ) Frequentemente
   ( ) Sempre

2. A função de busca encontra os resultados que você espera?
   (1) Discordo totalmente
   (2) Discordo parcialmente
   (3) Neutro
   (4) Concordo parcialmente
   (5) Concordo totalmente

3. Qual sua principal dificuldade ao usar a busca no app?
   (Resposta aberta)

4. Você recomendaria o app para amigos interessados em cozinhar?
   ( ) Sim
   ( ) Não
```

Esse questionário é simples, objetivo e mistura perguntas quantitativas com uma qualitativa, equilibrando rapidez de resposta e riqueza de dados.

### Evitando erros comuns

1. **Perguntas duplas ou confusas:**  
   Exemplo ruim:  
   _“Você usa a busca e acha fácil encontrar receitas?”_  
   O usuário pode querer responder que usa, mas não acha fácil, e uma resposta única não captura isso. Divida em duas perguntas separadas.

2. **Perguntas tendenciosas:**  
   Exemplo ruim:  
   _“Você concorda que nosso app é o melhor do mercado?”_  
   Essa pergunta induz a uma resposta positiva. Prefira perguntas neutras, como:  
   _“Como você classificaria nosso app em comparação a outros?”_

3. **Excesso de perguntas abertas:**  
   Perguntas abertas são valiosas, mas podem desestimular o usuário ou dificultar a análise em grandes volumes. Use-as com moderação.

### Aplicando o questionário na prática

Você pode criar esses questionários em ferramentas gratuitas como Google Forms, Typeform ou Microsoft Forms. Elas facilitam a distribuição, coleta e exportação dos dados para análise posterior.

### Exercício prático

Crie um questionário para um aplicativo de gestão de tarefas que você conheça, com no máximo 10 perguntas, incluindo:

- Pelo menos 3 perguntas de múltipla escolha.
- Pelo menos 2 perguntas com escala Likert.
- 1 pergunta aberta para feedback livre.

Depois, simule a coleta de respostas fictícias para cada pergunta e escreva um pequeno resumo do que esses dados poderiam revelar sobre os usuários.

---

### Solução comentada do exercício

Aqui está um exemplo de questionário para um app de tarefas:

```python
questionario_tarefas = """
1. Com que frequência você utiliza o app para adicionar novas tarefas?
   ( ) Nunca
   ( ) Raramente
   ( ) Às vezes
   ( ) Frequentemente
   ( ) Sempre

2. Quão fácil é organizar suas tarefas no app?
   (1) Muito difícil
   (2) Difícil
   (3) Neutro
   (4) Fácil
   (5) Muito fácil

3. Você utiliza notificações para lembrar das tarefas?
   ( ) Sim
   ( ) Não

4. Como você avalia a interface do app?
   (1) Muito ruim
   (2) Ruim
   (3) Regular
   (4) Boa
   (5) Excelente

5. Qual funcionalidade você gostaria de ver no app?
   (Resposta aberta)
"""

print(questionario_tarefas)
```

**Simulação de respostas:**

- Frequência: “Às vezes” (alternativa múltipla)
- Facilidade para organizar: 4 (escala Likert)
- Uso de notificações: “Sim”
- Avaliação da interface: 3 (regular)
- Feedback aberto: “Gostaria de ter integração com calendário.”

**Análise resumida:**  
Os usuários usam o app ocasionalmente e acham relativamente fácil organizar tarefas, mas a interface pode melhorar (nota regular). A maioria usa notificações, o que indica que lembretes são valorizados. O pedido por integração com calendário sugere uma oportunidade para aprimorar a experiência.

Esse exemplo mostra como questionários simples ajudam a identificar pontos fortes e oportunidades de melhoria, guiando o design para atender melhor o usuário.

---