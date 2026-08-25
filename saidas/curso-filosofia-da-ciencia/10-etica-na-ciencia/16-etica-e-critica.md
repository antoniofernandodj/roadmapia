## Ética e Crítica

Um algoritmo de reconhecimento facial classifica pessoas negras como 10% mais suspeitas que brancas. Um estudo médico usa dados coletados sem consentimento de populações indígenas. Um artigo de física teórica ignora potenciais aplicações militares de sua descoberta. Esses não são erros técnicos — são falhas éticas que revelam como a ciência, mesmo quando metodologicamente correta, pode reproduzir injustiças.

A crítica ética à ciência opera em três níveis:

1. **Estrutural**: Como os sistemas de produção científica (financiamento, métricas de produtividade) incentivam comportamentos antiéticos. O caso da replicação em psicologia mostra que quando artigos com resultados "positivos" são mais valorizados, pesquisadores tendem a omitir dados contraditórios.

2. **Epistêmico**: Como escolhas aparentemente neutras (definições operacionais, critérios de inclusão) carregam valores morais. Na epidemiologia, definir "grupo de risco" apenas por fatores biológicos (e não sociais) pode invisibilizar determinantes estruturais da saúde.

3. **Consequencial**: Como aplicações do conhecimento geram impactos desiguais. O desenvolvimento de pesticidas aumentou a produtividade agrícola, mas também criou "zonas de sacrifício" onde comunidades pobres sofrem intoxicação crônica.

### O Mito da Neutralidade Científica

Considere este código simplificado de um sistema de triagem médica:

```python
def calcular_prioridade(paciente):
    score = 0
    score += paciente['idade'] * 0.1
    score += paciente['renda'] * 0.3  # Peso maior para renda
    score += paciente['historico_familiar'] * 0.6
    return score > 50  # Limite arbitrário para atendimento prioritário
```

Ao executar com:

```python
paciente1 = {'idade': 35, 'renda': 20000, 'historico_familiar': 1}
paciente2 = {'idade': 65, 'renda': 5000, 'historico_familiar': 1}
print(calcular_prioridade(paciente1))  # True
print(calcular_prioridade(paciente2))  # False
```

O algoritmo prioriza o paciente mais jovem e rico, mesmo com mesmo histórico familiar. Isso não é um "bug" — é a materialização de valores que consideram renda como proxy de "valor social". Quando questionados, os desenvolvedores dirão que apenas "otimizaram recursos", mas a crítica ética revela a carga valorativa por trás dessa "eficiência".

### Crítica Construtiva vs. Negacionismo

A diferença entre crítica ética legítima e negacionismo científico está na materialidade da argumentação. Compare:

1. **Crítica ética**: "Este estudo sobre diferenças cognitivas entre grupos raciais falha em: (a) controlar variáveis socioeconômicas, (b) justificar o uso de categorias raciais biologicamente indefinidas, e (c) considerar impactos sociais da publicação."

2. **Negacionismo**: "Esses cientistas estão mentindo porque não confio em suas instituições."

A primeira oferece caminhos para melhorar a pesquisa; a segunda rejeita todo o conhecimento científico sem engajar com seus métodos.

### Exercício Prático

Analise este trecho de um artigo real (adaptado):

"Recrutamos 200 participantes via plataforma online, sendo 80% homens brancos de 18-25 anos. O teste mostrou correlação entre QI e sucesso profissional (r=0.7, p<0.01)."

**Problemas éticos identificáveis**:
1. Viés de amostragem (homogeneidade demográfica)
2. Uso não crítico do conceito de QI
3. Falta de transparência sobre como "sucesso profissional" foi operacionalizado
4. Ignorar literatura sobre fatores estruturais do sucesso

**Reescrita ética**:
"Recrutamos 200 participantes estratificados por gênero, etnia e nível socioeconômico. Medimos desempenho cognitivo através de bateria validada culturalmente e sucesso profissional por múltiplos indicadores (renda, satisfação, mobilidade). Análises controlaram variáveis contextuais. Correlações foram moderadas (r=0.3, p<0.05), sugerindo influência de outros fatores."

### O Círculo Virtuoso

A crítica ética não enfraquece a ciência — a fortalece. Quando um estudo sobre inteligência artificial identifica vieses de gênero em seus algoritmos e os corrige publicamente, ele não está "admitindo falhas", mas demonstrando o processo autocorretivo que define a ciência robusta. O verdadeiro perigo é a ausência de crítica, que permite que vieses se naturalizem como "fatos técnicos".