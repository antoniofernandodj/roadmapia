## Paradigmas e Métodos Científicos

Um cientista do século XVIII mede a temperatura da água fervente com um termômetro de mercúrio e anota 100°C. Seu colega do século XXI, usando sensores digitais em um laboratório de nanotecnologia, obtém 99,983°C. Ambos estão certos — dentro de seus paradigmas. O que muda não é a água, mas os métodos que cada época considera válidos para conhecê-la.

### O círculo entre paradigma e método

Thomas Kuhn demonstrou que paradigmas científicos determinam:

1. **O que conta como problema científico válido**: Na física aristotélica, perguntar "por que os objetos caem?" era irrelevante — a "tendência ao lugar natural" era axiomática.
2. **Os instrumentos legítimos**: Galileu foi criticado por usar telescópios, considerados brinquedos ópticos pela academia de seu tempo.
3. **Os padrões de prova**: Um ensaio clínico randomizado seria rejeitado no século XIX por violar princípios médicos individuais.

Exemplo concreto: compare os métodos de dois artigos sobre depressão:

```markdown
1. **Artigo positivista (2015)**
   - Método: Escalas HAM-D aplicadas a 1.200 pacientes
   - Análise: Modelos estatísticos de regressão linear
   - Paradigma implícito: Depressão como entidade mensurável e quantificável

2. **Artigo fenomenológico (2020)**
   - Método: Entrevistas narrativas com 15 participantes
   - Análise: Interpretação hermenêutica das experiências
   - Paradigma implícito: Depressão como construção subjetiva
```

O mesmo fenômeno exige métodos radicalmente diferentes conforme o paradigma. Tentar aplicar análise estatística às entrevistas narrativas gera erros metodológicos graves:

```python
# ERRO paradigmático: Quantificar dados qualitativos
entrevistas = ["Me sinto vazio", "É como um peso", "Não vejo cores"]
media = sum(len(frase) for frase in entrevistas) / len(entrevistas)  # Absurdo metodológico
```

### A ditadura dos paradigmas dominantes

Os paradigmas estabelecem hierarquias de métodos:

1. **Hierarquia de evidências na medicina**: 
   - Topo: Meta-análises de ensaios randomizados
   - Base: Relatos de caso e opinião de especialistas

2. **Ciências sociais**:
   - Positivismo: Dados quantitativos > qualitativos
   - Construcionismo: Validade interna > replicabilidade

Um estudo de 2018 na *Nature* mostrou que 73% dos artigos em psicologia usavam exclusivamente métodos quantitativos — não por adequação ao objeto, mas por pressão do paradigma dominante.

### Quando os métodos revelam anomalias

A história da ciência mostra que crises paradigmáticas frequentemente começam com falhas metodológicas:

1. **Física pré-quântica**:
   - Método: Medições precisas de radiação de corpos negros
   - Anomalia: Dados inconsistentes com equações de Rayleigh-Jeans
   - Resultado: Surgimento da teoria quântica

2. **Psicologia cognitiva**:
   - Método: Tempos de reação em tarefas laboratoriais
   - Anomalia: Dados não explicavam decisões no mundo real
   - Resultado: Ascensão da psicologia ecológica

### Exercício: Análise de métodos paradigmáticos

Leia este trecho de um artigo real e responda:

> "Aplicamos fMRI a 50 participantes durante tarefas de reconhecimento facial. Os dados foram processados com SPM12 usando um modelo GLM. Áreas com p<0.05 FWE foram consideradas significativas."

1. Qual paradigma científico está em ação?
2. Que métodos alternativos seriam rejeitados neste paradigma?
3. Que tipo de crítica um pesquisador interpretativista faria?

**Solução comentada**:

1. **Paradigma neurocognitivo positivista**: Assume que processos mentais correspondem a atividade cerebral mensurável.
2. **Métodos excluídos**: Entrevistas fenomenológicas, análises discursivas, estudos introspectivos.
3. **Crítica interpretativista**: Reduz a experiência subjetiva de reconhecer rostos a padrões de ativação neural, ignorando o significado cultural e pessoal.