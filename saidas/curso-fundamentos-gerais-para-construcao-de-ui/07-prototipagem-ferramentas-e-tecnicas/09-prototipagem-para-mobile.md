## Prototipagem para mobile

O dedo tem cerca de nove milímetros de largura útil e não tem ponta visível. Essa única frase explica metade das diferenças entre prototipar para celular e para desktop. A outra metade vem do contexto: quem usa o celular está em pé, com uma mão, no ônibus, com o sol na tela, sendo interrompido a cada dois minutos.

Prototipar mobile bem é aceitar essas duas restrições desde a primeira tela, em vez de encolher um layout de desktop e esperar que caiba.

### As medidas que governam tudo

Comece com os números certos, porque eles decidem o que é possível:

| Medida | Valor | Origem |
|---|---|---|
| Alvo de toque mínimo | 44 × 44 pt (iOS) / 48 × 48 dp (Android) | Diretrizes oficiais das plataformas |
| Espaço entre alvos | mínimo 8 pt | Evita toque acidental no vizinho |
| Zona de alcance do polegar | terço inferior da tela | Uso com uma mão |
| Frame de trabalho | 390 × 844 (iPhone padrão) ou 360 × 800 (Android comum) | Dispositivos medianos atuais |

O primeiro item é o mais violado. Um ícone de 24 pixels desenhado em um protótipo parece perfeitamente clicável no monitor; no dispositivo, ele exige mira. A solução padrão é manter o ícone com 24 pixels de tamanho visual e a **área tocável** com 44 ou 48 — um retângulo transparente maior em volta. No protótipo, desenhe essa área e deixe-a visível durante a construção, escondendo só no fim.

A zona do polegar tem consequência direta na hierarquia: em telas de 6 polegadas ou mais, o topo é praticamente inalcançável com uma mão. É por isso que a navegação principal migrou para o rodapé nos dois sistemas, e por isso ações destrutivas costumam ficar no topo — a dificuldade de alcance vira proteção.

### Prototipando gestos

Gestos são o que mais diferencia mobile, e as ferramentas suportam os principais:

- **Toque** (`On tap`) — equivalente ao clique.
- **Arrastar** (`On drag`) — para carrosséis, painéis deslizantes e o gesto de puxar para atualizar.
- **Deslizar** (`While hovering` não existe; use `On drag` com direção) — para ações em item de lista, como arquivar ou excluir.
- **Pressionar e segurar** (`On press` com atraso) — para menus contextuais.

Um exemplo completo: painel deslizante de baixo para cima (*bottom sheet*).

1. Crie o frame principal da tela.
2. Crie o painel como um frame separado, com a altura do conteúdo, posicionado fora da área visível.
3. No gatilho: `On tap` no botão → `Open overlay` → posicione **Bottom center**, com `Slide in` de baixo, e fundo escurecido.
4. Marque `Close when clicking outside`.
5. Dentro do painel, adicione uma alça (o tracinho horizontal) e configure `On drag` para baixo → `Close overlay`.

O passo 5 é o que faz a diferença no teste. Sem ele, as pessoas tentam arrastar o painel para baixo — porque é o que todo aplicativo faz — e nada acontece, e elas concluem que o protótipo está quebrado quando o problema é apenas de simulação.

### As transições importam mais aqui

Em desktop, uma transição instantânea é aceitável. Em mobile, ela desorienta: sem o movimento, a pessoa perde a noção de para onde foi e de como voltar. As convenções estabelecidas:

- **Avançar na hierarquia**: nova tela entra deslizando da direita.
- **Voltar**: sai deslizando para a direita.
- **Modal / ação temporária**: entra de baixo para cima.
- **Troca de aba na navegação principal**: sem movimento direcional, ou dissolve.

Contrariar isso confunde de um jeito que os participantes não conseguem verbalizar — eles apenas dizem que "ficou estranho". Se você ouvir isso no teste e não souber a causa, confira as direções de transição antes de qualquer outra coisa.

### Estados que só existem em mobile

O protótipo precisa cobrir situações que em desktop simplesmente não ocorrem:

**Teclado aberto.** Ele come metade da tela. Uma tela de formulário que parece perfeita passa a mostrar dois campos e nada mais — e o botão "Continuar", que estava no rodapé, fica escondido atrás do teclado. Desenhe pelo menos um frame com o teclado visível (um retângulo cinza de aproximadamente 300 pixels de altura já basta) e veja o que sobra.

**Rotação.** Se a aplicação permite paisagem, há um segundo layout. Se não permite, decida isso explicitamente.

**Conexão ruim.** Estados de carregamento em mobile duram mais e são mais frequentes. Um esqueleto de conteúdo ou um indicador de progresso não é refinamento, é obrigatório.

**Interrupção.** Uma ligação chega no meio do cadastro. Ao voltar, o que a pessoa encontra? Se o formulário foi limpo, você perdeu o usuário.

**Permissões.** Câmera, localização, notificações — cada uma é um diálogo do sistema operacional que interrompe o fluxo. Prototipar esse diálogo (mesmo como uma imagem estática sobreposta) revela se o pedido está sendo feito no momento certo, com contexto suficiente para a pessoa entender por que aceitar.

### O erro que você vai cometer: testar no navegador do computador

Você abre o protótipo no modo de apresentação, redimensiona a janela para um formato estreito e testa clicando com o mouse. Tudo funciona. Aí você abre no celular e descobre três coisas de uma vez: os alvos são pequenos demais, o texto de 12 pixels é ilegível ao sol, e o polegar cobre exatamente o elemento que precisava ser visto ao tocar.

Nenhum desses problemas é detectável com mouse em monitor. Todos são óbvios em cinco segundos no dispositivo.

A correção é trivial e quase ninguém faz: instale o aplicativo Figma Mirror (ou use o link de protótipo aberto no navegador do próprio celular) e teste **no aparelho**, segurando com uma mão só, de preferência em pé. Faça isso a cada rodada de mudanças, não só no fim. E se o seu público usa aparelhos de entrada com telas de 5 polegadas, teste num aparelho assim — não no seu, que provavelmente é melhor que o da maioria.

### Exercício prático

**Objetivo:** prototipar um fluxo mobile de três telas com gestos, teclado e estados.

Monte, em 390 × 844:

1. `lista` — lista de itens com ação de deslizar para arquivar.
2. `detalhe` — item aberto, com transição da direita e botão de voltar.
3. `novo-item` — formulário com três campos e botão de salvar no rodapé.
4. `novo-item-teclado` — a mesma tela com o teclado aberto ocupando 300 pixels na parte inferior.

Interações a implementar:

- Toque no item da lista → `detalhe`, com `Move in` da direita.
- Voltar em `detalhe` → ação `Back`, com `Move out` para a direita.
- Arrastar um item da lista para a esquerda → revela o botão "Arquivar".
- Botão flutuante de adicionar → `novo-item`, com `Move in` de baixo.
- Toque no primeiro campo de `novo-item` → `novo-item-teclado`.
- Botão salvar → sobreposição de confirmação por dois segundos (`After delay` → `Close overlay`) e volta à lista.

Teste tudo no celular, segurando com uma mão.

### Solução comentada

A tela `novo-item-teclado` é o coração do exercício, e o resultado é quase sempre o mesmo: **o botão "Salvar", que estava fixo no rodapé, desaparece atrás do teclado**.

Existem três soluções em uso, e todas têm custo:

1. **Botão que sobe junto com o teclado**, colado logo acima dele. É a melhor experiência e a mais trabalhosa de implementar, porque exige reagir à altura do teclado, que varia por dispositivo e por idioma.
2. **Botão no topo da tela**, na barra de navegação. Sempre visível, mas fora da zona do polegar e fora da convenção de "confirmar fica embaixo".
3. **Botão no fim do formulário**, alcançado rolando. Simples de implementar e o pior dos três em uso, porque a pessoa não sabe que ele existe até rolar.

O protótipo não resolve isso sozinho — mas colocar as três variantes na frente de três pessoas resolve em quinze minutos, e a decisão deixa de ser uma discussão de arquitetura para virar uma observação.

O gesto de deslizar para arquivar traz uma segunda lição. Ao testar no aparelho, é comum que os participantes **não descubram o gesto**. Gestos são invisíveis por natureza: não há nada na tela dizendo que deslizar faz algo. A conclusão correta não é abandonar o gesto — é que ele nunca pode ser o **único** caminho para uma ação importante. A regra prática: gesto é atalho para quem descobre, e sempre precisa de um equivalente visível, normalmente um menu de três pontos no item. Se, no seu teste, alguém precisou arquivar e não conseguiu, o problema não é a pessoa não conhecer o gesto — é a ausência do caminho alternativo.

---
