## Gênero e Sociologia

A divisão de tarefas domésticas em um casal heterossexual brasileiro raramente segue uma lógica de eficiência, mas sim um script cultural invisível. Quando Maria, professora com jornada dupla, lava a louça após o jantar enquanto Carlos, seu marido, "ajuda" ocasionalmente, estamos diante de um padrão documentado pelo IBGE: mulheres dedicam 21,3 horas semanais a afazeres domésticos, contra apenas 10,9 horas dos homens. Essa discrepância não é natural - é construída.

### O Gênero como Estrutura Relacional

Pierre Bourdieu demonstrou como o gênero opera como um "habitus": um sistema de disposições incorporadas que orientam comportamentos sem necessidade de coerção explícita. Na prática conjugal brasileira, isso se manifesta quando:

1. **Cuidado infantil**: Mesmo em lares onde ambos trabalham fora, 74% das decisões sobre saúde das crianças cabem às mães (PNAD 2019)
2. **Lazer conjugal**: Homens tendem a manter hobbies individuais (futebol com amigos), enquanto mulheres adaptam seus tempos livres à dinâmica familiar
3. **Conflitos financeiros**: Discussões sobre gastos frequentemente reproduzem o estereótipo do homem "provedor" versus mulher "administradora"

```python
# Simulação de divisão de tempo em casais heterossexuais (dados fictícios baseados em PNAD)
import pandas as pd

atividades = ['Trabalho remunerado', 'Tarefas domésticas', 'Cuidados com filhos', 'Lazer']
homem = [45, 8, 5, 12]
mulher = [38, 22, 18, 6]

df = pd.DataFrame({'Atividade': atividades, 'Homem (horas/semana)': homem, 'Mulher (horas/semana)': mulher})
print(df)
```

Saída:
```
          Atividade  Homem (horas/semana)  Mulher (horas/semana)
0  Trabalho remunerado                   45                     38
1   Tarefas domésticas                    8                     22
2   Cuidados com filhos                   5                     18
3               Lazer                    12                      6
```

### A Revolução Incompleta

A socióloga Arlie Hochschild cunhou o termo "revolução estagnada" para descrever como, apesar das mulheres terem invadido o espaço público (mercado de trabalho), os homens não ocuparam proporcionalmente o espaço privado (lar). No Brasil, isso gera um paradoxo mensurável:

- 72% das mulheres empregadas são as principais responsáveis pelas tarefas domésticas
- Casais onde há divisão igualitária relatam 23% mais satisfação conjugal (IPEA 2021)
- Contudo, apenas 5% dos lares brasileiros praticam essa divisão de forma consistente

### O Peso das Representações

A mídia reforça esses padrões através de representações desequilibradas. Análise de 100 comerciais de produtos de limpeza (2020-2022) mostra:

- 89% protagonizados por mulheres
- 62% associam sujeira à "falta de cuidado feminino"
- Apenas 3% mostram homens realizando tarefas sem tom cômico

### Exercício Prático

Registre por 3 dias a distribuição de tarefas em seu círculo social próximo (própria casa, pais, amigos casados). Categorize:

1. Quem inicia cada atividade doméstica?
2. Quem define os padrões de limpeza/organização?
3. Como conflitos sobre divisão são resolvidos?

**Solução esperada**: A maioria identificará padrões como:
- Mulheres como "gerentes domésticas" (delegam tarefas, não as compartilham)
- Homens realizando tarefas "masculinizadas" (lixo, manutenção)
- Disputas por "ajuda" versus "corresponsabilidade"

Essa observação direta revela como o gênero estrutura interações cotidianas que, somadas, compõem a arquitetura invisível do casamento heterossexual brasileiro.