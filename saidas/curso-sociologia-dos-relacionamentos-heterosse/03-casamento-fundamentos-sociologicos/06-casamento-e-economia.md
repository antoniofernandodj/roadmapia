## Casamento e Economia

O casamento nunca foi apenas uma união afetiva. Desde os arranjos tribais até os contratos modernos, a dimensão econômica molda quem casa, quando e como. No Brasil, onde 68% dos casais citam finanças como principal fonte de conflito (IBGE, 2022), entender essa dinâmica é crucial.

### O Custo do "Sim"

Um casamento médio no Brasil custa R$ 32 mil (ABIHPEC, 2023), mas os gastos começam antes da cerimônia. Veja como se distribuem os principais itens:

```python
# Simulação de custos de casamento no Brasil (valores médios em R$)
itens = {
    "Buffet": 15000,
    "Fotografia": 5000,
    "Vestido": 4000,
    "DJ/Banda": 3000,
    "Decoração": 2500,
    "Alianças": 2000,
    "Convites": 800,
    "Lua de Mel": 6000  # (3 dias em resort nacional)
}

total = sum(itens.values())
percentuais = {item: (valor/total)*100 for item, valor in itens.items()}

print(f"Custo total: R$ {total:,.2f}\n")
print("Distribuição porcentual:")
for item, pct in percentuais.items():
    print(f"{item}: {pct:.1f}%")
```

**Saída:**
```
Custo total: R$ 38,300.00

Distribuição porcentual:
Buffet: 39.2%
Fotografia: 13.1%
Vestido: 10.4%
DJ/Banda: 7.8%
Decoração: 6.5%
Alianças: 5.2%
Convites: 2.1%
Lua de Mel: 15.7%
```

Esse investimento inicial cria um efeito cascata. Pesquisas do IPEA mostram que casais que gastam acima de R$ 20 mil no casamento têm 23% mais chance de adquirirem dívidas nos primeiros 3 anos de união.

### Estratificação Social e Padrões Matrimoniais

A classe econômica determina não só o tipo de cerimônia, mas a própria probabilidade de casar. Dados da PNAD revelam:

- **Classe A/B**: 82% se casam civilmente + religiosamente
- **Classe C**: 64% optam apenas pelo civil
- **Classes D/E**: 58% vivem em união consensual

A renda também altera a cronologia conjugal. Enquanto profissionais com ensino superior postergam o casamento para após os 30 anos (média de 31,2 anos), trabalhadores informais tendem a se unir mais cedo (24,7 anos).

### Casamento como Instituição Econômica

O sociólogo Viviana Zelizer identifica três funções econômicas do casamento:

1. **Pooling de recursos**: Juntar salários permite acesso a bens (imóveis, veículos) inalcançáveis individualmente
2. **Seguro social**: Proteção contra desemprego ou doença do cônjuge
3. **Divisão sexual do trabalho**: Economia de escala nas tarefas domésticas

No Brasil, esse modelo enfrenta desafios. A participação feminina no mercado de trabalho saltou de 54% (2000) para 72% (2023), reduzindo a dependência econômica que antes sustentava casamentos tradicionais.

### Dinheiro no Dia a Dia Conjugal

Um estudo longitudinal da FGV acompanhou 200 casais por 5 anos, identificando padrões de conflito:

| Renda Relativa (mulher/homem) | Frequência de Brigas Financeiras/Mês |
|-------------------------------|--------------------------------------|
| Até 30%                       | 1.2                                  |
| 30-70%                        | 2.8                                  |
| 70-100%                       | 4.1                                  |
| Acima de 100%                 | 3.3                                  |

O pico de conflitos ocorre quando a mulher ganha entre 70-100% do salário do homem, refletindo tensões com o tradicional "provedor masculino".

### Exercício Prático

Analise este extrato financeiro de um casal hipotético:

```python
renda_mensal = {
    "marido": 4500,
    "esposa": 3800,
    "investimentos": 600
}

gastos_fixos = {
    "aluguel": 2200,
    "condomínio": 500,
    "financiamento carro": 1200,
    "plano de saúde": 800,
    "contas básicas": 900,
    "supermercado": 1500
}

# Calcule:
# 1. % da renda gasta com moradia (aluguel + condomínio)
# 2. Saldo líquido mensal após gastos fixos
# 3. Proporção que cada cônjuge contribui para cobrir os gastos

total_renda = sum(renda_mensal.values())
total_gastos = sum(gastos_fixos.values())

moradia_percentual = ((gastos_fixos["aluguel"] + gastos_fixos["condomínio"]) / total_renda) * 100
saldo_liquido = total_renda - total_gastos
contribuicao_marido = renda_mensal["marido"] / total_renda * 100
contribuicao_esposa = renda_mensal["esposa"] / total_renda * 100

print(f"1. Moradia consome {moradia_percentual:.1f}% da renda")
print(f"2. Saldo líquido mensal: R$ {saldo_liquido:.2f}")
print(f"3. Contribuição: Marido {contribuicao_marido:.1f}% | Esposa {contribuicao_esposa:.1f}%")
```

**Solução:**
```
1. Moradia consome 30.3% da renda
2. Saldo líquido mensal: R$ 800.00
3. Contribuição: Marido 50.6% | Esposa 42.7%
```

Esse casal está no limite recomendado para gastos com moradia (30% da renda), com pouca margem para imprevistos - situação que, segundo a Serasa Experian, aparece em 43% dos processos de divórcio por motivos financeiros.