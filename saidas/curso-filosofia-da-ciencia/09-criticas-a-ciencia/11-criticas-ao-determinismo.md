## Críticas ao Determinismo

Imagine um relógio cósmico onde cada evento futuro está rigidamente determinado por condições iniciais fixas — essa é a visão determinista clássica, que dominou a ciência desde Newton até o século XIX. O problema surge quando tentamos aplicar essa lógica a fenômenos como o decaimento radioativo de um átomo individual: mesmo sob condições idênticas, não podemos prever quando exatamente ele irá decair. Esse exemplo concreto da física quântica expõe a primeira grande crítica ao determinismo — a existência de processos intrinsecamente probabilísticos na natureza.

O determinismo laplaciano, formulado pelo matemático Pierre-Simon Laplace em 1814, afirmava que um intelecto suficientemente poderoso (o "demônio de Laplace") poderia calcular todo o futuro do universo conhecendo as posições e velocidades de todas as partículas em um instante. Esse modelo enfrenta três objeções fundamentais:

1. **Indeterminação quântica**: No experimento da dupla fenda, elétrons individuais não seguem trajetórias determinadas, mas mostram padrões de interferência mesmo quando disparados um por vez. A equação de Schrödinger fornece apenas probabilidades de localização, não posições exatas.

```python
# Simulação simplificada do padrão de interferência quântica
import numpy as np
import matplotlib.pyplot as plt

posições = np.random.normal(loc=0, scale=1, size=10000)  # Distribuição probabilística
plt.hist(posições, bins=50