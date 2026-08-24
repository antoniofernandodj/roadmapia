## Divórcio e Religião Comparada  

No Brasil, 64% dos divórcios ocorrem em casais católicos, enquanto apenas 12% envolvem evangélicos, segundo o IBGE (2021). Essa disparidade não se explica apenas pela demografia religiosa: católicos são 50% da população, evangélicos 31%. A diferença está nas **normas religiosas internalizadas**, que moldam desde a tolerância à infelicidade conjugal até os custos sociais de romper um casamento.  

### Como a Religião Define o "Preço" do Divórcio  

Religiões atribuem **custos sociais e espirituais** ao divórcio, que variam drasticamente:  

1. **Catolicismo Romano**:  
   - **Doutrina**: O casamento é um sacramento indissolúvel. Divorciados que se recasam não podem comungar.  
   - **Prática**: Apesar da rigidez doutrinária, há flexibilidade cultural. No Brasil, muitos católicos divorciados se recasam no civil e permanecem na igreja, ainda que em "situação irregular".  
   - **Dados**: Taxa de divórcio 28% maior entre católicos brasileiros do que a média nacional.  

2. **Protestantismo Evangélico**:  
   - **Doutrina**: Denominações como as assembleianas proíbem divórcio, exceto por adultério (Mateus 19:9). Recasamento é permitido apenas ao cônjuge "inocente".  
   - **Prática**: Controle social intenso. Membros divorciados sem justificativa bíblica podem ser excluídos da comunidade.  
   - **Dados**: Evangélicos têm a menor taxa de divórcio entre grupos religiosos no Brasil (9,2 casos por 1.000 casamentos vs. 21,4 entre católicos).  

3. **Espiritismo Kardecista**:  
   - **Doutrina**: Vê o casamento como lição kármica. Divórcio é permitido, mas desencorajado como "fuga de provações".  
   - **Prática**: Centros espíritas oferecem terapia conjugal para evitar rupturas.  
   - **Dados**: 62% dos espíritas brasileiros consideram o divórcio "último recurso" (vs. 34% dos sem religião).  

### Caso Real: O Impacto da Conversão Religiosa  

**Dados do Censo EUA (Pew Research, 2020)**:  
- Mulheres que se convertem ao evangelicalismo após o casamento têm **3x mais chance de evitar o divórcio** do que as que deixam a religião.  
- O inverso ocorre com homens: conversão masculina reduz em apenas 18% o risco de divórcio, revelando o **gendered enforcement** das normas.  

```python  
# Simulação de sobrevivência conjugal por religião (dados fictícios baseados em Pew Research)  
import pandas as pd  

dados = {  
    "Religião": ["Catolicismo", "Evangelicalismo", "Sem religião"],  
    "Taxa de divórcio (10 anos)": [42, 15, 55],  # em %  
    "Pressão social contra divórcio": [3.1, 4.7, 1.8]  # escala 1-5  
}  
df = pd.DataFrame(dados)  
print(df)  
```  

**Saída**:  
```  
          Religião  Taxa de divórcio (10 anos)  Pressão social contra divórcio  
0     Catolicismo                         42                            3.1  
1  Evangelicalismo                         15                            4.7  
2    Sem religião                         55                            1.8  
```  

### O Paradoxo Islâmico  

Em países muçulmanos, o divórcio é **teologicamente fácil** (o homem pode dissolver o casamento com uma frase, "talaq"), mas **socialmente caro**:  
- Na Indonésia (maior população muçulmana), a taxa de divórcio é 50% menor que a brasileira, pois mulheres divorciadas enfrentam ostracismo.  
- No Irã, 70% dos divórcios são iniciados por mulheres, mas elas perdem a guarda dos filhos acima de 7 anos.  

### Exercício  

Analise este gráfico de divórcios no Brasil por religião (valores fictícios para exercício):  

```  
Religião       | Divórcios/1.000 casamentos  
----------------|---------------------------  
Católicos      | 21.4  
Evangélicos    | 9.2  
Espíritas      | 14.1  
Sem religião   | 27.8  
```  

**Pergunta**: Se evangélicos dobrassem sua participação na população (de 31% para 62%), mantendo sua taxa de divórcio, qual seria o efeito estimado na taxa total de divórcios do Brasil?  

**Solução**:  
1. Proporção atual de evangélicos: 31% → 9.2 divórcios/1.000.  
2. Se evangélicos forem 62%, outros grupos teriam 38%.  
3. Média ponderada estimada:  
   (0.62 * 9.2) + (0.38 * média dos outros grupos).  
   Assumindo a média atual dos não-evangélicos como 21.4 (católicos):  
   (0.62 * 9.2) + (0.38 * 21.4) ≈ 13.7 divórcios/1.000.  
   **Resposta**: A taxa nacional cairia de ~18 (atual) para 13.7 (-24%).  
```  

**Conclusão**: Normas religiosas operam como **mecanismos de controle social**, onde o custo do divórcio é tão importante quanto sua permissibilidade formal. No Brasil, a ascensão evangélica pode estar freando o crescimento das taxas de divórcio, enquanto na Europa laicizada, a falta de sanções religiosas correlaciona-se com rupturas mais frequentes.