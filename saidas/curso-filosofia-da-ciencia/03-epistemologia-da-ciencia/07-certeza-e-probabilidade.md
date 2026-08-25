## Certeza e Probabilidade

A ciência opera em um terreno paradoxal: busca verdades universais enquanto reconhece que todo conhecimento empírico é provisório. Esse tensionamento entre certeza e probabilidade define a prática científica contemporânea. Vejamos como isso se manifesta na produção do conhecimento.

### O Mito da Certeza Cartesiana

René Descartes, no século XVII, buscava fundamentos indubitáveis para o conhecimento. Seu famoso "Penso, logo existo" pretendia estabelecer uma verdade absoluta. Porém, quando aplicamos esse ideal à ciência empírica, encontramos obstáculos insuperáveis:

1. **Problema da Indução**: Nenhum número finito de observações garante uma lei universal. Mesmo após ver 1.000 cisnes brancos, não podemos afirmar com certeza que todos os cisnes são brancos (como demonstrado pela descoberta de cisnes negros na Austrália).

2. **Subdeterminação das teorias**: Dados empíricos nunca determinam uma única teoria como verdadeira. Sempre existem múltiplas explicações compatíveis com as mesmas observações.

### Probabilidade como Linguagem da Ciência

Diante da impossibilidade da certeza absoluta, a ciência adotou a probabilidade como ferramenta epistêmica central. Considere este exemplo da física de partículas:

```python
# Simulação simples do princípio de incerteza
import random

def medir_posicao_e_momento():
    # Valores "verdadeiros" (inacessíveis)
    posicao_real = 5.0  
    momento_real = 3.0
    
    # Medições com incerteza (distribuição normal)
    posicao_medida = random.gauss(posicao_real, 0.5)
    momento_medido = random.gauss(momento_real, 0.5)
    
    return posicao_medida, momento_medido

# Executando múltiplas medições
resultados = [medir_posicao_e_momento() for _ in range(5)]
for i, (pos, mom) in enumerate(resultados, 1):
    print(f"Medição {i}: Posição={pos:.2f}, Momento={mom:.2f}")
```

Saída típica:
```
Medição 1: Posição=5.23, Momento=2.87
Medição 2: Posição=4.91, Momento=3.12
Medição 3: Posição=5.34, Momento=3.45
Medição 4: Posição=4.78, Momento=2.93
Medição 5: Posição=5.05, Momento=3.21
```

Esse código ilustra dois aspectos fundamentais:
1. Mesmo em condições controladas, as medições variam probabilisticamente
2. Nunca acessamos os valores "verdadeiros", apenas distribuições de probabilidade

### Graus de Certeza na Prática Científica

A ciência estabelece hierarquias de confiança através de mecanismos como:

- **Valor-p**: Probabilidade de obter resultados tão extremos quanto os observados, assumindo que a hipótese nula é verdadeira. Um valor-p de 0.01 significa que há 1% de chance dos dados serem compatíveis com a ausência do efeito estudado.

- **Intervalos de confiança**: Em vez de afirmar "a velocidade da luz é 299.792.458 m/s", dizemos "estamos 95% confiantes que está entre 299.792.457 e 299.792.459 m/s".

### O Caso do Bóson de Higgs

A descoberta do bóson de Higgs em 2012 exemplifica esse paradigma probabilístico. Os físicos não afirmaram "encontramos o Higgs", mas sim que havia uma probabilidade de 99.99994% (5σ) de que o sinal observado não fosse devido ao acaso. Esse padrão de 5 sigma tornou-se o limiar para "descoberta" na física de partículas.

### Certeza Matemática vs. Certeza Empírica

É crucial distinguir:

| Tipo de Certeza | Exemplo | Base |
|-----------------|---------|------|
| Matemática | "2+2=4" | Verdade lógica necessária |
| Empírica | "A água ferve a 100°C ao nível do mar" | Generalização de observações contingentes |

A primeira é a priori e infalível; a segunda é a posteriori e revisável. A confusão entre esses domínios leva a erros como o dogmatismo científico.

### Exercício: Avaliando Afirmações Científicas

Classifique estas afirmações quanto ao seu grau de certeza (use: Certa, Provável, Improvável, Falsa) e justifique:

1. "Todos os corpos caem com aceleração constante de 9,8 m/s²"
2. "O DNA humano tem estrutura de dupla hélice"
3. "Vacinas causam autismo"
4. "Existem infinitos números primos"

**Solução comentada:**

1. **Improvável**: A aceleração varia com altitude, latitude e características do corpo (resistência do ar).
2. **Provável**: Embora bem estabelecido, novas descobertas poderiam revelar exceções (como DNA quadruplex em algumas condições).
3. **Falsa**: Rejeitada por múltiplos estudos com alto poder estatístico.
4. **Certa**: Demonstração matemática rigorosa (Euclides, 300 a.C.) que não depende de evidência empírica.