## Filosofia da Ciência e Interdisciplinaridade

Um ecologista estuda o impacto das mudanças climáticas em uma floresta. Para interpretar os dados, ele precisa:  
1. **Física** (ciclos de carbono)  
2. **Química** (composição do solo)  
3. **Estatística** (análise de dados)  
4. **Sociologia** (ações humanas que afetam o ecossistema)  

Este cenário revela o problema central: nenhuma disciplina isolada consegue responder perguntas complexas da ciência contemporânea. A filosofia da ciência entra aqui para analisar como esses saberes se articulam — ou falham em se articular.

### O Mito da Ciência "Pura"

Considere este código Python que simula um modelo epidemiológico SIR (Suscetível-Infectado-Recuperado):

```python
import numpy as np
import matplotlib.pyplot as plt

def derivadas_SIR(y, t, beta, gamma):
    S, I, R = y
    dSdt = -beta * S * I
    dIdt = beta * S * I - gamma * I
    dRdt = gamma * I
    return [dSdt, dIdt, dRdt]

# Parâmetros: beta (transmissão) e gamma (recuperação)
beta = 0.3  
gamma = 0.1 

# Condições iniciais
S0 = 0.99  
I0 = 0.01  
R0 = 0.0   

t = np.linspace(0, 100, 1000)
sol = odeint(derivadas_SIR, [S0, I0, R0], t, args=(beta, gamma))

plt.plot(t, sol[:, 0], label='Suscetível')
plt.plot(t, sol[:, 1], label='Infectado')
plt.plot(t, sol[:, 2], label='Recuperado')
plt.legend()
plt.xlabel('Tempo')
plt.ylabel('Proporção da população')
plt.show()
```

**Saída gráfica**: Curvas mostrando a evolução dos três grupos ao longo do tempo.

Este modelo, aparentemente puramente matemático, esconde interdependências:  
- **Biologia**: Definição dos parâmetros β e γ requer conhecimento de períodos de infecção  
- **Sociologia**: Taxas de contato social afetam β  
- **Políticas públicas**: γ depende da disponibilidade de tratamento médico  

Quando epidemiologistas ignoram essas conexões, surgem erros como a previsão falha da COVID-19 em 2020, onde modelos subestimaram fatores comportamentais humanos.

### Caso Concreto: Neurociência e Filosofia

Um estudo sobre tomada de decisão usa ressonância magnética funcional (fMRI) para mapear atividade cerebral. Os dados brutos são:

| Região Cerebral      | Ativação (Z-score) |
|----------------------|--------------------|
| Córtex pré-frontal   | 3.2                |
| Amígdala             | 2.7                |
| Núcleo accumbens     | 1.9                |

A interpretação requer:  
1. **Neuroanatomia** (localização das regiões)  
2. **Psicologia** (funções cognitivas associadas)  
3. **Filosofia da mente** (o que "decisão" significa ontologicamente)  

O erro comum é reduzir a decisão à ativação neural (falácia neurocientífica). A filosofia da ciência questiona: como esses níveis explicativos se relacionam? Eles se complementam ou competem?

### Exercício Prático

Analise este cenário interdisciplinar:  
**Problema**: Desenvolvimento de um algoritmo de reconhecimento facial.  

Identifique:  
1. Três disciplinas envolvidas  
2. Um ponto de conflito potencial entre elas  
3. Como a filosofia da ciência ajudaria a resolver  

**Solução comentada**:  
1. **Ciência da Computação** (algoritmos), **Psicologia** (percepção visual), **Ética** (viés racial em conjuntos de dados)  
2. Conflito: Otimização técnica (precisão numérica) vs. Viés social (sub-representação de grupos)  
3. A filosofia da ciência:  
   - Questiona critérios de "sucesso" do algoritmo  
   - Examina como valores sociais moldam parâmetros técnicos  
   - Propõe estruturas para avaliação multidimensional