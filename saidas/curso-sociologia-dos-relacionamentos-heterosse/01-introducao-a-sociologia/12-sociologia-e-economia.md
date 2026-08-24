## Sociologia e Economia

Quando você escolhe entre comprar um pão na padaria da esquina ou no supermercado mais barato, está fazendo uma decisão econômica? Sim, mas também sociológica. A sociologia econômica revela como as relações sociais moldam mercados, preços e até mesmo o que consideramos "racional" nas trocas econômicas.

### O Mito do Homo Economicus

A economia clássica trabalha com a ficção do "homem econômico" - um ser que sempre maximiza benefícios e minimiza custos de forma independente. A sociologia econômica demonstra que isso não existe na prática:

```python
# Exemplo: Dois modelos de decisão de compra
class HomoEconomicus:
    def decidir(self, preços):
        return min(preços)  # Sempre escolhe o mais barato

class PessoaReal:
    def __init__(self):
        self.relações = {'padaria': 'amigo', 'supermercado': 'desconhecido'}
    
    def decidir(self, preços):
        if self.relações['padaria'] == 'amigo':
            return preços[0] + 2.00  # Paga mais para ajudar um conhecido
        else:
            return min(preços)

print(f"Economia clássica escolheria: R${HomoEconomicus().decidir([5.00, 4.50])}")
print(f"Decisão real seria: R${PessoaReal().decidir([5.00, 4.50])}")
```

Saída:
```
Economia clássica escolheria: R$4.5
Decisão real seria: R$7.0
```

### Mercados como Construções Sociais

Os economistas neoclássicos imaginam mercados como sistemas autônomos. A sociologia econômica mostra que até mesmo bolsas de valores dependem de:

1. **Redes de confiança**: Quem você conhece afeta que informações recebe
2. **Convenções culturais**: O que é considerado "investimento seguro" varia entre sociedades
3. **Estruturas de poder**: Grandes players influenciam regras do jogo

Um estudo clássico de Mitchel Abolafia sobre os traders de Wall Street mostrou que eles:
- Compram/vendem baseados em códigos de honra do grupo
- Ignoram análises técnicas quando um colega "confiável" dá uma dica
- Mantêm laços sociais que violariam teorias de mercado eficiente

### O Caso Brasileiro: Jeitinho como Moeda

No Brasil, a sociologia econômica explica fenômenos como:

```python
class TransaçãoBrasileira:
    def __init__(self):
        self.preço_oficial = 100.00
        self.descontos = {
            'parentesco': 0.15,
            'fidelidade': 0.10,
            'jeitinho': 0.20
        }
    
    def calcular_preço(self, relação):
        return self.preço_oficial * (1 - self.descontos.get(relação, 0))

transação = TransaçãoBrasileira()
print(f"Preço para desconhecido: R${transação.calcular_preço('desconhecido'):.2f}")
print(f"Preço para cliente antigo: R${transação.calcular_preço('fidelidade'):.2f}")
print(f"Preço para 'quem indica': R${transação.calcular_preço('jeitinho'):.2f}")
```

Saída:
```
Preço para desconhecido: R$100.00
Preço para cliente antigo: R$90.00
Preço para 'quem indica': R$80.00
```

### Quando a Sociologia Econômica Falha

Cuidado com o erro comum de achar que tudo é construção social. A realidade econômica impõe limites:

```python
def inflação_psicológica(salário, expectativas):
    return salário * (1 + expectativas['inflação_percebida'])

# Tentando aplicar apenas fatores sociais
salário = 3000
expectativas = {'inflação_percebida': 0.5}  # Medo generalizado
print(f"Salário necessário: R${inflação_psicológica(salário, expectativas):.2f}")

# ERRO: Ignorando fundamentos macroeconômicos
# Traceback (most recent call last):
#   File "<stdin>", line 1, in <module>
# NameError: name 'taxa_juros_real' is not defined
```

A solução está em integrar ambas as perspectivas:
```python
def salário_equilíbrio(salário, expectativas, fundamentos):
    return (salário * (1 + expectativas['inflação_percebida']) 
            + fundamentos['taxa_juros_real'])
```

### Exercício Prático

Analise esta transação real em uma feira livre:
- Preço tabelado do kg do tomate: R$ 5,00
- Dona Maria (vendedora há 15 anos) cobra R$ 4,00 de clientes antigos
- Cobra R$ 6,00 de turistas (que não sabem negociar)
- Aceita R$ 3,50 de quem ajuda a arrumar as caixas

**Pergunta:** Quais conceitos da sociologia econômica explicam essa variação?

**Solução Comentada:**
1. **Capital social** (clientes antigos têm "crédito" de relacionamento)
2. **Assimetria de informação** (turistas não conhecem o mercado local)
3. **Reciprocidade** (quem ajuda ganha desconto como troca implícita)
4. **Múltiplos circuitos econômicos** (não há um único "preço de mercado")