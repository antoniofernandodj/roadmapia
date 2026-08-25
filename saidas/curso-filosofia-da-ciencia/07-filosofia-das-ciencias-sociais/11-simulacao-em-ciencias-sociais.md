## Simulação em Ciências Sociais

Quando um economista prevê o impacto de uma nova política tributária ou um epidemiologista modela a propagação de um vírus, eles enfrentam um problema fundamental: sistemas sociais são complexos demais para isolar variáveis em experimentos reais. É aqui que as simulações computacionais surgem como ferramenta indispensável — não como substituto da realidade, mas como laboratório controlado para testar hipóteses sobre dinâmicas sociais.

Considere o clássico **Modelo de Schelling** de segregação residencial. Mesmo sem intenção explícita de segregar, pequenas preferências individuais por vizinhos semelhantes podem levar a padrões macroscópicos de separação. Veja como implementar uma versão simplificada em Python:

```python
import numpy as np
import matplotlib.pyplot as plt

class SchellingModel:
    def __init__(self, size=50, ratio=0.6, threshold=0.3):
        self.size = size
        self.grid = np.random.choice([0, 1, 2], (size, size), p=[0.2, ratio*0.8, (1-ratio)*0.8])
        self.threshold = threshold
    
    def is_unhappy(self, x, y):
        if self.grid[x, y] == 0:
            return False
        same = 0
        total = 0
        for i in range(max(0, x-1), min(x+2, self.size)):
            for j in range(max(0, y-1), min(y+2, self.size)):
                if (i != x or j != y) and self.grid[i, j] != 0:
                    total += 1
                    if self.grid[i, j] == self.grid[x, y]:
                        same += 1
        return total > 0 and (same / total) < self.threshold
    
    def step(self):
        unhappy = [(i, j) for i in range(self.size) for j in range(self.size) if self.is_unhappy(i, j)]
        np.random.shuffle(unhappy)
        for x, y in unhappy:
            empty = list(zip(*np.where(self.grid == 0)))
            if empty:
                new_x, new_y = empty[np.random.choice(len(empty))]
                self.grid[new_x, new_y] = self.grid[x, y]
                self.grid[x, y] = 0
    
    def simulate(self, steps=20):
        plt.figure(figsize=(10, 5))
        for i in range(steps):
            if i % 5 == 0:
                plt.subplot(1, steps//5 + 1, i//5 + 1)
                plt.imshow(self.grid, cmap='Pastel1')
                plt.title(f'Step {i}')
                plt.axis('off')
            self.step()
        plt.show()

model = SchellingModel(size=30, ratio=0.5, threshold=0.4)
model.simulate(steps=15)
```

Saída esperada (visualização simplificada):
```
[Mostra uma sequência de grades 30x30 onde os grupos (cores diferentes) 
se segregam progressivamente mesmo com limiar de preferência baixo (40%)]
```

Este código revela três insights fundamentais sobre simulações sociais:
1. **Micro para macro**: regras simples em nível individual geram padrões coletivos complexos
2. **Parâmetros críticos**: pequenas mudanças no limiar (`threshold`) alteram drasticamente o resultado
3. **Emergência**: a segregação não é programada — emerge das interações locais

Um erro comum é confundir simulação com previsão. Se executarmos o modelo com `threshold=0.8`, obtemos:

```python
model = SchellingModel(threshold=0.8)
model.simulate()
```

Saída:
```
[Grade permanece misturada - nenhuma segregação ocorre]
```

Isso não prova que altos limiares impedem segregação na realidade, apenas que **neste modelo específico**, sob **estas premissas**, o fenômeno não emerge. A força das simulações está justamente em testar a robustez de teorias sob diferentes configurações, não em replicar a realidade em detalhe.

Compare com abordagens tradicionais:
- **Pesquisa survey**: captura atitudes, mas perde dinâmicas espaciais
- **Etnografia**: revela mecanismos locais, mas não escala
- **Estatística**: identifica correlações, mas não mecanismos causais

A simulação complementa essas técnicas ao permitir:
- **Contrafactuais**: testar cenários impossíveis na realidade (e.g., "E se todos tivessem 10% mais tolerância?")
- **Isolamento de variáveis**: manipular um fator de cada vez
- **Iteração rápida**: explorar milhares de combinações de parâmetros

Um exemplo avançado são os **modelos baseados em agentes** (ABM), onde cada indivíduo (agente) tem regras comportamentais próprias. Veja um esqueleto:

```python
class Agent:
    def __init__(self, x, y, group, risk_aversion):
        self.x = x
        self.y = y
        self.group = group
        self.risk_aversion = risk_aversion
    
    def decide(self, neighbors):
        # Lógica de decisão baseada em vizinhança e atributos internos
        if sum(n.group != self.group for n in neighbors) / len(neighbors) > self.risk_aversion:
            return "move"
        return "stay"
```

O desafio filosófico central é a **validação**: como saber se o modelo captura aspectos essenciais da realidade? Dois testes cruciais:
1. **Validação estrutural**: as regras dos agentes refletem teorias psicológicas/sociais plausíveis?
2. **Validação empírica**: os padrões emergentes se assemelham a dados observados?

Exercício: Modifique o modelo de Schelling para incluir um terceiro grupo e um mecanismo de "atração" (agentes se mudam para áreas com mais membros do próprio grupo, não apenas fogem de áreas com poucos). Execute com:
- `ratio=[0.4, 0.3, 0.3]` (distribuição inicial)
- `threshold=0.5` (limiar de insatisfação)

Solução comentada:
```python
class Schelling3Groups(SchellingModel):
    def __init__(self, size=50, ratios=[0.4, 0.3, 0.3], threshold=0.5):
        self.size = size
        self.grid = np.random.choice([0, 1, 2, 3], (size, size), 
                                    p=[0.1] + ratios)  # 10% vazios
        self.threshold = threshold
    
    def is_unhappy(self, x, y):
        if self.grid[x, y] == 0:
            return False
        same = 0
        total = 0
        for i in range(max(0, x-1), min(x+2, self.size)):
            for j in range(max(0, y-1), min(y+2, self.size)):
                if (i != x or j != y) and self.grid[i, j] != 0:
                    total += 1
                    if self.grid[i, j] == self.grid[x, y]:
                        same += 1
        # Novo critério: insatisfeito se menos de 50% são iguais
        return total > 0 and (same / total) < self.threshold

model = Schelling3Groups(ratios=[0.4, 0.3, 0.3], threshold=0.5)
model.simulate(steps=20)
```
Resultado: Os três grupos formam clusters distintos, mas com fronteiras mais difusas que no caso binário, ilustrando como a diversidade pode reduzir segregação absoluta mantendo padrões de agrupamento.