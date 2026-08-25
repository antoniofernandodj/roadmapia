## Causalidade nas Ciências Sociais

Quando um economista afirma que "aumentar o salário mínimo reduz empregos", ou um sociólogo diz que "desigualdade gera violência", estão fazendo afirmações causais. Mas como estabelecer relações de causa e efeito em sistemas sociais complexos, onde múltiplos fatores interagem e experimentos controlados são raros?

### O Problema Fundamental

Considere um estudo que encontra correlação entre assistir TV e notas baixas na escola. Três explicações são possíveis:
1. **Causalidade direta**: TV prejudica o desempenho escolar
2. **Causalidade reversa**: alunos com dificuldades assistem mais TV
3. **Fator oculto**: famílias com menos recursos têm mais TV e menos apoio educacional

Em ciências naturais, um experimento controlado poderia isolar essas variáveis. Mas como fazer isso quando o "laboratório" é a sociedade real?

### Estratégias de Inferência Causal

1. **Contrafactuais**: Comparar o que aconteceu com o que teria acontecido sem a intervenção. Um economista estudando o efeito de um programa social pode usar:
   ```python
   # Dados fictícios de renda antes/depois do programa
   import pandas as pd
   dados = pd.DataFrame({
       'Grupo': ['Tratamento']*100 + ['Controle']*100,
       'Renda_Antes': [2000]*100 + [2100]*100,
       'Renda_Depois': [2500]*100 + [2200]*100
   })
   efeito = (dados[dados.Grupo=='Tratamento'].Renda_Depois.mean() - 
             dados[dados.Grupo=='Tratamento'].Renda_Antes.mean()) - \
            (dados[dados.Grupo=='Controle'].Renda_Depois.mean() - 
             dados[dados.Grupo=='Controle'].Renda_Antes.mean())
   print(f"Efeito causal estimado: R${efeito:.2f}")  # Saída: R$300.00
   ```
   Mesmo assim, se o grupo de controle não for comparável (ex.: regiões diferentes), o resultado será enviesado.

2. **Variáveis Instrumentais**: Usar um fator externo que afete apenas a causa suspeita. Para estudar o impacto da educação nos salários, economistas usaram a distância até universidades como "instrumento":
   ```python
   # Modelo simplificado de variável instrumental
   from statsmodels.formula.api import ols
   modelo = ols('Salario ~ Educação + Cidade', data=dados).fit()
   modelo_iv = ols('Salario ~ 1 + C(Cidade)', data=dados).fit()  # Versão simplificada
   print(modelo_iv.summary())  # Mostra coeficiente de educação "purificado"
   ```

3. **Regressão Discontínua**: Aproveitar pontos de corte naturais. Se um benefício social é concedido apenas para famílias com renda abaixo de R$2000:
   ```python
   import numpy as np
   import matplotlib.pyplot as plt
   np.random.seed(42)
   renda = np.random.normal(2000, 500, 1000)
   beneficio = np.where(renda < 2000, 1, 0)
   consumo = 800 + 0.3*renda + 150*beneficio + np.random.normal(0, 50, 1000)
   plt.scatter(renda, consumo, c=beneficio, alpha=0.5)
   plt.axvline(x=2000, color='r', linestyle='--')
   plt.show()
   ```
   A diferença no consumo logo acima e abaixo do corte sugere o efeito causal do benefício.

### Desafios Específicos

1. **Falácia Ecológica**: Inferir causalidade individual a partir de dados agregados. Um clássico:
   ```python
   dados_estados = pd.DataFrame({
       'Percentual_Imigrantes': [15, 20, 25, 30],
       'Taxa_Criminalidade': [200, 220, 240, 260]
   })
   correlacao = dados_estados.corr().iloc[0,1]
   print(f"Correlação ecológica: {correlacao:.2f}")  # Positiva
   ```
   Mas se olharmos indivíduos:
   ```python
   dados_individuais = pd.DataFrame({
       'Imigrante': [1]*300 + [0]*700,
       'Crime': [1]*30 + [0]*270 + [1]*70 + [0]*630
   })
   odds_ratio = (30/270)/(70/630)  # 1.0 - nenhuma associação
   ```

2. **Causalidade Circular**: Em sistemas sociais, causas podem se tornar efeitos e vice-versa. Modelos de equações simultâneas capturam isso:
   ```
   Desemprego → Tensão Social → Instabilidade Política → Investimentos → Desemprego
   ```

3. **Efeitos Heterogêneos**: Uma política pode beneficiar alguns e prejudicar outros. Análises de **efeitos marginais** são essenciais:
   ```python
   # Modelo com interação
   modelo_het = ols('Resultado ~ Tratamento*Renda', data=dados).fit()
   print(modelo_het.summary())  # Coeficiente de interação mostra variação do efeito
   ```

### Exercício Prático

Um município implementou aulas de reforço escolar em 10 das 20 escolas, selecionadas aleatoriamente. Os dados estão em `escolas.csv`:
```python
import pandas as pd
from statsmodels.formula.api import ols
dados = pd.read_csv('escolas.csv')
# 1. Calcule a diferença simples nas notas pós-intervenção
diff_simples = dados[dados.Tratamento==1].Nota_Pos.mean() - dados[dados.Tratamento==0].Nota_Pos.mean()
# 2. Estime o efeito usando diferença-em-diferenças
modelo_did = ols('Nota_Pos ~ Tratamento + C(Periodo) + Tratamento*C(Periodo)', data=dados).fit()
# 3. Interprete o coeficiente de interação (efeito causal)
print(modelo_did.summary())
```

**Solução**: O coeficiente da interação Tratamento*Periodo mostra o efeito causal isolado, controlado por diferenças pré-existentes entre grupos. Um valor positivo de 0.15 (p<0.05) indicaria que o reforço aumentou as notas em 15 pontos, estatisticamente significativo.