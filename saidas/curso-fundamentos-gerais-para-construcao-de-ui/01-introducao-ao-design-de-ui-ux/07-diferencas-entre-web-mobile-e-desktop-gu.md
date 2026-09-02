## Diferenças entre web, mobile e desktop GUI

Ao criar interfaces gráficas (GUIs) para diferentes plataformas — web, mobile e desktop — o designer de UI/UX enfrenta desafios específicos que vão além da simples adaptação visual. Cada contexto apresenta limitações técnicas, comportamentais e de ambiente que influenciam diretamente a experiência do usuário e a forma como a interface deve ser projetada. Entender essas diferenças é fundamental para garantir que o produto seja eficiente, acessível e agradável em qualquer dispositivo.

---

### Por que as diferenças importam?

Imagine um usuário tentando realizar uma tarefa no seu app de pizza. Se a interface web for cheia de elementos pequenos e menus complexos, ela pode ser frustrante na tela do celular. Se a versão desktop não aproveitar o espaço da tela para facilitar a visualização, o usuário pode perder tempo navegando. Por isso, o design não pode ser simplesmente “esticado” ou “reduzido” entre plataformas: é necessário repensar a interface considerando o contexto de uso.

---

### 1. Contexto de uso e ambiente

- **Desktop**: Geralmente usado em ambientes estáveis, como escritório ou casa, com usuário sentado, usando teclado e mouse, e tela grande. Tarefas podem ser mais complexas ou longas, com múltiplas janelas abertas simultaneamente.
- **Web**: Acessada por navegadores em vários dispositivos, desktop ou mobile. A diversidade de navegadores e conexões exige interfaces adaptáveis, que funcionem bem mesmo com instabilidades na conexão.
- **Mobile**: Usado em movimento, com telas pequenas e toque como principal forma de interação. O usuário pode estar distraído, com tempo limitado, ou com uma mão ocupada. A interface deve ser simples, clara e focada em tarefas rápidas.

---

### 2. Tamanho e resolução da tela

Na **desktop GUI**, o espaço é amplo. É possível mostrar muitos elementos simultaneamente, menus detalhados, e até múltiplos painéis. A alta resolução permite usar fontes pequenas e detalhes visuais complexos sem perda de legibilidade.

No **mobile**, a tela é reduzida e a resolução varia muito (de smartphones a tablets). Isso exige interfaces minimalistas, com elementos grandes para toque preciso e navegação simplificada. A hierarquia visual deve ser clara para evitar confusão em espaços limitados.

Na **web**, a tela pode variar desde desktops a dispositivos móveis, o que exige design responsivo. Isso significa que a interface se adapta automaticamente ao tamanho da tela, reorganizando ou ocultando elementos conforme necessário.

---

### 3. Modos de interação

- **Desktop**: Interação via teclado e mouse permite ações precisas, uso de atalhos, menus contextuais e múltiplas opções simultâneas. O hover (passar o mouse sobre um elemento) é uma forma importante de apresentar informações adicionais.
- **Mobile**: Interação por toque exige botões maiores e espaçados para evitar toques errados. Não existe hover, então todas as informações devem estar visíveis ou acessíveis por toque. Gestos (deslizar, pinçar) são comuns e devem ser considerados no design.
- **Web**: Depende do dispositivo, mas precisa funcionar bem tanto com mouse/teclado quanto com toque, o que torna o design mais complexo.

---

### 4. Performance e limitações técnicas

Em **desktop**, geralmente há mais poder de processamento, memória e conexão estável. Isso permite interfaces mais complexas, animações detalhadas e maior uso de recursos visuais.

No **mobile**, as limitações de hardware e conexões menos estáveis exigem otimização rigorosa: imagens leves, menos animações, carregamento progressivo e foco em eficiência.

Na **web**, a performance depende do dispositivo do usuário e da conexão. O design deve priorizar carregamento rápido e funcionalidade mesmo em conexões lentas ou instáveis.

---

### 5. Expectativas e comportamento do usuário

Usuários em **desktop** costumam esperar interfaces robustas, com muitas funcionalidades e controles detalhados, ideais para tarefas extensas, como edição de documentos ou análise de dados.

Usuários **mobile** buscam rapidez e simplicidade, com acesso rápido às funções mais importantes e navegação intuitiva.

Na **web**, o usuário espera flexibilidade: acessar o serviço de qualquer dispositivo, com uma experiência consistente e adaptada ao aparelho usado.

---

### Exemplo prático: formulário de pedido no app de pizza

Suponha que você projete um formulário para que o usuário finalize o pedido.

- No **desktop**, o formulário pode mostrar todos os campos de uma vez, com várias opções de personalização e botões pequenos com texto descritivo.
- No **mobile**, o formulário deve ser dividido em etapas ou usar menus suspensos para reduzir a quantidade de informação na tela. Os botões precisam ser grandes, e o texto, legível mesmo em telas pequenas.
- Na **web**, o formulário deve ser responsivo, adaptando a quantidade de campos mostrados conforme o tamanho da janela, funcionando bem no computador e no celular.

---

### Erro comum e sua correção

Um erro típico é aplicar exatamente o mesmo layout de desktop em mobile, apenas reduzindo o tamanho dos elementos. Isso leva a botões pequenos demais, necessidade de zoom, e dificuldade de navegação.

**Erro comum no código HTML/CSS (mobile):**

```html
<button style="width: 100px; height: 30px; font-size: 12px;">Enviar Pedido</button>
```

Este botão fica pequeno para toque em smartphone, causando frustração.

**Mensagem real de usabilidade:** “Botão muito pequeno para toque, difícil de clicar.”

**Correção recomendada:**

```html
<button style="width: 100%; height: 50px; font-size: 18px; padding: 10px;">Enviar Pedido</button>
```

Aumentar o tamanho, usar largura total e fonte maior facilita a interação no mobile.

---

### Conclusão prática

Projetar para web, mobile e desktop não é apenas redimensionar elementos, mas repensar a interface considerando contexto, interação, limitações técnicas e comportamento do usuário. Essa adaptação é essencial para garantir uma boa experiência em qualquer plataforma.

---

### Exercício

Você tem um aplicativo de agenda médica que funciona em desktop e mobile. No desktop, a interface mostra um calendário mensal completo e uma lista detalhada de compromissos. No mobile, o calendário aparece apenas em formato semanal e a lista é simplificada.

- Descreva quais são as razões para essa diferença no design entre as duas plataformas.
- Proponha três melhorias específicas para a versão mobile, justificando suas escolhas.

---

### Solução comentada

**Razões para as diferenças:**

- A tela do desktop é grande, permitindo mostrar o calendário mensal completo e detalhes, facilitando planejamento e visão global.
- A tela do mobile é pequena, então mostrar o calendário mensal completo deixaria os elementos muito pequenos e ilegíveis.
- O foco no mobile é em tarefas rápidas, como consultar compromissos do dia ou da semana, por isso o formato semanal é mais adequado.
- A lista simplificada evita excesso de informação, facilitando a leitura e toque.

**Três melhorias para mobile:**

1. **Botões maiores para navegação entre semanas:** facilitar o toque para mudar de período, evitando frustração com botões pequenos.
2. **Uso de gestos para navegação:** permitir deslizar horizontalmente para mudar semanas, aproveitando o toque intuitivo.
3. **Resumo do compromisso ao tocar no item:** mostrar detalhes em um modal ou tela separada, mantendo a lista enxuta mas com acesso rápido à informação.

Essas melhorias consideram as limitações de tela e interação do mobile, proporcionando uma experiência mais fluida e centrada no usuário.

---