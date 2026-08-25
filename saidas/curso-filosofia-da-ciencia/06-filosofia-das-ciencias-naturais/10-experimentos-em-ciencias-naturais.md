## Experimentos em Ciências Naturais

Um tubo de ensaio quebra no laboratório. O líquido escorre, reage com o piso e produz fumaça. Esse acidente banal revela o núcleo dos experimentos em ciências naturais: intervenções controladas que forçam a natureza a responder perguntas específicas. Mas o que torna um experimento científico diferente de uma simples observação ou tentativa e erro?

### O experimento como interrogatório controlado

Em 1897, J.J. Thomson não "observou" o elétron - ele o extraiu da matéria através de um experimento com tubos de raios catódicos. Aplicando voltagens específicas em gases rarefeitos e medindo desvios causados por campos magnéticos, Thomson forçou a matéria a revelar propriedades que nenhuma observação passiva poderia demonstrar. Esse é o primeiro princípio dos experimentos naturais: **isolamento de variáveis**. 

Considere este exemplo simples de termodinâmica:

```python
# Experimento virtual: Lei de Boyle (P vs V a T constante)
import numpy as np
import matplotlib.pyplot as plt

volumes = np.linspace(10, 100, 50)  # cm³
pressao_constante = 100  # kPa
temperatura = 300  # K

# Lei de Boyle: PV = nRT → P = nRT/V
n = 0.004  # mols
R = 8.314  # J/(mol·K)
pressoes = (n * R * temperatura) / (volumes * 1e-6) / 1000  # Convertendo para kPa

plt.figure(figsize=(8,5))
plt.plot(volumes, pressoes, 'b-', linewidth=2)
plt.title('Lei de Boyle: Pressão x Volume (T constante)')
plt.xlabel('Volume (cm³)')
plt.ylabel('Pressão (kPa)')
plt.grid(True)
plt.show()
```

**Saída esperada:** Um gráfico hiperbólico mostrando a relação inversa entre pressão e volume, demonstrando como o controle da temperatura permite isolar a relação P-V.

### Replicabilidade e a crise dos falsos positivos

Em 2011, um experimento no CERN sugeriu que neutrinos viajavam mais rápido que a luz. O resultado, que violaria a relatividade especial, foi posteriormente atribuído a um cabo de fibra óptica mal conectado. Esse episódio ilustra o segundo pilar dos experimentos: **replicabilidade**. 

Um experimento científico deve:
1. Documentar todos os procedimentos com precisão suficiente para reprodução
2. Incluir controles negativos (o que acontece sem intervenção)
3. Estimar margens de erro sistemático

A tabela abaixo mostra como um experimento simples de queda de corpos pode ser documentado para replicação:

| Variável        | Controle          | Instrumento       | Precisão      |
|-----------------|-------------------|-------------------|--------------|
| Altura          | 2,00 m fixos      | Trena laser       | ±0,5 mm      |
| Tempo           | 3 repetições      | Cronômetro digital| ±0,01 s      |
| Resistência do ar| Câmara de vácuo   | Manômetro         | ±1 Pa        |

### O problema da subdeterminação

Mesmo experimentos cuidadosamente controlados enfrentam o dilema da subdeterminação: múltiplas teorias podem explicar os mesmos dados. Considere o experimento clássico da dupla fenda:

```python
# Simulação do padrão de interferência na dupla fenda
wavelength = 500e-9  # 500 nm
slit_separation = 0.1e-3  # 0.1 mm
screen_distance = 1.0  # 1 metro

y = np.linspace(-0.01, 0.01, 1000)  # Posições na tela
theta = np.arctan(y / screen_distance)
beta = (np.pi * slit_separation * np.sin(theta)) / wavelength
intensity = (np.sin(beta) / beta)**2 * np.cos(np.pi * slit_separation * np.sin(theta) / wavelength)**2

plt.figure(figsize=(10,5))
plt.plot(y*1000, intensity, 'r-', linewidth=1.5)  # Convertendo para mm
plt.title('Padrão de interferência da dupla fenda')
plt.xlabel('Posição na tela (mm)')
plt.ylabel('Intensidade relativa')
plt.grid(True)
plt.show()
```

**Saída esperada:** Um padrão de franjas claras e escuras que pode ser interpretado tanto pela teoria ondulatória clássica quanto pela interpretação probabilística quântica.

### Exercício: Projeto experimental

Projete um experimento para testar a hipótese: "A taxa de evaporação da água é proporcional à área da superfície exposta". Inclua:
1. Variáveis independentes e dependentes
2. Controles necessários
3. Possíveis fontes de erro sistemático
4. Método de coleta de dados

**Solução comentada:**

1. **Variáveis:**
   - Independente: área superficial (variar usando recipientes de diferentes diâmetros)
   - Dependente: massa de água evaporada (medir com balança analítica)
   - Controladas: temperatura ambiente, umidade, fluxo de ar, pressão atmosférica

2. **Controles:**
   - Recipiente selado como controle negativo
   - Mesmo volume inicial de água em todos os testes
   - Mesmo material dos recipientes (vidro limpo)

3. **Fontes de erro:**
   - Variações na umidade relativa do ar
   - Correntes de ar não uniformes
   - Precisão da balança (usar balança com ±0,001g)

4. **Método:**
   - Medir massa inicial (m₁)
   - Deixar por tempo fixo (ex: 24h)
   - Medir massa final (m₂)
   - Calcular Δm = m₁ - m₂ para cada área
   - Plotar Δm vs área e verificar linearidade