## Aplicações Práticas

A sociologia dos relacionamentos não é apenas teórica. Ela oferece ferramentas concretas para entender e melhorar dinâmicas conjugais. Vamos explorar como os conceitos aprendidos se aplicam em situações reais, desde conflitos domésticos até decisões jurídicas.

### 1. Mediação de Conflitos Conjugais
Um mediador familiar usando dados sobre divórcios no Nordeste (onde 68% das dissoluções ocorrem nos primeiros 5 anos, segundo o IBGE) pode:

```python
# Exemplo: Análise de fatores de risco regional
fatores_nordeste = {
    "idade_casamento": 22.3, # média
    "renda_familiar": 1.8, # salários mínimos
    "escolaridade": "Ensino Médio incompleto",
    "motivos_mais_comuns": ["financeiros", "violência doméstica", "infidelidade"]
}

def sugerir_abordagem(regiao):
    if regiao == "Nordeste":
        return """Intervenção sugerida:
        1. Workshops de educação financeira conjugal
        2. Encaminhamento para apoio psicológico
        3. Mediação com foco em comunicação não-violenta"""
```

Saída esperada ao aplicar `sugerir_abordagem("Nordeste")`:
```
Intervenção sugerida:
1. Workshops de educação financeira conjugal
2. Encaminhamento para apoio psicológico
3. Mediação com foco em comunicação não-violenta
```

### 2. Políticas Públicas Preventivas
Prefeituras podem usar a correlação entre escolaridade e estabilidade conjugal para criar programas. Dados mostram que casais com ensino superior completo têm taxa de divórcio 40% menor. Um erro comum é ignorar variáveis intermediárias:

```python
# Modelo ingênuo (causação direta)
def divorcio_por_escolaridade(escolaridade):
    return 35 - escolaridade * 2 # Simulação simplista

# Modelo corrigido (incluindo variáveis mediadoras)
def divorcio_por_fatores(escolaridade, renda, acesso_a_servicos):
    return (40 
            - escolaridade * 1.2 
            - renda * 0.5 
            - acesso_a_servicos * 0.8)
```

### 3. Aconselhamento Pré-Nupcial
Casais podem usar princípios sociológicos para negociar contratos realistas. Um exemplo comum é subestimar a carga mental feminina:

```python
carga_mental = {
    "homens": ["manutenção carro", "contas grandes"],
    "mulheres": ["alimentação", "roupas", "saúde crianças", "agenda familiar", "limpeza"]
}

def calcular_equilibrio(tarefas):
    proporcao = len(tarefas["mulheres"]) / len(tarefas["homens"])
    if proporcao > 1.5:
        return "Alerta: Desequilíbrio de carga mental típico ({}:1)".format(round(proporcao,1))
```

Saída ao executar `calcular_equilibrio(carga_mental)`:
```
'Alerta: Desequilíbrio de carga mental típico (2.5:1)'
```

### 4. Decisões Judiciais
Juízes de família aplicam estatísticas sociológicas para definir guarda compartilhada. Um erro frequente é tratar todos os casos como iguais:

```python
def definir_guarda(perfil):
    if perfil["regiao"] == "Sudeste" and perfil["escolaridade_pai"] > perfil["escolaridade_mae"]:
        return "70% mãe"  # Padrão histórico incorreto
    else:
        return "Analisar: tempo disponível, vínculo afetivo, rede de apoio"
```

### Exercício Prático
Crie uma função que sugira intervenções para um casal considerando:
- Diferença salarial (>30%)
- Número de filhos
- Horas semanais de trabalho doméstico

Solução comentada:
```python
def sugerir_intervencao(casal):
    intervencoes = []
    if abs(casal["salario_h"] - casal["salario_m"]) / max(casal["salario_h"], casal["salario_m"]) > 0.3:
        intervencoes.append("Terapia para assimetria de poder")
    if casal["filhos"] > 2:
        intervencoes.append("Oficina de planejamento familiar")
    if casal["horas_domesticas_m"] > casal["horas_domesticas_h"] * 1.5:
        intervencoes.append("Redistribuição negociada de tarefas")
    return intervencoes or "Perfil equilibrado"

# Teste
casal_teste = {
    "salario_h": 5000,
    "salario_m": 3000,
    "filhos": 3,
    "horas_domesticas_h": 5,
    "horas_domesticas_m": 12
}
print(sugerir_intervencao(casal_teste))
```
Saída:
```
['Terapia para assimetria de poder', 'Oficina de planejamento familiar', 'Redistribuição negociada de tarefas']
```