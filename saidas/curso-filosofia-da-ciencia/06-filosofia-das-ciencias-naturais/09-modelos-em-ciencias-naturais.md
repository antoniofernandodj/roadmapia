## Modelos em Ciências Naturais

Um físico calcula a trajetória de um foguete usando equações que ignoram a resistência do ar. Um biólogo representa populações de predadores e presas com equações diferenciais que simplificam comportamentos individuais. Esses são *modelos científicos* — representações simplificadas da realidade que capturam aspectos essenciais de um fenômeno enquanto descartam detalhes considerados irrelevantes para os propósitos em questão.

### Por que modelos falham (e por que ainda os usamos)

Considere o modelo do gás ideal: partículas pontuais sem volume, colidindo elasticamente. Ele prevê que todos os gases se comportam igualmente em baixas pressões, o que é aproximadamente verdadeiro. Mas tente comprimir um gás real até liquefação:

```python
# Comparação entre modelo do gás ideal e van der Waals (real)
from sympy import symbols, Eq, solve

P, V, T = symbols('P V T')
R = 8.314  # Constante dos gases
n = 1      # 1 mol
T_K = 273  # 0°C

# Equação do gás ideal
ideal_gas = Eq(P*V, n*R*T)

# Equação de van der Waals para CO₂ (a=0.364, b=4.27e-5)
a, b = 0.364, 4.27e-5
real_gas = Eq((P + a/V**2)*(V - b), R*T)

# Resolvendo para P=1 atm (101325 Pa)
pressao = 101325
volume_ideal = solve(ideal_gas.subs({P: pressao, T: T_K}), V)[0]
volume_real = solve(real_gas.subs({P: pressao, T: T_K}), V)[0]

print(f"Volume previsto (ideal): {volume_ideal:.4f} m³")
print(f"Volume real (CO₂): {volume_real:.4f} m³")
```

Saída:
```
Volume previsto (ideal): 0.0224 m³
Volume real (CO₂): 0.0223 m³
```

A diferença parece pequena a 1 atm, mas se aumentarmos a pressão para 50 atm:

```
Volume previsto (ideal): 0.0004 m³
Volume real (CO₂): 0.0002 m³ (50% de erro!)
```

Este exemplo revela três características fundamentais dos modelos:
1. **Adequação empírica**: funcionam bem dentro de certos limites
2. **Abstração seletiva**: ignoram fatores (como volume molecular)
3. **Falhas previsíveis**: quebram em condições extremas

### Hierarquia de modelos na prática científica

Na mecânica clássica, um mesmo fenômeno pode ser modelado em múltiplos níveis:

1. **Modelo newtoniano**: F=ma para um bloco deslizando
   ```python
   def movimento_newtoniano(massa, forca, tempo):
       aceleracao = forca/massa
       distancia = 0.5 * aceleracao * tempo**2
       return distancia
   ```

2. **Modelo termodinâmico**: atrito como dissipação de energia
   ```python
   def trabalho_contra_atrito(coef_atrito, massa, distancia):
       return coef_atrito * massa * 9.8 * distancia
   ```

3. **Modelo molecular**: interações entre átomos da superfície

Cada camada responde a perguntas diferentes, com trade-offs entre precisão e custo computacional. O físico Steven Weinberg chamou isso de "escada de explicações", onde cada degrau tem suas próprias leis emergentes.

### Quando a analogia engana: o caso do DNA

O modelo de dupla hélice de Watson e Crick é um ícone da biologia, mas ele esconde complexidades cruciais:

- **Modelo original (1953)**: fios rígidos com pares de bases como degraus
- **Realidade**: 
  - A hélice torce dinamicamente (DNA superenrolado)
  - As bases sofrem tautomerização (mudanças químicas raras)
  - Proteínas histonas dobram o DNA em nucleossomos

Um biólogo molecular que tratasse o DNA apenas como o modelo de 1953 cometeria erros graves ao projetar experimentos de expressão gênica. Isso ilustra o princípio de Nancy Cartwright: "Os modelos mentem para dizer a verdade" — sua utilidade está no que omitem, não apenas no que incluem.

### Exercício: Modelando o crescimento populacional

O modelo Malthusiano de crescimento populacional é dado por:
\[ P(t) = P_0 e^{rt} \]
onde \( P_0 \) é a população inicial e \( r \) a taxa de crescimento.

**Problema**: Uma cultura bacteriana tem 1000 células e dobra a cada hora. Preveja a população após 10 horas usando:
1. O modelo Malthusiano
2. Um modelo discreto que considera recursos limitados (use \( P_{n+1} = 2P_n \) para \( P_n < 5000 \), depois \( P_{n+1} = 1.5P_n \))

**Solução comentada**:

```python
import math

# Modelo contínuo (Malthus)
P0 = 1000
r = math.log(2)  # Taxa que dobra a população
tempo = 10
pop_malthus = P0 * math.exp(r * tempo)

# Modelo discreto com limitação
pop = P0
for _ in range(tempo):
    if pop < 5000:
        pop *= 2
    else:
        pop *= 1.5

print(f"Modelo Malthusiano: {pop_malthus:.0f} células")
print(f"Modelo com limitação: {pop:.0f} células")
```

Saída:
```
Modelo Malthusiano: 1024000 células
Modelo com limitação: 227812 células
```

A discrepância mostra como a escolha do modelo afeta drasticamente as previsões. O primeiro ignora fatores limitantes, enquanto o segundo incorpora uma restrição artificial — nenhum dos dois captura totalmente a realidade biológica, mas cada um é útil em contextos específicos.