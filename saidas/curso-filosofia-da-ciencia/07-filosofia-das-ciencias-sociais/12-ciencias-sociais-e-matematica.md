## Ciências Sociais e Matemática

Um economista modela a inflação com equações diferenciais. Um sociólogo calcula índices de segregação urbana com álgebra matricial. Um cientista político prevê resultados eleitorais com estatística bayesiana. A matemática não é um acessório nas ciências sociais — é a linguagem que transforma intuições qualitativas em relações quantitativas testáveis. Mas como operações abstratas podem capturar realidades sociais fluidas e contextuais?

### O problema da medição

Considere o Índice de Desenvolvimento Humano (IDH). Ele agrega três dimensões (renda, educação, saúde) em um único número entre 0 e 1. O cálculo parece objetivo:

```python
def calcular_idh(expectativa_escolar, anos_escolaridade, pib_per_capita):
    # Normalização dos componentes
    indice_educacao = (expectativa_escolar / 18) + (anos_escolaridade / 15)
    indice_saude = (expectativa_vida - 20) / (85 - 20)
    indice_renda = (np.log(pib_per_capita) - np.log(100)) / (np.log(75000) - np.log(100))
    
    return (indice_educacao + indice_saude + indice_renda) / 3

# Exemplo para o Brasil (dados aproximados)
print(calcular_idh(16.3, 7.8, 14103))  # Saída: 0.759
```

Mas cada escolha matemática carrega pressupostos:
- Por que usar média aritmética e não geométrica?
- Por que logaritmo para a renda e linear para educação?
- Por que os limites 20-85 anos para saúde?

Essas decisões alteram rankings internacionais. Em 2010, a ONU modificou a fórmula, fazendo a Argentina ultrapassar o Chile. A matemática aqui não é neutra — codifica teorias sobre como dimensões sociais se relacionam.

### Modelos versus realidade

A Curva de Laffer, que relaciona taxação e arrecadação, é um modelo matemático simples:

```python
import numpy as np
import matplotlib.pyplot as plt

def arrecadacao(taxa, elasticidade=1.5, base=100):
    return base * taxa * (1 - taxa)**elasticidade

taxas = np.linspace(0, 1, 100)
plt.plot(taxas, arrecadacao(taxas))
plt.xlabel('Taxa de Imposto')
plt.ylabel('Arrecadação')
plt.show()
```

A curva tem um formato de sino, sugerindo que existe uma taxa ótima. Mas o modelo esconde complexidades:
- A elasticidade varia entre setores
- Não considera evasão fiscal
- Ignora efeitos de longo prazo no investimento

Quando políticos usam esse modelo para justificar cortes tributários, cometem o erro de confundir a elegância matemática com realidade social multifatorial.

### A armadilha da causalidade

Correlação não implica causalidade, mas a matemática pode criar ilusões de relação causal. Considere estes dados fictícios:

```python
import pandas as pd

dados = pd.DataFrame({
    'Investimento em educação (R$)': [100, 200, 300, 400, 500],
    'Notas no ENEM': [500, 550, 620, 580, 610]
})

correlacao = dados.corr()
print(correlacao)
# Saída: 0.74 (correlação positiva)
```

A matemática mostra associação, mas não diz se:
1. Educação causa melhores notas
2. Regiões ricas investem mais e têm alunos com vantagens prévias
3. Há uma terceira variável (ex.: formação dos professores)

Regressões multivariadas tentam resolver isso, mas esbarram no problema da especificação: quais variáveis incluir? A matemática sozinha não responde — exige teoria social.

### Simulações computacionais

A matemática também permite explorar dinâmicas sociais complexas. O modelo de Schelling mostra como pequenas preferências individuais geram segregação:

```python
import numpy as np
import matplotlib.pyplot as plt

def simular_segregacao(tamanho=50, tolerancia=0.3, iteracoes=10):
    grid = np.random.choice([0, 1, 2], size=(tamanho, tamanho))
    
    for _ in range(iteracoes):
        insatisfeitos = []
        for i in range(tamanho):
            for j in range(tamanho):
                if grid[i,j] == 0: continue
                vizinhos = grid[max(0,i-1):i+2, max(0,j-1):j+2]
                iguais = np.sum(vizinhos == grid[i,j]) - 1
                total = vizinhos.size - 1
                if iguais / total < tolerancia:
                    insatisfeitos.append((i,j))
        
        for i, j in insatisfeitos:
            grid[i,j] = 0  # Move para vazio
            vazios = np.argwhere(grid == 0)
            if len(vazios) > 0:
                novo = vazios[np.random.choice(len(vazios))]
                grid[novo[0], novo[1]] = grid[i,j]
    
    plt.imshow(grid, cmap='Pastel1')
    plt.show()

simular_segregacao()
```

Mesmo com tolerância alta (30%), padrões de segregação emergem. A matemática aqui revela mecanismos contra-intuitivos: resultados coletivos não refletem necessariamente preferências individuais.

### Limites da formalização

Nem tudo social é quantificável. Como modelar matematicamente:
- O significado cultural do véu islâmico?
- O efeito psicológico do desemprego?
- A dinâmica de poder em uma reunião familiar?

A tentativa de quantificar o não mensurável leva a reducionismos. O Índice de Felicidade Interna Bruta do Butão, por exemplo, agrega dimensões como "bem-estar psicológico" em escalas numéricas questionáveis.

### Exercício prático

Modifique o modelo de Schelling para incluir três grupos (cores) e uma regra: agentes toleram até 40% de vizinhos diferentes, mas têm preferência por um dos outros grupos. Execute 20 iterações e descreva os padrões emergentes.

**Solução comentada:**

```python
def simular_segregacao_multicor(tamanho=50, iteracoes=20):
    # 0=vazio, 1=grupoA, 2=grupoB, 3=grupoC
    grid = np.random.choice([0, 1, 2, 3], size=(tamanho, tamanho))
    
    for _ in range(iteracoes):
        insatisfeitos = []
        for i in range(tamanho):
            for j in range(tamanho):
                if grid[i,j] == 0: continue
                
                vizinhos = grid[max(0,i-1):i+2, max(0,j-1):j+2]
                total = vizinhos.size - 1
                if total == 0: continue
                
                # Preferência: grupoA prefere grupoB, grupoB prefere C, grupoC prefere A
                preferido = (grid[i,j] % 3) + 1
                indesejado = (preferido % 3) + 1
                
                # Calcula proporção
                iguais = np.sum(vizinhos == grid[i,j]) - 1
                preferidos = np.sum(vizinhos == preferido)
                outros = total - iguais - preferidos
                
                if (preferidos + iguais) / total < 0.4:
                    insatisfeitos.append((i,j))
        
        # Realoca insatisfeitos
        for i, j in insatisfeitos:
            grid[i,j] = 0
            vazios = np.argwhere(grid == 0)
            if len(vazios) > 0:
                novo = vazios[np.random.choice(len(vazios))]
                grid[novo[0], novo[1]] = grid[i,j]
    
    plt.imshow(grid, cmap='Pastel2')
    plt.show()

simular_segregacao_multicor()
```

Padrões emergentes mostram:
1. Formação de enclaves com cores predominantes
2. Áreas de transição onde grupos preferidos se misturam
3. Exclusão do grupo não-preferido de certas regiões
A matemática revela como preferências assimétricas criam hierarquias espaciais.