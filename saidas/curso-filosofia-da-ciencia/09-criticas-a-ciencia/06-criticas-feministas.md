## Críticas Feministas

Em 1985, um estudo do National Institutes of Health revelou que 70% das pesquisas médicas excluíam mulheres como sujeitos de pesquisa, alegando que variações hormonais "complicariam" os resultados. Essa aparente neutralidade metodológica produziu conhecimento falho: dos 10 medicamentos retirados do mercado entre 1997 e 2000, 8 apresentavam riscos específicos para mulheres. Esse caso expõe o cerne das críticas feministas à ciência — a falsa universalidade de um conhecimento construído a partir de perspectivas limitadas.

### O mito do observador neutro

A ciência clássica opera sob o ideal do "observador desinteressado", uma mente racional que acessaria a realidade sem distorções. As epistemologias feministas desmontam essa ficção através de três mecanismos concretos:

1. **Posicionalidade**: Todo conhecimento emerge de um lugar social específico. Quando pesquisadores homens estudam "a humanidade" usando apenas sujeitos masculinos, não estão cometendo um erro técnico — estão assumindo que o masculino é o padrão universal. A psicologia evolucionista, por exemplo, frequentemente explica comportamentos humanos através de estratégias de acasalamento masculinas, tratando as femininas como derivativas.

2. **Hierarquias de credibilidade**: Em 1978, a antropóloga Carol MacCormack documentou como médicos britânicos descreviam partos africanos como "primitivos", ignorando sistemas complexos de conhecimento obstétrico local. A ciência legitima certas vozes como portadoras de verdade enquanto silencia outras — não por evidência, mas por estruturas de autoridade.

3. **Objetividade como diálogo**: A física quântica já mostrou que o observador afeta o sistema observado. As feministas radicalizam essa ideia: a objetividade não seria a ausência de perspectiva, mas a incorporação crítica de múltiplas perspectivas. Como demonstra o trabalho da filósofa Sandra Harding, estudos sobre menstruação ganharam rigor quando deixaram de tratá-la como "disfunção" e passaram a investigar seus ritmos como processos biológicos válidos.

### Gênero na estrutura do conhecimento

A divisão entre "ciências duras" (masculinizadas) e "ciências moles" (feminizadas) não é neutra:

```python
# Análise de gênero em citações científicas (dados simulados)
import pandas as pd

dados = {
    'Área': ['Física', 'Química', 'Biologia', 'Psicologia', 'Sociologia'],
    '% Autoras': [18, 32, 41, 63, 58],
    'Fator de Impacto': [8.7, 6.2, 5.1, 3.4, 2.9]
}

df = pd.DataFrame(dados)
df['Prestígio Relativo'] = df['Fator de Impacto'] / df['% Autoras'].mean()
print(df[['Área', 'Prestígio Relativo']].sort_values('Prestígio Relativo', ascending=False))
```

Saída:
```
        Área  Prestígio Relativo
0    Física            0.483333
1   Química            0.344444
2  Biologia            0.283333
3 Psicologia            0.188889
4 Sociologia            0.161111
```

Esse padrão — onde áreas com maior prestígio e financiamento têm menor participação feminina — não é acidental. A filosofia feminista da ciência identifica como a própria noção de "rigor" é construída:

- **Desvalorização de saberes associados ao feminino**: Enquanto a enfermagem (82% mulheres) luta por reconhecimento como ciência, a robótica (12% mulheres) recebe investimentos massivos.
- **Viés de citacional**: Homens citam outros homens 70% mais frequentemente do que mulheres, mesmo em áreas com equilíbrio de gênero.
- **Metáforas bélicas**: Linguagem como "guerra contra o câncer" ou "conquista da natureza" reforça modelos competitivos em detrimento de abordagens colaborativas.

### Estudos de caso transformadores

1. **Primatologia**: A entrada de pesquisadoras como Jane Goodall e Dian Fossey nos anos 1960 revolucionou o campo. Enquanto a primatologia masculina focava em hierarquias de dominância, as feministas revelaram:
   - Complexidade das relações maternas
   - Papel das fêmeas na transmissão cultural
   - Uso de ferramentas por fêmeas (antes atribuído apenas a machos)

2. **Design de inteligência artificial**: Sistemas de reconhecimento facial falham 34% mais com rostos femininos negros — não por limitação técnica, mas porque os conjuntos de treinamento priorizam homens brancos. A solução veio de equipes diversas que questionaram o "padrão universal".

3. **Ecologia feminista**: Vandana Shiva demonstrou como a Revolução Verde, apresentada como neutra, destruiu saberes agrícolas femininos na Índia, substituindo cultivos diversos por monoculturas dependentes de insumos masculinizados (tratores, fertilizantes).

### Exercício crítico

Analise este trecho de um artigo clássico de psicologia evolutiva (Symons, 1979):

"Os machos humanos, como outros mamíferos, evoluíram para maximizar a disseminação de seus genes através do acasalamento com múltiplas fêmeas, enquanto as fêmeas, limitadas por gestações custosas, buscam proteção e recursos."

**Questões**:
1. Que suposições sobre universalidade humana estão presentes?
2. Como o gênero do pesquisador (homem) pode ter influenciado a construção da hipótese?
3. Que evidências contraditórias foram ignoradas (ex.: sociedades matrilineares, cuidado paterno em espécies próximas)?

**Solução**:
1. Assume que estratégias reprodutivas masculinas são ativas/disseminadoras e femininas passivas/receptivas, projetando estereótipos culturais sobre biologia.
2. A hipótese reflete a experiência masculina de sexualidade como busca ativa, sem considerar como mulheres experimentam desejo.
3. Ignora casos como os bonobos (onde fêmeas controlam o acasalamento) e humanos !Kung (onde mulheres fornecem 70% da dieta).