## Paradigmas e Revoluções Científicas

Um paradigma científico não é eterno. Quando anomalias — fenômenos que o paradigma vigente não consegue explicar — se acumulam, a comunidade científica enfrenta uma crise. Esse é o gatilho para revoluções científicas, onde um novo paradigma substitui o antigo, redefinindo o que conta como problema legítimo e solução aceitável.

### O Mecanismo das Revoluções

Thomas Kuhn, em *A Estrutura das Revoluções Científicas*, descreve o processo:

1. **Ciência Normal**: Pesquisa dentro do paradigma estabelecido, resolvendo "quebra-cabeças" previsíveis (ex: cálculos orbitais no modelo ptolomaico).
2. **Anomalias Persistentes**: Dados que resistem à explicação (ex: órbitas irregulares de Urano no século XIX).
3. **Crise**: O paradigma perde credibilidade, multiplicam-se teorias concorrentes.
4. **Revolução**: Um novo paradigma ganha adeptos (ex: mecânica quântica substituindo a física clássica em escalas atômicas).

Exemplo concreto: a transição da teoria do flogisto (século XVIII) para a química moderna de Lavoisier. O flogisto explicava a combustão como liberação de uma substância invisível, mas falhava ao:
- Prever ganho de massa na calcinação de metais
- Explicar por que alguns materiais não queimavam

Lavoisier propôs o oxigênio como agente da combustão, redefinindo conceitos básicos como "elemento químico". Isso não foi um acréscimo de conhecimento — foi uma reescrita das regras do jogo.

### Incomensurabilidade Paradigmática

A mudança não é cumulativa. Paradigmas rivais são *incomensuráveis*: usam linguagens e critérios diferentes. Comparar newtonianos e einsteinianos é como traduzir entre línguas sem dicionário comum:

| Paradigma Newtoniano          | Paradigma Einsteiniano         |
|-------------------------------|--------------------------------|
| Tempo absoluto                | Tempo relativo ao observador   |
| Gravidade como força          | Gravidade como curvatura do espaço-tempo |
| Espaço euclidiano fixo        | Espaço-tempo dinâmico          |

Isso explica a resistência inicial às novas ideias. Quando Max Planck introduziu os quanta em 1900, até ele tentou reconciliá-los com a física clássica. A geração seguinte (Heisenberg, Schrödinger) adotou a ruptura mais facilmente.

### Exercício Prático: Identificando Revoluções

Analise este trecho de um artigo de 1911 sobre radioatividade:

> "A desintegração espontânea de elementos como o rádio desafia os princípios da conservação da matéria. Propomos que a energia liberada segue uma lei estatística, não determinística."

1. Qual anomalia ao paradigma clássico é citada?
2. Que conceito novo está sendo introduzido?
3. Como isso prenuncia uma revolução?

**Solução comentada**:
1. A radioatividade violava o princípio clássico de conservação da matéria (anomalia).
2. Leis estatísticas substituem o determinismo rigoroso (mudança metodológica).
3. Isso levou à mecânica quântica, onde probabilidade é fundamental — uma ruptura completa com a física newtoniana.

### Erro Comum: Confundir Evolução com Revolução

Um equívoco frequente é chamar qualquer avanço de "revolucionário". A relatividade geral foi revolucionária; a descoberta do DNA foi extraordinária, mas dentro do paradigma bioquímico existente. A diferença está na redefinição dos fundamentos:

```python
# Evolução (dentro do paradigma)
def calcular_orbita_ajustada(massa, dados_observados):
    """Aplica equações newtonianas com correções empíricas"""
    return massa * dados_observados * 1.000132  # Fator de ajuste

# Revolução (novo paradigma)
class EspaçoTempoCurvo:
    def __init__(self, tensor_energia):
        self.métrica = resolver_equações_campo(tensor_energia)
    
    def prever_orbita(self):
        return self.métrica.solução_geodésica()
```

O primeiro caso adapta o modelo vigente; o segundo exige novas ferramentas matemáticas e conceituais.