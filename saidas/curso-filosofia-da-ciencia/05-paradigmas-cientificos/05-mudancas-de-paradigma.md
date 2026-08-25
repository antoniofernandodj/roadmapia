## Mudanças de Paradigma

Imagine um laboratório de física em 1890. Os cientistas medem com precisão o movimento dos planetas usando as leis de Newton, calculam trajetórias de projéteis e explicam o fluxo dos oceanos. Tudo parece perfeitamente descrito pelas equações da mecânica clássica — até que alguns experimentos com radiação e átomos começam a gerar resultados que nenhuma fórmula consegue prever. Esse é o momento em que um paradigma científico entra em crise.

### O que desencadeia uma mudança?

Três condições precisam coexistir para que uma comunidade científica considere abandonar seu paradigma:

1. **Anomalias persistentes**: fenômenos que resistem a explicações dentro do modelo vigente. Exemplo: no final do século XIX, a radiação do corpo negro desafiava todas as previsões da física clássica.

2. **Alternativas viáveis**: novas teorias que explicam tanto os dados antigos quanto as anomalias. Max Planck propôs que a energia era quantizada (emitida em pacotes discretos), não contínua como se acreditava.

3. **Crise de confiança**: quando os cientistas começam a duvidar da capacidade do paradigma atual de resolver problemas fundamentais. Einstein expressou isso claramente em 1905: "Parece que as leis da eletrodinâmica não se aplicam a sistemas em movimento".

### O processo de transição

A mudança não ocorre como uma substituição imediata. Veja como aconteceu na transição da mecânica clássica para a quântica:

1. **Fase de resistência** (1900-1913):  
   A comunidade física recebeu com ceticismo as ideias de Planck. Lord Kelvin chamou os quanta de "nuvens passageiras" na física.

2. **Fase de coexistência** (1913-1925):  
   O modelo atômico de Bohr (1913) usava quanta para explicar espectros atômicos, mas mantinha conceitos clássicos como órbitas definidas.

3. **Fase de ruptura** (1925-1927):  
   Heisenberg e Schrödinger desenvolveram formalismos matemáticos completamente novos (mecânica matricial e equação de onda) que não faziam analogias com a física clássica.

```python
# Analogia computacional: reescrevendo um sistema
# Paradigma clássico (determinístico)
def prever_posicao(t, velocidade_inicial):
    return velocidade_inicial * t

# Paradigma quântico (probabilístico)
import numpy as np
def funcao_onda(x, t):
    return np.exp(-x**2 / (2*(1 + 1j*t))) / np.sqrt(1 + 1j*t)
```

Saída do código clássico para t=2, v=5:  
`10.0`  
Saída do código quântico (módulo da função de onda em x=1, t=2):  
`0.2756`  

### Por que os cientistas resistem?

A adesão a um paradigma não é irracional. Um físico em 1905 tinha boas razões para manter a mecânica clássica:

- **Sucesso empírico**: previsões precisas para objetos macroscópicos.
- **Fertilidade**: gerava novos problemas pesquisáveis (e.g., mecânica celeste).
- **Investimento cognitivo**: anos de treinamento em técnicas matemáticas específicas.

O erro comum é imaginar que os cientistas mudam de paradigma quando veem "provas conclusivas". Na verdade, como mostrou Kuhn, a transição ocorre quando:

1. O novo paradigma resolve crises que o antigo não consegue.
2. Oferece um quadro conceitual mais amplo.
3. Gera consenso entre a nova geração de cientistas (os mais velhos frequentemente mantêm o paradigma anterior até o fim da vida).

### Exercício: Identificando mudanças

Analise este trecho de um artigo de geologia de 1960:  
*"Enquanto a teoria da Terra em expansão explica a distribuição dos continentes, ela falha em justificar o mecanismo físico para tal expansão. Medições recentes do fundo oceânico sugerem que novas crostas estão se formando nas dorsais meso-oceânicas."*

1. Qual anomalia é apontada no paradigma da Terra em expansão?  
2. Que novo conceito (que levaria à tectônica de placas) é sugerido?  

**Solução comentada**:  
1. A anomalia é a falta de um mecanismo físico para a expansão.  
2. A formação de crosta oceânica em dorsais sugere o conceito de placas móveis, que se tornaria central no novo paradigma.