## Experimentos em Ciências Sociais

Um economista quer testar se incentivos financeiros aumentam a produtividade de professores. Se simplesmente oferecer bônus e medir resultados, corre o risco de confundir correlação com causalidade — talvez escolas que adotam bônus já tenham outros fatores que melhoram desempenho. Esse é o problema central dos experimentos em ciências sociais: isolar o efeito de uma variável em sistemas complexos onde múltiplos fatores interagem.

### O desafio da causalidade

Considere um estudo clássico sobre o efeito da educação na renda. Dados mostram que pessoas com mais escolaridade ganham mais, mas isso não prova que estudar causa maior renda. Pode ser que famílias com mais recursos permitam mais estudos e também ofereçam melhores oportunidades. Esse é o problema da **variável omitida**, onde fatores não observados distorcem a relação aparente entre as variáveis de interesse.

Experimentos resolvem isso através da **aleatorização**. Ao atribuir participantes aleatoriamente a grupos de tratamento e controle, garantimos que, em média, todas as características observáveis e não observáveis se equilibram entre os grupos. A diferença nos resultados pode então ser atribuída ao tratamento.

### Estrutura básica de um experimento social

Um experimento mínimo requer:

1. **Hipótese testável**: "Aumentar o salário mínimo em 10% reduz o emprego juvenil em setores formais"
2. **Tratamento**: intervenção específica (ex.: subsídio salarial para empregadores)
3. **Grupo de controle**: equivalente ao de tratamento, mas sem intervenção
4. **Aleatorização**: atribuição aleatória de unidades (pessoas, escolas, cidades) aos grupos
5. **Variável de resultado**: medida objetiva (ex.: taxa de emprego após 6 meses)

Exemplo prático em Python, simulando um experimento sobre incentivos à reciclagem:

```python
import numpy as np
import pandas as pd
from scipy import stats

# Gerar dados simulados
np.random.seed(42)
n = 1000  # Número de domicílios
base_reciclagem = np.random.normal(5, 2, n)  # Kg/mês sem intervenção
efeito_tratamento = 1.5  # Efeito hipotético do incentivo

# Aleatorização
tratamento = np.random.choice([0, 1], size=n, p=[0.5, 0.5])

# Aplicar tratamento
reciclagem_observada = base_reciclagem + tratamento * efeito_tratamento + np.random.normal(0, 0.5, n)

# Criar DataFrame
dados = pd.DataFrame({
    'Tratamento': tratamento,
    'Reciclagem_kg': reciclagem_observada
})

# Teste t para diferença de médias
grupo_controle = dados[dados['Tratamento'] == 0]['Reciclagem_kg']
grupo_tratamento = dados[dados['Tratamento'] == 1]['Reciclagem_kg']
t_stat, p_valor = stats.ttest_ind(grupo_tratamento, grupo_controle)

print(f"Diferença de médias: {grupo_tratamento.mean() - grupo_controle.mean():.2f} kg")
print(f"Valor-p: {p_valor:.4f}")
```

Saída esperada:
```
Diferença de médias: 1.47 kg
Valor-p: 0.0000
```

### Problemas comuns e soluções

1. **Vazamento de tratamento**: Quando o grupo controle é afetado indiretamente. Solução: aumentar distância física ou social entre grupos.

2. **Atrito diferencial**: Participantes abandonam o estudo de forma não aleatória. Solução: análise de intenção de tratar (ITT), que mantém todos os aleatorizados em seus grupos originais.

3. **Efeitos de Hawthorne**: Mudança no comportamento por saber que está sendo observado. Solução: cegar participantes sobre seu status de tratamento quando possível.

4. **Heterogeneidade de efeitos**: O tratamento funciona diferente para subgrupos. Solução: análise estratificada pré-registrada.

### Exemplo real: Progresa/Oportunidades no México

Em 1997, o governo mexicano implementou um experimento randomizado para avaliar um programa de transferência condicional de renda. Algumas comunidades receberam o programa imediatamente (tratamento), outras depois (controle). Resultados mostraram:

- Aumento de 20% no consumo familiar
- Redução de 12% na incidência de doenças infantis
- Aumento de 3,4% na matrícula escolar

Esses efeitos foram mensurados comparando os dois grupos no mesmo período, não antes/depois dentro do mesmo grupo — a chave para estabelecer causalidade.

### Limitações éticas e práticas

Nem toda intervenção social pode ser testada experimentalmente. É antiético, por exemplo, randomizar acesso a tratamentos médicos comprovadamente eficazes. Alternativas incluem:

- **Experimentação natural**: Aproveitar eventos aleatórios como mudanças de política
- **Regressão descontínua**: Comparar unidades logo acima e abaixo de um limiar de elegibilidade
- **Variáveis instrumentais**: Usar fatores aleatórios que afetam apenas indiretamente o resultado

### Exercício prático

Um município testou um programa de mentoria para jovens em risco. Dos 500 participantes aleatorizados, 250 receberam mentores (grupo tratamento) e 250 não (controle). Após 1 ano:

- Tratamento: 30% empregados
- Controle: 22% empregados
- Valor-p: 0.03

**Pergunta**: Qual é o efeito causal estimado do programa? Quais fatores poderiam invalidar essa conclusão?

**Solução**: O efeito é de 8 pontos percentuais (30%-22%), estatisticamente significativo (p<0.05). Possíveis problemas: 
1) Se houver desistência diferencial (ex.: jovens mais motivados permaneceram no grupo tratamento); 
2) Contaminação se mentores ajudaram também o grupo controle; 
3) Efeito placebo se jovens souberam do estudo e mudaram comportamento.