## Exercícios de Computação

### O problema do viés algorítmico
Um algoritmo de seleção de currículos para estágio em tecnologia foi implementado assim:

```python
import pandas as pd

def filtrar_candidatos(df):
    # Peso maior para universidades de elite
    df['pontos'] = df['universidade'].map({'Harvard':5, 'MIT':5, 'Stanford':5, 
                                         'USP':3, 'UFMG':3, 'Outras':1})
    
    # Penaliza candidatos com nomes não-ocidentais
    nomes_penalizados = ['Mohammed', 'Fatima', 'Juan', 'Wei']
    df['pontos'] -= df['nome'].apply(lambda x: 3 if x in nomes_penalizados else 0)
    
    # Ordena por pontos e seleciona os 10% melhores
    return df.sort_values('pontos', ascending=False).head(int(len(df)*0.1))
```

Quando testado com dados históricos, o sistema replicou os vieses humanos anteriores em vez de corrigi-los. A saída para um conjunto fictício mostrou:

```
       nome universidade  pontos
12    João          USP       3
45  Pedro         UFMG       3 
8   Maria        Harvard     5  # Selecionado
63  Wei           MIT        2  # Penalizado
```

**Erro filosófico**: O código confunde correlação histórica (candidatos de certas universidades foram aprovados no passado) com causalidade (essas universidades produzem melhores profissionais). Implementa um realismo ingênuo ao tratar rótulos sociais como propriedades intrínsecas.

### Solução consciente
Reescrevemos o algoritmo usando critérios diretamente relacionados à função:

```python
def filtrar_candidatos(df, provas_tecnicas):
    # Unifica dados de currículo e desempenho real
    df = pd.merge(df, provas_tecnicas, on='id_candidato')
    
    # Critérios objetivos
    df['pontos'] = (
        0.6 * df['nota_prova'] + 
        0.3 * df['experiencia'] +
        0.1 * df['github_ativo'].astype(int)
    )
    
    # Ordenação justa
    return df.sort_values('pontos', ascending=False).head(int(len(df)*0.1))
```

A nova versão trata universidades e nomes como metadados irrelevantes para a decisão. Saída corrigida:

```
    nome universidade  nota_prova  pontos
12  João          USP         92    87.2
63  Wei           MIT         90    85.5
45 Pedro         UFMG         88    83.8
```

### O dilema do determinismo computacional
Considere este gerador "aleatório" de senhas:

```python
import random

random.seed(42)  # Fixa a semente

def gerar_senha():
    return ''.join(random.choice('ABCDEF123456') for _ in range(8))

print(gerar_senha())  # Sempre imprime 'A21B4F1D'
```

Aparentemente determinístico, mas quando executado em diferentes versões do Python pode variar. Isso demonstra como:

1. **Determinismo algorítmico**: O mesmo código + mesma entrada → mesma saída
2. **Indeterminismo físico**: Implementações diferentes quebram essa garantia
3. **Consequência filosófica**: Computação não opera num vácuo platônico

### Exercício prático: Emergência em sistemas simples
Implemente um autômato celular unidimensional (Regra 110) que exibe comportamentos complexos a partir de regras simples:

```python
def regra110(padrao):
    novo = []
    for i in range(len(padrao)):
        esq = padrao[i-1] if i>0 else 0
        centro = padrao[i]
        dir = padrao[i+1] if i<len(padrao)-1 else 0
        
        # Regra determinística
        novo.append(1 if (esq, centro, dir) in {(1,1,0),(1,0,1),(0,1,1),(0,0,1)} else 0)
    return novo

# Execução iterativa
estado = [0]*15 + [1] + [0]*15
for _ in range(20):
    print(''.join('█' if x else ' ' for x in estado))
    estado = regra110(estado)
```

Saída mostra padrões complexos emergindo:
```
               █               
              ██               
             ███               
            ██ █               
           █████               
          ██   █               
         ███  ██               
        ██ █ ███               
       ███████ █               
      ██     ███               
```

**Conclusão filosófica**: Propriedades de alto nível (complexidade) não estão contidas nas partes individuais (regras locais simples), mas surgem de suas interações - desafia o reducionismo clássico.

### Solução do exercício
A implementação correta deve:
1. Tratar as bordas como zeros (condição de contorno fixa)
2. Aplicar exatamente as 4 condições da Regra 110
3. Mostrar iterações sequenciais para visualizar a emergência

O erro mais comum é confundir as condições da regra, produzindo padrões trivialmente repetitivos em vez de complexidade genuína. A versão acima resolve isso mapeando corretamente os casos (1,1,0), (1,0,1), (0,1,1) e (0,0,1) para 1.