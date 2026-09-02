## Feedback visual e microinterações

Dois protótipos com exatamente as mesmas telas e o mesmo fluxo podem produzir reações opostas em teste. A diferença está no que acontece entre uma tela e outra: se o botão afunda ao ser pressionado, se a lista aparece deslizando ou aparece de estalo, se o item excluído some suavemente ou desaparece deixando um salto no layout.

Isso não é enfeite. Microinterações fazem três trabalhos concretos: confirmam que a ação foi recebida, explicam o que mudou e para onde, e dizem se o resultado foi bem-sucedido. Quando faltam, a pessoa preenche a lacuna sozinha — e normalmente preenche com "não funcionou, vou clicar de novo".

### A anatomia de uma microinteração

Toda microinteração tem quatro partes, e nomeá-las ajuda a projetar em vez de improvisar:

1. **Gatilho** — o que a inicia (uma ação da pessoa ou um evento do sistema).
2. **Regra** — o que acontece e sob que condições.
3. **Retorno** — o que a pessoa percebe: movimento, mudança de cor, som, vibração.
4. **Modo e ciclo** — o que acontece depois, e o que permanece mudado.

Tome o "curtir" de qualquer rede social. Gatilho: toque no ícone. Regra: alterna entre curtido e não curtido, e incrementa o contador. Retorno: o ícone muda de cor, cresce brevemente e volta; o número sobe. Modo: o estado curtido persiste.

Repare que o retorno acontece **antes** da confirmação do servidor. É deliberado: a interface assume o sucesso, mostra o resultado imediatamente e corrige caso a requisição falhe. Isso torna a ação instantânea aos olhos de quem usa, ao custo de uma reversão rara e visível.

### Os estados que todo elemento interativo precisa

Antes de qualquer animação, o básico. Um controle sem estados é um controle que não conversa:

| Estado | Quando ocorre | O que comunica |
|---|---|---|
| Padrão | Repouso | "Existo e sou clicável" |
| Hover | Ponteiro sobre (desktop) | "Você está mirando em mim" |
| Foco | Selecionado por teclado | "O teclado está aqui" |
| Pressionado | Durante o clique/toque | "Recebi sua ação" |
| Carregando | Ação em andamento | "Estou trabalhando" |
| Desabilitado | Indisponível | "Não sou uma opção agora" |
| Erro / Sucesso | Após a ação | "Deu errado / deu certo" |

O estado **pressionado** é o mais barato e o mais esquecido. Ele responde em menos de 100 milissegundos, sem depender do servidor, e sozinho elimina a maior parte dos cliques duplicados por insegurança.

O estado **desabilitado** merece um cuidado extra: um botão cinza que não faz nada e não diz por quê é uma das frustrações mais comuns em software. Sempre que possível, ou o botão está ativo e explica o erro ao ser acionado, ou permanece desabilitado com um texto ao lado dizendo o que falta.

### Prototipando movimento com Smart Animate

O recurso que faz o trabalho pesado é o `Smart Animate` do Figma. A regra dele é simples e precisa ser entendida para não desperdiçar tempo: ele compara os dois frames, encontra camadas **com o mesmo nome** e anima a diferença entre elas — posição, tamanho, opacidade, rotação, cor.

O que isso significa na prática:

- Se você renomear a camada, a animação quebra e vira um corte seco.
- Se você duplicar o frame e mover o elemento, funciona perfeitamente.
- Se você recriar o elemento do zero no segundo frame, não funciona.

Um exemplo completo — um item sendo marcado como concluído:

1. Duplique o frame da lista. Chame de `lista` e `lista-concluido`.
2. Em `lista-concluido`: no primeiro item, mude a cor do texto para cinza, aplique tachado, e troque o ícone do círculo vazio pelo círculo preenchido. **Não renomeie nada.**
3. No círculo do item em `lista`: `On tap` → `Navigate to` → `lista-concluido`, com `Smart animate`, `Ease out`, 200 ms.

O resultado é uma transição que parece programada, feita em dois minutos.

### Tempos e curvas: a diferença entre elegante e irritante

Duração é onde a maioria dos protótipos erra, e erra sempre para o mesmo lado: devagar demais. Uma animação que encanta na primeira vez é um atraso na décima.

| Tipo de movimento | Duração |
|---|---|
| Mudança de estado (hover, pressionado) | 50–100 ms |
| Transição pequena (item, ícone, tooltip) | 150–200 ms |
| Transição de tela | 200–300 ms |
| Painel grande entrando | 300–400 ms |
| Qualquer coisa acima disso | Provavelmente errado |

Sobre as curvas de aceleração: `Ease out` (rápido no início, desacelerando) é a escolha certa para quase tudo que **entra** ou responde a uma ação, porque o movimento começa imediatamente e o atraso não é percebido. `Ease in` serve para o que **sai**. `Linear` parece mecânico e deve ficar restrito a barras de progresso e giros contínuos.

Há um caso especial: elementos que se repetem muito — o hover de linhas de uma tabela, por exemplo — devem ser praticamente instantâneos. Cem milissegundos multiplicados por trezentas linhas percorridas com o mouse é uma interface que parece pesada, e ninguém consegue dizer por quê.

### O erro que você vai cometer: animar tudo porque a ferramenta deixa

Depois de descobrir o `Smart Animate`, é natural aplicá-lo em todo lugar. O protótipo fica impressionante na apresentação — e, no teste, os participantes ficam esperando as transições terminarem para poder agir.

Há um sintoma objetivo: se, ao percorrer o fluxo pela quinta vez, **você mesmo** começa a se incomodar, está lento demais. Você é a pessoa mais tolerante ao protótipo que existe, porque o construiu; se incomoda você, incomoda muito mais quem chega sem contexto.

E há um custo escondido: transições exageradas no protótipo criam expectativa na equipe de desenvolvimento. Uma animação de 600 ms com quatro elementos coreografados custa horas para implementar bem e não sobrevive ao primeiro dispositivo antigo. Se você não está disposto a defender aquele custo, não coloque no protótipo.

A régua prática: anime o que **explica uma relação** — de onde este painel veio, para onde este item foi, que este elemento se transformou naquele. Não anime o que apenas decora.

### Exercício prático

**Objetivo:** adicionar feedback a um fluxo já existente e medir o efeito.

Pegue um protótipo seu, já navegável, e faça duas versões:

**Versão A (atual):** transições instantâneas, sem estados de hover, sem carregamento.

**Versão B:** adicione, e apenas isto:
1. Estado pressionado em todos os botões (variante, `On press`).
2. Hover em botões e itens de lista, com 80 ms.
3. Um estado de carregamento no botão principal: ao clicar, o rótulo vira um indicador; após 800 ms (`After delay`), navega para a tela seguinte.
4. Transição de 250 ms com `Smart animate` entre telas que compartilham elementos.
5. Uma confirmação de sucesso que aparece, permanece 2 segundos e some sozinha.

Peça a três pessoas que percorram a versão A e a três outras que percorram a B, com a mesma tarefa. Pergunte, ao final: "quanto tempo você acha que levou?" e "o sistema pareceu rápido ou lento?".

### Solução comentada

O resultado desse exercício costuma parecer contraintuitivo: a versão B **leva mais tempo real** — você adicionou 800 ms de espera artificial e várias transições — e é frequentemente percebida como **mais rápida**.

A explicação está na diferença entre tempo objetivo e tempo percebido. Na versão A, o clique não produz nada até a tela trocar; esse intervalo é vivido como incerteza, e incerteza dilata a percepção de duração. Na versão B, o botão responde em 50 ms, o indicador de carregamento confirma que algo está acontecendo, e a transição explica o que mudou. O tempo continua passando, mas deixa de ser tempo vazio.

Esse é um resultado bem estabelecido na literatura de percepção de espera, e tem uma consequência prática importante para quem programa: **quando não dá para deixar mais rápido, dá para deixar mais informado**. Um relatório que leva doze segundos e mostra progresso com etapas nomeadas ("consultando pedidos… calculando totais… gerando arquivo") é tolerado muito melhor que um que leva oito segundos em silêncio.

Uma ressalva honesta sobre o item 3 do exercício: o atraso de 800 ms é uma simulação, e simular lentidão no protótipo é uma faca de dois gumes. Se você prototipar cada ação com meio segundo de espera, o teste vai medir a paciência das pessoas com o seu protótipo, não a usabilidade do desenho. Use o atraso simulado apenas onde o sistema real terá espera de fato — chamadas de rede, processamentos — e deixe instantâneo tudo o que será instantâneo.

---
