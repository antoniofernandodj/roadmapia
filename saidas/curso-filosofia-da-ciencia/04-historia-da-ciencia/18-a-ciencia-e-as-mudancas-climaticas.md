## A Ciência e as Mudanças Climáticas

O aumento médio de 1,1°C na temperatura global desde 1850 não seria compreensível sem a convergência de múltiplas disciplinas científicas. O físico John Tyndall, em 1859, demonstrou experimentalmente que certos gases - como CO₂ e metano - absorviam radiação infravermelha. Seu aparato, uma versão primitiva do espectrômetro moderno, consistia em um tubo com termopar que media diferenças de temperatura quando exposto a diferentes gases sob radiação térmica. Os dados brutos de seu caderno mostram:

```
[Experimento 12, 15/09/1859]
Ar seco: ΔT = 0,2°C 
Vapor d'água: ΔT = 3,1°C 
CO₂ (de calcário aquecido): ΔT = 4,7°C
```

Este efeito estufa natural, que mantém a Terra habitável, tornou-se problema quando Svante Arrhenius calculou em 1896 que a duplicação do CO₂ atmosférico elevaria a temperatura em 5-6°C. Sua equação pioneira:

ΔT = k · ln(CO₂_final/CO₂_inicial)

Onde k é uma constante empírica. Arrhenius errou nas previsões temporais (estimou 3000 anos para dobrar o CO₂), mas acertou no mecanismo físico. O erro veio de subestimar a taxa de queima de combustíveis fósseis - em 2023, já dobramos o CO₂ pré-industrial (de 280 para 420 ppm) em apenas 127 anos.

Os modelos climáticos modernos resolveram três desafios epistemológicos:

1. **Acoplamento de sistemas**: Um modelo típico como o CESM (Community Earth System Model) integra equações de Navier-Stokes para atmosfera, equações de transporte para oceanos, e modelos bioquímicos para ciclos de carbono. A versão 2.1.3 usa esta estrutura em Python:

```python
class ClimateModel:
    def __init__(self):
        self.atmosphere = NavierStokesSolver()
        self.ocean = OceanTransportModel()
        self.carbon = CarbonCycle()

    def timestep(self, dt):
        heat_flux = self.atmosphere.solve(dt)
        salinity = self.ocean.update(heat_flux)
        co2_flux = self.carbon.calculate(salinity)
        self.atmosphere.update_boundary(co2_flux)
```

2. **Validação paleoclimática**: Testar modelos contra dados históricos como testemunhos de gelo da Antártida. A amostra Vostok mostra correlação entre CO₂ e temperatura nos últimos 400.000 anos:

```
Idade (anos) | CO₂ (ppm) | ΔT (°C)
---------------------------------
120.000      | 190       | -8.2
20.000       | 180       | -7.1
10.000       | 260       | +0.5
```

3. **Incerteza quantificada**: O relatório AR6 do IPCC usa escalas de probabilidade calibradas:
   - "Virtualmente certo" (99-100%): temperaturas continuarão subindo
   - "Muito provável" (90-100%): aumento de eventos extremos
   - "Provável" (66-100%): acidificação oceânica acelerada

Críticas comuns enfrentam respostas científicas sólidas:

- *"O clima sempre mudou"*: Sim, mas a taxa atual é 10x mais rápida que qualquer mudança natural nos últimos 65 milhões de anos (dados de sedimentos oceânicos).
- *"Modelos são simplificações"*: O teste CMIP6 comparou 127 modelos independentes - todos previram aquecimento, variando apenas em magnitude.
- *"Houve um hiato no aquecimento"*: Reanálises mostraram que o calor estava sendo armazenado nos oceanos profundos (dados ARGO flutuantes).

O maior desafio atual é a não linearidade: pontos de inflexão como o colapso da camada de gelo da Groenlândia (já em curso a 286 Gt/ano) podem desencadear feedbacks irreversíveis. A física básica por trás disso está na equação de balanço energético:

S(1-α)/4 = εσT⁴ + ΔF

Onde:
- S = constante solar (1361 W/m²)
- α = albedo (0,3) 
- ε = emissividade (0,78)
- σ = constante de Stefan-Boltzmann
- ΔF = forçante radiativa (2,29 W/m² em 2023)

**Exercício**: Um modelo climático simplificado prevê que cada 100 ppm de CO₂ adicionais aumentam ΔF em 1,8 W/m². Se o albedo diminuir 0,01 devido ao derretimento do gelo, qual seria o novo equilíbrio térmico? (Use T₀=288K)

**Solução**:
1. Calcule o forçante original:
   ΔF_CO₂ = (420-280)/100 * 1,8 = 2,52 W/m²

2. Novo albedo: 0,3 - 0,01 = 0,29

3. Resolva a equação de balanço:
   1361*(1-0,29)/4 = 0,78*5,67e-8*T⁴ + 2,52
   T⁴ = (241,6 - 2,52)/(0,78*5,67e-8)
   T = 289,3 K (aumento de 1,3°C)