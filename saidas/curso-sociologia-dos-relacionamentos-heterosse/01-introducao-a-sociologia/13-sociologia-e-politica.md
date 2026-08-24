## Sociologia e Política

A política molda os relacionamentos mais íntimos sem que percebamos. No Brasil, onde 30% dos casamentos terminam em divórcio antes de completarem 10 anos (IBGE, 2022), leis como a do divórcio direto (2010) alteraram não apenas estatísticas, mas a própria concepção social do casamento. Veja como isso funciona na prática:

```python
# Simulador de Efeito de Leis no Divórcio (Dados fictícios para exemplo)
import matplotlib.pyplot as plt

# Antes da lei (2000-2009)
anos = [2000, 2005, 2009]
divorcios = [15, 18, 20]  # % de casamentos que terminavam em divórcio

# Após lei (2010-2022)
novos_anos = [2010, 2015, 2020, 2022]
novos_divorcios = [25, 28, 32, 35]

plt.plot(anos, divorcios, 'r-', label='Antes da Lei')
plt.plot(novos_anos, novos_divorcios, 'b--', label='Após Lei do Divórcio Direto')
plt.title('Impacto da Legislação nas Taxas de Divórcio')
plt.xlabel('Ano')
plt.ylabel('% de Casamentos que Terminam em Divórcio')
plt.legend()
plt.show()
```

![Gráfico mostrando aumento acentuado nas taxas de divórcio após mudança legislativa](imagem-ficticia.png)

**O que acontece nos bastidores:**
1. **Legislação como fator estrutural**: A exigência de separação judicial prévia (revogada em 2010) criava um "custo político" para o divórcio
2. **Efeito cascata**: A nova lei alterou percepções sociais - o divórcio tornou-se menos estigmatizado
3. **Feedback loop**: Mais divórcios visíveis → maior normalização → mais divórcios

Um erro comum é analisar relacionamentos apenas como escolhas individuais. Quando tentamos entender por que paulistanos se divorciam 40% mais que nordestinos (PNAD, 2021), precisamos examinar:

```python
# Comparação regional de divórcios (dados reais adaptados)
regioes = ['Norte', 'Nordeste', 'Sudeste', 'Sul', 'Centro-Oeste']
taxas_divorcio = [18, 22, 31, 27, 25]  # Divórcios por 100 casamentos

plt.bar(regioes, taxas_divorcio, color=['green', 'blue', 'red', 'purple', 'orange'])
plt.title('Taxas de Divórcio por Região (2021)')
plt.ylabel('Divórcios por 100 Casamentos')
plt.xticks(rotation=45)
plt.show()
```

A diferença de 13 pontos percentuais entre Sudeste e Nordeste revela como:
- Políticas estaduais de habitação afetam estabilidade conjugal
- Programas de transferência de renda alteram dinâmicas de poder doméstico
- Infraestrutura urbana influencia tempo de convivência do casal

**Exercício Prático:**
Analise este dado do Tribunal de Justiça de SP:
"Casamentos com bens separados tiveram 60% mais divórcios que comunhão parcial (2020)"

1. Que hipóteses políticas/sociais explicam isso?
2. Como testaria essas hipóteses com dados de outras capitais?

**Solução Comentada:**
1. **Hipóteses:**
   - Regimes de bens refletem desigualdade de gênero (mulheres com mais patrimônio optam por separação total)
   - Fatores econômicos: crises financeiras levam a mais divórcios quando os bens estão separados
   - Cultura jurídica: advogados podem sugerir regimes diferentes conforme perfil do casal

2. **Metodologia de teste:**
   ```python
   # Exemplo de análise comparativa
   import pandas as pd

   dados = {
       'Cidade': ['SP', 'RJ', 'BH', 'POA'],
       'Divórcios_bens_separados': [120, 95, 60, 45],
       'Divórcios_comunhão_parcial': [75, 60, 40, 30],
       'Índice_Gini': [0.52, 0.53, 0.47, 0.45]
   }

   df = pd.DataFrame(dados)
   df['Razão_divórcios'] = df['Divórcios_bens_separados'] / df['Divórcios_comunhão_parcial']
   print(df.corr())  # Verificar correlação entre razão de divórcios e desigualdade
   ```

   Resultado esperado mostraria correlação positiva entre desigualdade (Gini) e diferença nas taxas de divórcio por regime de bens, sugerindo que contextos políticos locais moldam os padrões conjugais.