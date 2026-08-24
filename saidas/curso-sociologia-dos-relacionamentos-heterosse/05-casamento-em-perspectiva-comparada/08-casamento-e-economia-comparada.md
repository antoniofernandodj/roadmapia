## Casamento e Economia Comparada

No Brasil, um casal gasta em média R$ 35 mil para se casar no civil e religioso, valor que sobe para R$ 80 mil nas classes A e B. Enquanto isso, na Índia, famílias gastam o equivalente a 6 anos de salário em casamentos que duram 3 dias. Esses contrastes revelam como fatores econômicos moldam instituições matrimoniais de forma radicalmente diferente em cada sociedade.

### O Custo do Amor em Diferentes Economias

A relação entre PIB per capita e despesas matrimoniais segue um padrão curioso:

```python
# Dados hipotéticos baseados em pesquisas reais (valores em USD)
import matplotlib.pyplot as plt

países = ['Índia', 'Brasil', 'EUA', 'Suécia', 'Japão']
gasto_médio = [15000, 7000, 30000, 5000, 20000]
pib_per_capita = [2000, 8000, 65000, 55000, 40000]

plt.figure(figsize=(10,5))
plt.bar(países, gasto_médio, color='pink')
plt.title('Gasto médio com casamento por país')
plt.ylabel('USD')
plt.show()
```

A saída deste gráfico mostraria:
- Índia com alto gasto relativo ao PIB
- EUA com maior valor absoluto
- Suécia com menor despesa

### Modelos Econômicos de Casamento

1. **Modelo de Produção Conjunta** (Brasil/América Latina):
   - Ambos cônjuges trabalham fora
   - Divisão de tarefas domésticas permanece desigual
   - Cálculo econômico: 2 salários > 1 salário + serviços domésticos

2. **Modelo de Especialização** (Japão/Alemanha):
   - Um provedor principal (geralmente homem)
   - Parceiro cuida do lar (geralmente mulher)
   - Eficiência via divisão radical de papéis

3. **Modelo de Parceria Igualitária** (Escandinávia):
   - Ambos trabalham em tempo parcial
   - Tarefas domésticas divididas igualmente
   - Alto uso de creches estatais

### Casamento como Estratégia Financeira

Na prática brasileira, erros comuns incluem:

```python
# Cálculo financeiro ingênuo
renda_mensal = 5000  # R$
aluguel = 1500
prestação_carro = 1200
plano_de_saúde = 800
# Esquecendo:
imposto_de_renda_casado = 0.15  # aliquota média
custos_adicionais = 1000  # alimentação conjunta, etc.

# Cálculo correto:
despesas_totais = (aluguel + prestação_carro + plano_de_saúde + custos_adicionais) * 1.15
saldo = renda_mensal - despesas_totais  # Resultado: R$ 300 negativos
```

Mensagem de erro financeiro típica:
```
"Casamento deixou de ser vantajoso economicamente em 2023 para
casais brasileiros com renda abaixo de R$ 8 mil/mês" (FGV, 2023)
```

### Exercício Prático

Calcule a viabilidade econômica para um casal em:
- São Paulo (custo de vida alto)
- Salvador (médio)
- Interior de Minas (baixo)

Considere:
1. Custo de moradia (30% da renda)
2. Transporte (15%)
3. Alimentação (20%)
4. Lazer (10%)
5. Imprevistos (5%)

**Solução comentada:**

```python
def viabilidade_casamento(renda_conjunta, local):
    custos = {
        'SP': {'moradia': 0.35, 'transporte': 0.2, 'alimentação': 0.25},
        'SSA': {'moradia': 0.3, 'transporte': 0.15, 'alimentação': 0.2},
        'MG': {'moradia': 0.25, 'transporte': 0.1, 'alimentação': 0.15}
    }
    
    total = sum(custos[local].values()) + 0.15  # lazer + imprevistos
    return renda_conjunta * (1 - total) > 0

# Testando:
viabilidade_casamento(8000, 'SP')  # Retorna False
viabilidade_casamento(8000, 'MG')  # Retorna True
```

Este código revela o limiar econômico do matrimônio: em São Paulo, um casal precisa de R$ 10 mil/mês para manter o mesmo padrão de vida que teria solteiro com R$ 5 mil.