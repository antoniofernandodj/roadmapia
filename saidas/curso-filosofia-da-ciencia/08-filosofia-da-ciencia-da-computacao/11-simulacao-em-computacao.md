## Simulação em Computação

Um engenheiro aeronáutico precisa testar um novo design de asa. Construir protótipos físicos custa milhões e leva meses. Em vez disso, ela escreve um programa que calcula como o ar fluirá em torno da superfície em diferentes condições. Isso é uma simulação computacional — uma ferramenta que transforma problemas do mundo real em operações matemáticas executáveis.

O código abaixo simula o movimento de um pêndulo simples usando as equações diferenciais que descrevem sua física:

```python
import numpy as np
import matplotlib.pyplot as plt

def simulate_pendulum(length=1.0, gravity=9.8, theta0=0.2, dt=0.01, steps=1000):
    """Simula um pêndulo simples usando o método de Euler."""
    theta = np.zeros(steps)
    omega = np.zeros(steps)
    theta[0] = theta0
    
    for i in range(1, steps):
        omega[i] = omega[i-1] - (gravity/length) * np.sin(theta[i-1]) * dt
        theta[i] = theta[i-1] + omega[i] * dt
    
    return theta

# Execução e visualização
angles = simulate_pendulum()
plt.plot(angles)
plt.title('Simulação de Pêndulo Simples')
plt.xlabel('Passo de Tempo')
plt.ylabel('Ângulo (radianos)')
plt.show()
```

Esta simulação produz um gráfico mostrando como o ângulo do pêndulo varia com o tempo. O resultado aproxima o comportamento real, mas contém erros — o método de Euler usado aqui acumula imprecisões a cada passo. Esse é o dilema central das simulações: são necessariamente simplificações.

Quando o mesmo código é executado com `dt=0.1` (passo de tempo maior), o erro se torna visível:

```
Warning: Simulation may be unstable with large time steps
```

O problema filosófico aparece quando confundimos a simulação com a realidade. Em 2008, modelos financeiros que simulavam mercados falharam catastróficamente porque assumiam comportamentos mais ordenados do que os observados na crise real. A simulação havia se tornado tão complexa que seus criadores passaram a tratá-la como oráculo, não como aproximação.

Três níveis de abstração operam em qualquer simulação:
1. **Modelo conceitual**: As equações do pêndulo θ'' = -(g/l)sinθ
2. **Implementação numérica**: O método de Euler discretizando as equações
3. **Artefato computacional**: O programa Python com seus erros de ponto flutuante

A validação exige confrontar todos os níveis com dados empíricos. Um erro comum é testar apenas o nível 3 (se o código roda) sem verificar se o modelo conceitual corresponde ao fenômeno real.

Exercício: Modifique a função `simulate_pendulum` para incluir atrito (termo proporcional à velocidade angular -k*ω). Compare com o caso sem atrito. O que muda no comportamento de longo prazo?

Solução:

```python
def simulate_pendulum_with_friction(length=1.0, gravity=9.8, theta0=0.2, 
                                  k=0.1, dt=0.01, steps=1000):
    theta = np.zeros(steps)
    omega = np.zeros(steps)
    theta[0] = theta0
    
    for i in range(1, steps):
        omega[i] = omega[i-1] - (gravity/length)*np.sin(theta[i-1])*dt - k*omega[i-1]*dt
        theta[i] = theta[i-1] + omega[i]*dt
    
    return theta
```

O atrito faz a amplitude das oscilações diminuir gradualmente até o pêndulo parar — comportamento qualitativamente diferente do caso sem atrito, onde as oscilações continuariam indefinidamente. Essa mudança ilustra como pequenas modificações no modelo alteram profundamente os resultados.