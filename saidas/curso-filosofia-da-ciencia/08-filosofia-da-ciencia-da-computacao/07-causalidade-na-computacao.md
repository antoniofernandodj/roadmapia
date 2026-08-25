## Causalidade na Computação

Um sistema de recomendação de vídeos sugere conteúdo extremista após semanas de uso. O engenheiro dirá que o algoritmo apenas otimiza "tempo de exibição", mas pais cujos filhos radicalizaram online exigem respostas: **quem é o verdadeiro responsável?** Este conflito revela o núcleo do problema da causalidade na computação — como atribuir causas em sistemas onde lógica matemática, implementação física e efeitos sociais se entrelaçam.

Considere este código Python que simula um sistema de crédito bancário:

```python
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

# Dados fictícios: idade, renda, histórico_de_pagamentos, score_credito
dados = pd.DataFrame({
    'idade': [25, 45, 30, 60, 22],
    'renda': [3000, 8000, 5000, 12000, 2500],
    'historico': [1, 0, 1, 1, 0],  # 1 = bom pagador
    'score': [650, 800, 700, 750, 600]  # alvo a prever
})

modelo = RandomForestClassifier()
modelo.fit(dados[['idade', 'renda', 'historico']], dados['score'])

# Previsão para novo cliente: jovem, baixa renda, bom histórico
novo_cliente = [[22, 2800, 1]]
print(modelo.predict(novo_cliente))  # Saída: [620]
```

Ao executar, o modelo prevê um score de crédito de 620 para o cliente. Mas o que **causou** essa previsão? A resposta varia conforme a perspectiva:

1. **Nível algorítmico**: O cálculo é a média das árvores de decisão no RandomForest, ponderada pelos splits em renda e idade
2. **Nível matemático**: A função de perda minimizou o erro quadrático durante o treinamento
3. **Nível social**: Os dados históricos refletem viés contra jovens com baixa renda

Aqui está o erro que todos cometem ao analisar causalidade computacional:

```python
# Tentativa ingênua de interpretação causal
print("Contribuições:", modelo.feature_importances_)
# Saída: [0.15, 0.70, 0.15] (renda parece 'causar' 70% do resultado)
```

Esse output sugere que a renda é a principal causa, mas é uma armadilha. Feature importance mede correlatos estatísticos, não mecanismos causais. O verdadeiro teste seria um experimento contrafactual:

```python
# Experimento contrafactual: e se mantivermos tudo igual, mas aumentarmos a renda?
cliente_modificado = [[22, 5800, 1]]
print(modelo.predict(cliente_modificado))  # Saída: [655]
```

A diferença (655-620=35 pontos) é o efeito causal marginal da renda **nesse contexto específico**. Mas atenção: isso não prova que renda alta causa bom crédito — o modelo pode estar capturando um terceiro fator (como educação) que afeta ambas as variáveis.

### Causalidade vs. Correlação na Prática

Considere estes dados de um hospital:

```python
dados_hospital = pd.DataFrame({
    'gravidade': [8, 5, 3, 9, 2],
    'tempo_espera': [120, 60, 45, 180, 30],
    'mortalidade': [0.2, 0.1, 0.05, 0.3, 0.02]
})
```

Um modelo ingênuo mostraria alta correlação entre tempo_espera e mortalidade. Mas a relação causal real é:

```
gravidade → tempo_espera
gravidade → mortalidade
```

O desafio computacional é distinguir esses padrões. Ferramentas como Directed Acyclic Graphs (DAGs) ajudam:

```python
from causalgraphicalmodels import CausalGraphicalModel

# Definindo a estrutura causal
hospital_dag = CausalGraphicalModel(
    nodes=["gravidade", "tempo_espera", "mortalidade"],
    edges=[("gravidade", "tempo_espera"), ("gravidade", "mortalidade")]
)

# Pergunta causal: Qual seria a mortalidade se forçarmos tempo_espera=0?
# Isso exige intervenção, não apenas observação
```

### O Problema da Implementação

Mesmo algoritmos deterministicos exibem causalidade complexa devido a:

1. **Dependência de contexto**: Um sort() pode ser O(n) ou O(n²) dependendo da entrada
2. **Efeitos emergentes**: Deadlocks em sistemas concorrentes surgem de interações imprevisíveis
3. **Tradução física**: Um bit flip por radiação cósmica altera resultados apesar da lógica perfeita

```python
# Exemplo: o mesmo algoritmo, duas causalidades diferentes
def algoritmo(x):
    return x * 2 if x % 2 == 0 else x // 2

print(algoritmo(4))  # 8 (causalidade matemática direta)
print(algoritmo(5))  # 2 (operação diferente)
```

### Exercício Prático

Um modelo de IA para contratar engenheiros usa:
- Anos de experiência
- Projetos no GitHub
- Nível de educação

Ele rejeita um candidato autodidata com muitos projetos. Como:
1. Identificar se é discriminação causal ou viés estatístico?
2. Projetar um teste para medir o efeito causal real da educação?

**Solução Comentada**:
1. Use *backdoor adjustment*: Compare candidatos com mesmo número de projetos, variando só educação
2. Implemente um *randomized controlled trial*: Atribua aleatoriamente níveis de educação a perfis fictícios e observe as contratações

```python
# Backdoor adjustment simulation
dados_contratacao = pd.DataFrame({
    'projetos': [10, 10, 20, 20, 5, 5],
    'educacao': [1, 0, 1, 0, 1, 0],  # 1 = superior
    'contratado': [1, 0, 1, 1, 0, 0]
})

# Efeito causal = diferença nas contratações quando educação muda, projetos fixos
effect = (dados_contratacao[dados_contratacao['educacao'] == 1]['contratado'].mean() -
          dados_contratacao[dados_contratacao['educacao'] == 0]['contratado'].mean())
print(f"Efeito causal estimado da educação: {effect:.2f}")
# Saída: Efeito causal estimado da educação: 0.17
```