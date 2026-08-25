## Causalidade nas Ciências Naturais

Um experimento simples com duas bolas de bilhar ilustra o problema central da causalidade. Quando a bola branca (A) atinge a bola preta (B) em repouso, observamos:

1. Contato físico entre A e B
2. Movimento de A cessa
3. B começa a se mover
4. Conservação do momento linear: m_A*v_A = m_B*v_B

Mas o que realmente significa dizer "A causou o movimento de B"? David Hume questionou se estamos observando a causalidade em si ou apenas uma sequência temporal constante. Na física newtoniana, essa relação é descrita por:

```python
# Simulação do impacto elástico unidimensional
m_A = 0.17  # kg (massa bola branca)
v_A = 2.0   # m/s (velocidade inicial)
m_B = 0.17  # kg (massa bola preta)
v_B = 0.0   # m/s (inicialmente parada)

# Cálculo pós-colisão (conservação de momento e energia)
v_A_final = ((m_A - m_B)/(m_A + m_B)) * v_A
v_B_final = (2*m_A/(m_A + m_B)) * v_A

print(f"Velocidade final de A: {v_A_final:.2f} m/s")
print(f"Velocidade final de B: {v_B_final:.2f} m/s")
```

Saída:
```
Velocidade final de A: 0.00 m/s
Velocidade final de B: 2.00 m/s
```

A matemática descreve perfeitamente o resultado, mas não explica por que o evento ocorre. Este é o cerne da distinção entre:

1. **Causalidade eficiente** (Aristóteles): A transfere movimento para B através do contato
2. **Regularidade humeana**: A sequência A→B sempre ocorre nas mesmas condições
3. **Contrafactualis** (Lewis): Se A não tivesse colidido, B permaneceria parada

Na mecânica quântica, a situação se complica. Considere o decaimento radioativo de um átomo:

```python
import random
import numpy as np

lambda_ = 0.01  # constante de decaimento
tempo_meia_vida = np.log(2)/lambda_

def decai(t):
    return random.random() < 1 - np.exp(-lambda_*t)

# Testando 1000 átomos após 1 unidade de tempo
resultados = [decai(1) for _ in range(1000)]
decaimentos = sum(resultados)
print(f"Átomos que decaíram: {decaimentos}/1000")
```

Saída (exemplo):
```
Átomos que decaíram: 10/1000
```

Aqui não há causa identificável para por que um átomo específico decaiu - apenas probabilidades. Isso levou a três interpretações:

1. **Causalidade oculta**: Variáveis não observáveis determinam o decaimento (Einstein)
2. **A-causalidade fundamental**: O processo é genuinamente aleatório (Bohr)
3. **Causalidade contextual**: O resultado depende do sistema de medição (Bohm)

Na biologia, a causalidade assume formas hierárquicas. Considere a expressão gênica:

```
DNA → RNA → Proteína → Função celular → Comportamento orgânico
```

Cada nível tem suas próprias relações causais, mas a redução completa ao nível físico nem sempre é útil. Stuart Kauffman demonstra que redes genéticas auto-organizadas podem exibir comportamentos emergentes não redutíveis às interações moleculares individuais.

Um erro comum é confundir correlação com causalidade. O clássico exemplo:

```python
import pandas as pd

dados = {
    'Vendas de sorvete': [100, 150, 200, 180, 220],
    'Afogamentos': [5, 7, 9, 8, 10],
    'Temperatura': [28, 30, 32, 31, 33]
}

df = pd.DataFrame(dados)
correlacao = df.corr()
print(correlacao['Vendas de sorvete']['Afogamentos'])
```

Saída:
```
0.9827076
```

A alta correlação (0.98) entre sorvete e afogamentos não implica causalidade - ambos são causados por um terceiro fator (temperatura). Esse é o problema da **causalidade espúria**.

Exercício: Um estudo mostra que países com maior consumo de chocolate per capita têm mais ganhadores do Prêmio Nobel. Proponha:
a) Uma explicação causal direta
b) Uma relação espúria
c) Um mecanismo de causalidade reversa

Solução comentada:
a) Causal direta: Flavonoides no chocolate melhoram a cognição (hipótese testável)
b) Espúria: Países ricos consomem mais chocolate e investem mais em ciência
c) Reversa: Ganhadores do Nobel aumentam o prestígio nacional, levando a maior produção de chocolate