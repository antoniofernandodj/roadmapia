## Modelos em Computação

Um motorista de aplicativo tenta prever quanto tempo levará de um ponto a outro na cidade. O GPS mostra um trajeto com estimativa de 15 minutos, mas ele sabe que naquela região há sempre congestionamento às 18h. Seu cérebro cria um modelo mental: "tempo oficial + 30% no horário de pico". Essa é a essência de um modelo computacional — uma representação simplificada da realidade que nos permite fazer previsões e tomar decisões.

Na computação, modelos são estruturas formais que capturam aspectos relevantes de um sistema real para análise e manipulação. Considere este trecho Python que modela o crescimento de uma população de bactérias:

```python
def crescimento_bacteriano(populacao_inicial, geracoes, taxa):
    populacao = populacao_inicial
    for _ in range(geracoes):
        populacao *= taxa
    return populacao

# Testando o modelo
print(crescimento_bacteriano(100, 3, 1.5))  # Saída: 337.5
```

Esse modelo assume que:
1. Cada bactéria se reproduz a cada geração
2. A taxa de crescimento é constante
3. Não há limitação de recursos
4. Não ocorrem mortes

A saída 337.5 é matematicamente correta, mas biologicamente ingênua. Na prática, os recursos são finitos, e o crescimento eventualmente estabiliza. Esse é o erro clássico de confundir o modelo com a realidade. O modelo exponencial só é válido em condições ideais — um insight que vale para todos os modelos computacionais.

Quando tentamos usar o mesmo modelo para 100 gerações, obtemos um número astronômico (3.6835915e+17), mostrando como modelos simples podem gerar previsões absurdas se aplicados fora de seu escopo. A mensagem de erro aqui não vem do código, mas do descompasso entre modelo e realidade.

Modelos mais sofisticados incorporam restrições. O modelo logístico adiciona uma capacidade máxima (K) ao ambiente:

```python
def crescimento_logistico(populacao_inicial, geracoes, taxa, K):
    populacao = populacao_inicial
    for _ in range(geracoes):
        populacao = (populacao * taxa * (1 - populacao/K))
    return populacao

# Mesmos parâmetros, com capacidade máxima 1000
print(crescimento_logistico(100, 100, 1.5, 1000))  # Saída: 333.333
```

Agora a população converge para um valor estável (333), mais condizente com a realidade biológica. Esta versão do modelo captura melhor a dinâmica real, mas ainda faz simplificações — não considera variações sazonais, espécies concorrentes ou mutações genéticas.

O trade-off é evidente: modelos mais complexos são mais realistas, mas também mais difíceis de analisar e mais custosos computacionalmente. Um princípio fundamental na ciência da computação é o "minimalismo eficiente": o modelo mais simples que captura os aspectos relevantes para o problema em mãos.

Em machine learning, essa tensão aparece na diferença entre underfitting (modelo muito simples) e overfitting (modelo complexo demais). Um exemplo com regressão linear:

```python
import numpy as np
from sklearn.linear_model import LinearRegression

# Dados sintéticos: y = 1.5x + ruído
X = np.array([1, 2, 3, 4, 5]).reshape(-1, 1)
y = np.array([2, 2.8, 4.5, 5.1, 7.3])

modelo = LinearRegression()
modelo.fit(X, y)
print(f"Coeficiente: {modelo.coef_[0]:.2f}")  # Saída: ~1.5
```

Se tentarmos modelar relações não-lineares com uma reta (underfitting), o erro será alto. Se usarmos um polinômio de grau 10 para 5 pontos (overfitting), o modelo memorizará os dados em vez de aprender o padrão geral.

A arte da modelagem computacional está em:
1. Identificar quais aspectos da realidade são essenciais
2. Escolher abstrações adequadas para representá-los
3. Validar o modelo contra dados empíricos
4. Reconhecer os limites de aplicabilidade

Um exercício útil é modelar o movimento de um pêndulo simples. Primeiro, assumindo pequenos ângulos (modelo linear), depois para qualquer ângulo (modelo não-linear mais preciso). Comparar os resultados numéricos com o comportamento real mostra como diferentes níveis de abstração afetam a precisão das previsões.