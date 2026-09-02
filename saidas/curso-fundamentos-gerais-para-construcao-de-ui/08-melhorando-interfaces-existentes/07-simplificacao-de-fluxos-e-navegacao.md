## Simplificação de fluxos e navegação

Ajustes visuais melhoram o que acontece dentro de uma tela. Revisão de arquitetura melhora onde as coisas ficam. Falta o terceiro eixo: quantos passos a pessoa precisa dar, em que ordem, e quantos deles existem por necessidade real.

Fluxos crescem por acúmulo. Cada nova exigência vira uma tela a mais, cada caso especial vira uma pergunta a mais, cada erro de produção vira uma confirmação a mais. Ninguém decide construir um fluxo de nove passos; ele chega lá em dois anos, um passo por vez, e cada passo foi justificado no momento em que entrou.

### Mapear antes de cortar

O instrumento é o mesmo que você usou em prototipagem, aplicado ao que já existe: escreva o fluxo real, passo a passo, com o que a pessoa faz em cada um.

```
Registrar devolução — fluxo atual

1. Menu → Pedidos                            (1 clique)
2. Buscar pedido por número                  (digitar + 1 clique)
3. Abrir o pedido                            (1 clique)
4. Aba "Itens"                               (1 clique)
5. Selecionar o item                         (1 clique)
6. Botão "Ações" → "Solicitar devolução"     (2 cliques)
7. Escolher o motivo (lista de 14 opções)    (2 cliques)
8. Descrever o motivo (campo obrigatório)    (digitar)
9. Anexar foto (obrigatório)                 (3 cliques + espera)
10. Confirmar dados                          (1 clique)
11. Tela de confirmação                      (leitura)

Total: 13 cliques, 2 campos de texto, 1 anexo
```

Com o mapa na mão, três perguntas por passo:

1. **Este passo é necessário?** Alguém decide algo aqui, ou é só uma tela de passagem?
2. **Precisa ser da pessoa?** O sistema poderia preencher, inferir ou decidir?
3. **Precisa ser agora?** Poderia ser depois, ou só quando necessário?

### As cinco simplificações mais produtivas

**1. Eliminar telas de passagem.** O passo 10, "Confirmar dados", só repete o que foi preenchido nos passos anteriores. Confirmação faz sentido antes de algo irreversível ou caro; uma solicitação de devolução, que pode ser cancelada, não precisa. Elimina-se um passo inteiro.

**2. Inferir em vez de perguntar.** O passo 8 pede descrição em texto livre, obrigatório, depois de a pessoa já ter escolhido o motivo em uma lista. Para a maioria dos motivos ("tamanho errado", "cor diferente"), a descrição não acrescenta nada — e o que se recebe na prática é "tamanho errado" digitado de novo. Torne o campo obrigatório apenas para o motivo "outro".

**3. Adiar o que não bloqueia.** O passo 9 exige foto antes de registrar. Se em 70% dos casos a foto não é analisada, ela pode ser opcional no registro e solicitada depois, apenas quando o motivo exigir. Isso tira do caminho principal um passo lento, que envolve sair do sistema, encontrar o arquivo e esperar o upload.

**4. Reduzir a distância entre o gatilho e a ação.** Os passos 1 a 6 existem para chegar até o item. Se a pessoa quase sempre chega ali vinda de um e-mail de cliente com o número do pedido, um campo de busca global que aceite o número e leve direto ao item elimina quatro passos.

**5. Encurtar listas de escolha com valores prováveis.** Catorze motivos numa lista custam leitura e decisão. Se três deles representam a maioria dos casos, mostre esses três primeiro, com um "ver todos" para os demais.

Aplicadas ao exemplo, essas cinco simplificações levam o fluxo de treze cliques para cinco ou seis — sem remover nenhuma funcionalidade e sem perder nenhuma informação que seja de fato usada.

### Atrito deliberado: quando não simplificar

Nem todo passo a menos é ganho. Há três casos em que o atrito é o objetivo:

**Ações irreversíveis.** Excluir, cancelar, enviar para produção. Aqui a confirmação existe para forçar uma pausa. A alternativa melhor, quando possível, é desfazer em vez de confirmar — mas quando desfazer é impossível, a confirmação fica.

**Decisões com consequência para terceiros.** Aprovar um pagamento, publicar algo visível a clientes. O passo extra é uma barreira contra o deslize.

**Dados que exigem atenção.** Um campo pré-preenchido que a pessoa deveria conferir tende a passar sem conferência. Se o valor errado tem custo alto, às vezes é melhor não pré-preencher.

O critério: atrito se justifica quando o custo do erro é maior que o custo do passo. Multiplique os dois pela frequência antes de decidir.

### O erro que você vai cometer: contar cliques como métrica

A regra dos três cliques — "tudo deve estar a no máximo três cliques" — circula há décadas e não se sustenta em evidência. Estudos sobre o tema não encontram relação confiável entre número de cliques e sucesso ou satisfação. O que importa é se cada clique é **óbvio**: as pessoas percorrem alegremente sete passos claros e desistem no terceiro que exige adivinhação.

Otimizar por contagem de cliques leva a erros previsíveis: enfiar tudo em uma tela única, criar menus com trinta itens visíveis, ou substituir dois cliques claros por um clique ambíguo em um ícone sem rótulo.

A métrica melhor é dupla: **tempo até a conclusão** e **taxa de conclusão sem ajuda**. Ambas medem o que importa e não premiam a compressão artificial.

Uma consequência prática: às vezes a simplificação correta **aumenta** o número de passos. Dividir um formulário de vinte e oito campos em três etapas adiciona dois cliques e reduz o abandono, porque cada etapa fecha um ciclo de memória de trabalho e o progresso fica visível.

### Simplificar sem quebrar o que as pessoas aprenderam

Fluxos alterados punem quem já era fluente. Três cuidados:

**Preserve o caminho antigo por um tempo**, mesmo que ele fique escondido. Alguém que fazia a tarefa de olhos fechados precisa de uma transição.

**Não mude a posição e o comportamento ao mesmo tempo.** Se o botão mudou de lugar e passou a fazer algo levemente diferente, a pessoa vai errar duas vezes. Faça uma coisa por entrega.

**Avise antes.** Para sistemas de uso profissional diário, uma nota de duas linhas na semana anterior evita a maior parte dos chamados.

### Exercício prático

**Objetivo:** simplificar um fluxo real, com medição antes e depois.

1. Escolha uma tarefa frequente de um sistema que você conhece.
2. Mapeie o fluxo atual passo a passo, contando cliques, campos e esperas.
3. Cronometre três pessoas executando a tarefa, e anote onde cada uma hesitou.
4. Para cada passo, responda as três perguntas: é necessário? precisa ser da pessoa? precisa ser agora?
5. Proponha o fluxo simplificado, marcando quais passos foram eliminados, automatizados ou adiados — e quais foram mantidos deliberadamente como atrito.
6. Prototipe o novo fluxo e cronometre com três pessoas diferentes.
7. Compare tempo, taxa de conclusão sem ajuda e número de hesitações.

### Solução comentada

O passo 4 costuma revelar um padrão que se repete em praticamente todo sistema corporativo: **uma parte considerável dos campos obrigatórios não é usada por ninguém**.

A descoberta acontece quando você tenta responder "este dado é necessário?" e vai atrás de quem o consome. Frequentemente a resposta é que ele foi exigido anos atrás por uma área que não existe mais, ou para um relatório que ninguém mais roda, ou "por garantia". Enquanto isso, todas as pessoas que executam a tarefa pagam o custo do preenchimento, todos os dias.

Há um sinal diagnóstico que confirma isso na hora: se o campo é preenchido majoritariamente com o mesmo valor — "0000", "não se aplica", "-" —, ele não está coletando informação, está coletando ruído. Nesse caso a simplificação tem duplo ganho: economiza o tempo de quem preenche e limpa a base de dados falsos.

Sobre o passo 7 e a comparação: o resultado mais comum é uma redução de tempo menor do que a redução de cliques sugeriria. Se você cortou o fluxo de treze para seis cliques, é natural esperar que o tempo caia pela metade — e ele costuma cair bem menos. A razão é que boa parte do tempo original não estava nos cliques, e sim nas decisões: escolher o motivo entre catorze opções, redigir a descrição, decidir se a foto está boa o bastante.

Isso não invalida a simplificação; recalibra a expectativa e aponta onde investir depois. Se o tempo continua concentrado em uma decisão específica, o próximo trabalho não é remover mais passos — é ajudar a decisão, com informação no lugar certo, valores prováveis em destaque ou uma regra que decida no lugar da pessoa quando o caso for claro.

---
