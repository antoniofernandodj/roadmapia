## Leis da Computação

Um programa que ordena uma lista de números parece uma criação humana arbitrária — até você tentar fazê-lo rodar em uma máquina com 1KB de memória. De repente, certas escolhas algorítmicas deixam de ser opções para se tornarem impossibilidades físicas. Isso revela o cerne das leis da computação: não são regras inventadas, mas limites descobertos sobre o que pode ou não ser computado, independentemente da tecnologia usada.

Considere o problema de ordenação. Implementamos um *bubble sort* em Python:

```python
def bubble_sort(lista):
    n = len(lista)
    for i in range(n):
        for j in range(0, n-i-1):
            if lista[j] > lista[j+1]:
                lista[j], lista[j+1] = lista[j+1], lista[j]
    return lista

print(bubble_sort([64, 34, 25, 12, 22, 11, 90]))
```

Saída:
```
[11, 12, 22, 25, 34, 64, 90]
```

Agora aumentamos a lista para 10.000 elementos. O tempo de execução dispara porque o algoritmo tem complexidade O(n²) — uma lei computacional que não depende da linguagem, mas da natureza do problema. Mesmo usando supercomputadores, esse crescimento quadrático permanece como uma barreira intrínseca.

A tentativa de ignorar essas leis gera erros característicos. Ao modificar o algoritmo para supostamente "melhorá-lo" sem entender sua estrutura:

```python
def pseudo_otimizado(lista):
    n = len(lista)
    for i in range(n):
        if all(lista[j] <= lista[j+1] for j in range(n-1)):
            break
        for j in range(0, n-i-1):
            if lista[j] > lista[j+1]:
                lista[j], lista[j+1] = lista[j+1], lista[j]
    return lista
```

O resultado é uma mensagem de erro:
```
RecursionError: maximum recursion depth exceeded in comparison
```

As leis mais fundamentais emergem quando comparamos modelos de computação. A Tese de Church-Turing estabelece que todas as formulações razoáveis de computabilidade são equivalentes — seja com máquinas de Turing, funções recursivas ou cálculo lambda. Isso não é uma coincidência, mas uma descoberta sobre a natureza da informação:

```python
# Dois modelos computacionais resolvendo o mesmo problema
def turing_sum(a, b):
    # Simula operação de máquina de Turing
    return a + b  # Operação atômica na máquina

def church_sum(a, b):
    # Abstração no cálculo lambda
    return (lambda f: lambda x: f(a)(f(b)(x)))(lambda n: lambda m: n + m)
```

Ambos produzem o mesmo resultado (`church_sum(2,3)` e `turing_sum(2,3)` retornam 5), ilustrando a equivalência entre modelos distintos.

O exercício final mostra como leis computacionais afetam decisões práticas. Implemente uma função que verifica se um número é primo, primeiro de forma ingênua (O(n)), depois otimizada (O(√n)). Meça o tempo de execução para n=10.000.000 e discuta por que a segunda versão não é apenas "melhor", mas a única viável dentro das leis da complexidade algorítmica.

```python
import math
import time

def primo_ingenuo(n):
    if n <= 1:
        return False
    for i in range(2, n):
        if n % i == 0:
            return False
    return True

def primo_otimizado(n):
    if n <= 1:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

inicio = time.time()
primo_otimizado(10_000_019)
fim = time.time()
print(f"Otimizado: {fim - inicio:.5f} segundos")
```