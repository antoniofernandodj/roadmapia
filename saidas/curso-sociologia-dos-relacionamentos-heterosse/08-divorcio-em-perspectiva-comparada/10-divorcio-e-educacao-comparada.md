## Divórcio e Educação Comparada

No Brasil, mulheres com ensino superior completo divorciam-se 3 vezes mais que aquelas com apenas o fundamental, segundo o IBGE (2021). Esse padrão se repete em países como França e Canadá, mas inverte-se na Turquia, onde mais escolarização significa menos divórcios. Por quê?

### O Efeito da Educação na Autonomia Feminina

Quando uma brasileira completa a faculdade:
1. Seu salário médio sobe 147% (IPEA, 2022)
2. Seu círculo social inclui mais mulheres independentes
3. Ela reconhece mais rapidamente relacionamentos abusivos

Veja como isso se traduz em dados reais:

```python
# Simulação baseada em microdados da PNAD
import pandas as pd

dados_divorcio = {
    'Escolaridade': ['Fundamental', 'Médio', 'Superior'],
    'Divórcios_por_1000': [12, 27, 41],
    'Idade_Média_Divórcio': [39, 34, 31]
}

df = pd.DataFrame(dados_divorcio)
print(df)
```

Saída:
```
  Escolaridade  Divórcios_por_1000  Idade_Média_Divórcio
0   Fundamental                  12                    39
1        Médio                  27                    34
2     Superior                  41                    31
```

O código mostra três fenômenos simultâneos:
- A taxa de divórcio triplica entre os extremos educacionais
- Mulheres escolarizadas divorciam-se mais jovens
- O "pico" do divórcio migra da meia-idade para os 30 anos

### O Caso Japonês: Quando Educação Não Liberta

No Japão, mulheres com doutorado divorciam-se menos que as graduadas. A explicação está em dois fatores culturais:
1. **Pressão Social**: "Mulher de verdade não abandona o matrimônio" (Yamada, 2020)
2. **Mercado de Trabalho**: Empresas discriminam solteiras acima dos 35 anos

Tabela comparativa Brasil-Japão (dados normalizados):

| Escolaridade | Brasil (% divórcio) | Japão (% divórcio) |
|--------------|---------------------|--------------------|
| Fundamental  | 12                  | 8                  |
| Médio        | 27                  | 15                 |
| Superior     | 41                  | 22                 |
| Pós-graduação | 38                 | 18                 |

### O Paradoxo dos Países Nórdicos

Suécia e Noruega apresentam um padrão inesperado:
- Educação universal desde os anos 1970
- Taxas de divórcio estagnadas desde 2005
- 72% dos divórcios são iniciados por homens (contra 85% por mulheres no Brasil)

Isso ocorre porque:
1. Políticas públicas garantem autonomia independente da educação formal
2. Homens assumem 45% das tarefas domésticas (contra 31% no Brasil)
3. O estigma social do divórcio desapareceu

### Exercício Prático

Analise este dado hipotético de Portugal:

```python
dados_portugal = {
    'Nível_Educacional': ['Baixo', 'Médio', 'Alto'],
    'Idade_Casamento': [22, 26, 30],
    'Duração_Casamento': [11, 9, 6]
}
```

**Pergunta**: Com base nos padrões estudados, qual seria a provável taxa de divórcio para cada grupo, considerando que:
- Portugal tem forte tradição católica
- 40% das mulheres trabalham em tempo integral
- Creches públicas cobrem 60% da demanda

**Solução Esperada**:

Padrão provável:
1. **Baixa escolaridade**: Divórcios ~15/1000 (casamentos precoces, mas com forte pressão religiosa)
2. **Média escolaridade**: Divórcios ~25/1000 (equilíbrio entre autonomia e tradição)
3. **Alta escolaridade**: Divórcios ~35/1000 (mulheres adiam casamento e têm mais independência)

A justificativa combina:
- Fator Brasil (educação como empoderamento)
- Fator Japão (tradição religiosa moderadora)
- Dados concretos (idade e duração dos casamentos)