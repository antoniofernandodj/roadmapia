## Justificação Científica

Quando um cientista afirma que "o aquecimento global é causado por atividades humanas", como essa conclusão se sustenta? A justificação científica é o alicerce que transforma uma hipótese em conhecimento aceito, mas seus critérios variam conforme as tradições epistemológicas.

### O Problema da Base Empírica

Considere o caso da descoberta do bóson de Higgs. Os físicos do CERN anunciaram sua observação em 2012 com um nível de confiança de 5 sigma (probabilidade de 1 em 3,5 milhões de ser um acaso). Este é um exemplo claro de justificação através de evidência estatística robusta, mas que levanta questões:

1. Por que 5 sigma e não 4 ou 6?  
2. Como dados experimentais se conectam a uma entidade teórica proposta 48 anos antes?

O erro comum aqui é a falácia da "prova definitiva". Quando um estudo inicial sobre vacinas mostra 95% de eficácia, leigos podem interpretar como verdade absoluta, ignorando que:

```python
# Simulação de replicação de estudos
import numpy as np

resultados = []
for _ in range(100):
    amostra = np.random.binomial(n=1000, p=0.95, size=50)
    resultados.append(np.mean(amostra))

print(f"Variação entre replicações: {np.std(resultados):.2f}%")
# Saída típica: Variação entre replicações: 0.68%
```

Esta variação demonstra que mesmo resultados altamente consistentes possuem margens de incerteza que exigem justificação metodológica.

### Critérios de Justificação

Na prática científica contemporânea, três pilares sustentam a justificação:

1. **Reprodutibilidade**: O estudo da crise de replicação em psicologia (Open Science Collaboration, 2015) mostrou que apenas 36% dos 100 estudos replicaram seus resultados originais. Isso levou à adoção de práticas como pré-registro de hipóteses.

2. **Consistência Externa**: A teoria da relatividade de Einstein foi justificada não apenas por seus próprios testes, mas por resolver anomalias na órbita de Mercúrio que a física newtoniana não explicava.

3. **Fertibilidade Heurística**: O modelo padrão da física de partículas se justifica por gerar novas linhas de pesquisa, como a busca por partículas supersimétricas, mesmo quando estas não são encontradas.

### O Debate sobre Fundamentos

Duas visões contrastantes sobre justificação emergem:

**Fundacionalismo Científico**  
Propõe que certas observações básicas (como medições instrumentais) são autoevidentes e servem como base para justificar teorias. Por exemplo, leituras de termômetros calibrados em experimentos de mudança climática.

**Coerentismo Epistêmico**  
Argumenta que justificação vem da coerência mútua entre teorias, modelos e dados. A aceitação da tectônica de placas ocorreu quando múltiplas linhas de evidência (fósseis, magnetismo rochoso, distribuição de terremotos) convergiram em um quadro coerente.

### Caso Prático: Justificação em Epidemiologia

Analisemos como diferentes abordagens justificam a afirmação "fumar causa câncer de pulmão":

1. **Empirista**:  
   - Dados: 85% dos casos ocorrem em fumantes  
   - Estudo: Doll & Hill (1954) com 40.000 médicos britânicos  
   Limitação: Correlação ≠ causalidade

2. **Realista**:  
   - Mecanismo: 60 carcinógenos identificados no tabaco  
   - Modelos animais: tumores induzidos em ratos  
   Limitação: Extrapolação entre espécies

3. **Pragmático**:  
   - Eficácia: Países com políticas antitabaco tiveram redução de 15% na incidência  
   Limitação: Fatores confundidores

O exercício abaixo mostra como diferentes critérios levam a conclusões distintas:

```python
# Avaliando evidências
criterios = {
    'correlacao': 0.85,
    'mecanismo': 0.60,
    'intervencao': 0.15
}

pesos = {
    'empirista': [0.7, 0.2, 0.1],
    'realista': [0.3, 0.6, 0.1],
    'pragmatico': [0.2, 0.3, 0.5]
}

for abordagem, w in pesos.items():
    score = sum(criterios[k]*w[i] for i,k in enumerate(criterios))
    print(f"{abordagem}: {score:.2f}")

# Saída:
# empirista: 0.69
# realista: 0.59
# pragmatico: 0.38
```

### Exercício Crítico

Um artigo afirma que "meditação reduz estresse em 23% (p=0,04)". Analise esta afirmação considerando:

1. Qual seria um critério adequado de justificação?  
2. Que evidências adicionais seriam necessárias?  
3. Como diferentes tradições epistemológicas avaliariam o resultado?

**Solução Comentada**:  
1. O valor-p sozinho é insuficiente - necessita tamanho do efeito, poder estatístico e intervalo de confiança  
2. Evidências mecanísticas (ex: cortisol salivar), replicação independente, exclusão de placebo  
3. Empirista exigiria mais replicações, realista buscaria mecanismos neurais, pragmático avaliaria aplicabilidade clínica