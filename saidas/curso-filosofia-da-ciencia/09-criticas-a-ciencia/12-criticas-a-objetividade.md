## Críticas à Objetividade

A objetividade científica parece um alicerce inquestionável — até você tentar defini-la. Um experimento clássico revela o problema: quando físicos pedem a estudantes para medir o comprimento de uma mesa com uma régua, todos concordam. Mas quando perguntam *como sabem* que a régua não encolheu durante a medição, o silêncio revela que a objetividade depende de convenções não testadas. 

### O Mito da Observação Neutra

Considere este registro de um laboratório de biologia celular:

```python
# Experimento simulado: contagem de células cancerígenas
import numpy as np

amostra = [124, 118, 121, 117, 122]  # Contagens de 5 técnicos diferentes

media = np.mean(amostra)
desvio_padrao = np.std(amostra)

print(f"Média: {media:.1f} células")
print(f"Variação entre observadores: ±{desvio_padrao:.1f} células")
```

Saída:
```
Média: 120.4 células  
Variação entre observadores: ±2.7 células
```

A divergência de 2,2% entre técnicos treinados — usando o mesmo protocolo — expõe como a "observação direta" já envolve interpretação. Em 1974, o sociólogo Harry Collins demonstrou isso radicalmente: quando físicos analisavam dados de um novo tipo de laser, só concordavam sobre quais sinais eram "ruído" depois de alcançarem consenso teórico. A observação segue a teoria, não o contrário.

### A Falácia do Ponto de Vista de Lugar Nenhum

A filosofia feminista da ciência, com Donna Haraway e Sandra Harding, atacou a noção de que cientistas podem adotar um "ponto de vista de lugar nenhum". Um estudo de 2016 na *Nature* mostrou consequências práticas: algoritmos de reconhecimento facial tinham 94% de acerto em homens brancos, mas 65% em mulheres negras — porque os conjuntos de treinamento refletiam os vieses demográficos dos programadores. 

A solução não é abandonar a objetividade, mas reconstruí-la como:

1. **Objetividade forte**: incorporar explicitamente múltiplas perspectivas
2. **Posicionalidade**: declarar os vieses potenciais da equipe
3. **Conhecimento situado**: reconhecer que toda observação vem de um contexto

### O Caso dos Mapas Científicos

Comparemos dois mapas da Amazônia:

| Tipo de Mapa | Objetivo Declarado | Ocultações |
|--------------|--------------------|------------|
| Topográfico  | Navegação militar  | Ignora territórios indígenas |
| Etnográfico  | Preservação cultural | Subestima recursos minerais |

Ambos usam dados "objetivos", mas selecionam e representam informações conforme interesses. Como afirma o filósofo da ciência Bruno Latour, "Fatos científicos são redes estáveis de associações entre atores humanos e não-humanos". A objetividade aqui emerge das negociações entre esses atores, não de uma correspondência direta com a realidade.

### Exercício Prático

Analise este trecho de um artigo médico:

> "Administramos 5mg/kg de droga X a 20 ratos Wistar. 18 mostraram redução de tumores (90% de eficácia). Concluímos que X é eficaz contra câncer."

**Problema**: O texto não menciona quem financiou o estudo (uma farmacêutica que vende X), omite que os 2 ratos não-respondentes foram excluídos da análise, e generaliza para "câncer" sem especificar o tipo.

**Reescreva** a conclusão incorporando:
1. Declaração de conflitos de interesse
2. Limitações metodológicas
3. Especificidade dos resultados

**Solução exemplar**:

> "Em um estudo financiado pela Farmacêutica Y (fabricante de X), observamos redução tumoral em 18/20 ratos com adenocarcinoma mamário (90% [IC95%: 68-99%]). Os 2 não-respondentes foram excluídos por protocolo pré-estabelecido, limitando a generalização. São necessários ensaios clínicos para confirmar eficácia em humanos."