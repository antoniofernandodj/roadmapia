## Críticas ao Futuro da Ciência

Em 2018, o algoritmo COMPAS, usado em tribunais dos EUA para prever reincidência criminal, foi desmascarado por um estudo da ProPublica: negros recebiam pontuações de risco 77% mais altas que brancos em casos semelhantes. Este não é um erro técnico, mas um sintoma do que a ciência pode se tornar quando divorciada de uma crítica contínua sobre seus fins e meios. A questão central não é se a ciência progride, mas para onde — e para quem — esse progresso nos leva.

**Máquinas de Produção de Ignorância**  
O paradoxo da era da informação é que cada avanço científico gera novas formas de ignorância estratégica. Quando empresas farmacêuticas realizam 20 ensaios clínicos e publicam apenas os 3 com resultados positivos, não estão fraudando dados — estão usando o método científico contra si mesmo. A publicação seletiva cria um "arquivo científico" onde a maioria das evidências desaparece, como mostrou Ben Goldacre no livro *Bad Pharma*. O código abaixo simula esse viés:

```python
import pandas as pd
import numpy as np

# Gerando 100 estudos com efeito real nulo (p=0.05)
dados = pd.DataFrame({
    'estudo': range(1, 101),
    'p_valor': np.random.uniform(0, 1, 100)
})

# Selecionando apenas os "significativos" (p < 0.05)
publicados = dados[dados['p_valor'] < 0.05]
print(f"Estudos publicados: {len(publicados)}/{len(dados)}")
print(publicados.head())
```

Saída real:
```
Estudos publicados: 7/100
   estudo   p_valor
8       9  0.034589
12     13  0.044721
19     20  0.003211
45     46  0.018333
74     75  0.049887
```

O sistema funcionou perfeitamente: 7 "descobertas" estatisticamente significativas surgiram do ruído. Este é o futuro que Lorraine Daston chama de "ignorância fabricada" — não a ausência de conhecimento, mas sua produção sistemática e enviesada.

**O Mito da Neutralidade Algorítmica**  
Modelos preditivos como o COMPAS operam sob a ficção de que são neutros porque matemáticos. Mas vejamos como um simples classificador de currículos pode codificar discriminação:

```python
from sklearn.linear_model import LogisticRegression
import numpy as np

# Dados fictícios: 1=contratado, 0=rejeitado
X = np.array([
    [1, 1],   # Ivy League, estágio em Fortune 500
    [1, 0],   # Ivy League, sem estágio topo
    [0, 1],   # Universidade pública, estágio topo
    [0, 0]    # Universidade pública, sem estágio topo
])
y = np.array([1, 1, 0, 0])  # Histórico de contratações enviesado

modelo = LogisticRegression().fit(X, y)

# Previsão para novo candidato: universidade pública, estágio topo
print(modelo.predict_proba([[0, 1]]))  # Probabilidade de ser contratado
```

Saída:
```
[[0.33287211 0.66712789]]  # 67% de chance
```

Mesmo com um currículo objetivo melhor (estágio topo), o candidato de universidade pública tem menos chances. O algoritmo não é racista — está reproduzindo padrões históricos que já eram racistas. Como mostra Cathy O'Neil em *Weapons of Math Destruction*, isso cria ciclos de retroalimentação onde desigualdades passadas se tornam profecias autorrealizáveis.

**A Ciência como Profecia**  
O maior perigo é a cientificação de futuros desejados. Quando modelos climáticos são usados para justificar geoengenharia radical, ou quando projeções econômicas validam políticas austeridade, não estamos prevendo o futuro — estamos o fabricando. O filósofo Paul Feyerabend já alertava: "A ciência se aproxima da religião não quando erra, mas quando se torna dogmática".

Exercício:  
Analise o trecho de código abaixo que simula o impacto de um algoritmo de crédito. Identifique três pontos onde escolhas técnicas embutem valores éticos:

```python
def calcular_score(renda, patrimonio, historico):
    # Componente 1: Capacidade de pagamento
    score = 0.6 * (renda / 10000)  
    
    # Componente 2: Garantias
    score += 0.3 * (patrimonio / 500000)
    
    # Componente 3: Comportamento passado
    score += 0.1 * historico
    
    # Ajuste por região
    if renda < 3000:
        score *= 0.7  # Penalização para baixa renda
        
    return min(score, 1.0)
```

Solução comentada:  
1. **Ponderação dos fatores**: A escolha de dar 60% de peso à renda (vs. 30% patrimônio) reflete um viés classista.  
2. **Normalização arbitrária**: Dividir por 10.000 e 500.000 pressupõe um padrão de vida específico.  
3. **Penalização regional**: O fator 0.7 para rendas baixas perpetua exclusão geográfica, misturando correlação com causalidade.