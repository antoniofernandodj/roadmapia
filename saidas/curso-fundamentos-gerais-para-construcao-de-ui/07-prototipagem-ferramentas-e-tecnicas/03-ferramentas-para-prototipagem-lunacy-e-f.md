## Ferramentas para prototipagem: Lunacy e Figma

Ao avançarmos na prototipagem, escolher a ferramenta adequada é fundamental para transformar wireframes estáticos em protótipos interativos que possam ser testados e validados. Lunacy e Figma são duas opções populares, cada uma com características que atendem a diferentes necessidades, desde a criação rápida até a colaboração em equipe e a integração com fluxos de trabalho de desenvolvimento.

### Lunacy: prototipagem local com alta performance

Lunacy é um editor gráfico focado em design de interfaces, desenvolvido pela Icons8. Ele se destaca por ser uma aplicação nativa para Windows, o que garante alta velocidade e funcionamento offline sem depender de navegador. Além disso, Lunacy suporta arquivos .sketch, permitindo interoperabilidade com designs criados no macOS.

#### Funcionalidades básicas para prototipagem no Lunacy

1. **Criação e organização de telas (frames):** Lunacy permite criar pranchetas (artboards) para organizar as telas do protótipo, definindo tamanhos customizados para dispositivos móveis, desktop ou até layouts responsivos.

2. **Inserção de elementos interativos simulados:** Embora não seja uma ferramenta focada em prototipagem avançada, Lunacy oferece recursos para criar links entre pranchetas por meio de hotspots invisíveis, simulando a navegação entre telas.

3. **Componentes reutilizáveis:** É possível criar símbolos/componentes que permitem manter consistência no design e facilitar atualizações em múltiplas telas do protótipo.

4. **Exportação e compartilhamento:** Lunacy permite exportar protótipos em formatos comuns (PNG, SVG, PDF) e, mais importante, salvar arquivos que podem ser abertos por outros membros da equipe, mesmo sem conta na ferramenta.

#### Exemplo prático: criando um protótipo simples no Lunacy

Imagine que você já tenha um wireframe para um formulário de cadastro. No Lunacy:

- Crie uma nova prancheta com dimensões 375x812 (tamanho típico de smartphone).
- Desenhe os campos do formulário com caixas de texto e botões.
- Insira um retângulo invisível sobre o botão "Enviar".
- Atribua uma ação de link para outra prancheta, representando a tela de sucesso.
  
Esse link simula a navegação e permite testar o fluxo básico sem programação.

#### Erro comum ao usar Lunacy: tentar prototipar interações complexas

Usuários iniciantes podem esperar que Lunacy suporte animações ou transições avançadas como o Figma. Ao tentar isso, a ausência desses recursos pode causar frustração. A solução é entender que Lunacy é excelente para prototipagem estática com navegação simples, mas para protótipos interativos mais ricos, outras ferramentas são indicadas.

---

### Figma: prototipagem avançada e colaborativa na nuvem

Figma é uma ferramenta baseada na web que revolucionou o design colaborativo. Com ela, múltiplos usuários podem trabalhar simultaneamente em um projeto, além de permitir a criação de protótipos interativos com uma interface intuitiva.

#### Funcionalidades básicas para prototipagem no Figma

1. **Frames e Layouts flexíveis:** Frames funcionam como pranchetas, podendo ser dimensionados para qualquer dispositivo. Layout grids ajudam a alinhar e organizar elementos.

2. **Componentes e Variantes:** Crie componentes reutilizáveis com diferentes estados (botão normal, hover, ativo), facilitando a simulação de interações.

3. **Interações e animações:** Figma permite definir gatilhos (click, hover, drag) para navegar entre frames, com opções de transições animadas (dissolver, deslizar, smart animate).

4. **Prototipagem integrada:** O modo protótipo conecta frames e componentes, criando fluxos navegáveis. É possível testar diretamente no navegador ou dispositivo móvel via app.

5. **Comentários e colaboração em tempo real:** Equipes podem comentar diretamente no protótipo, facilitando o feedback e o ajuste iterativo.

6. **Exportação e compartilhamento:** Protótipos podem ser compartilhados via link, com permissões configuráveis (visualização, edição).

#### Exemplo prático: prototipando um formulário com validação e feedback no Figma

Suponha que você tenha o wireframe do formulário de cadastro:

- Crie um frame para a tela do formulário.
- Crie um componente para o botão "Enviar" com variantes: normal, desabilitado e erro.
- Adicione um campo de texto com uma camada de mensagem de erro oculta.
- No modo protótipo, defina que ao clicar no botão "Enviar" com dados inválidos, o protótipo navegue para a mesma tela, mas com o botão e o campo em estado de erro (simulando validação).
- Utilize a transição “smart animate” para suavizar a mudança visual.
  
Isso cria uma experiência interativa que simula o comportamento real do formulário antes do desenvolvimento.

#### Erro comum ao usar Figma: confundir frames com componentes

É comum que iniciantes tentem aplicar interações diretamente em componentes, sem entender que o protótipo navega entre frames. Isso gera protótipos que não funcionam como esperado, com links quebrados ou sem resposta. A solução é estruturar o projeto com frames para as telas e usar componentes para elementos repetidos dentro dessas telas.

---

### Comparação prática e recomendação

| Aspecto                  | Lunacy                              | Figma                                |
|--------------------------|-----------------------------------|------------------------------------|
| Plataforma               | Aplicativo desktop (Windows)      | Web (funciona em qualquer SO)      |
| Offline                  | Sim                               | Não, depende de conexão            |
| Colaboração              | Limitada, via arquivos compartilhados | Em tempo real, multiusuário     |
| Interatividade           | Básica (links simples)             | Avançada (transições, animações)  |
| Curva de aprendizado     | Baixa                             | Moderada                          |
| Integração com dev       | Suporta exportação de assets       | Plugins e integração mais amplas  |

Para prototipagem rápida local, especialmente em ambiente Windows, Lunacy é uma ótima escolha. Para protótipos mais detalhados, interativos e colaborativos, Figma é a ferramenta recomendada.

---

### Exercício prático

**Objetivo:** Criar um protótipo básico de um formulário de login que simule o fluxo de erro de senha incorreta, utilizando Lunacy e Figma.

1. No Lunacy:
   - Crie duas pranchetas: Tela de login e Tela de erro.
   - Desenhe o formulário nas duas telas, na segunda destaque o erro da senha.
   - Adicione um hotspot sobre o botão "Entrar" na primeira tela que leva à segunda.
   - Exporte o projeto e abra as telas para testar a navegação.

2. No Figma:
   - Crie um frame para a tela de login.
   - Crie um componente para o botão "Entrar" com variantes normal e erro.
   - Inclua um campo de texto para senha com mensagem de erro.
   - Configure a interação para que, ao clicar "Entrar" com senha inválida, o protótipo mostre a variante de erro no mesmo frame, usando smart animate.
   - Compartilhe o link do protótipo para visualização.

---

### Solução comentada

No Lunacy, o protótipo é simples, com navegação direta entre telas. Isso permite testar o fluxo, mas não oferece feedback visual dinâmico, apenas a troca de telas.

No Figma, o uso de variantes e animações cria uma experiência mais realista, simulando o estado do botão e a mensagem de erro sem sair da tela. Essa abordagem é mais próxima de um aplicativo real, facilitando o entendimento do comportamento pelo usuário e equipe.

Ambas as ferramentas ajudam a validar hipóteses, mas o Figma amplia a riqueza da prototipagem, especialmente para interações complexas e colaboração.

---