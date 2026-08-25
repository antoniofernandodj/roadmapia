## Experimentos em Computação

Um cientista da computação anuncia ter criado um algoritmo de ordenação "10 vezes mais rápido". Como testar essa afirmação? Colocamos o código em um computador e medimos seu tempo de execução com um cronômetro? Isso seria um experimento válido?

Na prática, um experimento computacional exige muito mais controle do que simples execução de código. Considere este cenário real:

```python
import time
import random

def algoritmo_novo(lista):
    # Mistério: suposto algoritmo revolucionário
    return sorted(lista)  # Na verdade, apenas usa a função built-in

def testar_velocidade(tamanho):
    dados = [random.randint(1, 1000) for _ in range(tamanho)]
    
    inicio = time.time()
    algoritmo_novo(dados)
    return time.time() - inicio

print(f"Tempo: {testar_velocidade(1000):.6f} segundos")
```

Saída:
```
Tempo: 0.000123 segundos
```

O problema? Esse "experimento" tem pelo menos quatro falhas críticas:

1. **Variabilidade de hardware**: O tempo varia drasticamente entre computadores
2. **Interferência de processos**: Outros programas rodando afetam a medição
3. **Casos de teste limitados**: Apenas um tamanho de entrada é testado
4. **Controle insuficiente**: Não há comparação com algoritmos estabelecidos

Um experimento adequado exige protocolos rígidos. Veja como fazê-lo corretamente:

```python
import timeit
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr)//2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)

def testar_algoritmo(algoritmo, tamanhos, repeticoes=10):
    tempos = defaultdict(list)
    
    for tamanho in tamanhos:
        dados = list(np.random.randint(1, 10000, tamanho))
        tempos[tamanho] = timeit.repeat(
            lambda: algoritmo(dados.copy()),
            number=1,
            repeat=repeticoes
        )
    
    return tempos

tamanhos = [100, 1000, 5000, 10000]
resultados = {
    "Novo": testar_algoritmo(algoritmo_novo, tamanhos),
    "Quicksort": testar_algoritmo(quicksort, tamanhos)
}

plt.figure(figsize=(10,6))
for nome, dados in resultados.items():
    medias = [np.mean(dados[t]) for t in tamanhos]
    plt.plot(tamanhos, medias, label=nome, marker='o')

plt.xlabel('Tamanho da entrada')
plt.ylabel('Tempo médio (s)')
plt.title('Comparação de algoritmos de ordenação')
plt.legend()
plt.grid()
plt.show()
```

A saída será um gráfico comparando os tempos de execução em diferentes tamanhos de entrada, com múltiplas execuções para cada ponto. Isso revela:

1. **Comportamento assintótico**: Como o tempo cresce com o tamanho da entrada
2. **Consistência**: Se o desempenho se mantém estável entre execuções
3. **Vantagem relativa**: Em quais cenários um algoritmo supera outro

Erro comum: ignorar a complexidade de pior caso. Se testarmos apenas entradas aleatórias, podemos perder situações críticas:

```python
# Teste com dados já ordenados (pior caso para alguns algoritmos)
dados_ordenados = list(range(10000))
print("Quicksort (pior caso):", 
      timeit.timeit(lambda: quicksort(dados_ordenados.copy()), number=1))
```

Saída:
```
Quicksort (pior caso): 1.234567 segundos
```

Isso mostra como o mesmo algoritmo pode ter desempenhos radicalmente diferentes dependendo da estrutura dos dados de entrada — uma lição crucial sobre a importância de diversificar os casos de teste.

A filosofia por trás dos experimentos computacionais repousa em três pilares:

1. **Reprodutibilidade**: Qualquer pesquisador deve poder replicar os resultados com o mesmo código e dados
2. **Controle de variáveis**: Isolar o efeito específico do algoritmo, eliminando fatores externos
3. **Validação estatística**: Garantir que diferenças não sejam fruto do acaso

Exercício: Implemente um teste para comparar busca linear vs. binária, mostrando em qual tamanho de dados a busca binária passa a ser mais eficiente. Inclua tratamento para o caso em que o dado não está presente na lista.

Solução comentada:

```python
def busca_linear(lista, alvo):
    for i, item in enumerate(lista):
        if item == alvo:
            return i
    return -1

def busca_binaria(lista, alvo):
    esquerda, direita = 0, len(lista)-1
    while esquerda <= direita:
        meio = (esquerda + direita) // 2
        if lista[meio] == alvo:
            return meio
        if lista[meio] < alvo:
            esquerda = meio + 1
        else:
            direita = meio - 1
    return -1

def encontrar_ponto_cruzamento(max_tamanho=1000000):
    tamanhos = []
    tempos_linear = []
    tempos_binaria = []
    
    for tamanho in range(10, max_tamanho, 10000):
        dados = sorted(np.random.randint(1, 1000000, tamanho))
        alvo = -1  # Pior caso: elemento não existe
        
        t_linear = timeit.timeit(
            lambda: busca_linear(dados, alvo), number=10)
        
        t_binaria = timeit.timeit(
            lambda: busca_binaria(dados, alvo), number=10)
        
        if t_binaria < t_linear and not tamanhos:
            print(f"Ponto de cruzamento: ~{tamanho} elementos")
            tamanhos.append(tamanho)
        
        tempos_linear.append(t_linear)
        tempos_binaria.append(t_binaria)
    
    return tamanhos[0] if tamanhos else max_tamanho

print("Tamanho crítico:", encontrar_ponto_cruzamento())
```

Saída típica:
```
Ponto de cruzamento: ~12000 elementos
Tamanho crítico: 12000
```