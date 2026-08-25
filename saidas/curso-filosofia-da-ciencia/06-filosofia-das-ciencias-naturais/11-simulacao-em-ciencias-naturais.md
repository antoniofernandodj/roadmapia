## Simulação em Ciências Naturais

Quando um furacão se aproxima da costa, meteorologistas não podem testar diferentes cenários no mundo real. Em vez disso, rodam simulações computacionais que combinam equações fluidodinâmicas com dados observacionais. Esse é o poder das simulações em ciências naturais: permitem explorar sistemas complexos onde experimentos reais seriam impossíveis, caros ou antiéticos.

### O que torna uma simulação científica?

Considere este modelo simples de crescimento populacional:

```python
import matplotlib.pyplot as plt

def crescimento_populacional(p0, r, t):
    """Modelo Malthusiano: p0=população inicial, r=taxa, t=tempo"""
    return p0 * (1 + r)**t

# Parâmetros
anos = list(range(0, 50))
populacao = [crescimento_populacional(100, 0.1, t) for t in anos]

# Visualização
plt.plot(anos, populacao)
plt.xlabel('Anos')
plt.ylabel('População')
plt.title('Crescimento Exponencial')
plt.show()
```

A saída mostra uma curva exponencial ascendente - uma previsão que raramente se concretiza na natureza. O modelo falha porque:
1. Ignora recursos limitados
2. Desconsidera predação
3. Assume reprodução contínua

Este é o dilema central da simulação: todo modelo é necessariamente uma simplificação. A arte científica está em decidir quais simplificações são aceitáveis para o fenômeno estudado.

### Validação de Modelos

Um modelo climático que prevê aumento de 5°C na temperatura global até 2100 só tem valor se pudermos confiar em suas previsões. A validação ocorre em três níveis:

1. **Verificação**: O código implementa corretamente as equações? Teste unitário para a lei dos gases ideais:

```python
def pressao_ideal(n, V, T):
    R = 8.314  # Constante dos gases
    return n * R * T / V

# Teste conhecido: 1 mol a 273K em 22.4L deve dar 101.325 kPa
assert round(pressao_ideal(1, 0.0224, 273), 2) == 101.32
```

2. **Comparação com dados históricos**: O modelo reproduz padrões já observados? Por exemplo, simulações da formação lunar devem reproduzir a composição química atual da Lua.

3. **Previsão cega**: O modelo prevê fenômenos ainda não observados? A existência do bóson de Higgs foi prevista por simulações décadas antes de sua detecção experimental.

### Tipos de Simulação

1. **Baseadas em equações**: Resolvem sistemas de equações diferenciais. Exemplo: movimento planetário usando as leis de Newton:

```python
from scipy.integrate import odeint

def movimento_orbital(y, t):
    x, vx, y, vy = y
    r = (x**2 + y**2)**0.5
    dxdt = vx
    dvxdt = -x / r**3
    dydt = vy
    dvydt = -y / r**3
    return [dxdt, dvxdt, dydt, dvydt]

# Condições iniciais: Terra a 1 UA do Sol com velocidade orbital
y0 = [1, 0, 0, 6.28]  # Unidades astronômicas
tempo = np.linspace(0, 1, 1000)  # 1 ano
solucao = odeint(movimento_orbital, y0, tempo)
```

2. **Modelos baseados em agentes**: Simulam interações entre entidades autônomas. Exemplo: difusão de epidemias onde cada pessoa é um agente com regras de movimento e contágio.

3. **Métodos de Monte Carlo**: Usam aleatoriedade controlada. Em física nuclear, simulam o caminho aleatório de partículas através da matéria.

### Limitações Filosóficas

As simulações levantam questões profundas:
- **Realismo computacional**: Uma galáxia simulada é "real" em algum sentido?
- **Epistemologia da caixa preta**: Podemos confiar em modelos tão complexos que nenhum humano entende completamente todas as interações?
- **Problema da subdeterminação**: Diferentes modelos podem produzir resultados similares com premissas distintas. Como escolher entre eles?

O caso do modelo climático do MIT ilustra o desafio. Nas décadas de 1970-80, ele previu tanto resfriamento quanto aquecimento global, dependendo de como parametrizava a influência de aerossóis. A ciência precisou de 20 anos de dados adicionais para resolver a ambiguidade.

### Exercício Prático

Implemente um modelo de Lotka-Volterra para predador-presa:

```python
def lotka_volterra(z, t, alpha, beta, delta, gamma):
    x, y = z
    dxdt = alpha*x - beta*x*y
    dydt = delta*x*y - gamma*y
    return [dxdt, dydt]

# Parâmetros: α=natalidade presas, β=morte por predação, 
# δ=crescimento predadores, γ=morte predadores
params = (0.1, 0.02, 0.01, 0.1)
z0 = [40, 9]  # Populações iniciais
t = np.linspace(0, 200, 1000)

sol = odeint(lotka_volterra, z0, t, args=params)
```

**Solução Esperada**: O gráfico deve mostrar oscilações características, onde o aumento de predadores leva ao declínio de presas, que por sua vez causa declínio de predadores, permitindo a recuperação das presas.