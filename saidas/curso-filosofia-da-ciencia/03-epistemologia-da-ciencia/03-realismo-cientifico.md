## Realismo Científico

Imagine que você está diante de um microscópio observando bactérias se dividirem. O realismo científico afirma que essas bactérias existem de fato, independentemente de sua observação, e que as leis da biologia que descrevem seu comportamento correspondem a aspectos genuínos da realidade. Essa posição filosófica contrasta com visões que consideram o conhecimento científico como meras construções humanas ou instrumentos úteis para previsões, sem compromisso com a verdade última.

O núcleo do realismo científico pode ser decomposto em três teses fundamentais:

1. **Tese ontológica**: As entidades postuladas pelas teorias científicas bem-sucedidas (como átomos, campos gravitacionais ou genes) existem objetivamente, independentemente de nossas mentes.
2. **Tese semântica**: As afirmações científicas devem ser interpretadas literalmente, como descrições da realidade, e não como metáforas ou ficções úteis.
3. **Tese epistemológica**: As teorias científicas maduras fornecem conhecimento aproximadamente verdadeiro sobre o mundo, incluindo aspectos inobserváveis.

Um exemplo clássico é a teoria atômica. Quando John Dalton propôs que a matéria era composta de átomos no século XIX, muitos consideraram essa ideia uma mera hipótese. Hoje, com microscópios de tunelamento que mostram átomos individuais, o realista argumenta que a teoria revelou uma verdade profunda sobre a natureza da matéria, não sendo apenas um modelo conveniente.

Considere este caso concreto:

```python
# Analogia computacional: Modelo vs. Realidade
class Realidade:
    def __init__(self):
        self.leis_fundamentais = "E=mc²"
    
    def produzir_fenomeno(self):
        return "Radiação Hawking observada"

class ModeloCientifico:
    def prever(self):
        return "Radiação Hawking observada"

experiencia = Realidade()
modelo = ModeloCientifico()

print(experiencia.produzir_fenomeno() == modelo.prever())  # Saída: True
```

Neste código, a correspondência entre a saída do modelo e o fenômeno real ilustra a visão realista: quando o modelo acerta, isso ocorre porque capturou algo da estrutura subjacente da realidade, não por coincidência.

**Objeção comum e resposta realista:**

"Se o realismo fosse verdadeiro, por que teorias antigas como a mecânica newtoniana foram substituídas?" O realista estrutural responde que mesmo teorias substituídas preservam elementos estruturais corretos. A mecânica newtoniana ainda descreve com precisão o movimento de objetos em baixas velocidades, mostrando que continha verdades parciais sobre a estrutura do mundo.

Um experimento mental ajuda a entender o debate:

```python
def teoria_cientifica(realista=True):
    if realista:
        return "As entidades teóricas correspondem a objetos reais"
    else:
        return "As entidades teóricas são apenas instrumentos de cálculo"

# Testando as consequências
for crenca in [True, False]:
    print(f"Se {teoria_cientifica(crenca)}, então a ciência descobre ou inventa?")
```

Saída:
```
Se As entidades teóricas correspondem a objetos reais, então a ciência descobre ou inventa?
Se As entidades teóricas são apenas instrumentos de cálculo, então a ciência descobre ou inventa?
```

O realista sustenta que a ciência descobre fatos pré-existentes, enquanto o anti-realista vê a ciência como um processo de invenção de modelos. O sucesso preditivo da ciência, para o realista, seria inexplicável se as teorias não estivessem progressivamente se aproximando da verdade.

**Exercício:** Analise a descoberta das ondas gravitacionais em 2016. Um realista argumentaria que:
a) A detecção confirmou uma previsão de Einstein de 1915, mostrando que a relatividade geral descreve aspectos genuínos da realidade
b) O fenômeno só "existe" porque nossos instrumentos o mediram
c) É apenas um modelo útil para unificar a física
d) A confirmação foi acidental e não reflete verdade objetiva

**Solução comentada:** A resposta (a) representa a posição realista. A detecção direta das ondas gravitacionais por instrumentos como o LIGO é interpretada como evidência de que o espaço-tempo realmente se curva na presença de massas, conforme previsto pela teoria. As outras opções representam formas de anti-realismo (b-c) ou ceticismo radical (d).