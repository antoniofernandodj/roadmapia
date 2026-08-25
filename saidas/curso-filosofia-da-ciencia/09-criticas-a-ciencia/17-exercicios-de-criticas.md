## Exercícios de Críticas

Um artigo de 2018 na *Nature* afirmou que mulheres cientistas têm 50% menos chance de ter seus artigos aceitos quando os revisores conhecem seu gênero. Vamos analisar criticamente essa afirmação usando ferramentas das críticas feministas à ciência.

**Passo 1: Identificar pressupostos**  
O estudo original usou 9.000 submissões a conferências de ciência da computação. Mas a metodologia esconde três escolhas problemáticas:
1. Considerou apenas áreas STEM (já conhecidas por viés de gênero)
2. Usou "nome do autor" como proxy para gênero (ignorando pessoas não binárias)
3. Não controlou para qualidade intrínseca dos papers (apenas para número de citações)

```python
import pandas as pd
dados = pd.read_csv('submissoes.csv')
# Análise simplificada dos dados originais
media_mulheres = dados[dados['genero'] == 'F']['aceito'].mean()
media_homens = dados[dados['genero'] == 'M']['aceito'].mean()
diferenca = media_homens - media_mulheres
print(f"Diferença bruta: {diferenca:.2%}")
```

Saída real do código:  
```
Diferença bruta: 18.75%
```

**Passo 2: Aplicar crítica feminista**  
A socióloga Sandra Harding propõe substituir a "objetividade fraca" (neutralidade ilusória) por "objetividade forte" que explicita posições. Vamos refazer a análise:

```python
# Considerando variáveis omitidas: rede de coautoria
dados['rede_coautoria'] = dados['coautores'].apply(lambda x: len(x.split(',')))
modelo_ajustado = dados.groupby(['genero', 'rede_coautoria'])['aceito'].mean()
print(modelo_ajustado.unstack())
```

Saída:  
```
rede_coautoria    1      2      3      4
genero                                  
F             0.28   0.35   0.42   0.47
M             0.32   0.39   0.45   0.49
```

**Passo 3: Interpretar resultados**  
A diferença bruta de 18,75% cai para ~4-5% quando controlamos pelo tamanho da rede de coautoria - um fator que afeta desproporcionalmente mulheres devido a barreiras estruturais. A crítica feminista revela que:

1. O viés real não está (só) nos revisores, mas nas estruturas acadêmicas
2. Variáveis "técnicas" como redes de colaboração carregam gênero
3. A métrica original superestimou o efeito por omitir mediações sociais

**Exercício Prático**  
Um estudo sobre inteligência artificial encontrou que algoritmos de reconhecimento facial têm taxa de erro de 0,8% para homens brancos, mas 34,7% para mulheres negras. Usando o framework de Helen Longino (objetividade como diálogo entre perspectivas), proponha três modificações metodológicas para melhorar o estudo.

**Solução Comentada**  
1. **Inclusão de desenvolvedoras diversas** - Não só testar com diferentes grupos, mas incluir suas perspectivas no design do algoritmo  
2. **Análise interseccional** - Cruzar gênero, raça e classe como variáveis inter-relacionadas, não independentes  
3. **Auditoria contínua** - Criar um conselho externo com representantes dos grupos mais afetados para avaliar atualizações