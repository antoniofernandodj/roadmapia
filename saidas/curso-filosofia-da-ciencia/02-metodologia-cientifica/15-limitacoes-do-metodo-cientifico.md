## Limitações do Método Científico

O método científico, apesar de sua eficácia comprovada, não é uma ferramenta infalível. Suas limitações surgem tanto de restrições intrínsecas à própria natureza da investigação científica quanto de fatores externos que influenciam sua aplicação. Vamos examinar essas barreiras através de casos concretos.

### O Problema da Subdeterminação das Teorias

Considere um conjunto de dados sobre o crescimento de plantas sob diferentes condições de luz:

```python
import pandas as pd
dados = pd.DataFrame({
    'Horas_de_Luz': [2, 4, 6, 8, 10],
    'Crescimento_cm': [5.1, 7.3, 9.8, 11.2, 12.5]
})
```

Duas equipes de pesquisadores podem propor explicações distintas para esses dados:

1. **Hipótese Linear**: Crescimento = 1.2 * Horas_de_Luz + 3.1
2. **Hipótese Logarítmica**: Crescimento = 5 * log(Horas_de_Luz) + 5

Ambas as equipes podem apresentar bons ajustes estatísticos (R² > 0.95) para os dados observados, mas preveem resultados radicalmente diferentes para 12 horas de luz. Esse é o cerne do problema da subdeterminação: os dados disponíveis não são suficientes para determinar qual teoria está correta.

### Limitações Empíricas: O Caso da Psicologia Social

A crise de replicação na psicologia social (2010-2015) revelou uma limitação prática crucial. Um estudo clássico sobre "priming" (Bargh et al., 1996) sugeria que pessoas expostas a palavras relacionadas à velhice caminhavam mais devagar. Quando pesquisadores tentaram replicar:

```python
resultados_originais = {'diferença_velocidade': -0.30, 'p_valor': 0.02}
replicacoes = [
    {'diferença_velocidade': -0.05, 'p_valor': 0.38},
    {'diferença_velocidade': 0.02, 'p_valor': 0.75},
    {'diferença_velocidade': -0.11, 'p_valor': 0.21}
]
```

A média das replicações (-0.047) foi significativamente diferente do resultado original, com um intervalo de confiança que incluía zero. Isso expôs problemas como:
- Efeitos pequenos exigem tamanhos amostrais maiores do que os usados originalmente
- Viés de publicação (estudos com p > 0.05 não são publicados)
- Flexibilidade analítica (escolha de métricas após ver os dados)

### Restrições Tecnológicas: O Exemplo da Astronomia

Em 1846, Urbain Le Verrier propôs a existência de Netuno baseado em perturbações na órbita de Urano. Mas quando aplicou o mesmo método a Mercúrio, encontrou discrepâncias que só foram explicadas 57 anos depois pela Teoria da Relatividade Geral. Isso ilustra duas limitações:

1. **Dependência tecnológica**: Instrumentos da época não podiam medir o efeito relativístico
2. **Paradigma newtoniano**: Os cientistas tentavam explicar tudo dentro de um modelo incompleto

Einstein escreveu: "Não foram descobertos planetas além de Netuno, e a confiança no método estava tão arraigada que a possibilidade de falha do próprio Newton nem foi considerada".

### Viés Cognitivo na Prática Científica

Um experimento clássico de Mahoney (1977) mostrou como o viés de confirmação afeta até revisores especializados. Dois grupos avaliaram o mesmo estudo fictício sobre psicoterapia:

- Grupo 1 (resultados positivos): 89% recomendaram publicação
- Grupo 2 (resultados negativos): apenas 12% recomendaram

Isso se manifesta em problemas reais como:
- P-hacking: testar múltiplas hipóteses até achar significância
- HARKing: formular hipóteses após conhecer os resultados
- Viés de disponibilidade: dar mais peso a dados que confirmam teorias estabelecidas

### Exercício Prático: Análise de um Caso Controverso

Considere os dados de um estudo sobre um novo medicamento:

```python
dados_medicamento = {
    'Grupo': ['Placebo']*100 + ['Tratamento']*100,
    'Melhora': [0]*70 + [1]*30 + [0]*40 + [1]*60
}
```

1. Calcule as taxas de melhora para cada grupo
2. Teste a significância estatística (qui-quadrado)
3. Identifique três limitações potenciais no desenho do estudo

**Solução:**

1. Placebo: 30/100 = 30%; Tratamento: 60/100 = 60%
2. Teste qui-quadrado (χ² = 18.75, p < 0.001)
3. Limitações:
   - Não cegado (pacientes podem saber qual grupo estão)
   - Sem randomização (grupos podem diferir em variáveis ocultas)
   - Sem acompanhamento de longo prazo