## Casos práticos de aplicação do design thinking

Imagine que você precisa redesenhar a experiência de compra em um aplicativo de supermercado online, pois os usuários reclamam que o processo é confuso e demorado. Como aplicar o design thinking para resolver esse problema?

### 1. Empatia: conhecendo o usuário na prática

Você começa entrevistando usuários reais, observando como fazem compras pelo app. João, um usuário, diz: “Eu sempre erro a quantidade dos produtos porque não entendo onde ajustar”. Ana comenta: “O app demora para carregar a lista e isso me irrita”. Você anota essas dores e emoções, percebendo que a interface atual não é clara nem responsiva.

**Erro comum:** tentar resolver só com base em dados quantitativos, como número de cliques, sem ouvir o usuário. Isso pode levar a mudanças que não melhoram a experiência real.

### 2. Definição do problema: sintetizando as necessidades reais

A partir das entrevistas, você identifica que o problema principal não é só velocidade, mas a dificuldade em ajustar quantidades e revisar o carrinho antes da compra. A definição clara fica:

> "Usuários têm dificuldade em ajustar quantidades de produtos e revisar o carrinho, o que causa erros e frustração durante a compra no app."

Sem essa definição, soluções podem focar só na velocidade, ignorando a usabilidade.

### 3. Ideação: gerando soluções variadas

Agora, você reúne seu time para uma sessão de brainstorming. Aplicando a técnica "E se...", geram ideias como:

- E se o app tivesse um resumo do carrinho destacando produtos com quantidades acima de 1?  
- E se fosse possível ajustar quantidades direto na lista de produtos, sem precisar abrir outra tela?  
- E se o app mostrasse alertas quando a quantidade ultrapassasse o estoque disponível?

Você usa um script simples em Python para organizar essas ideias por categoria, como “interface”, “alertas” e “fluxo”.

```python
ideas = [
    "Resumo do carrinho com destaque para quantidades",
    "Ajuste de quantidade na lista de produtos",
    "Alertas de estoque insuficiente",
    "Carregamento mais rápido da lista",
    "Botão de confirmação antes do pagamento"
]

categories = {"interface": [], "alertas": [], "fluxo": []}

for idea in ideas:
    if "alertas" in idea or "estoque" in idea:
        categories["alertas"].append(idea)
    elif "ajuste" in idea or "resumo" in idea:
        categories["interface"].append(idea)
    else:
        categories["fluxo"].append(idea)

print("Ideias organizadas por categoria:")
for cat, items in categories.items():
    print(f"{cat.capitalize()}:")
    for i in items:
        print(f" - {i}")
```

**Saída real:**

```
Ideias organizadas por categoria:
Interface:
 - Resumo do carrinho com destaque para quantidades
 - Ajuste de quantidade na lista de produtos
Alertas:
 - Alertas de estoque insuficiente
Fluxo:
 - Carregamento mais rápido da lista
 - Botão de confirmação antes do pagamento
```

### 4. Prototipagem rápida: criando um modelo tangível

Você decide prototipar a ideia do ajuste direto na lista e o resumo do carrinho. Em papel ou no Figma, cria telas simplificadas que mostram o produto com botões “+” e “–” para alterar quantidades e uma tela de resumo destacando produtos com quantidade maior que 1.

**Erro comum:** pular a prototipagem e ir direto para o desenvolvimento, o que pode resultar em retrabalho se a solução não funcionar para os usuários.

### 5. Teste e validação com usuários

Você convida João e Ana para testar o protótipo. Eles simulam a compra e apontam que ajustar quantidades ficou muito mais fácil e rápido. Ana comenta que o resumo do carrinho ajuda a evitar erros, mas sugere um alerta visual mais chamativo para quantidades altas.

Você anota o feedback, percebe que o protótipo ainda pode melhorar, e volta para a etapa de ideação ou prototipagem para ajustar.

### 6. Iteração: refinando com base no feedback

Incorpora o alerta visual no protótipo e repete o teste com outros usuários. A melhoria é confirmada, e o time se sente seguro para avançar para o desenvolvimento real.

---

## Outro exemplo: Redesenho de tela de login para app bancário

- **Empatia:** usuários reclamam de erros frequentes e dificuldade em entender mensagens.  
- **Definição:** problema claro: “Usuários não compreendem o motivo dos erros de login, causando desistência.”  
- **Ideação:** gerar ideias como mensagens de erro claras, sugestões de recuperação de senha, e feedback visual imediato.  
- **Prototipagem:** criar protótipos com mensagens simples, campos destacados, e botões de ajuda.  
- **Teste:** observar que usuários conseguem corrigir erros sozinhos.  
- **Iteração:** ajustar mensagens para torná-las ainda mais amigáveis e evitar termos técnicos.

---

## Exercício prático

Escolha um app ou site que você usa com frequência e identifique um problema que os usuários enfrentam. Aplique as etapas do design thinking para criar uma solução inicial:

1. Liste 3 reclamações comuns (empatia).  
2. Defina o problema em uma frase clara e específica.  
3. Gere ao menos 5 ideias para solucionar o problema (use “E se...” ou mapa mental).  
4. Esboce um protótipo rápido (pode ser em papel).  
5. Teste seu protótipo com alguém (pode ser um amigo ou familiar) e anote o feedback.  
6. Proponha uma melhoria para o protótipo com base no teste.

---

## Solução comentada

Suponha que você escolheu um app de transporte que demora para calcular rotas.

1. Reclamações: demora para mostrar rotas, interface confusa, dificuldade em cancelar corrida.  
2. Problema: “Usuários enfrentam lentidão e dificuldade para cancelar corridas no app.”  
3. Ideias:  
   - Mostrar barra de progresso durante cálculo  
   - Botão de cancelamento visível e fácil de acessar  
   - Opção de rotas alternativas rápidas  
   - Mensagens claras sobre status da corrida  
   - Tela simplificada para usuários iniciantes  
4. Protótipo: desenha tela com barra de progresso e botão cancelamento destacado.  
5. Teste: usuário nota que barra ajuda a entender o que está acontecendo, mas sugere botão maior.  
6. Iteração: aumenta botão e adiciona opção de confirmação para evitar cancelamento acidental.

---

Este exercício demonstra como o design thinking guia a solução de problemas reais, focando no usuário, experimentando rápido e melhorando com feedback — o caminho para designs eficazes e centrados no ser humano.