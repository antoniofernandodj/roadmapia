## Computação e Sociedade

Um algoritmo de recomendação do YouTube sugere vídeos cada vez mais extremos a usuários conservadores e liberais, criando realidades paralelas. Um sistema de crédito nega empréstimos a bairros pobres usando dados "objetivos". Esses não são bugs técnicos, mas manifestações de como a computação remodela relações sociais de formas que transcendem a intenção dos programadores.

### O Mito da Neutralidade Algorítmica

Considere este código simples que classifica candidatos a emprego:

```python
def classificar_candidato(experiencia, formacao, idade):
    score = experiencia * 0.6 + formacao * 0.3
    if idade > 45:
        score *= 0.7  # penalização para maiores de 45 anos
    return score > 8.0

# Testando com:
print(classificar_candidato(10, 9, 30))  # True
print(classificar_candidato(12, 8, 50))  # False (apesar de mais experiente)
```

A saída mostra como um critério aparentemente técnico (idade) codifica um viés social. Quando executado em massa, esse algoritmo reproduz desigualdades existentes sob o disfarce de objetividade matemática. O erro filosófico aqui é confundir *formalização* com *neutralidade* — toda modelagem computacional implica escolhas valorativas.

### A Materialização de Teorias Sociais

Redes sociais implementam teorias psicológicas através de algoritmos. O "Like" do Facebook, por exemplo, opera com base no behaviorismo de Skinner — reforço positivo para moldar comportamentos. Veja uma simulação simplificada:

```python
import random

class Usuario:
    def __init__(self):
        self.engajamento = 0
    
    def receber_conteudo(self, polarizacao):
        if random.random() < 0.1 + self.engajamento * 0.05:
            self.engajamento += polarizacao * 0.1
            return True  # interagiu
        return False

# Simulando 100 usuários expostos a conteúdo polarizante
usuarios = [Usuario() for _ in range(100)]
for dia in range(30):
    for usuario in usuarios:
        if usuario.receber_conteudo(polarizacao=0.8):
            pass  # conteúdo extremo aumenta engajamento
```

Este modelo minimalista mostra como plataformas *operacionalizam* teorias sobre comportamento humano, transformando abstrações acadêmicas em mecanismos concretos que afetam milhões. A filosofia da computação aqui revela que não há "simples ferramentas" — toda tecnologia computacional é uma teoria social em ação.

### O Problema da Opacidade

Mesmo algoritmos transparentes tecnicamente podem ser opacos socialmente. Considere este sistema de priorização de atendimento médico:

```python
def calcular_prioridade(idade, historico, sintomas):
    return (0.4 * idade/100 + 
            0.3 * sum(historico) + 
            0.3 * sum(s for s in sintomas.values()))

sintomas_paciente = {'febre': 0.8, 'dor': 0.6}
print(calcular_prioridade(30, [1, 0], sintomas_paciente))
```

A saída numérica (ex.: 0.62) mascara os valores sociais embutidos nos pesos (0.4, 0.3, 0.3). Quando esses sistemas falham, como no caso do algoritmo COMPAS para avaliação de réus, a defesa comum é "o código está correto" — ignorando que a correção técnica não resolve problemas de justiça distributiva.

### Exercício Prático

Analise este trecho de código que filtra currículos:

```python
def filtrar_curriculo(palavras_chave, historico_emprego):
    score = sum(p in palavras_chave for p in ['Python', 'SQL', 'PhD'])
    if historico_emprego < 2:
        score -= 2
    return score >= 3
```

**Problema:** Identifique três vieses sociais possivelmente codificados e reescreva a função para mitigá-los.

**Solução comentada:**

1. Viés educacional (valorização excessiva de PhD)
2. Viés contra iniciantes (penalização por pouca experiência)
3. Viés de gênero (linguagens técnicas como filtro)

Versão revisada:

```python
def filtrar_curriculo(projetos, habilidades, tempo_carreira):
    score_projetos = len([p for p in projetos if p.relevante])
    score_habilidades = sum(h.nivel for h in habilidades if h.requerida)
    # Considera trajetórias não-lineares
    return (score_projetos + score_habilidades) / (tempo_carreira + 1) > 2.5
```

Esta versão evita critérios rígidos, considerando trajetórias diversas e habilidades demonstradas em projetos, não apenas títulos ou tempo formal de emprego.