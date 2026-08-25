## Exercícios de Ciências Sociais

### Modelagem de Normas Sociais

Considere o seguinte cenário: você está estudando como normas sociais emergem e se mantêm em uma comunidade. Para isso, vamos usar um modelo computacional simples em Python que simula como indivíduos adotam comportamentos com base na influência de seus vizinhos.

```python
import numpy as np
import matplotlib.pyplot as plt

# Parâmetros do modelo
tamanho_populacao = 100
iteracoes = 100
probabilidade_adocao = 0.3

# Inicialização da população
populacao = np.random.choice([0, 1], tamanho_populacao, p=[0.5, 0.5])

# Função para atualizar a população
def atualizar_populacao(populacao):
    nova_populacao = populacao.copy()
    for i in range(tamanho_populacao):
        vizinhos = [populacao[(i-1) % tamanho_populacao], populacao[(i+1) % tamanho_populacao]]
        if np.random.random() < probabilidade_adocao:
            nova_populacao[i] = np.random.choice(vizinhos)
    return nova_populacao

# Simulação
historico = [populacao.copy()]
for _ in range(iteracoes):
    populacao = atualizar_populacao(populacao)
    historico.append(populacao.copy())

# Visualização
plt.figure(figsize=(10, 6))
plt.imshow(historico, cmap='binary', aspect='auto')
plt.xlabel('Indivíduo')
plt.ylabel('Iteração')
plt.title('Emergência de Normas Sociais')
plt.show()
```

**Saída Esperada:** O gráfico mostra como, ao longo das iterações, os indivíduos começam a adotar comportamentos similares, ilustrando a emergência de normas sociais.

### Exercício: Modificação do Modelo

1. **Alterar a Probabilidade de Adoção:** Modifique a variável `probabilidade_adocao` para valores mais altos e mais baixos. Observe como isso afeta a velocidade e a consistência da emergência das normas sociais.

2. **Introduzir Resistência à Mudança:** Adicione uma nova variável `resistencia` que determina a probabilidade de um indivíduo manter seu comportamento atual, independentemente da influência dos vizinhos. Como isso altera o resultado final?

3. **Simular Diferentes Tamanhos de População:** Experimente com diferentes valores de `tamanho_populacao`. Como o tamanho da comunidade afeta a estabilidade das normas sociais emergentes?

### Solução Comentada

1. **Alterar a Probabilidade de Adoção:** Quando a probabilidade de adoção é alta, as normas sociais emergem rapidamente, mas podem ser menos estáveis. Quando é baixa, a emergência é mais lenta, mas as normas tendem a ser mais consistentes.

2. **Introduzir Resistência à Mudança:** A resistência à mudança pode levar à coexistência de múltiplas normas sociais dentro da mesma comunidade, dependendo da distribuição inicial de comportamentos.

3. **Simular Diferentes Tamanhos de População:** Comunidades maiores tendem a ter normas sociais mais estáveis, mas também podem apresentar maior diversidade de comportamentos devido ao maior número de interações possíveis.

### Modelagem de Segregação Espacial

Outro fenômeno interessante é a segregação espacial, onde indivíduos de grupos diferentes tendem a se agrupar. Vamos usar o modelo de Schelling para simular esse processo.

```python
import numpy as np
import matplotlib.pyplot as plt

# Parâmetros do modelo
tamanho_grid = 50
densidade = 0.8
limiar_tolerancia = 0.3

# Inicialização do grid
grid = np.random.choice([0, 1, 2], (tamanho_grid, tamanho_grid), p=[1 - densidade, densidade/2, densidade/2])

# Função para calcular satisfação
def calcular_satisfacao(grid, i, j):
    tipo = grid[i, j]
    vizinhos = grid[max(i-1, 0):min(i+2, tamanho_grid), max(j-1, 0):min(j+2, tamanho_grid)]
    if tipo == 0:
        return 1
    similar = np.sum(vizinhos == tipo) - 1
    total = np.sum(vizinhos != 0) - 1
    return similar / total if total != 0 else 1

# Função para atualizar o grid
def atualizar_grid(grid):
    nova_grid = grid.copy()
    for i in range(tamanho_grid):
        for j in range(tamanho_grid):
            if calcular_satisfacao(grid, i, j) < limiar_tolerancia:
                nova_grid[i, j] = 0
                posicoes_vazias = np.argwhere(nova_grid == 0)
                if len(posicoes_vazias) > 0:
                    nova_posicao = posicoes_vazias[np.random.randint(len(posicoes_vazias))]
                    nova_grid[nova_posicao[0], nova_posicao[1]] = grid[i, j]
    return nova_grid

# Simulação
for _ in range(100):
    grid = atualizar_grid(grid)

# Visualização
plt.figure(figsize=(10, 10))
plt.imshow(grid, cmap='viridis')
plt.title('Segregação Espacial')
plt.show()
```

**Saída Esperada:** O gráfico mostra a formação de áreas segregadas, onde indivíduos de um mesmo tipo tendem a se agrupar.

### Exercício: Modificação do Modelo

1. **Alterar o Limiar de Tolerância:** Modifique a variável `limiar_tolerancia` para valores mais altos e mais baixos. Observe como isso afeta o grau de segregação.

2. **Introduzir um Terceiro Grupo:** Adicione um terceiro grupo ao modelo, representado pelo valor `3`. Como isso altera a dinâmica de segregação?

3. **Simular Diferentes Densidades:** Experimente com diferentes valores de `densidade`. Como a densidade da população afeta a formação de áreas segregadas?

### Solução Comentada

1. **Alterar o Limiar de Tolerância:** Um limiar de tolerância mais alto resulta em maior segregação, enquanto um limiar mais baixo permite maior integração entre os grupos.

2. **Introduzir um Terceiro Grupo:** A introdução de um terceiro grupo pode levar à formação de áreas mistas ou à criação de novos padrões de segregação, dependendo das preferências de cada grupo.

3. **Simular Diferentes Densidades:** Populações mais densas tendem a formar áreas segregadas mais rapidamente, enquanto populações menos densas podem apresentar padrões mais dispersos e menos definidos.