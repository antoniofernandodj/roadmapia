## Divórcio e Gênero Comparado  

Quando um casal heterossexual se divorcia no Brasil, quem sofre mais economicamente? Quem retoma a vida afetiva mais rápido? E como isso se compara a outros países? Os dados revelam padrões surpreendentes que desafiam estereótipos comuns.  

### O Impacto Econômico por Gênero  

No Brasil, mulheres divorciadas têm maior probabilidade de enfrentar queda na renda do que homens. Pesquisas do IBGE mostram que, em média, a renda feminina cai 20% após o divórcio, enquanto a masculina se mantém estável ou aumenta. Isso ocorre porque:  

1. **Divisão de bens**: Mesmo com a partilha igualitária, homens acumulam mais patrimônio durante o casamento (devido a diferenças salariais históricas).  
2. **Pensão alimentícia**: Apenas 30% dos ex-maridos pagam valores integrais e regulares, segundo o CNJ.  
3. **Mercado de trabalho**: Mulheres interrompem carreiras para cuidar dos filhos com mais frequência, reduzindo sua empregabilidade pós-divórcio.  

Compare com a Suécia: lá, a renda de ambos os gêneros oscila menos de 5%, graça a políticas como:  
- Licença parental obrigatória para homens e mulheres  
- Creches públicas universais  
- Ajuste automático de pensões via agência tributária  

```python  
# Simulação de impacto financeiro pós-divórcio (Brasil vs. Suécia)  
import pandas as pd  

dados = {  
    "País": ["Brasil", "Suécia"],  
    "Queda Renda Feminina (%)": [20, 4],  
    "Queda Renda Masculina (%)": [0, 3]  
}  
df = pd.DataFrame(dados)  
print(df)  
```  

Saída:  
```  
     País  Queda Renda Feminina (%)  Queda Renda Masculina (%)  
0   Brasil                      20                         0  
1   Suécia                       4                         3  
```  

### Reconstrução Afetiva: Quem se Casa Novamente?  

Nos EUA, 64% dos homens se recasam em 5 anos, contra 52% das mulheres (Pew Research Center). No Brasil, a diferença é maior: 70% dos homens versus 40% das mulheres. Dois fatores explicam isso:  

1. **Pressão etária**: Homens de 50+ são considerados "maduros", enquanto mulheres da mesma idade enfrentam estigma de "solteironas".  
2. **Cuidado parental**: 85% das crianças ficam com as mães após o divórcio (ENFAM), limitando sua disponibilidade para novos relacionamentos.  

Exemplo real: Um estudo de caso da UFMG acompanhou 200 divorciados em Belo Horizonte. Homens relataram "sentir-se livres para sair" 3x mais que mulheres, que mencionaram "culpa por deixar os filhos com babás" como barreira.  

### O Paradoxo da Felicidade Pós-Divórcio  

Pesquisas globais mostram que, embora homens relatem maior felicidade imediata após o divórcio, mulheres alcançam níveis mais altos de bem-estar a longo prazo (5+ anos). Por quê?  

- **Homens**: Valorizam a liberdade inicial, mas depois sentem falta de redes de apoio emocional (que antes eram providas pelas esposas).  
- **Mulheres**: Sofrem no curto prazo com sobrecarga de trabalho, mas desenvolvem autonomia e redes sociais mais sólidas.  

Dados do World Values Survey:  
| Gênero | Felicidade (1 ano) | Felicidade (5 anos) |  
|--------|--------------------|--------------------|  
| Homem  | 7.2/10            | 6.8/10            |  
| Mulher | 5.9/10            | 7.5/10            |  

### Exercício Prático  

Analise este depoimento de uma divorciada brasileira (Fonte: Revista Cláudia, 2022):  
*"Perdi meu emprego de professora quando me casei, pois meu ex queria que cuidássemos dos filhos. Após o divórcio, consegui apenas bicos. Ele, que era gerente, já está morando com outra."*  

1. Identifique 3 fatores de gênero que impactam essa situação.  
2. Como políticas suecas poderiam ter alterado esse cenário?  

**Solução Comentada**:  
1.  
- Interrupção da carreira feminina por expectativa de cuidado parental  
- Dificuldade de reinserção no mercado de trabalho para mulheres  
- Assimetria na reconstrução afetiva pós-divórcio  

2.  
- Licença parental compartilhada evitaria a saída definitiva do mercado  
- Creches públicas permitiriam conciliar trabalho e filhos  
- Ajuste salarial via impostos compensaria a desigualdade inicial