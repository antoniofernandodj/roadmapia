## Exercícios de Metodologia

### Testando Hipóteses com Dados Reais

Suponha que você coletou dados sobre o crescimento de plantas sob diferentes condições de luz. Seu conjunto de dados inclui:

```python
import pandas as pd

dados = {
    'Planta': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    'HorasLuz': [2, 3, 4, 5, 6, 2, 3, 4, 5, 6],
    'Altura(cm)': [10, 15, 18, 22, 25, 9, 14, 17, 20, 23],
    'Grupo': ['A', 'A', 'A', 'A', 'A', 'B', 'B', 'B', 'B', 'B']
}

df = pd.DataFrame(dados)
```

**Hipótese nula (H₀):** Não há diferença significativa no crescimento das plantas entre os grupos A e B.

**Análise estatística:**

```python
from scipy import stats

grupo_a = df[df['Grupo'] == 'A']['Altura(cm)']
grupo_b = df[df['Grupo'] == 'B']['Altura(cm)']

resultado = stats.ttest_ind(grupo_a, grupo_b)
print(f"Teste t: estatística = {resultado.statistic:.2f}, p-valor = {resultado.pvalue:.4f}")
```

Saída:
```
Teste t: estatística = 1.41, p-valor = 0.1956
```

Como o p-valor (0.1956) é maior que 0.05, não rejeitamos a hipótese nula. Isso significa que, com esses dados, não há evidência estatística para afirmar que os grupos diferem significativamente.

### Erro Comum: Confundir Correlação com Causalidade

Considere estes dados fictícios sobre vendas de sorvete e afogamentos:

```python
dados = {
    'Mês': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
    'Sorvete (kg)': [50, 70, 90, 120, 150, 180],
    'Afogamentos': [5, 7, 9, 12, 15, 18]
}

df = pd.DataFrame(dados)
correlacao = df['Sorvete (kg)'].corr(df['Afogamentos'])
print(f"Correlação: {correlacao:.2f}")
```

Saída:
```
Correlação: 1.00
```

A correlação perfeita de 1.00 não implica causalidade. O erro seria concluir que "sorvete causa afogamentos". Na realidade, ambas as variáveis estão relacionadas a uma terceira variável não medida: a temperatura ambiente.

### Exercício de Operacionalização

Transforme o conceito abstrato "qualidade de vida" em variáveis mensuráveis para um estudo em idosos:

1. **Variável dependente:** Escore de qualidade de vida (0-100)
2. **Indicadores operacionais:**
   - Número de consultas médicas/mês
   - Escala de dor (0-10)
   - Índice de mobilidade (teste Timed Up-and-Go em segundos)
   - Escore de depressão geriátrica (0-15)
   - Número de interações sociais/semana

**Exemplo de coleta:**

```python
dados_idosos = {
    'Participante': [1, 2, 3],
    'Consultas_mes': [2, 4, 1],
    'Escala_dor': [3, 7, 2],
    'Mobilidade_seg': [12, 25, 10],
    'Depressao': [3, 10, 2],
    'Interacoes_semana': [5, 1, 7]
}
```

### Análise de Dados Qualitativos

Transcrição de entrevista sobre hábitos de estudo:

```
"Eu estudo melhor à noite, com música ambiente. Quando tento estudar de manhã, 
me distraio facilmente com barulhos externos. A biblioteca é muito silenciosa, 
o que paradoxalmente me deixa ansioso."
```

**Codificação temática:**

1. **Horário preferencial:** Noite
2. **Fator facilitador:** Música ambiente
3. **Barreiras:** 
   - Ruídos matutinos
   - Silêncio excessivo (biblioteca)
4. **Efeito emocional:** Ansiedade em ambientes muito silenciosos

### Exercício Prático: Desenho Experimental

**Problema:** Avaliar se um novo método de ensino melhora o aprendizado de matemática.

**Passos:**

1. **População:** Alunos do 8º ano
2. **Amostragem:** 60 alunos randomizados em 2 grupos
3. **Variável independente:** Método (tradicional vs. novo)
4. **Variável dependente:** Nota no teste padronizado
5. **Controles:**
   - Mesmo professor para ambos os grupos
   - Mesmo horário do dia
   - Mesmo material didático básico
6. **Duração:** 4 semanas
7. **Análise:** Teste t para amostras independentes

**Código para randomização:**

```python
import random

alunos = [f"Aluno_{i}" for i in range(1, 61)]
random.shuffle(alunos)
grupo_novo = alunos[:30]
grupo_tradicional = alunos[30:]

print("Grupo novo:", grupo_novo[:5], "...")
print("Grupo tradicional:", grupo_tradicional[:5], "...")
```

### Solução Comentada do Exercício

1. **Randomização:** Garante que diferenças pré-existentes entre alunos se distribuam igualmente entre grupos
2. **Controles:** Eliminam variáveis de confusão como efeito do professor ou cansaço acumulado
3. **Tamanho amostral:** 30 por grupo permite detectar efeitos moderados (poder estatístico ~80%)
4. **Duração:** Suficiente para observar efeitos, mas não tanto a ponto de outros fatores interferirem
5. **Análise:** Teste paramétrico adequado para comparação de médias em grupos independentes

Erro comum seria não randomizar ou ter grupos muito pequenos (<15 por grupo), o que reduziria o poder estatístico e aumentaria o risco de resultados falsos positivos.