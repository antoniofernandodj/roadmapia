## Filosofia dos Algoritmos

Um algoritmo de recomendação de vídeos sugere conteúdo cada vez mais radical. Um sistema de crédito nega empréstimos a bairros pobres. Um chatbot reproduz discursos de ódio. Por trás desses casos está uma questão filosófica fundamental: algoritmos são neutros ou carregam valores implícitos?

Considere o algoritmo de ordenação mais básico, o bubble sort:

```python
def bubble_sort(lista):
    n = len(lista)
    for i in range(n):
        for j in range(0, n-i-1):
            if lista[j] > lista[j+1]:
                lista[j], lista[j+1] = lista[j+1], lista[j]
    return lista

print(bubble_sort([64, 34, 25, 12, 22, 11, 90]))
```

Saída:
```
[11, 12, 22, 25, 34, 64, 90]
```

Aparentemente neutro, mas sua "filosofia" está nas decisões:
1. **Prioriza ordem crescente** (poderia ser decrescente)
2. **Comparação direta entre elementos** (ignora relações contextuais)
3. **Eficiência como valor máximo** (sacrifica clareza para velocidade)

Quando implementamos um algoritmo de busca binária, escondemos uma ontologia:

```python
def busca_binaria(arr, alvo):
    esquerda, direita = 0, len(arr) - 1
    while esquerda <= direita:
        meio = (esquerda + direita) // 2
        if arr[meio] == alvo:
            return meio
        elif arr[meio] < alvo:
            esquerda = meio + 1
        else:
            direita = meio - 1
    return -1

print(busca_binaria([1, 3, 5, 7, 9, 11], 7))
```

Saída:
```
3
```

Os pressupostos metafísicos aqui incluem:
- **Discretização do contínuo** (classificação binária "maior/menor")
- **Ordenação total** (qualquer elemento é comparável)
- **Existência de respostas exatas** (índice ou -1)

O erro filosófico comum é confundir o mapa com o território. Um algoritmo de classificação de imagens médicas pode retornar:

```python
classificador.predict(imagem_raio_x)
```
Saída:
```
"normal"  # quando na verdade há um tumor raro
```

A mensagem de erro filosófica seria: "O modelo reduziu uma realidade complexa (saúde humana) a probabilidades estatísticas (89.7% de confiança)".

Exercício: Modifique o bubble sort para priorizar números pares, mantendo a ordenação dentro de cada grupo. Isso revela como critérios aparentemente técnicos incorporam juízos de valor.

Solução:
```python
def bubble_sort_pares(lista):
    n = len(lista)
    for i in range(n):
        for j in range(0, n-i-1):
            # Prioriza pares, depois ordena dentro de cada grupo
            if (lista[j] % 2 != lista[j+1] % 2 and lista[j] % 2 == 1) or \
               (lista[j] % 2 == lista[j+1] % 2 and lista[j] > lista[j+1]):
                lista[j], lista[j+1] = lista[j+1], lista[j]
    return lista

print(bubble_sort_pares([37, 12, 51, 28, 43, 6, 19]))
```

Saída:
```
[6, 12, 28, 19, 37, 43, 51]  # Pares primeiro, ordenados; depois ímpares ordenados
```