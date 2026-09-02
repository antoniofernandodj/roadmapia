## O papel do designer de UX e UI

Quando falamos em desenvolvimento de software, especialmente na criação de aplicações e sistemas que envolvem interação humana, é comum que desenvolvedores assumam múltiplas funções. Porém, o trabalho de design de UX (User Experience) e UI (User Interface) exige um conjunto específico de responsabilidades que vão além da implementação técnica. Entender claramente o papel do designer de UX e UI ajuda a evitar confusões, melhorar a colaboração e entregar produtos que realmente funcionam para os usuários.

### Por que o papel do designer é distinto do desenvolvedor?

Desenvolvedores são especialistas em transformar ideias e especificações em código funcional. Eles garantem que o sistema execute corretamente as tarefas previstas, lide com dados, conecte-se a bancos de dados, APIs, e mantenha a performance e segurança. No entanto, o desenvolvedor muitas vezes não tem a responsabilidade principal de definir como o usuário interage emocional e visualmente com o sistema — isso é a especialidade do designer de UX e UI.

O designer de UX/UI foca no *porquê* e *como* o usuário usa o produto, enquanto o desenvolvedor se concentra no *o quê* o produto faz e *como* ele é construído tecnicamente. A divisão ajuda a garantir que a experiência do usuário não seja um mero efeito colateral da programação, mas sim um elemento central do desenvolvimento.

### Responsabilidades do designer de UX

O designer de UX atua no planejamento e na criação de uma experiência positiva, eficiente e satisfatória para o usuário. Isso envolve:

- **Entender o usuário:** Pesquisar quem são os usuários, seus objetivos, necessidades, motivações e limitações. Conhecer o contexto em que o produto será usado.
- **Definir fluxos e jornadas:** Mapear as etapas que o usuário percorre para realizar tarefas no sistema, considerando facilidade, clareza e minimização de erros.
- **Arquitetura da informação:** Organizar e estruturar o conteúdo e funcionalidades para que façam sentido lógico e sejam acessíveis.
- **Criar wireframes e protótipos:** Desenvolver representações simples e interativas para testar e validar ideias de interação e navegação.
- **Garantir usabilidade e acessibilidade:** Assegurar que o produto seja fácil de usar, intuitivo e disponível para pessoas com diferentes habilidades.
- **Iterar com base em testes:** Analisar feedback de usuários e métricas para aprimorar continuamente o produto.

Por exemplo, em um app de pizza, o designer de UX decide o fluxo para escolher sabores, tamanho e forma de pagamento, buscando evitar frustrações como um botão escondido ou etapas confusas que levem o usuário a desistir do pedido.

### Responsabilidades do designer de UI

Enquanto o UX define a estrutura e a experiência, o designer de UI é responsável pelo aspecto visual e interativo:

- **Definir o visual da interface:** Escolher cores, tipografia, ícones, espaçamentos e estilos que estejam alinhados à identidade da marca e ao público-alvo.
- **Criar elementos interativos:** Desenvolver botões, menus, formulários, animações e outros componentes que facilitam a interação.
- **Garantir consistência visual:** Usar sistemas de design, guias de estilo e padrões para que a interface tenha harmonia e previsibilidade.
- **Adaptar interfaces para diferentes dispositivos:** Ajustar o layout e elementos para funcionar bem em telas variadas, como celular, tablet e desktop.
- **Colaborar com desenvolvedores:** Fornecer especificações visuais e interativas claras para que o desenvolvimento seja fiel ao design proposto.

Voltando ao app de pizza, o designer de UI cria o visual dos botões de “Adicionar ao carrinho”, escolhe a cor que indica um item selecionado e define a animação que aparece ao confirmar o pedido, tudo isso para garantir uma interface agradável e intuitiva.

### Diferenças práticas entre o papel do designer e do desenvolvedor

Para ilustrar a distinção, imagine a tarefa de criar um formulário de cadastro:

- O **designer de UX** decide quais campos são realmente necessários, a ordem lógica deles, como o usuário será guiado para preencher sem confusão, e o que acontece se ele cometer um erro (mensagens claras e amigáveis).
- O **designer de UI** define o estilo do formulário, cores dos campos, tamanho dos botões e como o foco muda de um campo para outro, garantindo que o formulário seja visualmente atraente e fácil de usar.
- O **desenvolvedor** implementa o código HTML, CSS e JavaScript para que o formulário funcione, valide os dados e envie para o servidor.

Se um desenvolvedor tentar fazer sozinho a parte de UX/UI, é comum que o formulário funcione tecnicamente, mas tenha problemas como:

- Campos desnecessários ou na ordem errada, causando confusão.
- Falta de feedback claro quando o usuário erra o preenchimento.
- Interface visual pouco intuitiva, com botões pequenos ou cores inadequadas.

Um erro típico que um desenvolvedor que ignora a UX pode enfrentar é uma alta taxa de desistência do formulário. Por exemplo, mensagens genéricas de erro do navegador, como:

```
Por favor, preencha este campo.
```

Essas mensagens, embora funcionais, não explicam claramente o que o usuário deve fazer, gerando frustração.

Já um designer de UX cuidaria para que, ao tentar enviar um formulário incompleto, apareça uma mensagem específica, como:

```
Por favor, informe seu endereço de e-mail para enviarmos a confirmação do pedido.
```

Essa diferença melhora a experiência e reduz o abandono.

### Como UX, UI e desenvolvimento se complementam

No mundo real, as funções de UX, UI e desenvolvimento frequentemente se sobrepõem, especialmente em equipes pequenas. No entanto, cada papel tem um foco e conjunto de habilidades próprios que complementam o produto final.

- O designer de UX é o guardião da experiência do usuário, garantindo que o produto seja útil, utilizável e desejável.
- O designer de UI é o responsável pela estética e interatividade, entregando uma interface visualmente coerente e funcional.
- O desenvolvedor é o executor técnico, transformando os designs em código que opera com qualidade e performance.

Essa colaboração entre papéis é essencial para criar produtos que não apenas funcionam, mas que encantam e fidelizam os usuários.

---

### Exercício

Imagine que você está participando da criação de um app para agendar consultas médicas. Descreva três responsabilidades específicas que um designer de UX teria nesse projeto, e três responsabilidades específicas de um designer de UI. Evite mencionar o código e o desenvolvimento técnico.

---

### Solução comentada

**Responsabilidades do designer de UX:**

1. Pesquisar as necessidades dos pacientes para entender o que esperam do app (ex.: facilidade de escolher especialidade, horários disponíveis).
2. Criar o fluxo de agendamento, garantindo que seja simples e rápido, com etapas claras e feedback imediato.
3. Definir como o app lida com erros, como quando um horário está indisponível, para evitar frustrações.

**Responsabilidades do designer de UI:**

1. Escolher cores que transmitam confiança e tranquilidade, importantes em um app de saúde.
2. Projetar botões grandes e legíveis para facilitar o toque em dispositivos móveis.
3. Desenvolver uma tela inicial visualmente organizada, com ícones que representem as especialidades médicas.

Note que nenhuma das responsabilidades envolve escrever código, mas sim planejar e criar a experiência e a interface para que o usuário tenha uma interação satisfatória e eficiente.

---