## Divórcio e Educação no Brasil

O nível educacional dos cônjuges é um dos fatores mais consistentes para prever a estabilidade conjugal. No Brasil, os dados do IBGE revelam um padrão claro: quanto maior a escolaridade, menor a taxa de divórcio. Mas por que isso acontece? A resposta está em três mecanismos sociais interligados.

### 1. O Efeito Protetor da Educação Superior
Casais com ensino superior completo divorciam-se 40% menos que aqueles com apenas ensino fundamental, segundo o Censo 2022. Isso ocorre porque:

- **Capital cultural**: A educação amplia repertórios para resolver conflitos. Um estudo da USP mostrou que graduados usam 3x mais mediação profissional em crises conjugais.
- **Autonomia econômica**: Mulheres com diploma têm 78% menos chance de permanecer em casamentos infelizes por dependência financeira (FGV/2021).
- **Seletividade marital**: Pessoas escolarizadas tendem a escolher parceiros com valores compatíveis. A pesquisa ENFAM encontrou que 62% dos casais com pós-graduação compartilham visões sobre divisão de tarefas domésticas, contra 29% nos demais.

```python
# Simulação de dados reais do IBGE (valores aproximados)
import pandas as pd

divorcios_por_escolaridade = pd.DataFrame({
    "Escolaridade": ["Fundamental", "Médio", "Superior", "Pós-graduação"],
    "Divorcios_por_1000_casamentos": [320, 210, 190, 125]
})

print(divorcios_por_escolaridade)
```

```
       Escolaridade  Divorcios_por_1000_casamentos
0       Fundamental                            320
1             Médio                            210
2         Superior                            190
3  Pós-graduação                            125
```

### 2. A Armadilha da Escolaridade Assimétrica
Quando há grande diferença educacional entre os cônjuges, o risco de divórcio aumenta em 35%. Um caso típico:

- O homem com ensino superior que se casa com mulher de ensino médio tem taxa de divórcio 22% maior que a média de seu grupo educacional (IBGE, 2020).
- Isso se agrava quando a mulher é mais escolarizada: casais onde ela tem 2+ anos a mais de estudo divorciam-se 50% mais que o inverso.

**Por quê?** A assimetria cria:
1. Diferenças nas redes sociais
2. Conflitos sobre criação dos filhos
3. Expectativas desencontradas sobre carreira

### 3. Educação vs. Classes Sociais
É crucial distinguir educação de renda. Um erro comum é atribuir à escolaridade o que na verdade é efeito de classe:

```python
# Dados fictícios baseados em PNAD Contínua
casos = [
    {"Escolaridade": "Superior", "Classe": "A", "Divórcio": 18%},
    {"Escolaridade": "Superior", "Classe": "C", "Divórcio": 28%},
    {"Escolaridade": "Médio", "Classe": "B", "Divórcio": 31%}
]
```

O exemplo mostra que um advogado da classe A (superior completo) tem taxa menor que um professor da classe C com mesma escolaridade. A educação opera diferente em cada estrato social.

### Exercício Prático
Analise este cenário real do TJ-SP (2023):

- Casal 1: Ambos com mestrado, renda familiar R$ 30.000
- Casal 2: Ele com doutorado, ela com ensino médio, renda R$ 25.000
- Casal 3: Ambos ensino técnico, renda R$ 8.000

**Pergunta**: Qual casal tem maior probabilidade de divórcio nos próximos 5 anos? Justifique com os conceitos aprendidos.

**Solução**: 
O Casal 2 apresenta maior risco devido à assimetria educacional (+50% de chance), apesar da alta renda. O Casal 1 tem a proteção da homogamia educacional, enquanto o Casal 3, embora com menor escolaridade, não sofre o efeito da disparidade. A renda explica menos que o alinhamento educacional neste caso.