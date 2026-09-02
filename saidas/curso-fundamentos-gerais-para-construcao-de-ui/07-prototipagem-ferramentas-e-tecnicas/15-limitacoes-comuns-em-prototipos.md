## Limitações comuns em protótipos

Um protótipo bem feito engana. Ele parece o produto, comporta-se como o produto em quase tudo o que se testa, e por isso as conclusões tiradas dele carregam uma confiança que nem sempre se justifica. Saber onde ele mente é tão importante quanto saber construí-lo — porque as decisões erradas mais caras da carreira de um designer costumam vir de um protótipo que validou algo que ele não tinha como validar.

### O que um protótipo simplesmente não sabe

**Desempenho.** No protótipo, todas as telas aparecem instantaneamente. No produto, a listagem com dois mil registros leva quatro segundos, o gráfico trava ao redimensionar, e o formulário fica lento após o décimo campo. Nenhum teste de protótipo detecta isso, e o problema de desempenho costuma anular ganhos de usabilidade duramente conquistados: uma tela perfeita que demora seis segundos é pior que uma tela mediana instantânea.

**Volume e variedade real de dados.** Você desenhou vinte linhas; o usuário tem quatro mil. Você usou nomes de três palavras; a base tem razões sociais de noventa caracteres, campos preenchidos com "XXXX", datas de 1900 e valores negativos. Um protótipo com dados escolhidos por você testa o layout que você já sabia que funcionava.

**Uso continuado.** Uma sessão de teste dura vinte minutos. O operador usa o sistema oito horas por dia, cinco dias por semana, dois anos. Coisas que são deliciosas na primeira vez — uma animação, um passo extra de confirmação, uma mensagem de boas-vindas — tornam-se insuportáveis na milésima. E coisas que parecem áridas no teste, como densidade alta e atalhos de teclado, são exatamente o que o uso continuado exige.

**Aprendizado.** No teste, todo participante é novato. Isso é útil para avaliar descoberta e primeira impressão, e é enganoso para avaliar eficiência. Uma interface otimizada para o primeiro uso pode ser péssima para o centésimo, e o protótipo dá voz apenas ao primeiro.

**O contexto real.** A pessoa testa sentada, concentrada, sem telefone tocando, sabendo que está sendo observada. No trabalho real, ela é interrompida três vezes no meio do formulário, atende um cliente enquanto preenche, e usa o sistema com a tela suja, num monitor mal calibrado, sob pressão de tempo.

**Integrações e o que vem de fora.** O CEP que não é encontrado, o serviço de pagamento que expira, o arquivo que o cliente envia em um formato inesperado. O protótipo assume que tudo funciona.

### As limitações da simulação em si

Além do que ele não sabe, há o que ele finge:

**Não há estado.** Você já viu isso: o protótipo não guarda o que foi digitado, não soma, não valida. Cada estado é uma tela desenhada. Isso significa que qualquer teste envolvendo entrada de dados real é parcialmente teatro — a pessoa digita e nada acontece com o que digitou.

**Os caminhos são finitos.** No produto, a pessoa pode fazer qualquer coisa em qualquer ordem. No protótipo, ela pode seguir os caminhos que você ligou. Quando ela clica em algo não ligado e nada acontece, a sessão sofre uma interrupção que não existiria no real — e algumas pessoas, a partir daí, param de explorar por medo de "quebrar".

**A fidelidade sugere acabamento.** Um protótipo em alta fidelidade recebe comentários sobre cor e alinhamento; o mesmo fluxo em baixa fidelidade recebe comentários sobre estrutura. O nível de acabamento **determina o tipo de feedback** que você vai receber, o que é uma limitação e também uma ferramenta — se você quer discutir estrutura, mantenha o protótipo feio de propósito.

### O erro que você vai cometer: usar o protótipo como especificação completa

O protótipo ficou bom. A equipe aprovou. Ele é entregue ao desenvolvimento como se fosse a especificação, com a frase que sempre aparece: "está tudo no Figma".

O que não está no Figma: as regras de negócio, os casos de erro, o comportamento assíncrono, as permissões, os limites, a origem dos dados. Você já viu esse problema pelo lado da documentação; do lado das limitações, ele tem uma consequência adicional e mais sutil.

Quando o protótipo é tratado como especificação, ele adquire uma autoridade que não merece — e o desenvolvedor que encontra um caso não previsto tende a **inventar uma solução compatível com o que viu**, em vez de perguntar. O resultado são comportamentos que ninguém projetou, presentes no produto, coerentes com o protótipo e errados.

A correção é declarar explicitamente, na entrega, o que o protótipo cobre e o que não cobre. Uma lista de cinco linhas no início do arquivo:

> **Este protótipo cobre:** o fluxo principal de devolução, telas 1 a 6, nos estados normal e vazio.
> **Não cobre:** cálculo de frete de retorno, regras de prazo, permissões por perfil, comportamento offline, integração com a transportadora.
> **Decisões ainda abertas:** se a devolução parcial é permitida (aguardando definição do jurídico).

Essa lista transforma a pergunta do desenvolvedor de "será que isso está previsto?" em "isto está na lista do que não foi coberto — vou perguntar".

### Quando não vale prototipar

Há situações em que o protótipo custa mais do que rende, e reconhecê-las é maturidade:

- **A mudança é menor que o protótipo.** Trocar o rótulo de um botão ou reordenar dois campos: implemente atrás de uma flag e meça no produto real.
- **O problema é de desempenho ou de dados.** Nenhum protótipo responderá; vá direto a um experimento técnico.
- **A convenção já está estabelecida.** Um formulário de login não precisa ser prototipado. Use o padrão conhecido.
- **Não há quem teste.** Um protótipo que ninguém vai avaliar é um desenho caro. Se o acesso a usuários é impossível, gaste o tempo em outra coisa — uma avaliação heurística, por exemplo.

### Exercício prático

**Objetivo:** identificar, num protótipo real, tudo o que ele não é capaz de validar.

1. Pegue um protótipo seu, já testado.
2. Liste as afirmações que você faria com base nele — por exemplo, "as pessoas encontram o filtro", "o fluxo de checkout é compreensível", "a tabela é legível".
3. Para cada afirmação, marque: o protótipo **sustenta** isso, sustenta **parcialmente**, ou **não sustenta**?
4. Para as parciais e as não sustentadas, escreva o que seria necessário para sustentá-las: dados reais, teste em produção, medição de desempenho, sessão longa com usuário experiente.
5. Escreva a lista "cobre / não cobre / decisões abertas" para a entrega.

### Solução comentada

O passo 3 costuma reclassificar afirmações que pareciam sólidas. Três exemplos frequentes:

**"A tabela é legível."** Parcialmente sustentado. O protótipo mostra que a estrutura da tabela funciona com os dados que você colocou. Não mostra o que acontece com nomes longos (a menos que você os tenha incluído deliberadamente), nem com quatrocentas linhas, nem em um monitor de 1366 pixels se você desenhou em 1920. A parte sustentada é a hierarquia das colunas; a não sustentada é o comportamento sob dados reais.

**"O fluxo é rápido."** Não sustentado, quase nunca. Velocidade percebida em protótipo é artificial — não há espera de rede, não há processamento. O que você pode afirmar é "o fluxo tem poucos passos", que é uma propriedade estrutural, não uma medida de tempo.

**"As pessoas preferem a versão B."** Sustentado apenas para primeira impressão, e apenas para o perfil que você testou. Preferência declarada em teste é notoriamente instável e frequentemente contradiz o comportamento observado — as mesmas pessoas que dizem preferir a versão com mais opções costumam ser mais rápidas e cometer menos erros na versão com menos.

A conclusão do exercício não é que o protótipo vale pouco. É que ele vale muito para um conjunto específico de perguntas — estrutura, sequência, rótulos, descoberta, compreensão — e quase nada para outro — desempenho, escala, uso continuado, contexto real. Um profissional que sabe declarar essa fronteira ganha credibilidade; um que apresenta todas as conclusões com a mesma confiança a perde na primeira vez que uma delas não se confirma em produção.

---
