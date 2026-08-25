## Filosofia da Economia

Um agricultor colhe 100kg de trigo. Um padeiro transforma esse trigo em 80 pães. Um entregador distribui os pães para 10 famílias. Quanto vale cada etapa desse processo? A filosofia da economia investiga justamente a natureza desse valor que parece invisível, mas organiza toda a vida social.

### O paradoxo do valor

Em 1776, Adam Smith formulou o que ficou conhecido como "paradoxo da água e do diamante": por que a água, essencial à vida, tem valor de troca tão baixo, enquanto diamantes, meros adornos, valem fortunas? A resposta clássica envolve dois conceitos:

1. **Valor de uso**: utilidade prática do bem (alta para água, baixa para diamantes)
2. **Valor de troca**: relação quantitativa entre mercadorias (baixa para água, alta para diamantes)

```python
# Simulando o paradoxo
class Bem:
    def __init__(self, nome, valor_uso, valor_troca):
        self.nome = nome
        self.valor_uso = valor_uso  # Escala de 1-10
        self.valor_troca = valor_troca  # Em unidades monetárias

agua = Bem("Água", 10, 1)
diamante = Bem("Diamante", 2, 10000)

print(f"{agua.nome}: Uso={agua.valor_uso}, Troca=${agua.valor_troca}")
print(f"{diamante.nome}: Uso={diamante.valor_uso}, Troca=${diamante.valor_troca}")
```

Saída:
```
Água: Uso=10, Troca=$1
Diamante: Uso=2, Troca=$10000
```

### Teorias do valor

Marx propôs uma solução radical: o valor deriva exclusivamente do trabalho humano incorporado na mercadoria. Seu cálculo do "valor-trabalho" pode ser representado como:

```
Valor = Tempo de trabalho socialmente necessário × Número de trabalhadores
```

Já a Escola Marginalista, no século XIX, inverteu a lógica: o valor emerge da utilidade marginal (o quanto a última unidade consumida satisfaz necessidades). Um exemplo numérico:

| Copos de água consumidos | Utilidade marginal |
|-------------------------|--------------------|
| 1º                      | 10                 |
| 2º                      | 8                  |
| 3º                      | 5                  |
| 4º                      | 2                  |
| 5º                      | 0                  |

Aqui, o valor do 1º copo é maior que o do 5º, embora seja a mesma água.

### A revolução keynesiana

Quando Keynes questionou a "mão invisível" do mercado em 1936, trouxe um problema filosófico profundo: como agregar preferências individuais em escolhas coletivas racionais? Sua equação fundamental mostra o dilema:

```
Demanda Agregada = Consumo + Investimento + Gastos Governamentais + (Exportações - Importações)
```

O erro comum é presumir que otimização individual leva à ótimo social. A falácia da composição mostra o contrário:

```python
# Paradoxo da poupança
def economia(poupanca_individual):
    consumo_total = 100 - poupanca_individual
    if all(poupanca_individual > 5 for _ in range(10)):
        return "Recessão: consumo insuficiente"
    return "Economia estável"

print(economia(4))  # Cada um poupa 4%
print(economia(6))  # Cada um poupa 6%
```

Saída:
```
Economia estável
Recessão: consumo insuficiente
```

### A natureza do dinheiro

O dinheiro moderno é uma ficção coletiva sustentada por três propriedades filosóficas:

1. **Meio de troca**: aceitação universal como intermediário
2. **Reserva de valor**: capacidade de manter poder de compra no tempo
3. **Unidade de conta**: padrão de medida abstrato

Quando o Bitcoin surgiu em 2009, testou esses princípios. Sua equação de oferta (simplificada) revela o constructo artificial:

```
Novos Bitcoins = max(0, 21.000.000 - Bitcoins em circulação) × 0,5^(ano/4)
```

### Economia como sistema complexo

A crise de 2008 expôs a fragilidade dos modelos econômicos tradicionais diante de:

- **Emergência**: propriedades do sistema não redutíveis às partes (como bolhas especulativas)
- **Não linearidade**: pequenas causas podem gerar grandes efeitos (efeito borboleta)
- **Retroalimentação**: ciclos viciosos ou virtuosos (como profecias autorrealizáveis)

Um modelo simplificado de crise:

```python
class Economia:
    def __init__(self):
        self.confianca = 100
        
    def crise(self):
        if self.confianca < 50:
            self.confianca -= 10  # Espiral negativa
            return "Crise se aprofunda"
        return "Estabilidade"

sistema = Economia()
sistema.confianca = 45
print(sistema.crise())  # Saída: "Crise se aprofunda"
```

### Exercício

Um país tem 1.000 trabalhadores: 400 na agricultura (produzem 2 toneladas de alimento cada), 300 na indústria (3 produtos cada) e 300 em serviços (4 transações cada). Calcule:

1. O produto total sob a teoria do valor-trabalho (1 dia de trabalho = 1 unidade de valor)
2. O valor por setor se serviços valem 2x indústria e 4x agricultura (abordagem marginalista)

**Solução comentada**:

1. Valor-trabalho:
   - Agricultura: 400 trabalhadores × 1 = 400
   - Indústria: 300 × 1 = 300
   - Serviços: 300 × 1 = 300
   - Total = 400 + 300 + 300 = 1.000 unidades

2. Valor marginal:
   - Se agricultura = x, indústria = 2x, serviços = 4x
   - 400x + 300(2x) + 300(4x) = 400x + 600x + 1200x = 2200x
   - Para totalizar 1.000: 2200x = 1000 → x ≈ 0,4545
   - Agricultura: 400 × 0,4545 ≈ 181,8
   - Indústria: 600 × 0,4545 ≈ 272,7
   - Serviços: 1200 × 0,4545 ≈ 545,5