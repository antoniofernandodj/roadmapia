## Computação e Matemática

Um algoritmo de ordenação parece pura matemática até você executá-lo em dados reais. Considere o `quicksort`, celebrado por sua eficiência teórica O(n log n):

```python
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr)//2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)

# Teste com dados reais
dados = [3, 6, 8, 10, 1, 2, 1, 0.5, 2.718, 3.1415]
print(quicksort(dados))
```

Saída:
```
[0.5, 1, 1, 2, 2.718, 3, 3.1415, 6, 8, 10]
```

A matemática garante que o algoritmo termina e produz a saída correta para qualquer entrada finita. Mas tente executá-lo em uma lista com 10.000 elementos já ordenados:

```python
dados_ordenados = list(range(10000))
quicksort(dados_ordenados)  # RecursionError: maximum recursion depth exceeded
```

A implementação ingênua falha porque a profundidade recursiva atinge o limite do interpretador Python (~1000 chamadas). A matemática pura não prevê esse colapso - ele surge na intersecção entre o modelo abstrato e as limitações físicas da máquina.

Esse fosso aparece em três níveis:

1. **Precisão Numérica**: Números reais na matemática versus ponto flutuante IEEE 754. A equação (0.1 + 0.2) == 0.3 é verdadeira matematicamente, mas falsa computacionalmente devido a arredondamentos binários.

2. **Complexidade Assintótica vs. Real**: Um algoritmo O(n²) pode ser mais rápido que um O(n) para pequenos conjuntos de dados, pois as constantes ocultas importam na prática.

3. **Indecidibilidade**: O Teorema de Rice prova que nenhum programa pode determinar propriedades não-triviais de outros programas. Isso limita o que podemos automatizar na análise de código.

A relação entre computação e matemática é uma ponte de mão dupla. Enquanto a computação implementa estruturas matemáticas, ela também revela novos problemas filosóficos:

- **Ontologia de Objetos Computacionais**: Um grafo existe como conceito matemático, mas sua representação em memória (lista de adjacências vs. matriz) afeta seu comportamento observável.

- **Epistemologia de Algoritmos**: O conhecimento matemático sobre um algoritmo (e.g., correção do Dijkstra) difere do conhecimento empírico obtido através de benchmarks.

- **Semântica Operacional**: A equivalência lambda-cálculo (matemática) versus redução eager/lazy (implementação) mostra como a mesma teoria pode gerar comportamentos díspares.

Exercício: Implemente uma função que calcule a sequência de Fibonacci usando a fórmula fechada (Binet):

```python
import math

def fib_binet(n):
    phi = (1 + math.sqrt(5)) / 2
    return round((phi**n - (-phi)**(-n)) / math.sqrt(5))

# Teste para n=100
print(fib_binet(100))  # 354224848179263111168 (incorreto para n > 70)
```

A saída para n=100 está errada devido a erros de arredondamento em ponto flutuante. A solução matemática exata (usando aritmética simbólica) exigiria uma implementação radicalmente diferente, demonstrando como a matemática contínua e a computação discreta divergem.