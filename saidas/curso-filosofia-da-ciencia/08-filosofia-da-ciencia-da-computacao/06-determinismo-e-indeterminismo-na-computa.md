## Determinismo e Indeterminismo na Computação

Um programa que sempre produz a mesma saída para a mesma entrada parece óbvio — até você encontrar um sistema que se comporta de forma diferente a cada execução. Considere este código Python que simula um jogo de dados:

```python
import random

def lancar_dado():
    return random.randint(1, 6)

print(lancar_dado())  # Pode ser 3
print(lancar_dado())  # Pode ser 5
```

Executando repetidamente, obtemos saídas variáveis:
```
4
1
```
E na próxima execução:
```
2
6
```

Aqui está o paradoxo: o código é deterministicamente o mesmo (nenhum bit mudou), mas os resultados divergem. O `random` do Python usa o relógio do sistema como semente — um fator externo ao programa. Isso ilustra o primeiro nível do debate: sistemas computacionais podem ser **determinísticos em teoria** (mesmo algoritmo) mas **indeterminísticos na prática** (dependência de estados externos).

A computação clássica opera sob o paradigma determinista de Church-Turing: dada uma máquina de Turing e seu estado atual, o próximo estado é univocamente determinado. Porém, a implementação física introduz ruídos:

```python
# Simulação de erro de hardware
def operacao_risco():
    if random.random() < 0.001:  # 0.1% de chance de falha
        return "ERRO"
    return 42

print(operacao_risco())  # Normalmente 42, mas...
```

Saída em 999 de 1000 casos:
```
42
```

E no caso raro:
```
ERRO
```

Este comportamento levou à distinção crucial:
- **Determinismo algorítmico**: o modelo abstrato é previsível (sempre 42 no código acima)
- **Indeterminismo físico**: a implementação real pode falhar (o "ERRO" ocasional)

Quando programadores ignoram essa diferença, surgem bugs difíceis de reproduzir:

```python
# Exemplo de bug não determinístico
cache = {}

def calcular(id, x):
    if id not in cache:
        # Simulação de processamento demorado
        resultado = x * 2
        cache[id] = resultado
        return resultado
    return cache[id]

# Thread 1: calcular(1, 21) → 42
# Thread 2: calcular(1, 22) → 44 ou 42?
```

A saída depende da ordem de execução das threads — uma **condição de corrida** clássica. O sistema é deterministico em nível microscópico (cada thread segue regras fixas), mas macroscopicamente imprevisível.

Na fronteira com a física, a computação quântica desafia ainda mais o determinismo. Um qubit em superposição:

```python
# Simulação simplificada de qubit
from qiskit import QuantumCircuit, Aer, execute

qc = QuantumCircuit(1, 1)
qc.h(0)  # Porta Hadamard cria superposição
qc.measure(0, 0)

backend = Aer.get_backend('qasm_simulator')
result = execute(qc, backend, shots=10).result()
print(result.get_counts())  # Exemplo: {'0': 5, '1': 5}
```

Saída típica (varia a cada execução):
```
{'0': 4, '1': 6}
```

Aqui, o indeterminismo não é um defeito, mas uma propriedade fundamental. A mesma operação gera resultados estatisticamente distribuídos — uma ruptura radical com o determinismo clássico.

**Exercício**: Modifique o primeiro exemplo de dados para usar uma semente fixa (`random.seed(42)`). Execute várias vezes e observe o efeito. Depois, comente a linha de seed e compare.

**Solução**:
```python
random.seed(42)  # Fixa a semente
print(lancar_dado())  # Sempre 4
print(lancar_dado())  # Sempre 2

# random.seed(42)  # Descomente para ver o padrão repetir
```
Com seed fixo, o "aleatório" é na verdade determinístico — uma sequência pseudoaleatória reproduzível. Isso revela que até a aleatoriedade em computação é, em última análise, um determinismo disfarçado.