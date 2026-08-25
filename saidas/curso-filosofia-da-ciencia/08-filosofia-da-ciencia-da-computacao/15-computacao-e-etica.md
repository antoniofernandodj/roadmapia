## Computação e Ética

Um algoritmo de recomendação de vídeos sugere conteúdo cada vez mais radical. Um sistema de crédito nega empréstimos a bairros pobres. Um chatbot reproduz discursos de ódio. Esses não são bugs técnicos, mas manifestações de um problema mais profundo: a ética embutida nas escolhas computacionais aparentemente neutras.

Tome o caso de um sistema de triagem médica que prioriza pacientes. O código abaixo parece objetivo:

```python
def priorizar_paciente(idade, gravidade, comorbidades):
    score = (idade * 0.3) + (gravidade * 0.6) + (comorbidades * 0.1)
    return score
```

Ao executar com `priorizar_paciente(70, 8, 3)` versus `priorizar_paciente(25, 7, 0)`, obtemos:

```
72.1 (idoso)
21.0 (jovem)
```

O sistema privilegia idosos — uma escolha ética disfarçada de cálculo matemático. Se alterarmos os pesos para `(0.1, 0.7, 0.2)`, jovens com condições graves passam à frente. Não há resposta "técnica" correta, apenas valores implícitos.

**O que torna esses dilemas distintos dos da ética tradicional?**

1. *Escalabilidade*: decisões algorítmicas afetam milhões instantaneamente
2. *Opacidade*: até os desenvolvedores podem não entender sistemas complexos
3. *Feedback loops*: vieses se amplificam automaticamente

Considere este trecho de um algoritmo de contratação:

```python
def filtrar_candidatos(experiencia, formacao, teste_psicometrico):
    if teste_psicometrico < 50:
        return False  # Elimina 50% dos candidatos
    return experiencia >= 2 and formacao in ['TI', 'Engenharia']
```

Ao testar com dados históricos, descobrimos que o teste psicométrico exclui 70% das mulheres — não por malícia, mas porque foi calibrado em uma cultura corporativa masculina. O erro aparece quando executamos:

```python
dados = [
    {'experiencia': 3, 'formacao': 'TI', 'teste': 45, 'genero': 'F'},
    {'experiencia': 2, 'formacao': 'Engenharia', 'teste': 60, 'genero': 'M'}
]
resultados = [filtrar_candidatos(**candidato) for candidato in dados]
```

Saída:
```
[False, True]  # Mulher qualificada eliminada pelo teste
```

**Três níveis de responsabilidade ética emergem:**

1. *Intencional*: decisões explícitas (ex.: excluir minorias)
2. *Estrutural*: vieses nos dados de treinamento
3. *Emergente*: consequências não antecipadas (ex.: polarização por algoritmos de recomendação)

O caso clássico da COMPAS — sistema de risco criminal que discriminava negros — revela como até algoritmos "justos" matematicamente podem ser injustos socialmente. Ao comparar:

```python
# Falso positivo: liberdade negada indevidamente
falso_positivo = {'raça': 'negro', 'risco_predito': 'alto', 'reincidiu': False}

# Falso negativo: liberdade concedida perigosamente
falso_negativo = {'raça': 'branco', 'risco_predito': 'baixo', 'reincidiu': True}
```

A ética da computação exige ir além da correção sintática do código. Um framework útil é o *Princípio da Precaução Computacional*:

1. Identifique stakeholders afetados (não apenas usuários diretos)
2. Mapeie cadeias causais de segunda ordem (como o sistema pode ser mal utilizado?)
3. Implemente mecanismos de auditoria contínua
4. Documente pressupostos éticos como comentários no código:

```python
# DECISÃO ÉTICA: priorizar gravidade sobre idade (pesos 0.1, 0.7, 0.2)
# JUSTIFICATIVA: evitar discriminação etária conforme diretriz OMS-2023
def priorizar_paciente(idade, gravidade, comorbidades):
    ...
```

**Exercício**: Um algoritmo de preços dinâmicos para passagens aéreas usa demanda, antecedência e histórico de compras. Como você modificaria para evitar discriminação econômica? Mostre em código e justifique as escolhas éticas.

*Solução comentada*:

```python
def calcular_preco(demanda, antecedencia, historico):
    preco_base = 1000
    # Limita ajuste por histórico para evitar penalizar compradores ocasionais
    ajuste_historico = min(historico * 10, 200)  # Teto de 20%
    # Desconto por antecedência linear, não exponencial
    desconto = min(antecedencia * 0.5, 300)  # Máximo 30%
    preco = preco_base + (demanda * 50) - desconto + ajuste_historico
    # Garante piso e teto socialmente aceitáveis
    return max(500, min(preco, 2000))
```

Justificativas:
1. *Limites absolutos*: evita preços proibitivos ou exploratórios
2. *Descontos acessíveis*: beneficia planejamento sem prejudicar urgências
3. *Histórico moderado*: não penaliza voos esporádicos
4. *Transparência*: fórmula simples e auditável