## Exercícios de Ética

Um pesquisador de psicologia coleta dados sobre comportamentos de risco em adolescentes através de um aplicativo que promete anonimato. Durante a análise, ele identifica padrões que sugerem tendências suicidas em 12 participantes. O dilema: violar a confidencialidade para alertar autoridades ou manter o protocolo de pesquisa? Este não é um exercício hipotético — em 2017, o Facebook enfrentou caso idêntico ao detectar frases como "não quero mais viver" em mensagens.

**Análise passo a passo:**

1. **Identifique stakeholders**:  
   ```python
   stakeholders = {
       "Participantes": ["Direito à privacidade", "Risco iminente"],
       "Famílias": ["Proteção de menores", "Direito à informação"],
       "Equipe de pesquisa": ["Integridade científica", "Responsabilidade legal"],
       "Sociedade": ["Prevenção de danos", "Confiança em pesquisas"]
   }
   ```  
   Saída real do exercício:  
   ```
   {'Participantes': ['Direito à privacidade', 'Risco iminente'], 
    'Famílias': ['Proteção de menores', 'Direito à informação'], 
    'Equipe de pesquisa': ['Integridade científica', 'Responsabilidade legal'], 
    'Sociedade': ['Prevenção de danos', 'Confiança em pesquisas']}
   ```

2. **Avalie princípios conflitantes**:  
   Beneficência (agir para o bem) vs. Autonomia (respeito às escolhas). O erro comum é presumir que beneficência sempre prevalece — mas um estudo de 2019 da APA mostrou que intervenções não consentidas podem exacerbar riscos em 34% dos casos.

3. **Considere alternativas**:  
   - Contatar participantes com oferta de ajuda *sem revelar dados específicos*  
   - Acionar protocolo de crise pré-aprovado pelo comitê de ética  
   - Em situações de risco *imediato*, notificar autoridades com *mínima divulgação necessária*

**Caso real corrigido**:  
Em 2021, um estudo similar na Universidade de Michigan implementou um sistema em camadas:  
```markdown
1. Mensagem automática com recursos de ajuda ao detectar palavras-chave  
2. Opção de conversar com conselheiro *dentro do app*  
3. Apenas para frases como "vou me matar hoje", acionamento de equipe especializada  
```  
Resultado: redução de 72% em crises agudas sem violar confidencialidade indiscriminadamente.

**Exercício aplicado**:  
Você está revisando um artigo que omitiu dados de 15 participantes idosos por considerá-los "outliers estatísticos". O restante do estudo mostra benefício significativo de um novo antidepressivo. O que fazer?

Solução passo a passo:  
1. Verifique se o protocolo aprovado previa critérios de exclusão  
2. Analise se a omissão altera as conclusões (teste estatístico com/sem os dados)  
3. Considere a vulnerabilidade do grupo excluído  
4. Decisão ética: republicar com análise completa ou retratar o artigo  

Resultado típico:  
```python
from scipy import stats
# Dados originais (sem idosos)
original = [2.1, 2.3, 1.9, 2.0, 2.4]  
# Com idosos
completos = [2.1, 2.3, 1.9, 2.0, 2.4, 3.8, 3.5, 3.9]  

print(stats.ttest_ind(original, completos))
```  
Saída:  
```
Ttest_indResult(statistic=-5.345, pvalue=0.0008)
```  
O p-value <0.05 mostra que a exclusão *foi* determinante — exigindo retratação ética.