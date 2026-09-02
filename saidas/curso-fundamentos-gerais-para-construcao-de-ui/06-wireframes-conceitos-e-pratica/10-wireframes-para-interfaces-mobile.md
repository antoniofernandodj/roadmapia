## Wireframes para interfaces mobile

O desafio de criar wireframes para interfaces mobile está diretamente ligado às limitações físicas e contextuais dos dispositivos móveis. A tela menor, o uso predominantemente com as mãos e a necessidade de interações rápidas e intuitivas exigem uma abordagem diferenciada para estruturar o conteúdo e a navegação. Sem levar em conta o design responsivo, que será abordado em outro momento, o foco aqui é entender essas particularidades e aplicar princípios eficazes de wireframing para mobile.

### O impacto do tamanho reduzido na estruturação dos wireframes

Em dispositivos móveis, a área visível é significativamente menor do que em desktops ou mesmo tablets. Isso significa que o wireframe deve priorizar a informação essencial e garantir que o usuário possa navegar e interagir sem esforço excessivo.

Imagine um app de tarefas, onde o usuário quer rapidamente adicionar, visualizar e completar uma tarefa. Um wireframe mobile deve evitar aglomeração de elementos que obrigariam a muitos scrolls ou toques para alcançar funções básicas.

**Exemplo prático: wireframe mobile para tela inicial de app de tarefas**

```plaintext
+-----------------------------+
| [Ícone Menu]    TAREFAS      |
+-----------------------------+
| + Nova Tarefa               >|
+-----------------------------+
| Tarefa 1                    >|
| Tarefa 2                    >|
| Tarefa 3                    >|
+-----------------------------+
| [Home] [Adicionar] [Perfil] |
+-----------------------------+
```

Esse wireframe básico define:

- Um cabeçalho simples com menu e título.
- Um botão claro para adicionar nova tarefa, destacado e de fácil alcance.
- Lista de tarefas clicáveis para detalhes.
- Barra de navegação inferior, acessível com o polegar.

### Toque, alcance e zona de conforto do usuário

Um erro comum ao criar wireframes para mobile é colocar elementos interativos em áreas de difícil alcance, como no topo da tela para usuários que operam o celular com uma mão. Pesquisas mostram que o polegar tem maior facilidade para alcançar a parte inferior e central da tela.

Portanto, no wireframe, botões importantes como "Adicionar" ou "Enviar" devem estar posicionados preferencialmente próximo à base da tela, e o menu principal pode ficar acessível por um gesto ou um ícone no canto superior, onde o uso do polegar é menos frequente.

### Priorizar conteúdo e reduzir elementos visuais desnecessários

Wireframes mobile devem evitar excesso de texto, múltiplos botões ou imagens que poluem a tela. Isso não só prejudica a clareza visual, como também pode causar frustração no uso.

No wireframe, use blocos simples para representar conteúdo e ações, sem detalhes visuais. Por exemplo, campos de entrada devem ser indicados por retângulos com rótulos claros, e ícones devem ser estilizados de forma minimalista.

### Indicar claramente o fluxo e navegação simplificada

Como o espaço é escasso, a navegação deve ser direta e óbvia. Em wireframes mobile, a navegação inferior (barra com ícones) ou menus hambúrguer são comuns para economizar espaço.

Além disso, o fluxo deve ser representado com setas e anotações claras que indiquem o caminho do usuário, evitando ambiguidades.

**Exemplo prático: fluxo simplificado para adicionar tarefa**

```plaintext
[Tela Inicial] --(tocar "+ Nova Tarefa")--> [Tela de Nova Tarefa]
[Botão Salvar] --(tocar)--> [Tela Inicial com tarefa adicionada]
```

Essa representação pode ser adicionada como anotação no wireframe para orientar desenvolvedores e designers.

### Atenção ao desempenho mental e carga cognitiva

Com base nos conceitos de psicologia cognitiva já estudados, wireframes mobile devem minimizar a carga cognitiva do usuário, apresentando poucos elementos de cada vez e utilizando padrões familiares de interface.

Por exemplo, o uso de ícones comuns como lupa para busca ou lápis para edição, mesmo em wireframes de baixa fidelidade, ajuda o time a entender rapidamente a intenção da interface.

### Erro comum: tentar replicar toda a interface desktop no mobile

Um erro frequente é tentar reduzir todos os elementos da versão desktop para a tela pequena do celular, criando interfaces confusas e pouco usáveis.

**Exemplo de wireframe incorreto para mobile:**

```plaintext
+--------------------------------------------------+
| Menu Principal | Notificações | Perfil | Configs |
+--------------------------------------------------+
| Lista longa de tarefas com detalhamento extenso |
| Muitos botões de ação em cada item               |
| Vários links e menus suspensos                    |
+--------------------------------------------------+
| Rodapé com 10 ícones diferentes                   |
+--------------------------------------------------+
```

Esse wireframe, mesmo que estrutural, indica sobrecarga visual e interativa. O usuário teria dificuldade para encontrar rapidamente o que precisa e realizar ações básicas.

### Exercício prático

Crie um wireframe para uma tela inicial de um app de notícias mobile, considerando:

- Um cabeçalho com o logo e um ícone de busca.
- Uma lista simplificada de manchetes (3 a 5 itens).
- Um botão fixo para acessar a seção de categorias, posicionando-o em área de fácil alcance.
- Uma barra de navegação inferior com 3 ícones principais: Home, Favoritos e Perfil.
- Indicação clara do fluxo para abrir uma notícia e voltar à lista.

**Solução comentada**

```plaintext
+-----------------------------+
| [Logo]           [Ícone 🔍]  |
+-----------------------------+
| Manchete 1                > |
| Manchete 2                > |
| Manchete 3                > |
+-----------------------------+
| [Botão Categorias]          |
+-----------------------------+
| [Home] [Favoritos] [Perfil] |
+-----------------------------+
```

- O cabeçalho tem logo e busca, itens essenciais para identificação e pesquisa rápida.
- A lista é curta para evitar scroll excessivo.
- O botão de categorias está posicionado logo abaixo da lista para fácil alcance.
- A barra inferior mantém a navegação consistente e acessível com o polegar.
- O fluxo é indicado nas anotações: tocar na manchete leva à página da notícia, onde um botão "Voltar" retorna à lista.

Este wireframe respeita as limitações do mobile, priorizando clareza, simplicidade e usabilidade, elementos essenciais para uma boa experiência no ambiente móvel.

---