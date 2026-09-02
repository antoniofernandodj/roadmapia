## Tipos de pesquisa: qualitativa e quantitativa

Imagine que você está desenvolvendo um aplicativo de finanças pessoais e precisa entender como os usuários gerenciam seu dinheiro no dia a dia para criar uma interface que realmente faça sentido para eles. Como descobrir o que eles precisam? Como evitar criar funções inúteis ou confusas? É aqui que entra a pesquisa em UX, e mais especificamente, os dois tipos principais de pesquisa: qualitativa e quantitativa.

### Por que diferenciar pesquisa qualitativa e quantitativa?

Muitas vezes, iniciantes em UX confundem essas duas abordagens ou tentam usá-las de forma errada. Isso gera problemas como coletar dados demais, mas sem sentido prático, ou então opiniões vagas que não ajudam a tomar decisões. Entender as diferenças e quando usar cada tipo é fundamental para extrair informações úteis que irão guiar o design.

### Pesquisa qualitativa: o que é e para que serve?

Pesquisa qualitativa é sobre **entender o "porquê" e o "como"** por trás do comportamento dos usuários. Ela trata de dados descritivos, que não podem ser facilmente reduzidos a números. Seu foco está em captar sentimentos, motivações, dificuldades e contextos de uso.

#### Exemplos comuns de pesquisa qualitativa

- Entrevistas em profundidade
- Observação direta do usuário
- Grupos focais
- Análise de feedback aberto

#### O que acontece por baixo

Quando você conduz uma entrevista, por exemplo, está coletando relatos detalhados que revelam a lógica por trás das ações do usuário. Por exemplo, um usuário pode dizer: "Eu evito usar a função X porque ela me parece confusa e não sei se meus dados estão seguros." Esse tipo de dado ajuda a entender problemas reais e necessidades ocultas.

#### Quando usar pesquisa qualitativa

- Ao explorar um problema ainda pouco conhecido
- Para descobrir necessidades, desejos e frustrações dos usuários
- Para validar hipóteses iniciais do design
- Para obter insights que não seriam captados com números

### Pesquisa quantitativa: o que é e para que serve?

Pesquisa quantitativa foca no **"quanto"**, "com que frequência" ou "quão grande" um fenômeno acontece. Ela trata de dados numéricos que podem ser medidos e analisados estatisticamente. Seu objetivo é quantificar comportamentos, preferências e características do usuário.

#### Exemplos comuns de pesquisa quantitativa

- Questionários com perguntas fechadas (sim/não, múltipla escolha)
- Análise de métricas de uso (como tempo em tela, cliques, taxas de conversão)
- Testes A/B
- Análise de logs e dados de uso

#### O que acontece por baixo

Ao aplicar um questionário que pergunta “Com que frequência você usa a função Y?”, você está recolhendo dados que podem ser organizados em gráficos e usados para identificar padrões gerais. Por exemplo, se 70% dos usuários respondem que usam a função Y diariamente, isso confirma sua importância.

#### Quando usar pesquisa quantitativa

- Para validar hipóteses com uma amostra maior
- Para medir a extensão de um comportamento
- Para comparar grupos ou mudanças antes e depois de uma alteração
- Para apoiar decisões com dados objetivos e mensuráveis

### Comparando qualitativa e quantitativa: quando usar cada uma?

| Aspecto                 | Pesquisa Qualitativa                            | Pesquisa Quantitativa                         |
|------------------------|------------------------------------------------|----------------------------------------------|
| Tipo de dado           | Descritivo, textual, subjetivo                  | Numérico, mensurável, objetivo                |
| Amostra                | Pequena, focada em profundidade                 | Grande, focada em representatividade          |
| Objetivo               | Explorar motivos, sentimentos e contextos       | Medir comportamento, frequência e proporções  |
| Tipos de perguntas     | "Como?", "Por quê?", "O que você sente?"        | "Quantos?", "Com que frequência?", "Qual a nota?" |
| Análise                | Interpretação, categorização, identificação de padrões | Estatística, gráficos, comparações            |
| Aplicação típica       | Entrevistas, observação, grupos focais          | Surveys, testes A/B, análise de métricas       |

### Erro comum: tentar usar quantitativa para tudo

Muitos desenvolvedores já acostumados com dados digitais tentam resolver todos os problemas com números, como se uma planilha fosse suficiente para entender o usuário. Isso pode levar a conclusões erradas, pois dados quantitativos não explicam o motivo por trás do comportamento. Por exemplo, saber que 50% abandonam um formulário não diz *por que* isso acontece.

### Erro comum: confiar só na pesquisa qualitativa

Por outro lado, focar só em relatos e entrevistas pode gerar um viés, pois a amostra é pequena e não necessariamente representativa. Você pode acabar criando um design baseado em opiniões de poucos usuários, que não refletem o comportamento da maioria.

### Exemplo prático: pesquisa para um app de receitas

Imagine que você quer melhorar a tela inicial de um app de receitas. Você faz:

- **Pesquisa qualitativa**: entrevista 5 usuários sobre como escolhem receitas, o que os frustra, o que gostam. Descobre que muitos se sentem perdidos com excesso de opções e preferem filtros por tempo de preparo.
- **Pesquisa quantitativa**: envia um questionário para 200 usuários perguntando quais filtros usam mais. Recebe dados que mostram 60% usam filtro por tempo, 30% por tipo de comida, 10% nunca usam filtro.

Combinando os dois, você entende o problema (qualitativo) e sabe a proporção dos usuários afetados (quantitativo). Assim, pode priorizar melhorar o filtro por tempo, que é o mais usado.

---

## Código completo: exemplo de análise quantitativa simples em Python

Vamos simular uma análise quantitativa básica com dados fictícios de um survey onde usuários indicam a frequência de uso de uma função (diariamente, semanalmente, raramente).

```python
import matplotlib.pyplot as plt

# Dados fictícios: número de usuários por categoria de uso
dados_uso = {
    "Diariamente": 140,
    "Semanalmente": 50,
    "Raramente": 20,
    "Nunca": 10
}

# Total de usuários
total = sum(dados_uso.values())

# Calcula percentual de cada categoria
percentuais = {k: v / total * 100 for k, v in dados_uso.items()}

# Imprime resultados
print("Frequência de uso da função X:")
for categoria, percentual in percentuais.items():
    print(f"{categoria}: {percentual:.1f}%")

# Gráfico de pizza
plt.figure(figsize=(6, 6))
plt.pie(dados_uso.values(), labels=dados_uso.keys(), autopct='%1.1f%%', startangle=140)
plt.title("Frequência de uso da função X")
plt.show()
```

Saída no terminal:

```
Frequência de uso da função X:
Diariamente: 63.6%
Semanalmente: 22.7%
Raramente: 9.1%
Nunca: 4.5%
```

E o gráfico mostra visualmente a distribuição, ajudando a comunicar os dados.

---

## Exercício

Você está desenvolvendo um app de leitura digital e quer entender por que alguns usuários abandonam o app logo após o primeiro acesso. Para isso, imagine que pode fazer:

- Uma entrevista com 5 usuários que abandonaram o app.
- Um questionário online com 100 usuários para saber quantos abandonaram e com que frequência usam o app.

**Perguntas:**

1. Qual tipo de pesquisa (qualitativa ou quantitativa) cada uma dessas ações representa?
2. Qual informação você espera obter de cada uma?
3. Por que usar ambas as pesquisas ajuda a entender melhor o problema?

---

## Solução comentada

1. A entrevista com 5 usuários é pesquisa qualitativa: você busca entender os motivos, sentimentos e contextos que levaram ao abandono.
2. O questionário com 100 usuários é pesquisa quantitativa: você mede a frequência de abandono e padrões gerais de uso.
3. Usar ambas permite identificar o problema em profundidade (qualitativa) e quantificar sua extensão e impacto (quantitativa), garantindo decisões de design mais embasadas e eficazes.

---