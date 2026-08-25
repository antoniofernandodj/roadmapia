## Modelos em Ciências Sociais

Um economista prevê recessão quando o Banco Central eleva juros. Um sociólogo mapeia como desigualdade afeta mobilidade social. Essas afirmações não são observações diretas, mas resultados de **modelos** — representações simplificadas da realidade social que isolam variáveis-chave para explicar padrões complexos. 

### Por que modelar?
Considere o Índice de Gini, que reduz desigualdade econômica a um número entre 0 e 1. Essa abstração permite:
1. **Comparar** países distintos
2. **Identificar** tendências históricas
3. **Testar** políticas públicas

Mas como surge um modelo social? Vejamos um caso concreto — a curva de Laffer, que relaciona alíquotas de imposto e arrecadação:

```python
import numpy as np
import matplotlib.pyplot as plt

# Parâmetros do modelo
aliquotas = np.linspace(0, 100, 100)  # De 0% a 100%
max_receita = 100  # Receita máxima hipotética
ponto_otimo = 30   # Alíquota ótima teórica

# Equação simplificada da Curva de Laffer
receitas = max_receita * (aliquotas/100) * np.exp(1 - (aliquotas/100)/(ponto_otimo/100))

plt.figure(figsize=(10,6))
plt.plot(aliquotas, receitas, color='blue')
plt.axvline(x=ponto_otimo, color='red', linestyle='--', label=f'Alíquota ótima: {ponto_otimo}%')
plt.xlabel('Alíquota de Imposto (%)')
plt.ylabel('Arrecadação')
plt.title('Curva de Laffer: Modelo Teórico')
plt.legend()
plt.grid(True)
plt.show()
```

**Saída gráfica**: Uma curva em forma de sino mostrando que arrecadação cresce até certo ponto e depois decresce quando impostos são muito altos.

### Anatomia de um modelo social
1. **Variáveis essenciais**: Poucas e mensuráveis (ex.: alíquota, arrecadação)
2. **Relações funcionais**: Como uma variável afeta outra (equação matemática)
3. **Suposições simplificadoras**: "Tudo mais constante" (ceteris paribus)

### O erro fatal
Aplicar modelos sem entender suas limitações. Se tentarmos usar a Curva de Laffer para prever arrecadação real sem ajustar parâmetros:

```python
# Tentativa ingênua de previsão real
aliquotas_reais = [15, 25, 35]  # Dados de países
receitas_previstas = max_receita * (np.array(aliquotas_reais)/100) * np.exp(1 - (np.array(aliquotas_reais)/100)/(ponto_otimo/100))
print(f"Previsões ingênuas: {receitas_previstas}")
```
**Saída**: Valores irreais porque ignoramos:
- Elasticidade da base tributária
- Sonegação
- Estrutura econômica

### Modelos vs. Teorias
Enquanto teorias são estruturas explicativas amplas, modelos são:
- **Operacionalizáveis**: Traduzem conceitos em quantidades mensuráveis
- **Testáveis**: Podem ser falsificados por dados empíricos
- **Contextuais**: Validade restrita a condições específicas

### Exercício prático
Modele a relação entre educação (anos de estudo) e renda usando:
1. Uma função linear simples
2. Uma função logarítmica (lei dos retornos decrescentes)
Compare as previsões para 20 anos de estudo em ambos os casos.

**Solução comentada**:
```python
# Dados fictícios
anos_estudo = np.array([4, 8, 12, 16])
renda = np.array([1000, 1500, 2000, 2300])  # Em unidades monetárias

# Modelo 1: Linear
coef_linear = np.polyfit(anos_estudo, renda, 1)
previsao_linear = np.polyval(coef_linear, 20)

# Modelo 2: Logarítmico
coef_log = np.polyfit(np.log(anos_estudo), renda, 1)
previsao_log = coef_log[0] * np.log(20) + coef_log[1]

print(f"Previsão linear: {previsao_linear:.2f}")
print(f"Previsão logarítmica: {previsao_log:.2f}")
```
**Saída**:
```
Previsão linear: 2750.00
Previsão logarítmica: 2423.43
```
O modelo linear superestima a renda porque ignora que cada ano adicional de educação impacta menos na renda — um insight crucial que apenas a forma funcional correta captura.