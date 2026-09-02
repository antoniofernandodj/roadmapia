## Definição do problema

No processo de design centrado no usuário, definir o problema de forma clara é o passo que orienta todas as etapas seguintes. Sem uma definição precisa, o time de design pode criar soluções que não atendem às reais necessidades dos usuários, desperdiçar recursos e perder tempo com funcionalidades irrelevantes. Por isso, é crucial transformar o caos de informações coletadas — entrevistas, observações, dados qualitativos — em um enunciado de problema que seja específico, direcionado e acionável.

### Por que definir o problema de design é crítico?

Imagine que você entrevistou usuários de um aplicativo de compras, anotou reclamações sobre lentidão, dificuldade para encontrar produtos e processos de pagamento confusos. Se você simplesmente listar esses problemas como “o app é lento”, “navegação ruim” e “pagamento complicado”, está colocando sintomas soltos no papel, não a causa raiz que deve ser resolvida.

Sem um problema bem definido, a equipe tende a “atirar no escuro” tentando melhorar tudo ao mesmo tempo ou focar em aspectos superficiais, como a aparência visual, sem resolver as dores reais. Isso gera protótipos que parecem bonitos, mas não melhoram a experiência do usuário.

### O que significa, de fato, “definir o problema”?

Definir o problema é sintetizar e transformar o conjunto de observações e dados em um enunciado claro que:

- **Expresse uma necessidade real do usuário.** Não é o que a empresa quer, nem o que parece mais fácil de fazer.  
- **Seja específico e delimitado.** Evite generalidades vagas como “melhorar o app” ou “aumentar vendas”.  
- **Indique um impacto mensurável ou perceptível.** Por exemplo, “usuários gastam muito tempo para finalizar a compra” ou “novos usuários abandonam o cadastro antes de concluir”.  
- **Sirva como guia para soluções práticas.** A definição deve apontar para o que deve ser melhorado ou criado.

### Como transformar dados em uma definição de problema?

1. **Revisite as informações coletadas** com foco nas dificuldades e necessidades expressas pelos usuários.  
2. **Agrupe problemas semelhantes** e elimine ruídos ou opiniões isoladas que não representam a maioria.  
3. **Pergunte “por quê?” repetidamente** para entender causas profundas, não só sintomas visíveis.  
4. **Escreva frases curtas e objetivas** que resumam o problema.  
5. **Valide a definição com colegas ou até com usuários**, para garantir que o problema faz sentido e é relevante.

### Exemplo prático

Suponha que, após entrevistas e observação de comportamento, você tenha os seguintes dados:

- Usuários reclamam que “a busca demora a responder”.  
- Alguns dizem que “não encontram os filtros que querem”.  
- Outros abandonam o app sem completar a compra.  

Uma definição vaga poderia ser:

> “O app tem problemas na busca e navegação.”

Observe que isso não orienta claramente o que deve ser feito. Agora, vamos aplicar o processo:

- Por que a busca demora? Porque o sistema processa muitos dados sem otimização.  
- Por que os filtros não são encontrados? Porque a interface que exibe os filtros é confusa e pouco acessível.  
- Por que abandonam a compra? Porque não conseguem filtrar produtos rapidamente, o que gera frustração.

A definição do problema pode ser refinada para:

> “Usuários gastam mais de 30 segundos tentando encontrar filtros relevantes na busca, o que causa desistência na finalização da compra.”

Esse enunciado é específico, baseado em comportamento real, e direciona o time para melhorar o desempenho da busca e a usabilidade dos filtros, impactando diretamente na taxa de conversão.

### Erro comum: problema mal definido

Um erro clássico é definir o problema focando em soluções ou desejos da empresa antes de entender o usuário. Por exemplo:

> “Precisamos implementar um sistema de recomendação para aumentar as vendas.”

Essa frase não diz qual problema real do usuário está sendo resolvido, nem por que a recomendação seria útil. Sem isso, o time pode construir uma função sofisticada que ninguém usa.

Ao tentar rodar um script simples para organizar informações de entrevistas, o aluno pode cometer erros como tentar acessar dados sem filtrá-los previamente, causando exceções ou dados inconsistentes. Por exemplo, em Python:

```python
entrevistas = [
    {"usuario": "Ana", "problemas": ["busca lenta", "filtros confusos"]},
    {"usuario": "Carlos", "problemas": []},  # Usuário sem problemas relatados
]

for entrevista in entrevistas:
    for problema in entrevista["problemas"]:
        print(f"{entrevista['usuario']} relatou: {problema}")
```

Se a estrutura dos dados estiver irregular e o código não tratar listas vazias, pode ocorrer erro de iteração ou impressão incorreta.

### Exercício prático

Você entrevistou usuários de um sistema de agendamento online e anotou as seguintes frases:

- “Demoro muito para encontrar horários disponíveis.”  
- “O site fecha antes que eu termine o cadastro.”  
- “Não recebo confirmação clara do agendamento.”  
- “Prefiro usar o app, mas ele é mais lento e trava.”  

Com essas informações, escreva uma definição clara do problema que possa guiar a próxima etapa do design.

---

### Solução comentada

Um exemplo de definição para esse cenário seria:

> “Usuários enfrentam dificuldades para completar o agendamento online devido a demora na exibição dos horários disponíveis e falta de confirmação clara, resultando em desistências durante o cadastro.”

Comentários:

- O enunciado sintetiza as reclamações mais críticas.  
- Foca na experiência do usuário, não em soluções técnicas.  
- Aponta para áreas específicas de melhoria: desempenho na exibição e comunicação da confirmação.  
- É claro e acionável para a equipe de design.

---

Definir o problema dessa maneira evita desperdício de esforços, orienta a ideação de soluções relevantes e mantém o foco no que realmente importa para o usuário. Esse é o coração da aplicação do design thinking em UI/UX: transformar empatia e dados em desafios concretos a serem superados.