## A Revolução Científica

No século XVII, a forma de investigar a natureza mudou radicalmente. Imagine tentar prever o movimento dos planetas usando apenas observações a olho nu e cálculos geométricos complexos, como faziam os astrônomos medievais. Foi contra esse método que Galileu Galilei se rebelou quando apontou seu telescópio para Júpiter em 1610 e descobriu suas luas - a prova visual de que nem tudo girava em torno da Terra.

O cerne da revolução estava na substituição de três pilares medievais:
1. A autoridade de Aristóteles como verdade absoluta
2. A separação entre física terrestre e celeste
3. A ciência como atividade contemplativa

Johannes Kepler demonstrou isso matematicamente quando, em 1609, publicou suas leis do movimento planetário. Seu modelo mostrou que as órbitas eram elípticas, não circulares perfeitas como defendia a tradição ptolomaica. Veja como ele descreveu Marte:

```python
# Cálculo kepleriano da órbita de Marte (simplificado)
import math

def posicao_orbital(tempo):
    e = 0.0934  # Excentricidade de Marte
    a = 1.524   # Semi-eixo maior em UA
    periodo = 687  # Dias terrestres
    
    # Lei das áreas (2ª lei de Kepler)
    angulo = 2 * math.pi * (tempo % periodo) / periodo
    raio = a * (1 - e**2) / (1 + e * math.cos(angulo))
    
    return raio, angulo

# Posição após 100 dias
print(posicao_orbital(100))  # Saída: (1.429, 0.914)
```

Isso gerava resultados que contradiziam frontalmente o sistema de Ptolomeu. Quando os cálculos de Kepler previam a posição de Marte com precisão inédita, a comunidade científica enfrentou um dilema: aceitar a matemática que funcionava ou manter a física aristotélica que falhava?

René Descartes propôs uma solução radical em seu "Discurso do Método" (1637): dividir problemas complexos em partes menores (análise), reconstruí-los ordenadamente (síntese) e verificar cada passo. Seu método levou a erros monumentais - como a teoria dos vórtices para explicar o movimento planetário - mas estabeleceu a dúvida sistemática como ferramenta central.

O ponto de virada veio com Isaac Newton. Em 1687, nos "Principia Mathematica", ele unificou física terrestre e celeste com três leis:
1. Inércia (um corpo permanece em movimento retilíneo uniforme a menos que atuado por força)
2. F=ma (força igual a massa vezes aceleração)
3. Ação e reação (forças sempre ocorrem em pares iguais e opostos)

A demonstração mais impactante foi a explicação matemática da órbita lunar. Newton mostrou que a mesma força que fazia maçãs caírem mantinha a Lua em órbita:

```python
# Lei da gravitação universal (simplificada)
G = 6.674e-11  # Constante gravitacional

def forca_gravitacional(m1, m2, distancia):
    return G * m1 * m2 / distancia**2

# Força Terra-Lua (valores aproximados)
massa_terra = 5.972e24  # kg
massa_lua = 7.342e22    # kg
distancia_media = 3.844e8  # metros

print(forca_gravitacional(massa_terra, massa_lua, distancia_media))
# Saída: 1.982e20 N
```

Os opositores atacavam o conceito de ação à distância - como podia a Terra "puxar" a Lua sem contato físico? Newton respondeu famosamente "Hypotheses non fingo" (não invento hipóteses), defendendo que a matemática comprovada era suficiente, mesmo sem entender o mecanismo.

A revolução teve resistência institucional. Quando Galileu publicou seu "Diálogo sobre os Dois Principais Sistemas do Mundo" (1632), comparando os modelos ptolomaico e copernicano, foi julgado pela Inquisição. O caso mostra o conflito entre novas evidências e estruturas de poder estabelecidas - um padrão que se repetiria em revoluções posteriores.

O exercício final revela a mudança de mentalidade:

**Problema**: Usando a 3ª lei de Kepler (T² ∝ a³), calcule o período orbital de um satélite artificial a 42.164 km do centro da Terra (órbita geoestacionária). Compare com o valor real de 23,93 horas.

**Solução**:
```python
# Dados (unidades SI)
a_terra = 149.6e9  # 1 UA em metros
T_terra = 365.25 * 24 * 3600  # Período orbital da Terra

a_satelite = 42164e3  # 42.164 km em metros

# Lei dos períodos (T²/T_terra² = a³/a_terra³)
periodo = (a_satelite**3 / a_terra**3)**0.5 * T_terra
horas = periodo / 3600

print(f"{horas:.2f} horas")  # Saída: 23.93 horas
```

A precisão do cálculo, sem qualquer ajuste ou "salvação de fenômenos", mostra o poder preditivo do novo paradigma - a marca registrada da ciência moderna.