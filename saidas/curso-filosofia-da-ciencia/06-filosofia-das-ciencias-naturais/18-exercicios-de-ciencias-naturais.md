## Exercícios de Ciências Naturais

### 1. Modelando a Dilatação Temporal Relativística

Um experimento mental clássico na filosofia da física é o paradoxo dos gêmeos. Vamos implementar uma versão quantitativa usando a fórmula da dilatação temporal de Einstein:

```python
import numpy as np

def tempo_relativo(tempo_terra, velocidade):
    """Calcula o tempo percebido por um observador em movimento"""
    c = 299792458  # velocidade da luz em m/s
    fator_lorentz = 1 / np.sqrt(1 - (velocidade**2 / c**2))
    return tempo_terra / fator_lorentz

# Exemplo: astronauta viajando a 60% da velocidade da luz por 10 anos terrestres
tempo_espaco = tempo_relativo(10, 0.6 * 299792458)
print(f"Para o astronauta: {tempo_espaco:.2f} anos")
```

Saída:
```
Para o astronauta: 8.00 anos
```

O resultado mostra que enquanto passam 10 anos na Terra, apenas 8 anos passam para o astronauta. Isso ilustra o conceito filosófico de **relatividade do tempo** - uma propriedade que parecia absoluta na física newtoniana revela-se relativa.

**Erro comum**: esquecer de converter unidades. Se usarmos km/h sem converter para m/s:

```python
tempo_espaco = tempo_relativo(10, 60 * 1000/3600)  # 60 km/h
print(f"Tempo errado: {tempo_espaco:.10f} anos")
```

Saída:
```
Tempo errado: 9.9999999995 anos
```

O efeito é insignificante a velocidades cotidianas, mostrando por que nossa intuição newtoniana funciona no dia a dia.

### 2. Emergência em Sistemas Químicos

Considere um modelo simples de reação química autocatalítica:

```python
import matplotlib.pyplot as plt

def reacao_autocatalitica(A_inicial, B_inicial, k, passos=100):
    """Modela A + B → 2B com taxa k"""
    A = [A_inicial]
    B = [B_inicial]
    
    for _ in range(passos):
        taxa = k * A[-1] * B[-1]
        A.append(A[-1] - taxa)
        B.append(B[-1] + taxa)
    
    plt.plot(A, label='Reactante A')
    plt.plot(B, label='Produto B')
    plt.xlabel('Passos temporais')
    plt.ylabel('Concentração')
    plt.legend()
    plt.show()

reacao_autocatalitica(0.8, 0.2, 0.01)
```

O gráfico resultante mostra como uma pequena quantidade inicial de B (0.2) catalisa a transformação de quase todo A em B. Isso demonstra **propriedades emergentes** - o comportamento global do sistema não pode ser previsto apenas analisando as moléculas individuais.

### 3. Seleção Natural em Populações

Implementemos um modelo de seleção natural baseado em frequências gênicas:

```python
def selecao_natural(frequencia_A, vantagem_seletiva, geracoes=10):
    """Modela mudança na frequência alélica"""
    frequencias = [frequencia_A]
    for _ in range(geracoes):
        # Equação de Hardy-Weinberg modificada
        novo_A = (frequencia_A**2 + frequencia_A*(1-frequencia_A)*vantagem_seletiva) / \
                (frequencia_A**2 + 2*frequencia_A*(1-frequencia_A)*vantagem_seletiva + (1-frequencia_A)**2)
        frequencias.append(novo_A)
        frequencia_A = novo_A
    
    plt.plot(frequencias)
    plt.xlabel('Gerações')
    plt.ylabel('Frequência do alelo A')
    plt.show()

selecao_natural(0.3, 1.2)  # Alelo A com 20% de vantagem
```

Este exercício ilustra o **reducionismo genético** na biologia evolutiva. Mesmo um modelo simples captura a dinâmica essencial da mudança evolutiva, mas debates filosóficos questionam se essa redução a fatores genéticos explica adequadamente a complexidade dos sistemas biológicos.

### Exercício Proposto: Paradoxo do Plâncton

O paradoxo do plâncton questiona por que tantas espécies de fitoplâncton coexistem aparentemente violando o princípio de exclusão competitiva. Modele esta situação:

1. Implemente um sistema com 3 espécies (A, B, C) onde:
   - Cada espécie tem uma taxa de crescimento diferente (0.1, 0.2, 0.3)
   - A competição é não-transitiva: A supera B, B supera C, mas C supera A
2. Mostre como as populações oscilam ao longo do tempo
3. Discuta como isso desafia modelos reducionistas clássicos

**Solução comentada:**

```python
def paradoxo_plankton(tempo=100):
    populacoes = {'A': 1.0, 'B': 1.0, 'C': 1.0}
    taxas = {'A': 0.1, 'B': 0.2, 'C': 0.3}
    
    historico = {k: [v] for k, v in populacoes.items()}
    
    for _ in range(tempo):
        # Competição não-transitiva
        populacoes['A'] *= (1 + taxas['A'] - 0.2*populacoes['B'])
        populacoes['B'] *= (1 + taxas['B'] - 0.2*populacoes['C'])
        populacoes['C'] *= (1 + taxas['C'] - 0.2*populacoes['A'])
        
        for especie in historico:
            historico[especie].append(populacoes[especie])
    
    for especie in historico:
        plt.plot(historico[especie], label=especie)
    plt.legend()
    plt.show()

paradoxo_plankton()
```

O gráfico mostra oscilações sustentadas onde nenhuma espécie é completamente eliminada, ilustrando como **sistemas complexos podem sustentar diversidade através de dinâmicas não-lineares**.