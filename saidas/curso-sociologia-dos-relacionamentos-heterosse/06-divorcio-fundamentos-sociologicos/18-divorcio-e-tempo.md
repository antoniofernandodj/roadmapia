## Divórcio e Tempo

No Brasil, a duração média de um casamento antes do divórcio é de 15 anos, segundo o IBGE. Mas por que alguns relacionamentos duram décadas enquanto outros terminam em poucos anos? O tempo não é apenas um marcador cronológico - ele revela padrões sociais profundos sobre expectativas, adaptação e pontos de ruptura nos relacionamentos heterossexuais.

**O mito dos "sete anos"**  
A crença popular sobre crises matrimoniais periódicas (como a famosa "crise dos sete anos") não resiste aos dados. Pesquisas do IPEA mostram que:

1. 20% dos divórcios ocorrem nos primeiros 5 anos
2. O pico ocorre entre 5 e 10 anos de união
3. Apenas 12% acontecem após 20 anos de casamento

Essa distribuição revela dois momentos críticos distintos:

```python
# Simulação de dados reais de divórcio por anos de casamento
import matplotlib.pyplot as plt

anos = [1, 3, 5, 7, 10, 15, 20, 25]
divorcios = [5, 15, 20, 25, 18, 10, 5, 2]

plt.bar(anos, divorcios, color='#ff6b6b')
plt.title('Distribuição de divórcios por tempo de casamento no Brasil')
plt.xlabel('Anos de casamento')
plt.ylabel('% de divórcios')
plt.show()
```

O gráfico resultante mostra claramente o formato de "montanha" com o ápice entre 5-10 anos, desmentindo a noção de ciclos regulares.

**Tempo biológico vs tempo social**  
A pressão do relógio biológico cria dinâmicas específicas:

- Casais que se unem antes dos 25 anos têm 50% mais chance de divórcio (FGV/2022)
- Mulheres entre 30-35 anos demonstram maior taxa de iniciativa de separação
- Homens acima de 45 anos apresentam menor disposição a recasamento

Esses padrões variam drasticamente entre regiões. Enquanto no Sudeste a estabilidade conjugal aumenta após 10 anos, no Nordeste esse patamar só é alcançado após 15 anos.

**A curva da adaptação conjugal**  
Estudos longitudinais da USP identificaram três fases distintas:

1. **Lua-de-mel institucional** (0-2 anos):  
   - Conflitos são vistos como "ajustes"
   - Alto investimento emocional mútuo
   - Exemplo: "Ele esqueceu nosso aniversário, mas está aprendendo"

2. **Desencantamento progressivo** (3-12 anos):  
   - Padrões negativos se cristalizam
   - Críticas substituem brincadeiras
   - Exemplo: "Sempre foi egoísta" substitui "Ele está distraído"

3. **Estabilização ou ruptura** (13+ anos):  
   - Aceitação mútua ou esgotamento
   - Diálogo se ritualiza ou desaparece
   - Exemplo: "Já nos entendemos" vs "Não temos mais o que dizer"

**Exercício prático:**  
Analise este depoimento real de um processo de divórcio e identifique em qual fase temporal o casal provavelmente se encontrava:

"Nos primeiros anos, eu relevava quando ele esquecia datas importantes. Depois comecei a cobrar, mas ele dizia que eu era exigente demais. Nos últimos dois anos, nem cobrava mais, só registrava mentalmente mais uma decepção."

**Solução comentada:**  
O relato mostra claramente a transição entre as três fases:  
1. "Relevava" → fase de lua-de-mel  
2. "Comecei a cobrar" → desencantamento  
3. "Nem cobrava mais" → fase de ruptura  

O tom de resignação ("registrava mentalmente") e a cronologia sugerem que o casal estava na fase final de desencantamento (9-11 anos), prestes a atingir o ponto de ruptura decisiva.

O tempo no divórcio opera como um revelador social: expõe como expectativas românticas colidem com realidades institucionais, como as pressões econômicas se acumulam diferencialmente sobre os gêneros, e como a cultura brasileira negocia (ou falha em negociar) essas transições temporais nos relacionamentos heterossexuais.