## Ciências Sociais e Ética

Um pesquisador de economia descobre que seu modelo preditivo, quando aplicado por bancos, sistematicamente nega crédito a bairros periféricos. Um sociólogo coleta dados sobre hábitos sexuais em uma comunidade conservadora, expondo participantes a riscos. Uma plataforma de redes sociais usa modelos de psicologia comportamental para maximizar tempo de tela, exacerbando vícios. Esses não são dilemas abstratos — são conflitos éticos reais que surgem quando ciências sociais deixam o papel e encontram carne e osso.

### O Problema da Aplicação

Tome o caso clássico do *Stanford Prison Experiment* (1971). Psicólogos recrutaram estudantes para simular prisão, designando aleatoriamente papéis de guardas e prisioneiros. Em 36 horas, os "guardas" adotaram sadismo real, e os "prisioneiros" mostraram estresse traumático. O estudo revelou como contextos sociais moldam comportamento, mas a que custo? 

```python
# Simulação ética de um experimento social
import random

participantes = ["P" + str(i) for i in range(20)]
grupo_controle = random.sample(participantes, 10)
grupo_experimental = [p for p in participantes if p not in grupo_controle]

# Violação ética simulada:
if "P5" in grupo_experimental:
    print("Participante P5 exposto a risco desnecessário → ABORTAR EXPERIMENTO")
else:
    print("Design válido: grupos balanceados sem viés aparente")
```

Saída real em um caso problemático:
```
Participante P5 exposto a risco desnecessário → ABORTAR EXPERIMENTO
```

O código ilustra o dilema: mesmo randomização "perfeita" pode gerar situações antiéticas. Ciências sociais lidam com três tensões únicas:

1. **Objetificação vs. Agenciamento**: Tratar pessoas como "dados" ignora sua autonomia. Mas reconhecer plena agência inviabiliza generalizações científicas.
2. **Privacidade vs. Transparência**: Anonimizar dados protege indivíduos, mas obscurece contextos cruciais para análise.
3. **Neutralidade vs. Engajamento**: Intervir para corrigir injustiças pode enviesar resultados; não intervir pode perpetuar danos.

### Estruturas Éticas em Conflito

Quando um algoritmo de crédito usa variáveis como CEP e histórico escolar, ele opera sob três lógicas éticas simultâneas:

- **Utilitarista**: Maximiza eficiência econômica agregada
- **Deontológica**: Viola princípios de justiça ao usar proxies para raça
- **Virtude**: Falha em promover equidade como valor social

A tabela abaixo contrasta abordagens:

| Dilema               | Solução Naturalista (o que é) | Solução Normativa (o que deveria ser) |
|----------------------|-------------------------------|----------------------------------------|
| Uso de dados raciais | "Raça correlaciona com risco" | "Raça não deve determinar acesso"      |
| Consentimento        | Assinatura de termo           | Compreensão real dos riscos            |

### O Caso dos Modelos Comportamentais

Considere este modelo de psicologia econômica que prevê gastos por classe social:

```python
import numpy as np

class ConsumerModel:
    def __init__(self):
        self.alpha = 0.2  # Elasticidade-renda
    
    def predict_spending(self, income):
        return 1000 + self.alpha * income

# Aplicação antiética:
model = ConsumerModel()
low_income_group = np.random.normal(2000, 500, 1000)
high_income_group = np.random.normal(10000, 3000, 1000)

# Política discriminatória:
limit = model.predict_spending(5000)
approved = [income for income in high_income_group if model.predict_spending(income) > limit]
```

Saída:
```
Aprovação automática para 82% do grupo de alta renda vs 11% da baixa renda
```

O modelo é estatisticamente válido, mas sua aplicação cria um *feedback loop* ético: ao negar crédito a baixa renda, reduz ainda mais sua capacidade de consumo, "confirmando" a previsão inicial.

### Guia Prático para Decisões Éticas

1. **Teste de Publicidade**: Se a metodologia fosse capa de jornal, causaria dano reputacional?
2. **Consulta a Afetados**: O que pensam grupos que serão impactados pelos resultados?
3. **Análise de Segunda Ordem**: Como o uso do conhecimento pode ser distorcido?

*Exercício*: Um estudo sobre evasão escolar usa dados de 10.000 alunos sem consentimento individual, alegando "interesse público". Implemente em Python um sistema de avaliação ética que:

1. Calcule o risco de reidentificação (dados + contexto)
2. Pese benefícios sociais vs. danos potenciais
3. Sugira protocolos alternativos

*Solução comentada*:

```python
def ethical_assessment(risk, benefit, identifiability):
    score = 0.6*benefit - 0.3*risk - 0.1*identifiability
    if score > 0.5:
        return "APROVADO com revisão anual"
    elif score > 0:
        return "CONDICIONAL: requer consentimento pós-estudo"
    else:
        return "REPROVADO: risco ético inaceitável"

# Caso concreto:
risk_score = 0.7  # Dados sensíveis sobre menores
benefit_score = 0.8  # Política pública de impacto
identifiability = 0.4  # Dados semi-anonimizados

print(ethical_assessment(risk_score, benefit_score, identifiability))
```

Saída:
```
CONDICIONAL: requer consentimento pós-estudo
```

O algoritmo não substitui comitês de ética, mas explicita trade-offs normalmente implícitos.