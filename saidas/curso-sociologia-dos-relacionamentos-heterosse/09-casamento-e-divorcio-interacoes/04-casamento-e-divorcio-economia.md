## Casamento e Divórcio: Economia  

Quando um casal decide se casar ou se divorciar, raramente pensa apenas em amor ou desgaste emocional. Há um fator silencioso que molda essas decisões: a economia. No Brasil, onde a desigualdade social é acentuada, o dinheiro não apenas facilita ou dificulta a vida a dois, mas redefine o próprio significado do matrimônio e sua dissolução.  

### O Custo do Casamento  

O casamento no Brasil tem um preço literal. Desde a cerimônia até a manutenção da vida conjugal, os gastos são estratificados por classe social:  

1. **Casamentos de alto padrão**: Custam em média R$ 80 mil (IBGE, 2022), valor que supera o salário anual de 60% dos brasileiros. Esse investimento reflete não só afeto, mas status social — um "capital simbólico" (Bourdieu) que fortalece redes profissionais e familiares.  
2. **Casamentos populares**: Realizados em cartórios ou igrejas simples, gastam em média R$ 5 mil, muitas vezes financiados por meses de trabalho. Aqui, o casamento funciona como projeto de mobilidade: unir rendas para comprar um imóvel, por exemplo.  

Exemplo concreto:  
```python  
# Simulação de custos de casamento por classe social (valores em R$)  
classes = ["Alto padrão", "Classe média", "Popular"]  
custos = [80000, 20000, 5000]  
salario_anual_medio = 35200  # Dados IBGE 2022  

for classe, custo in zip(classes, custos):  
    proporcao_salario = (custo / salario_anual_medio) * 100  
    print(f"{classe}: {custo} reais ({proporcao_salario:.1f}% do salário anual médio)")  
```  
Saída:  
```  
Alto padrão: 80000 reais (227.3% do salário anual médio)  
Classe média: 20000 reais (56.8% do salário anual médio)  
Popular: 5000 reais (14.2% do salário anual médio)  
```  

### Economia e Estabilidade Conjugal  

A renda familiar determina não só *como* se casa, mas *se* o casamento dura. Dados do IPEA (2021) mostram que:  

- Casais com renda combinada acima de 5 salários mínimos têm taxa de divórcio 40% menor.  
- Para famílias abaixo de 2 salários, conflitos por dinheiro são a 3ª maior causa de divórcio (atrás apenas de infidelidade e violência).  

Isso ocorre porque a pobreza gera estresse crônico, reduzindo a "reserva emocional" para resolver conflitos. Um estudo da UFMG acompanhou 300 casais por 10 anos e descobriu que:  

> "Cada R$ 1.000 a mais na renda mensal reduz em 7% a chance de discussões recorrentes sobre finanças."  

### O Divórcio como Ajuste Financeiro  

A decisão de divorciar também é econômica. Mulheres pobres divorciadas sofrem uma queda média de 30% na renda (FGV, 2020), enquanto homens de classe alta costumam manter ou aumentar seus ganhos. A explicação está em três fatores:  

1. **Pensão alimentícia**: Só 43% dos ex-maridos pagam em dia (Defensoria Pública SP, 2023).  
2. **Dupla jornada**: Mulheres divorciadas trabalham 8h a mais por semana que os ex-cônjuges (IBGE).  
3. **Patrimônio**: 72% dos imóveis ficam com homens em divórcios não consensuais (OAB/SP).  

### Exercício Prático  

Analise este caso real:  

**Casal Silva**  
- Renda conjunta: R$ 4.000/mês (ele: R$ 2.500; ela: R$ 1.500)  
- Filhos: 2 (5 e 8 anos)  
- Dívidas: R$ 20.000 (financiamento de carro + cartão de crédito)  

Pergunta: Se eles se divorciarem, qual será o impacto financeiro para a esposa, considerando que:  
a) Ela ficará com a guarda das crianças;  
b) O ex-marido pagará pensão de 30% do seu salário;  
c) As dívidas serão rateadas?  

**Solução**:  
```python  
renda_ex_marido = 2500  
pensao = 0.3 * renda_ex_marido  # 750 reais  
divida_mulher = 20000 / 2  # 10.000 reais  
nova_renda_mulher = 1500 + pensao  # 2.250 reais  

print(f"Renda pós-divórcio: R$ {nova_renda_mulher:.2f}")  
print(f"Dívida assumida: R$ {divida_mulher:.2f}")  
print(f"Redução percentual da renda: {(4000 - 2250) / 4000 * 100:.1f}%")  
```  
Saída:  
```  
Renda pós-divórcio: R$ 2250.00  
Dívida assumida: R$ 10000.00  
Redução percentual da renda: 43.8%  
```  

Conclusão: Mesmo com pensão, a esposa perderá quase metade da renda familiar original, enquanto o ex-marido manterá R$ 1.750 (2500 - 750), mais 70% de seu salário anterior. Esse desequilíbrio explica por que muitas mulheres adiam o divórcio — não por amor, mas por necessidade.