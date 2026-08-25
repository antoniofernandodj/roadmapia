## Objetividade nas Ciências Sociais

Um economista afirma que a inflação é "objetivamente" 5% ao ano. Um sociólogo diz que a desigualdade "objetivamente" aumentou. Mas o que significa "objetivo" quando falamos de fenômenos sociais? A objetividade nas ciências sociais não é um dado, mas um problema a ser resolvido — e seu exame revela tensões fundamentais.

### O mito do dado bruto

Considere a afirmação: "O desemprego no Brasil é de 9%". Parece objetiva, mas esconde uma cadeia de decisões:

1. **Definição operacional**: Quem conta como desempregado? Alguém que trabalhou 1 hora na semana? Quem desistiu de procurar emprego?
2. **Coleta de dados**: Pesquisa domiciliar amostral, com margem de erro e viés de não resposta.
3. **Interpretação**: O número ignora subemprego, informalidade e trabalho não remunerado.

```python
# Simulação de como diferentes critérios alteram a taxa de desemprego
import numpy as np

base = np.random.choice([0, 1, 2], size=1000, p=[0.85, 0.10, 0.05])  # 0=empregado, 1=desempregado, 2=desalentado

# Critério 1: apenas desempregados ativos
desemprego_1 = sum(base == 1) / len(base)  
# Critério 2: inclui desalentados
desemprego_2 = (sum(base == 1) + sum(base == 2)) / len(base)  

print(f"Taxa restrita: {desemprego_1:.1%}, Taxa ampliada: {desemprego_2:.1%}")
```
Saída:
```
Taxa restrita: 9.6%, Taxa ampliada: 14.2%
```

A mesma realidade produz números radicalmente diferentes dependendo das escolhas metodológicas. Isso não invalida a pesquisa, mas mostra que a objetividade aqui é **construída**, não descoberta.

### Duas concepções de objetividade

1. **Objetividade como neutralidade**: O ideal clássico, herdado das ciências naturais. O pesquisador seria um espelho que reflete a realidade sem distorções. Max Weber chamava isso de "livre de valores" (*wertfrei*). Problema: escolhas teóricas e metodológicas já carregam valores. Ao definir "crime", um pesquisador incorpora visões sobre moralidade e ordem social.

2. **Objetividade como intersubjetividade**: Alternativa contemporânea. A objetividade emerge do debate crítico entre pesquisadores com perspectivas diferentes. Como diz Helen Longino: "É o processo social, não o indivíduo isolado, que produz conhecimento objetivo". Exemplo: quando economistas keynesianos e neoliberais debatem políticas públicas, suas divergências revelam pressupostos ocultos.

### Caso prático: O coeficiente Gini

O índice de Gini mede desigualdade de renda em uma escala de 0 (igualdade perfeita) a 1 (desigualdade máxima). Parece perfeito para comparações objetivas entre países. Mas veja os problemas:

```python
# Cálculo simplificado do Gini
def gini(rendas):
    rendas = sorted(rendas)
    n = len(rendas)
    numerador = sum((i+1)*renda for i, renda in enumerate(rendas))
    denominador = n * sum(rendas)
    return (2 * numerador) / denominador - (n + 1)/n

# Cenário A: sociedade com 10 pessoas
rendas_A = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10]  # Igualdade perfeita
rendas_B = [1, 1, 1, 1, 1, 1, 1, 1, 1, 91]          # Desigualdade extrema

print(f"Gini A: {gini(rendas_A):.3f}, Gini B: {gini(rendas_B):.3f}")
```
Saída:
```
Gini A: 0.000, Gini B: 0.810
```

O Gini é matematicamente preciso, mas:
- Ignora diferenças regionais ou de custo de vida
- Não captura desigualdade de riqueza (só renda)
- Trata igualmente desigualdades em diferentes faixas de renda

### Exercício: Objetividade em disputa

Analise este trecho de um artigo fictício: 

> "A pesquisa **objetivamente** mostra que políticas de ação afirmativa aumentam a desigualdade. Usamos dados do Censo (2010-2020) e modelos econométricos robustos. O coeficiente β de 0.73 (p<0.01) confirma nosso resultado."

**Solução comentada**:
1. O termo "objetivamente" mascara escolhas: quais variáveis foram incluídas/excluídas do modelo? Como "aumento de desigualdade" foi operacionalizado?
2. Dados oficiais não são neutros: o Censo pode subestimar rendas altas (sonegação) ou baixas (subnotificação).
3. "Robustez" estatística não resolve problemas conceituais: correlação ≠ causalidade. Variáveis omitidas (ex.: crises econômicas) podem explicar os resultados.
4. O p-valor só avalia erro aleatório, não viés sistemático na coleta ou análise.

A verdadeira objetividade estaria em:
- Explicitar limitações dos dados
- Testar modelos alternativos
- Comparar com estudos que chegam a conclusões opostas
- Reconhecer valores embutidos nas perguntas de pesquisa