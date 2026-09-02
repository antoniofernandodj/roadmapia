## Fluxo e navegação em wireframes

Imagine que você está projetando um aplicativo de notas. Seu usuário precisa criar, visualizar, editar e excluir notas facilmente. Como garantir que, antes mesmo de desenhar telas detalhadas, o caminho que o usuário fará para realizar essas tarefas esteja claro, lógico e intuitivo? É aí que entra a representação do fluxo e da navegação em wireframes.

Wireframes não são apenas desenhos estáticos de interfaces; eles devem comunicar o percurso do usuário — ou seja, a sequência de telas e interações que levam o usuário a completar uma tarefa. Representar o fluxo e a navegação no wireframe ajuda a detectar gargalos, opções confusas e passos desnecessários, evitando retrabalho e problemas no desenvolvimento.

### Por que representar o fluxo e a navegação?

Sem uma visão clara do fluxo, é comum criar telas isoladas, como se cada página fosse um mundo à parte. O usuário, porém, navega por um sistema seguindo caminhos lógicos, e o design deve refletir isso. Se o fluxo for confuso, o usuário se perde, gera frustração e abandona a tarefa.

No nível do wireframe, o foco não está em animar o fluxo, mas em indicar claramente, de forma simples e compreensível, como as telas se conectam e quais ações o usuário pode realizar para avançar, voltar, ou acessar funcionalidades importantes.

### Como representar fluxo e navegação em wireframes

Ao criar wireframes, você pode usar elementos visuais simples para mostrar navegação e sequência:

- **Setas e linhas**: Conectam telas ou áreas clicáveis, indicando para onde o usuário vai ao interagir.
- **Botões e links destacados**: Indicam ações que iniciam transições.
- **Anotações breves**: Explicam o que acontece em cada ação, como “Ao clicar em ‘Editar’, abre a tela de edição”.
- **Hierarquia de navegação**: Menus, barras de navegação e botões de retorno devem estar claros.

Vamos criar um exemplo prático para um fluxo básico de um app de notas com três telas principais:

- Tela inicial: lista de notas
- Tela de criação/edição de nota
- Tela de visualização detalhada da nota

### Exemplo prático: fluxo simplificado em wireframes

```plaintext
+---------------------+          +--------------------------+
| Tela Inicial: Lista  | --(1)--> | Tela Visualização da Nota |
| de Notas             |          |                          |
| - Lista de títulos   |          | - Mostra conteúdo da nota |
| - Botão "Nova Nota"  |          | - Botão "Editar"          |
+---------------------+          +--------------------------+
       ^      |                             |
       |      |(3) Botão "Salvar"           |(2) Botão "Editar"
       |      v                             v
+---------------------+          +--------------------------+
| Tela de Criação/     | <------------------------------+
| Edição de Nota       |
| - Campo título       |
| - Campo conteúdo     |
| - Botão "Salvar"     |
+---------------------+
```

**Explicação do fluxo:**

1. Na Tela Inicial, o usuário pode clicar em uma nota para abrir a Tela de Visualização da Nota.
2. Na Tela de Visualização, o usuário pode clicar em "Editar" para ir para a Tela de Criação/Edição.
3. Na Tela de Criação/Edição, após fazer alterações, o usuário clica em "Salvar" e volta para a Tela Inicial, atualizando a lista.

Esse esquema mostra claramente para onde cada ação leva o usuário, sem necessidade de diagramas complexos.

### Criando o fluxo passo a passo no wireframe

Agora, vamos desenhar os wireframes com indicação do fluxo usando setas e símbolos simples.

```plaintext
[ Tela Inicial: Lista de Notas ]
---------------------------------
| + Nova Nota           ( + )    |
|                               |
| - Nota 1                      >|
| - Nota 2                      >|
| - Nota 3                      >|
---------------------------------

Seta (>) indica clicar para abrir a nota.

[ Tela Visualização da Nota ]
-----------------------------
| Nota 1                      |
| ---------------------------------
| Conteúdo da nota...             |
|                               |
| [Editar]                      |
| [Voltar]                     |
-----------------------------

Seta [Editar] leva para tela de edição.

[ Tela Criação/Edição da Nota ]
------------------------------
| Título: [Nota 1]             |
| Conteúdo: [Conteúdo...]      |
|                              |
| [Salvar]   [Cancelar]        |
------------------------------

Botão [Salvar] retorna para Tela Inicial com lista atualizada.
```

No wireframe, você pode usar linhas ou setas desenhadas à mão ou com ferramentas simples para ligar esses botões ou áreas clicáveis à próxima tela correspondente. Isso torna o fluxo visível e compreensível para desenvolvedores, designers e stakeholders.

### Erro comum: não indicar o fluxo no wireframe

Um erro frequente é criar wireframes para telas sem mostrar para onde o usuário vai ao interagir. Por exemplo, um wireframe da Tela Inicial com botões e lista, mas sem indicação de “ao clicar em nota X, abre a tela tal”. Isso gera dúvidas, retrabalho e confusão.

Se você deixar o fluxo implícito, o desenvolvedor pode implementar navegação errada, o usuário pode se perder, e o time de design não terá base para discutir melhorias.

### Dica para fluxo simples e eficaz

- Use setas para indicar navegação entre telas.
- Anote ações relevantes (ex: “botão salvar retorna à lista”).
- Mostre botões de navegação padrão (voltar, menu) claramente.
- Evite criar fluxos complexos demais no wireframe; foque no essencial para a tarefa chave.
- Use símbolos comuns, como “>” para links, “+” para criar, “x” para fechar, para facilitar leitura rápida.

### Exercício prático

Crie wireframes para um fluxo de cadastro simples, composto por:

1. Tela inicial com botão “Cadastrar”.
2. Tela de formulário de cadastro com campos para nome, email e senha, além de botões “Salvar” e “Cancelar”.
3. Tela de confirmação de cadastro com mensagem “Cadastro realizado com sucesso” e botão “Voltar para início”.

Represente o fluxo do usuário entre essas telas usando setas e anotações simples, indicando o que cada botão faz e para onde leva o usuário.

---

### Solução comentada do exercício

```plaintext
[ Tela Inicial ]
----------------------
| Cadastrar (botão)   |
----------------------

(ao clicar "Cadastrar", vai para tela de cadastro)

[ Tela Cadastro ]
----------------------
| Nome: [_________]    |
| Email: [_________]   |
| Senha: [_________]   |
| [Salvar] [Cancelar]  |
----------------------

- "Salvar": valida e, se sucesso, vai para tela de confirmação.
- "Cancelar": volta para tela inicial.

[ Tela Confirmação ]
----------------------
| Cadastro realizado   |
| com sucesso!         |
|                      |
| [Voltar para início] |
----------------------

(ao clicar "Voltar para início", retorna para Tela Inicial)
```

O fluxo é:

- Tela Inicial → (Cadastrar) → Tela Cadastro
- Tela Cadastro → (Salvar) → Tela Confirmação
- Tela Cadastro → (Cancelar) → Tela Inicial
- Tela Confirmação → (Voltar para início) → Tela Inicial

Esse fluxo claro, indicado no wireframe com setas e anotações, garante que o projeto seja compreendido e validado antes da prototipagem ou desenvolvimento.

---

Representar o fluxo e a navegação em wireframes é fundamental para planejar uma experiência de usuário fluida e eficiente. Use elementos visuais simples para deixar claro o caminho que o usuário deve seguir, facilitando comunicação e evitando erros futuros.