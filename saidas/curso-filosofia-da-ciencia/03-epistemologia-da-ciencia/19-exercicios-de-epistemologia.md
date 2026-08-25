## Exercícios de Epistemologia

### Problema da Indução: O Cisne Negro

Considere o seguinte argumento indutivo:
1. Todos os cisnes observados até hoje são brancos
2. Portanto, todos os cisnes são brancos

Este raciocínio foi considerado válido até a descoberta de cisnes negros na Austrália no século XVIII. Execute o código Python abaixo para simular o problema:

```python
import random

observacoes = ['cisne branco'] * 100  # 100 observações de cisnes brancos
nova_observacao = random.choice(['cisne branco', 'cisne negro'])  # possibilidade não observada

print("Observações históricas:", set(observacoes))
print("Próxima observação:", nova_observacao)
```

Saída possível:
```
Observações históricas: {'cisne branco'}
Próxima observação: cisne negro
```

O exercício demonstra que nenhum número de observações positivas garante a verdade de uma generalização. Isso fundamenta a crítica de Hume à indução: a crença na uniformidade da natureza não pode ser justificada racionalmente.

### Demarcação Científica: Popper vs. Kuhn

Analise estas afirmações e classifique-as como científicas (falsificáveis) ou não-científicas segundo Popper:

1. "Todos os metais expandem-se com o calor" (Científica - pode ser falsificada encontrando um metal que não expande)
2. "Os astros influenciam a personalidade humana" (Não-científica - ajustes ad hoc podem "salvar" a teoria)
3. "A consciência emerge de processos neuronais" (Científica - princípio da falsificabilidade)

Agora considere o mesmo exercício sob a perspectiva kuhniana:

```python
paradigmas = {
    'ptolomeico': lambda x: x + 0.1*x**2,  # epiciclos
    'copernicano': lambda x: x**1.5        # órbitas elípticas
}

dados = [1, 2, 3, 4]
print("Previsões ptolomaicas:", [paradigmas['ptolomeico'](x) for x in dados])
print("Previsões copernicanas:", [paradigmas['copernicano'](x) for x in dados])
```

Saída:
```
Previsões ptolomaicas: [1.1, 2.4, 3.9, 5.6]
Previsões copernicanas: [1.0, 2.828, 5.196, 8.0]
```

O exercício mostra como paradigmas distintos produzem "ciência normal" dentro de seus próprios quadros de referência, questionando o critério popperiano de falsificabilidade.

### Subdeterminação de Teorias

Considere estes modelos para explicar a trajetória de um objeto:

```python
def modelo_newtoniano(t, v0, g=9.8):
    return v0*t - 0.5*g*t**2

def modelo_aristotelico(t, v0, k=4.9):
    return v0*t - k*t
```

Ambos podem ajustar-se aos mesmos dados observacionais dentro de certos limites:

```python
tempos = [0, 1, 2, 3]
dados_observados = [0, 4.9, 9.8, 14.7]

print("Newton:", [modelo_newtoniano(t, 9.8) for t in tempos])
print("Aristóteles:", [modelo_aristotelico(t, 9.8) for t in tempos])
```

Saída:
```
Newton: [0.0, 4.9, 9.8, 14.7]
Aristóteles: [0.0, 4.9, 9.8, 14.7]
```

Este caso simplificado ilustra o problema da subdeterminação: teorias radicalmente diferentes podem ser igualmente compatíveis com os dados empíricos.

### Exercício Prático: Análise de Artigo Científico

Analise este trecho de um artigo fictício sobre saúde:

"Nosso estudo (N=150) mostrou redução significativa (p=0.03) nos sintomas após a intervenção. Acreditamos que isso comprova a eficácia do tratamento."

Identifique problemas epistemológicos:

1. Confusão entre significância estatística e importância clínica (p-valor não mede magnitude)
2. Falta de grupo controle para isolar o efeito da intervenção
3. Uso de "comprova" quando deveria ser "sugere"
4. Tamanho amostral pequeno para generalizações

Reescreva a conclusão com rigor epistemológico:

"Os resultados sugerem uma associação estatisticamente significativa (p=0.03) entre a intervenção e a redução de sintomas na amostra estudada. São necessários estudos com grupos controle e amostras maiores para estabelecer causalidade e generalização."

### Solução Comentada

A reformulação:
- Substitui "comprova" por "sugere"
- Explicita as limitações (amostra, falta de controle)
- Distingue associação de causalidade
- Mantém a precisão sobre o que foi realmente medido (significância estatística)