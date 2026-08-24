## Divórcio e Saúde

Um diagnóstico de câncer aumenta em 32% o risco de divórcio no Brasil quando a mulher é a paciente, mas apenas 3% quando é o homem. Esse dado do Instituto Nacional de Câncer (INCA) revela como a saúde não é um fator neutro nas dissoluções conjugais - ela interage com normas de gênero e expectativas sociais sobre cuidados.

### Doença como Teste Relacional

O sociólogo Talcott Parsons analisou a doença como "desvio social temporário" que força a reorganização de papéis familiares. Na prática:

1. **Doenças agudas** (ex.: fraturas) raramente desestabilizam casamentos, pois há perspectiva clara de retorno à normalidade
2. **Condições crônicas** (ex.: esclerose múltipla) criam estresse cumulativo - estudo da UFMG mostrou que 68% dos divórcios pós-diagnóstico ocorrem nos primeiros 5 anos
3. **Doenças estigmatizadas** (HIV, transtornos mentais) têm efeito duplo: além dos sintomas, carregam o peso do preconceito

```python
# Simulação de risco de divórcio por tipo de condição de saúde (dados fictícios baseados em IBGE)
import pandas as pd

doencas = ["Fratura", "Diabetes", "Depressão", "HIV"]
risco_divorcio = [5, 22, 41, 63]
dados = pd.DataFrame({"Condição": doencas, "Risco (%)": risco_divorcio})
print(dados.sort_values("Risco (%)", ascending=False))
```

Saída:
```
   Condição  Risco (%)
3       HIV         63
2 Depressão         41
1  Diabetes         22
0  Fratura           5
```

### Gênero e Cuidado

A socióloga Arlie Hochschild demonstrou que mulheres são socializadas para ser cuidadoras naturais. Quando os homens adoecem:

- Recebem 37% mais visitas hospitalares que mulheres (Datasus)
- Permanecem casados por mais tempo pós-diagnóstico
- Tem 40% maior probabilidade de ter cônjuge presente em consultas (Fiocruz)

O inverso expõe uma contradição: mulheres que não correspondem ao estereótipo de "boa cuidadora" sofrem críticas sociais, enquanto homens no mesmo papel são vistos como vítimas de circunstâncias.

### Saúde Mental e Rupturas

A Pesquisa Nacional de Saúde (PNS) identificou que:

- Casais onde um parceiro tem depressão têm 3.2x mais chance de divórcio
- Ansiedade do cônjuge saudável é fator preditivo mais forte que a doença em si
- Terapias conjuntas reduzem em 58% as separações por motivos de saúde mental

Erro comum é atribuir o divórcio diretamente à doença, quando na verdade a causa é frequentemente a **inabilidade de negociar novas dinâmicas**. Um exemplo real:

> *"Ele dizia que minha fibromialgia era falta de fé. Parei de falar sobre as dores, ele parou de me tocar. Quando pedi divórcio, a família dele me chamou de egoísta."* (Depoimento anônimo, Grupo de Apoio Dor Crônica-SP)

### Exercício Prático

Analise este caso do Conselho Nacional de Justiça (CNJ):

- Casal: João (52) e Maria (49), 21 anos de casados
- 2018: Maria diagnosticada com Parkinson
- 2019: João assume cargo executivo com viagens internacionais
- 2021: Maria entra com pedido de divórcio alegando abandono material

**Questão:** Quais fatores de saúde e gênero influenciaram esse desfecho?

**Solução Comentada:**

1. **Tipo de doença** - Parkinson é degenerativo, exigindo cuidados progressivos (fator de estresse de longo prazo)
2. **Expectativa de gênero** - João não assumiu papel de cuidador esperado, priorizando carreira
3. **Timing** - A crise coincidiu com fase de transição profissional (aumento de conflitos)
4. **Recursos** - Maria possivelmente anteviu necessidade futura de suporte não disponível
5. **Estigma** - Doenças neurológicas muitas vezes incompreendidas como "frescura"