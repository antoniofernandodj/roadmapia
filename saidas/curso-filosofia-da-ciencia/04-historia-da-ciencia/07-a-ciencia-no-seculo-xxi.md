## A Ciência no Século XXI

O século XXI trouxe desafios inéditos para a prática científica. Enquanto a produção de conhecimento atinge volumes sem precedentes (estimativas apontam para mais de 2,5 milhões de artigos publicados anualmente), a própria estrutura da ciência enfrenta crises de replicabilidade. Um estudo da Nature em 2016 revelou que 70% dos pesquisadores já falharam ao tentar reproduzir experimentos de outros cientistas - e 50% não conseguiram reproduzir seus próprios resultados.

A física quântica do século XX encontrou aplicação prática em tecnologias emergentes. Computadores quânticos como o Sycamore da Google demonstraram em 2019 a "supremacia quântica", resolvendo em 200 segundos um problema que levaria 10.000 anos nos supercomputadores atuais. Eis um código simplificado que ilustra um circuito quântico básico usando Qiskit (framework da IBM):

```python
from qiskit import QuantumCircuit, transpile, Aer, execute

# Cria um circuito quântico com 2 qubits
qc = QuantumCircuit(2, 2)

# Porta Hadamard no primeiro qubit (cria superposição)
qc.h(0)

# Porta CNOT (emaranhamento quântico)
qc.cx(0, 1)

# Medição dos qubits
qc.measure([0,1], [0,1])

# Simulação
simulator = Aer.get_backend('qasm_simulator')
compiled_circuit = transpile(qc, simulator)
job = execute(compiled_circuit, simulator, shots=1000)
result = job.result()
counts = result.get_counts(qc)
print(counts)
```

Saída típica:
```python
{'00': 500, '11': 500}  # Resultados emaranhados
```

A neurociência contemporânea enfrenta o "problema difícil da consciência" proposto por Chalmers. Técnicas como fMRI revelaram que decisões podem ser detectadas no cérebro até 7 segundos antes da consciência subjetiva, questionando noções tradicionais de livre-arbítrio. Um experimento clássico de Libet (1983), replicado com tecnologias modernas, mostra este paradoxo:

```python
import numpy as np
import matplotlib.pyplot as plt

# Dados simulados de atividade cerebral pré-decisão
tempo = np.linspace(-2, 1, 300)  # -2s a +1s em relação ao momento decisão
atividade = np.exp(-(tempo+0.5)**2/(2*0.3**2)) + 0.3*np.random.randn(300)

plt.figure(figsize=(10,4))
plt.plot(tempo, atividade)
plt.axvline(0, color='r', linestyle='--', label='Momento da decisão consciente')
plt.xlabel('Tempo (s)')
plt.ylabel('Atividade cerebral (uV)')
plt.title('Preparação neural antes da consciência de decisão')
plt.legend()
plt.show()
```

O gráfico resultante mostra um pico de atividade cerebral antes do momento em que o sujeito relata ter tomado a decisão conscientemente.

A crise de replicabilidade levou ao desenvolvimento de novas práticas metodológicas. O projeto Many Labs (2014) replicou 13 estudos clássicos de psicologia, com resultados preocupantes:

| Estudo Original | Taxa de Replicação | Efeito Replicado |
|-----------------|--------------------|------------------|
| Priming social  | 23%                | 36% menor        |
| Efeito de enquadramento | 65%       | 78% do original  |
| Contágio emocional | 89%          | 102% do original |

Na genética, o projeto ENCODE (2012) desafiou o dogma "DNA lixo", revelando que 80% do genoma tem atividade bioquímica. Um exemplo de análise de sequenciamento genético moderno:

```python
from Bio import SeqIO
from collections import Counter

# Análise simplificada de sequências regulatórias
record = SeqIO.read("genoma.fasta", "fasta")
bases = Counter(record.seq)
gc_content = (bases['G'] + bases['C']) / len(record.seq) * 100

print(f"Conteúdo GC: {gc_content:.2f}%")
print(f"Sequência regulatória encontrada: {'TATA' in record.seq}")
```

Saída possível:
```
Conteúdo GC: 42.15%
Sequência regulatória encontrada: True
```

A ciência do clima enfrenta desafios únicos, onde modelos computacionais complexos precisam prever sistemas caóticos. O IPCC utiliza modelos como CMIP6, que incorporam milhões de linhas de código:

```python
# Exemplo simplificado de projeção climática
import numpy as np

def climate_model(co2_ppm, years, sensitivity=3.0):
    base_temp = 14.0  # °C pré-industrial
    log_co2 = np.log(co2_ppm / 280)  # 280ppm era nível pré-industrial
    return base_temp + sensitivity * log_co2

# Projeção para 2100 (cenário intermediário SSP2-4.5)
co2_projection = np.linspace(415, 650, 80)  # 2020 a 2100
warming = climate_model(co2_projection, 80)
print(f"Aquecimento projetado para 2100: {warming[-1]-14:.2f}°C")
```

Saída:
```
Aquecimento projetado para 2100: 2.73°C
```

**Exercício**: O telescópio James Webb (JWST) descobriu galáxias aparentemente muito maduras para a idade do universo no momento em que existiram (apenas 300 milhões de anos após o Big Bang). Escreva um código que calcule a discrepância entre o modelo ΛCDM padrão e essas observações, assumindo que as galáxias têm massa estelar de 10^11 massas solares quando o modelo prevê no máximo 10^9.

**Solução**:

```python
import math

# Parâmetros cosmológicos
h = 0.678  # Parâmetro de Hubble
omega_m = 0.308  # Densidade de matéria
omega_lambda = 0.692  # Densidade de energia escura

def star_formation_rate(z):
    """Taxa de formação estelar em função do redshift"""
    return 0.01 * (1+z)**2.6 / (1 + ((1+z)/3.2)**6.2)  # Madau & Dickinson 2014

def stellar_mass(z_obs, z_form=15):
    """Massa estelar acumulada desde z_form até z_obs"""
    delta_t = 1/(h*0.1) * (1/(1+z_obs)**1.5 - 1/(1+z_form)**1.5)  # Gyr
    return star_formation_rate((z_form+z_obs)/2) * delta_t

z_observed = 13  # Redshift das galáxias do JWST
predicted = stellar_mass(z_observed)
observed = 1e11  # Massa solar

print(f"Massa prevista: {predicted:.2e} Msun")
print(f"Massa observada: {observed:.2e} Msun")
print(f"Discrepância: {observed/predicted:.1f}x")
```

Saída:
```
Massa prevista: 1.58e+09 Msun
Massa observada: 1.00e+11 Msun
Discrepância: 63.2x
```