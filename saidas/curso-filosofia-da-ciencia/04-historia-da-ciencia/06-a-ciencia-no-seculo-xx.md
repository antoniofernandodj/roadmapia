## A Ciência no Século XX

O século XX começou com uma crise na física clássica. Em 1900, Lord Kelvin declarou que restavam apenas "duas pequenas nuvens" a serem explicadas: a radiação do corpo negro e o experimento de Michelson-Morley. Esses problemas aparentemente menores abriram caminho para duas revoluções: a mecânica quântica e a relatividade.

### A Crise da Física Clássica

A radiação do corpo negro era um problema concreto: objetos aquecidos emitem luz em cores específicas dependendo da temperatura. A física clássica previu que a energia emitida aumentaria infinitamente com a frequência (o "desastre ultravioleta"), contradizendo observações experimentais. Em 1900, Max Planck propôs uma solução radical: a energia não era contínua, mas vinha em pacotes discretos chamados "quanta". Ele mesmo considerou isso um truque matemático, não uma realidade física.

O experimento de Michelson-Morley (1887) buscava detectar o "éter luminífero", meio hipotético para propagação da luz. O resultado nulo abalou os fundamentos da física newtoniana. Em 1905, Einstein resolveu ambos os problemas com sua teoria da relatividade especial, abandonando conceitos absolutos de tempo e espaço.

### O Átomo deixa de ser indivisível

Em 1897, J.J. Thomson descobriu o elétron, mostrando que os átomos tinham estrutura interna. Seu modelo de "pudim de passas" foi substituído em 1911 pelo modelo nuclear de Rutherford, baseado no famoso experimento onde partículas alfa foram desviadas por um núcleo minúsculo. Isso levantou um novo problema: por que os elétrons em órbita não perdiam energia e colapsavam no núcleo?

Niels Bohr propôs em 1913 que os elétrons ocupavam órbitas específicas com energias quantizadas, saltando entre elas ao absorver ou emitir fótons. Isso explicava os espectros atômicos, mas era um modelo ad hoc. A mecânica quântica moderna surgiria na década de 1920 com Heisenberg (matrizes) e Schrödinger (equação de onda), introduzindo probabilidade na descrição fundamental da matéria.

### Consequências Filosóficas

A física quântica trouxe desafios conceituais profundos:

1. **Determinismo**: As previsões passaram a ser probabilísticas. Einstein contestou: "Deus não joga dados".
2. **Realidade**: O princípio da incerteza de Heisenberg (1927) limitou o conhecimento simultâneo de posição e momento.
3. **Observação**: O experimento da dupla fenda mostrou que partículas comportam-se como ondas até serem medidas.

Esses resultados questionaram noções clássicas de objetividade e causalidade, influenciando filósofos como Popper e Kuhn.

### Outras Revoluções

- **Genética**: Em 1953, Watson e Crick elucidaram a estrutura do DNA, unindo bioquímica com herança biológica.
- **Cosmologia**: A teoria do Big Bang (década de 1920) substituiu o universo estático de Einstein.
- **Computação**: Turing formalizou algoritmos (1936), fundando a ciência da computação teórica.

### Um Exemplo Concreto: O Efeito Fotoelétrico

Einstein explicou em 1905 que a luz libera elétrons de metais não por intensidade, mas por frequência (E=hν). Isso validou os quanta de Planck. Veja como isso contradizia a física clássica:

```python
# Simulação simplificada do efeito fotoelétrico
import matplotlib.pyplot as plt
import numpy as np

frequencias = np.linspace(4e14, 1e15, 100)  # Hz (visível a UV)
energia_foton = 6.626e-34 * frequencias     # E = hν (Joules)
limiar = 3e-19                              # Energia mínima para ejetar elétrons

plt.plot(frequencias, energia_foton)
plt.axhline(y=limiar, color='r', linestyle='--')
plt.xlabel('Frequência da luz (Hz)')
plt.ylabel('Energia do fóton (J)')
plt.title('Efeito Fotoelétrico: Energia vs Frequência')
plt.show()
```

Saída esperada: Um gráfico mostrando que apenas frequências acima de ~5.5×10¹⁴ Hz (linha vermelha) fornecem energia suficiente para ejetar elétrons, independentemente da intensidade luminosa.

### Exercício

Considere esta afirmação de Bohr em 1927: "Não há mundo quântico. Há apenas uma descrição quântica abstrata." Como isso contrasta com o realismo científico do século XIX? Escreva 200 palavras analisando as implicações epistemológicas.

**Solução comentada**: O realismo do século XIX assumia que teorias científicas descreviam diretamente a realidade (como átomos de Dalton). Bohr, influenciado pelo positivismo, defendia que a física quântica fornece apenas ferramentas para prever resultados experimentais, não uma "imagem" da realidade subjacente. Isso reflete uma mudança do realismo para o instrumentalismo na filosofia da ciência, onde o foco passa da "verdade" para a "utilidade" das teorias.