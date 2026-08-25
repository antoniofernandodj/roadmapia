## Simulação e Computação

Quando Galileu estudou a queda dos corpos, precisou inclinar planos para reduzir a aceleração e medir tempos com relógios de água. Hoje, resolveríamos esse problema com uma simulação computacional em poucas linhas de código:

```python
import numpy as np
import matplotlib.pyplot as plt

# Parâmetros da simulação
g = 9.8  # aceleração gravitacional (m/s²)
θ = np.radians(30)  # ângulo de inclinação em radianos
a = g * np.sin(θ)  # aceleração ao longo do plano
tempo = np.linspace(0, 2, 100)  # 2 segundos de simulação

# Equação do movimento
posicao = 0.5 * a * tempo**2

plt.plot(tempo, posicao)
plt.xlabel('Tempo (s)')
plt.ylabel('Posição (m)')
plt.title('Queda em Plano Inclinado (30°)')
plt.grid()
plt.show()
```

A saída mostra exatamente o gráfico parabólico que Galileu deduziu, mas obtido em milissegundos, sem erros de medição humana. Esse é o poder transformador da simulação computacional na ciência contemporânea.

### O que é uma Simulação Científica?

Simulações são modelos computacionais dinâmicos que imitam sistemas reais através de algoritmos matemáticos. Diferentemente dos modelos estáticos (como equações no papel), elas permitem:

1. **Variação de parâmetros**: testar "e se?" rapidamente
2. **Visualização dinâmica**: ver a evolução temporal do sistema
3. **Complexidade manejável**: lidar com múltiplas variáveis simultaneamente

Considere este modelo populacional simplificado:

```python
def modelo_predador_presa(t, y, α, β, δ, γ):
    presas, predadores = y
    dydt = [
        α * presas - β * presas * predadores,  # Equação para presas
        δ * presas * predadores - γ * predadores  # Equação para predadores
    ]
    return dydt

# Parâmetros do modelo Lotka-Volterra
α = 1.1  # Taxa de crescimento das presas
β = 0.4  # Taxa de predação
δ = 0.1  # Taxa de conversão de presas em predadores
γ = 0.4  # Taxa de mortalidade dos predadores
```

Executar essa simulação revela ciclos oscilatórios que ecologistas levariam anos para observar na natureza.

### Validação e Limitações

Uma simulação só é útil se refletir a realidade. O erro mais comum é confiar cegamente nos resultados sem validação empírica. Veja este exemplo problemático:

```python
# Modelo de crescimento bacteriano INCOMPLETO
def crescimento_bacteriano(t, N0, k):
    return N0 * np.exp(k * t)  # Crescimento exponencial infinito?

# Testando com parâmetros irrealistas
tempo = np.linspace(0, 48, 100)  # 48 horas
populacao = crescimento_bacteriano(tempo, 1, 0.5)  # k=0.5/hora
```

A saída mostra uma população que cresce indefinidamente - biologicamente impossível. O modelo falha em considerar:
- Limites de nutrientes
- Acúmulo de toxinas
- Competição intraespecífica

A versão corrigida inclui capacidade de carga (K):

```python
def crescimento_logistico(t, N0, k, K):
    return K / (1 + (K/N0 - 1)*np.exp(-k*t))

populacao_realista = crescimento_logistico(tempo, 1, 0.5, 1000)  # K=1000
```

### Tipos de Simulação na Prática Científica

1. **Simulações determinísticas**: como os exemplos acima, onde parâmetros fixos levam a resultados previsíveis.

2. **Métodos de Monte Carlo**: usam aleatoriedade para modelar sistemas complexos. Exemplo: difusão de partículas:

```python
n_passos = 1000
passos = np.random.choice([-1, 1], size=n_passos)  # Movimentos aleatórios
posicao = np.cumsum(passos)  # Posição acumulada

plt.plot(posicao)
plt.xlabel('Passo')
plt.ylabel('Posição')
plt.title('Caminhada Aleatória 1D')
```

3. **Modelos baseados em agentes**: simulam entidades autônomas com regras locais. Úteis para tráfego urbano ou dinâmica social.

### Exercício Prático

Modele a propagação de uma doença com:
- População fixa de 1000 indivíduos
- Taxa de transmissão β = 0.3
- Taxa de recuperação γ = 0.1
- 5 infectados iniciais

Use o modelo SIR (Suscetível-Infectado-Recuperado):

```python
# Solução:
def modelo_SIR(t, y, β, γ):
    S, I, R = y
    N = S + I + R
    dSdt = -β * S * I / N
    dIdt = β * S * I / N - γ * I
    dRdt = γ * I
    return [dSdt, dIdt, dRdt]

from scipy.integrate import solve_ivp
sol = solve_ivp(modelo_SIR, [0, 100], [995, 5, 0], args=(0.3, 0.1), dense_output=True)
t = np.linspace(0, 100, 200)
y = sol.sol(t)

plt.plot(t, y.T)
plt.legend(['Suscetíveis', 'Infectados', 'Recuperados'])
plt.xlabel('Dias')
plt.ylabel('População')
```

A curva resultante mostra o pico epidêmico e a imunidade de rebanho emergindo do modelo.