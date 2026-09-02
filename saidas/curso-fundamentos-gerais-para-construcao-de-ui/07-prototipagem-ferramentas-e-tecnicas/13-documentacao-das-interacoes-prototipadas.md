## Documentação das interações prototipadas

O protótipo mostra o que acontece quando você clica no botão certo, no momento certo, com os dados certos. Tudo o mais — as condições, os limites, as regras, o que acontece quando a rede cai — mora na sua cabeça. E é exatamente esse "tudo o mais" que o desenvolvedor precisa para implementar.

A conta é dura: um protótipo entregue sem documentação gera, em média, uma dúzia de perguntas durante a implementação. Cada pergunta é uma interrupção de dois lados. As que não são feitas viram suposições, e suposições viram retrabalho.

### O que o protótipo não consegue dizer

Antes de escrever qualquer coisa, vale ter clara a lista do que é invisível em um arquivo de design:

- **Condições.** O botão fica desabilitado *quando*? A mensagem aparece *se*?
- **Origem dos dados.** Este número vem de onde? É calculado ou armazenado?
- **Limites.** Quantos caracteres cabem? Quantos itens a lista carrega de uma vez?
- **Validações.** O que é aceito neste campo, e qual a mensagem exata quando não é?
- **Permissões.** Quem vê este botão? O que muda para um usuário sem permissão?
- **Comportamento assíncrono.** O que acontece entre o clique e a resposta? E se falhar?
- **Persistência.** Se a pessoa sair no meio, o que é preservado?
- **Prioridade de estados.** Um campo com erro que também está desabilitado aparece como qual dos dois?

Nenhum desses itens é visível em um frame, e todos precisam de resposta antes da primeira linha de código.

### Onde documentar: ao lado, não em outro lugar

A regra que determina se a documentação será lida: ela precisa estar a menos de um clique do que ela descreve. Um documento em outra ferramenta, por melhor que seja, perde para uma anotação colada ao frame.

Três camadas que funcionam juntas:

**1. Anotações no canvas.** Ao lado de cada frame, uma coluna de texto com as regras específicas daquela tela. Use um componente de anotação padronizado — uma caixa amarela com título e lista — para que fiquem visualmente distintas do produto.

**2. Comentários ancorados.** Para observações pontuais sobre um elemento específico, que se resolvem em uma conversa.

**3. Documento de fluxo.** Um arquivo curto, versionado com o código, cobrindo o que atravessa telas: regras de negócio, estados de erro globais, permissões.

A camada 1 é a que mais rende e a mais negligenciada.

### O formato de anotação que funciona

Anotação em prosa é ignorada. O que se lê durante a implementação é lista curta com estrutura previsível. Um modelo:

```
TELA: Carrinho — finalizar compra

INTERAÇÕES
• "Finalizar" → tela Endereço
  Habilitado apenas se: carrinho tem ≥ 1 item E todos com estoque
  Desabilitado: cinza, com texto ao lado "Remova os itens sem estoque"
• "Remover item" → remove a linha, atualiza total
  Sem confirmação. Mostra "Item removido — Desfazer" por 5 s
• Alterar quantidade → atualiza total após 400 ms de inatividade
  Limite: 1 a 99. Acima de 99 → mantém 99 e mostra dica

DADOS
• Subtotal = soma (preço unitário × quantidade), sem frete
• Frete: calculado só na tela seguinte; aqui mostra "a calcular"

ESTADOS
• Vazio: ilustração + "Seu carrinho está vazio" + botão "Ver produtos"
• Carregando: esqueleto de 3 linhas
• Erro ao carregar: "Não foi possível carregar seu carrinho" + "Tentar novamente"

LIMITES
• Nome do produto: 2 linhas, depois reticências; completo no tooltip
• Máximo de 50 itens distintos no carrinho

PERMISSÕES
• Visitante não autenticado: vê o carrinho, "Finalizar" leva ao login
```

Note o que esse bloco tem e um texto corrido não teria: cada linha é verificável. O desenvolvedor consegue marcar item por item, e o testador consegue transformar cada linha em um caso de teste. Isso não é coincidência — a documentação de interação bem escrita **é** a especificação de teste.

### Documentando o que muda entre plataformas

Se o mesmo fluxo existe em desktop e mobile, documente as **diferenças**, não duplique tudo. Uma tabela resolve:

| Comportamento | Desktop | Mobile |
|---|---|---|
| Filtros | Coluna lateral fixa | Painel de tela cheia |
| Remover item | Botão de lixeira na linha | Deslizar para a esquerda + botão no menu |
| Confirmação | Modal centralizado | Painel inferior |
| Atalhos | `Esc` fecha, `Enter` confirma | Não se aplica |

Duplicar a documentação inteira garante que uma das cópias vai ficar desatualizada, e nunca se sabe qual.

### O erro que você vai cometer: documentar depois

O protótipo fica pronto na quinta-feira. A entrega é na sexta. A documentação fica "para segunda", e na segunda já há outra prioridade. O arquivo é entregue sem anotação nenhuma, com a promessa de "qualquer dúvida me chama".

O que acontece: as dúvidas chegam durante três semanas, uma a uma, sempre no momento em que você está em outra coisa. As respostas ficam espalhadas por conversas de chat que ninguém mais encontra. E quando o mesmo fluxo precisar de ajuste dali a seis meses, todas as regras terão que ser redescobertas — por engenharia reversa do código, que é a forma mais cara possível.

A correção é uma mudança de ordem, não de esforço: **anote enquanto prototipa**. No momento em que você desenha o estado desabilitado do botão, você está pensando na condição que o desabilita — escreva a condição ali, naquele instante. Escrita depois, a mesma frase exige reconstruir o raciocínio inteiro e leva três vezes mais tempo.

Um teste que confirma isso: cronometre a anotação de uma tela feita durante a construção e a de outra feita uma semana depois. A diferença costuma ser de cinco minutos contra vinte.

### Exercício prático

**Objetivo:** documentar um fluxo prototipado de forma que outra pessoa consiga implementá-lo sem perguntar.

1. Escolha três telas de um protótipo seu.
2. Para cada uma, escreva o bloco de anotação no formato acima, com as cinco seções (interações, dados, estados, limites, permissões).
3. Ao lado de cada frame, no canvas, coloque essa anotação como texto visível.
4. Entregue o link para uma pessoa que não participou do projeto — de preferência alguém que programa — e peça que ela liste **todas** as perguntas que faria antes de começar a implementar.
5. Para cada pergunta, decida: era para estar documentado e faltou, ou é genuinamente uma decisão em aberto?

### Solução comentada

O passo 4 é o teste real, e o resultado típico é entre cinco e dez perguntas mesmo depois de uma documentação cuidadosa. Isso não é fracasso — é o valor do exercício aparecendo.

As perguntas se distribuem em três grupos, e cada um pede uma resposta diferente.

**As que você deveria ter documentado.** Normalmente giram em torno de comportamento assíncrono e erro: "o que acontece se a requisição falhar?", "o botão fica travado enquanto salva?", "e se a pessoa clicar duas vezes?". Elas se repetem em praticamente todo fluxo, o que sugere a solução mais econômica: em vez de escrever as mesmas regras em cada tela, escreva **uma vez** um documento de padrões globais — como o sistema trata carregamento, erro de rede, timeout, duplo clique — e referencie. A anotação da tela só menciona o que foge do padrão.

**As que são decisões em aberto de verdade.** "Se o produto ficar sem estoque enquanto está no carrinho, avisamos na hora ou na finalização?" Não é omissão de documentação, é uma regra de negócio que ninguém definiu. O valor de descobrir isso agora, e não na terça-feira da sprint, é exatamente o motivo pelo qual protótipos existem. Anote como pergunta em aberto, com um responsável e um prazo.

**As que revelam que o protótipo está errado.** Às vezes a pergunta é "por que essa tela tem dois botões que fazem a mesma coisa?" — e a resposta honesta é que você não tinha percebido. O olhar de fora encontra incoerências que o autor não vê, e é por isso que o passo 4 não deve ser pulado nem substituído por autoavaliação.

Há um subproduto que vale registrar: a lista de perguntas do passo 5, respondida e organizada, é praticamente o documento de requisitos daquele fluxo — e foi produzida em uma hora, por duas pessoas, a partir de um protótipo, em vez de em uma reunião de especificação de três horas com seis participantes.

---
