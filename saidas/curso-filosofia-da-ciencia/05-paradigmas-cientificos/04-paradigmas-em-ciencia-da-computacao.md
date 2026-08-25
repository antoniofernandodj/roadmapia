## Paradigmas em Ciência da Computação

Um programa que calcula a média de três números pode ser escrito de maneiras radicalmente diferentes dependendo do paradigma escolhido. Veja este exemplo em Python usando o paradigma **imperativo**:

```python
# Paradigma Imperativo
nota1 = 7.5
nota2 = 8.0
nota3 = 6.5
soma = nota1 + nota2 + nota3
media = soma / 3
print(media)  # Saída: 7.333333333333333
```

O mesmo cálculo, no paradigma **funcional**, seria:

```python
# Paradigma Funcional
from functools import reduce

notas = [7.5, 8.0, 6.5]
media = reduce(lambda x, y: x + y, notas) / len(notas)
print(media)  # Saída: 7.333333333333333
```

A diferença essencial não está no resultado, mas na estrutura mental que cada abordagem exige. O paradigma imperativo descreve **como** fazer (passo a passo), enquanto o funcional define **o que** deve ser feito (transformações matemáticas).

### O que torna um paradigma científico

Na Ciência da Computação, um paradigma é reconhecido quando:

1. Possui um **modelo mental** distinto (como variáveis mutáveis vs. imutáveis)
2. Define **restrições** específicas (ex.: sem efeitos colaterais no funcional)
3. Oferece **ferramentas conceituais** próprias (objetos, funções de alta ordem)
4. Resolve **problemas fundamentais** de forma característica

O paradigma **orientado a objetos**, por exemplo, surge da necessidade de modelar sistemas complexos através de entidades autônomas:

```python
# Paradigma Orientado a Objetos
class CalculadoraMedia:
    def __init__(self, notas):
        self.notas = notas
    
    def calcular(self):
        return sum(self.notas) / len(self.notas)

calc = CalculadoraMedia([7.5, 8.0, 6.5])
print(calc.calcular())  # Saída: 7.333333333333333
```

### Conflitos paradigmáticos

A escolha do paradigma afeta diretamente a solução de problemas. Considere este erro comum ao misturar paradigmas:

```python
# Anti-padrão: mistura imperativo com funcional
notas = [7.5, 8.0, 6.5]
soma = 0

# Erro: tentativa de paradigma funcional com mutabilidade
map(lambda nota: soma += nota, notas)  # TypeError: unsupported operand type(s) for +=: 'int' and 'map'
```

A mensagem de erro revela o conflito: o paradigma funcional proíbe mutabilidade, enquanto `soma += nota` é uma operação imperativa. A versão correta seria:

```python
# Paradigma funcional puro
notas = [7.5, 8.0, 6.5]
soma = sum(notas)  # Função pura sem efeitos colaterais
```

### Paradigmas contemporâneos

1. **Lógico** (Prolog): Baseado em regras e inferência
   ```prolog
   % Exemplo em Prolog
   media([X,Y,Z], M) :- M is (X + Y + Z) / 3.
   ?- media([7.5, 8.0, 6.5], M).  % M = 7.333333333333333
   ```

2. **Reativo** (JavaScript/React): Responde a fluxos de dados
   ```javascript
   // Exemplo reativo
   const notas = [7.5, 8.0, 6.5];
   const media = notas.reduce((acc, val) => acc + val, 0) / notas.length;
   ```

3. **Concorrente** (Go): Comunicação entre processos
   ```go
   // Exemplo em Go
   func media(notas []float64, ch chan float64) {
       sum := 0.0
       for _, nota := range notas {
           sum += nota
       }
       ch <- sum / float64(len(notas))
   }
   ```

### Exercício Prático

Transforme este código imperativo em funcional, mantendo o mesmo resultado:

```python
# Código original (imperativo)
numeros = [1, 2, 3, 4, 5]
pares = []
for num in numeros:
    if num % 2 == 0:
        pares.append(num)
print(pares)  # Saída: [2, 4]
```

**Solução:**

```python
# Versão funcional
numeros = [1, 2, 3, 4, 5]
pares = list(filter(lambda x: x % 2 == 0, numeros))
print(pares)  # Saída: [2, 4]
```

A diferença crucial está na ausência de variáveis mutáveis (`pares = []` e `append`) na versão funcional, substituídas por composição de funções puras (`filter` + `lambda`).