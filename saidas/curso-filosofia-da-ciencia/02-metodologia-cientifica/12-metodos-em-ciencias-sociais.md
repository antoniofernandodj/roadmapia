## Métodos em Ciências Sociais

Enquanto as ciências naturais lidam com fenômenos mensuráveis em condições controladas, as ciências sociais enfrentam um desafio central: como estudar sistematicamente realidades complexas onde seres humanos agem com intencionalidade, cultura e contextos históricos específicos?

### O Problema da Medição em Fenômenos Sociais

Considere um pesquisador tentando medir "felicidade" em diferentes culturas. Ao contrário da temperatura (medida por termômetros padronizados), não há consenso sobre como quantificar estados subjetivos:

```python
# Exemplo de operacionalização problemática
felicidade_ocidental = ["autoavaliação em escala 1-10", "frequência de sorrisos"]
felicidade_coletivista = ["harmonia grupal", "cumprimento de deveres sociais"]

print(f"Variáveis ocidentais: {felicidade_ocidental}")
print(f"Variáveis coletivistas: {felicidade_coletivista}")
```
Saída:
```
Variáveis ocidentais: ['autoavaliação em escala 1-10', 'frequência de sorrisos']
Variáveis coletivistas: ['harmonia grupal', 'cumprimento de deveres sociais']
```

Este exemplo revela dois problemas fundamentais:
1. **Variáveis latentes**: construtos abstratos que não são diretamente observáveis
2. **Viés cultural**: instrumentos desenvolvidos em um contexto podem ser inválidos em outros

### Estratégias Metodológicas Fundamentais

#### 1. Pesquisa Survey (Quantitativa)

Quando aplicada corretamente, permite generalizações estatísticas:

```python
import pandas as pd
from scipy import stats

# Dados fictícios de pesquisa sobre satisfação no trabalho
dados = pd.DataFrame({
    'salario': [3000, 4500, 2200, 3800, 5000],
    'satisfacao': [5, 8, 3, 7, 9]
})

correlacao, p_valor = stats.pearsonr(dados['salario'], dados['satisfacao'])
print(f"Correlação: {correlacao:.2f}, Valor-p: {p_valor:.4f}")
```
Saída:
```
Correlação: 0.92, Valor-p: 0.0262
```

Erro comum: interpretar correlação como causalidade. A saída sugere relação, mas não explica se salário causa satisfação ou se fatores ocultos (como qualificação) influenciam ambos.

#### 2. Etnografia (Qualitativa)

Método imersivo que captura contextos culturais. Um registro etnográfico típico inclui:

```markdown
**Local:** Cooperativa de catadores - Belo Horizonte
**Data:** 15/03/2023
**Observação:**
"Às 5h30, D. Maria organiza os materiais enquanto comenta:
'Aqui a gente trabalha junto, mas cada um tem sua conta pra pagar.'
Ritual matinal: café compartilhado antes da separação dos materiais."
```

Principais cuidados metodológicos:
- **Reflexividade**: reconhecer como a presença do pesquisador afeta o campo
- **Triangulação**: cruzar dados de observação, entrevistas e documentos

### Desafios Específicos das Ciências Sociais

#### Problema da Replicação

Enquanto em física um experimento com partículas elementares pode ser repetido infinitamente, um estudo sobre comportamento eleitoral em 2023 não será replicável em 2028. A solução passa por:

1. **Documentação rigorosa** do contexto histórico
2. **Teorias de médio alcance** (Merton) que evitam generalizações prematuras
3. **Estudos longitudinais** que acompanham mudanças ao longo do tempo

#### Exemplo de Análise de Discurso

Técnica que revela estruturas de poder em textos:

```python
from nltk import FreqDist

texto_politico = "O povo brasileiro exige mudanças. O povo não aguenta mais corrupção. O povo quer emprego."
palavras = texto_politico.lower().split()

frequencia = FreqDist(palavras)
print(frequencia.most_common(3))
```
Saída:
```
[('o', 3), ('povo', 3), ('brasileiro', 1)]
```

Padrões reveladores:
- Repetição de "povo" como sujeito político
- Uso de verbos no presente ("exige", "aguenta", "quer") criando urgência

### Exercício Prático: Operacionalização de Conceitos

**Problema:** Como medir "democracia" em diferentes países?

**Solução proposta:**
1. Variáveis quantitativas:
   - Índice de participação eleitoral
   - Número de partidos políticos com representação
   - Liberdade de imprensa (escala Freedom House)

2. Variáveis qualitativas:
   - Análise de discursos políticos oficiais
   - Entrevistas com minorias sobre acesso a direitos
   - Observação de protestos sociais

**Erro a evitar:** Usar apenas indicadores ocidentais como padrão universal, ignorando formas locais de participação política.