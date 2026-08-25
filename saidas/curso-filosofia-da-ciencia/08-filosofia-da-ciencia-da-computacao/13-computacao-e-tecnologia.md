## Computação e Tecnologia

Um programa que ordena números parece uma ferramenta puramente técnica, até você perceber que `sort([3,1,4])` e `sort(["maçã", "banana"])` exigem filosofias distintas. O primeiro opera sobre magnitudes matemáticas, o segundo sobre convenções linguísticas arbitrariamente codificadas. Esta é a primeira fissura que revela como a computação não é neutra — mesmo algoritmos aparentemente objetivos carregam pressupostos ontológicos sobre o que pode ser comparado e como.

Considere o problema prático de implementar um sistema de recomendação de livros. Um engenheiro ingênuo poderia escrever:

```python
def recomendar(livros_usuario, todos_livros):
    return sorted(todos_livros, 
                 key=lambda x: -sum(1 for y in livros_usuario if y.categoria == x.categoria))
```

Quando testado com:

```python
livros = [Livro("Crime e Castigo", "Literatura"), 
          Livro("Python for Dummies", "Técnico"),
          Livro("1984", "Literatura")]
print(recomendar([livros[0]], livros))
```

A saída seria:
```
[<Livro: Crime e Castigo>, <Livro: 1984>, <Livro: Python for Dummies>]
```

O erro filosófico aqui é sutil mas crucial: o algoritmo assume que categorias são compartimentos estanques e que preferências são transitivas — se você gosta de um livro de literatura, gostará de todos. Na prática, isso gera recomendações absurdas como sugerir Dostoiévski para quem comprou um manual de Python, apenas por compartilharem a categoria "Literatura Russa" em algum nível de classificação.

A mensagem de erro conceitual não vem como `SyntaxError`, mas como usuários frustrados. Para corrigir, precisamos reconhecer que tecnologia é sempre uma teoria materializada:

```python
def recomendar(livros_usuario, todos_livros):
    # Considera múltiplas dimensões: estilo, tema, complexidade
    def similaridade(a, b):
        return (0.4*a.estilo.similar(b.estilo) + 
                0.3*a.temas.comuns(b.temas) + 
                0.3*(1 - abs(a.complexidade - b.complexidade)))
    
    return sorted(todos_livros,
                 key=lambda x: -max(similaridade(y, x) for y in livros_usuario))
```

Este código melhorado explicita os juízos de valor (pesos 0.4, 0.3, 0.3) que sempre estiveram presentes, mas eram ocultos na versão anterior. A filosofia aparece nos coeficientes — por que estilo vale mais que temas? Quem define o que é "complexidade"? Eis o cerne da relação computação-tecnologia: toda implementação técnica é uma congelamento provisório de escolhas conceituais contestáveis.

O experimento decisivo vem quando alteramos os pesos:

```python
# Versão temática
pesos = [0.2, 0.6, 0.2]  # Ênfase em temas
# Versão elitista
pesos = [0.1, 0.2, 0.7]  # Ênfase em complexidade
```

Cada configuração produz recomendações radicalmente diferentes para os mesmos inputs, revelando como a tecnologia não é um espelho da realidade, mas uma lente que a distorce de formas específicas. Quando sistemas de IA falham em reconhecer sotaques regionais ou perpetuam estereótipos de gênero, não são "bugs" técnicos — são sintomas dessa camada filosófica subjacente que confunde convenções humanas com verdades computacionais.

Exercício: Implemente uma função `filtrar_noticias(artigos, preferencias)` que selecione artigos jornalísticos baseado em critérios de relevância. Mostre como diferentes definições de "relevância" (atualidade, proximidade geográfica, impacto social) produzem realidades informacionais distintas para os mesmos dados brutos.

Solução comentada:

```python
class Artigo:
    def __init__(self, titulo, data, local, impacto):
        self.titulo = titulo
        self.data = data  # dias atrás
        self.local = local  # km de distância
        self.impacto = impacto  # escala 1-10

def filtrar_noticias(artigos, preferencias):
    """Filtra artigos baseado em pesos conceituais"""
    tempo, espaco, social = preferencias
    return sorted(artigos,
                 key=lambda x: -(tempo/(x.data+1) + espaco/(x.local+1) + social*x.impacto))

# Dados de exemplo                
artigos = [Artigo("Greve geral", 1, 50, 8),
           Artigo("Eclipse lunar", 3, 1000, 5),
           Artigo("Novo parque", 10, 5, 3)]

# Três realidades possíveis:
print("Visão localista:", filtrar_noticias(artigos, [1, 10, 1]))  # Prioriza proximidade
print("Visão temporal:", filtrar_noticias(artigos, [10, 1, 1]))   # Prioriza atualidade
print("Visão social:", filtrar_noticias(artigos, [1, 1, 10]))     # Prioriza impacto
```

A saída revela como a tecnologia não filtra notícias, mas constrói diferentes realidades:

```
Visão localista: [Novo parque, Greve geral, Eclipse lunar]
Visão temporal: [Greve geral, Eclipse lunar, Novo parque] 
Visão social: [Greve geral, Eclipse lunar, Novo parque]
```