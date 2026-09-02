## Prototipagem do projeto

Imagine que você já tem seu wireframe pronto, estruturando as telas e o fluxo de navegação do seu produto. O próximo passo é transformar esse esqueleto em algo palpável, que possa ser explorado, clicado, e testado — mesmo que ainda não seja um software funcional. A prototipagem do projeto é justamente essa etapa: criar uma versão interativa, onde o usuário pode navegar entre telas, acionar botões e entender como a interface realmente vai se comportar.

### Por que prototipar?

Você pode pensar: “Já tenho os wireframes, por que não partir direto para o desenvolvimento?” O problema é que, sem protótipos, muitos detalhes importantes ficam ocultos. Interações, fluxos e até mesmo a lógica de navegação podem apresentar falhas que só aparecerão quando o usuário estiver usando o produto. Corrigir isso depois que o código está pronto é muito custoso e demorado.

Protótipos resolvem esse problema ao criar um ambiente controlado para validar hipóteses, testar caminhos, e comunicar a ideia de forma clara para equipes ou clientes. Eles evitam mal-entendidos, reduzem retrabalho e aceleram decisões.

### Diferença entre protótipos e wireframes

Wireframes são representações estáticas da estrutura da interface, focados em organização e hierarquia visual, sem funcionalidade. Prototipagem acrescenta interatividade — o usuário pode clicar, navegar e sentir o fluxo do produto.

Por exemplo, um wireframe pode mostrar um botão “Enviar” numa tela de formulário, mas o protótipo permitirá que o usuário clique nesse botão e veja o que acontece em seguida, navegando para uma tela de confirmação.

### Níveis de fidelidade na prototipagem

Você pode criar protótipos de baixa, média ou alta fidelidade. Para o projeto final, o foco aqui é prototipagem de baixa a média fidelidade, sem animações complexas, priorizando a clareza e a usabilidade.

- **Baixa fidelidade:** protótipos simples, parecidos com wireframes clicáveis, sem detalhes visuais elaborados. Úteis para validar fluxo e estrutura.
- **Média fidelidade:** mais próximo do visual final, com cores, tipografia e componentes mais definidos, mas ainda sem funcionalidades complexas ou animações avançadas.
- **Alta fidelidade:** protótipos quase idênticos ao produto final, com interações detalhadas e animações, geralmente usados em etapas finais de validação ou apresentação.

### Ferramentas para prototipagem

Ferramentas como **Figma** e **Lunacy** são ideais para criar protótipos interativos sem precisar programar. Ambas permitem conectar telas, definir hotspots clicáveis e simular navegação.

Aqui usaremos o Figma para um exemplo simples, mas o conceito vale para outras ferramentas.

---

### Exemplo prático: prototipando um fluxo simples no Figma

Suponha que você tenha duas telas principais no seu projeto: uma tela inicial com botão para acessar um formulário, e uma tela de formulário com botão de envio.

1. **Abra o Figma** e importe as telas que você desenhou nos wireframes, seja desenhando diretamente ou importando imagens.
2. Na tela inicial, selecione o botão que leva ao formulário.
3. Com o botão selecionado, clique em “Prototype” (Prototipagem) no painel direito.
4. Arraste o nó azul do botão para a tela de formulário, criando um link.
5. Defina a ação como “On Click” (ao clicar) e o tipo de transição, por exemplo “Instant” para uma troca rápida.
6. Na tela de formulário, selecione o botão “Enviar”.
7. Crie um link para a tela de confirmação ou agradecimento, repetindo o processo.

Agora, clique em “Present” para abrir o protótipo em modo de visualização interativa.

---

### Código e configuração não são necessários, mas veja como isso se traduz em lógica simples:

```text
Tela Inicial:
  Botão "Abrir Formulário" -> Ao clicar -> Navegar para Tela de Formulário

Tela de Formulário:
  Botão "Enviar" -> Ao clicar -> Navegar para Tela de Confirmação
```

---

### Erro comum: tentar criar protótipos com funcionalidades reais

Um erro recorrente é tentar incluir funcionalidades reais no protótipo, como validar dados de formulário ou armazenar informações. Ferramentas de prototipagem não são ambientes de programação completos. Se você tentar, verá mensagens de erro ou comportamentos estranhos, como:

```
Erro: Ação não suportada no protótipo.
```

Para evitar isso, mantenha o foco em simular a navegação e as interações básicas, deixando a lógica complexa para o desenvolvimento real.

---

### Construindo fluxos de navegação coerentes

Ao criar seu protótipo, pense sempre no caminho natural que o usuário fará. Para isso:

- **Mapeie o fluxo:** desenhe o caminho que começa na primeira tela e segue até o objetivo final, por exemplo, o envio de um formulário.
- **Use componentes reutilizáveis:** botões, menus e campos que aparecem em várias telas devem ser criados como componentes. Isso facilita alterações e mantém a consistência.
- **Inclua feedback visual simples:** mesmo sem animações avançadas, você pode indicar estados como “botão pressionado” com variações visuais de cor ou sombra.
- **Evite quebrar o fluxo:** certifique-se que todas as interações levam a uma tela ou ação definida. Telas sem saída ou links quebrados geram confusão.

---

### Exercício prático

Crie um protótipo interativo para um fluxo simples de cadastro com as seguintes telas:

1. Tela inicial com botão “Cadastrar”.
2. Tela de formulário com campos para nome, email e senha, e botão “Enviar”.
3. Tela de confirmação que agradece o cadastro.

**Passos para o exercício:**

- Utilize uma ferramenta de prototipagem (Figma, Lunacy ou similar).
- Importe ou crie telas simples, sem detalhes visuais avançados.
- Defina as interações entre os botões e as telas correspondentes.
- Teste o protótipo navegando entre as telas.
- Documente as interações criadas com anotações breves, para que qualquer pessoa entenda o fluxo.

---

### Solução comentada

Seguindo o exercício, você deve ter:

- Tela inicial com botão “Cadastrar” configurado para navegar à tela de formulário.
- Tela de formulário com botão “Enviar” que leva à tela de confirmação.
- Cada botão configurado com a ação “On Click” e transição “Instant” para facilitar a fluidez.
- Uso de componentes para botões, garantindo consistência visual e facilidade de ajustes.
- Anotações próximas aos botões explicando as interações, por exemplo:  
  `// Botão "Cadastrar" navega para a tela de formulário`  
  `// Botão "Enviar" leva à tela de confirmação, finalizando o fluxo`

Ao executar o protótipo, você deve conseguir navegar de forma linear e intuitiva, validando o fluxo básico do cadastro. Esse protótipo é uma base sólida para testes iniciais e comunicação do projeto.

---

A prototipagem do seu projeto não precisa ser complexa para ser eficaz. Com interações simples, fluxo claro e componentes reutilizáveis, você cria uma experiência próxima da real, que facilita a validação e o diálogo com equipes e usuários. Lembre-se: o objetivo é validar o fluxo e a usabilidade, não construir um produto final em código.