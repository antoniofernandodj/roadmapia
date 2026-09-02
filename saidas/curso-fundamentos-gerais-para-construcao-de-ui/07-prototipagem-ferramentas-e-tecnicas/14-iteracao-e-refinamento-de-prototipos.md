## Iteração e refinamento de protótipos

Você testou com cinco pessoas. Três não encontraram o botão de filtro, duas se perderam depois da confirmação, e uma perguntou o que significava "conciliar". Agora vem a parte que decide se o teste valeu alguma coisa: transformar essas observações em mudanças, na ordem certa, sem refazer tudo e sem quebrar o que já funcionava.

Iterar não é "melhorar o protótipo". É um ciclo com etapas definidas — observar, diagnosticar, priorizar, alterar, retestar — e a etapa que quase todo mundo pula é a segunda.

### Do sintoma ao diagnóstico

Uma observação de teste é um sintoma. Agir diretamente sobre ela produz correções que não corrigem.

| Observação | Diagnóstico apressado | Diagnósticos possíveis |
|---|---|---|
| "Não achei o filtro" | Deixar o botão maior | Rótulo errado; posição fora da varredura; a pessoa não sabia que filtrar era possível; a tarefa não exigia filtrar |
| "Cliquei em Voltar e perdi tudo" | Adicionar confirmação | Falta de salvamento automático; o botão parece "cancelar"; a etapa é longa demais |
| "Não entendi 'conciliar'" | Trocar por outra palavra | Termo interno da empresa; falta de contexto na tela; o conceito em si não foi explicado em lugar nenhum |

O método para sair do sintoma é olhar **o que a pessoa fez antes** de travar. Se ela varreu a tela inteira com o olho e voltou ao topo, é problema de posição. Se ela leu o rótulo e seguiu adiante, é problema de rótulo. Se ela nem procurou, é problema de expectativa — ela não sabia que aquilo existia.

Essa distinção só é possível se você anotou comportamento durante a sessão, e não apenas conclusões. É a razão pela qual o registro de "onde clicou primeiro" e "onde hesitou" vale mais que qualquer opinião coletada no fim.

### Priorizando o que mudar

Nem toda descoberta merece uma alteração, e alterar tudo de uma vez impede saber o que funcionou. Duas dimensões bastam para ordenar:

**Severidade** — o problema impediu a conclusão da tarefa, atrasou, ou apenas incomodou?
**Frequência** — quantos participantes o enfrentaram?

O que fazer com cada quadrante:

- **Grave e frequente**: corrija antes de qualquer outra coisa. É o que invalida o fluxo.
- **Grave e raro**: investigue. Pode ser um caso específico daquele participante, ou pode ser um problema que só aparece em um perfil de usuário que você não testou o suficiente.
- **Leve e frequente**: corrija, é barato e melhora a percepção geral.
- **Leve e raro**: anote e ignore. Voltará se importar.

Uma disciplina que ajuda: limite cada rodada a **três a cinco mudanças**. Mais que isso e a rodada seguinte não consegue atribuir causa — se você mudou doze coisas e o resultado melhorou, não sabe qual das doze fez efeito, e possivelmente uma delas piorou algo sem que você perceba.

### Iterar sem destruir

Cada rodada precisa preservar o estado anterior, por duas razões: comparar, e voltar atrás quando a mudança piora.

O procedimento, no arquivo:

1. **Salve uma versão nomeada** antes de qualquer alteração: `v3 — antes da rodada 2 de testes`.
2. **Duplique a página** de apresentação, renomeando para `Fluxo v4`. A anterior fica intacta.
3. **Anote as mudanças** em uma caixa no canto da nova página: o que mudou, por que, e qual observação do teste motivou.
4. Só então altere.

O passo 3 é o que constrói, sem esforço extra, o registro que o portfólio vai pedir depois: uma sequência de versões com a justificativa de cada mudança e o dado que a sustentou. Reconstruir isso meses depois é praticamente impossível; anotar no momento custa dois minutos.

### Quando parar

Iteração sem critério de parada vira refinamento infinito, e há sempre mais um detalhe a ajustar. Três critérios objetivos, e basta um:

**Convergência.** Duas rodadas seguidas com participantes diferentes não revelam nenhum problema novo de severidade alta. As observações passam a ser preferências pessoais e divergem entre si.

**Custo.** A próxima mudança exige informação que só o produto real dará — desempenho com dados de verdade, comportamento em conexão lenta, uso continuado ao longo de semanas. Nesse ponto, o protótipo esgotou o que sabe responder.

**Decisão.** O protótipo já respondeu à pergunta que motivou sua existência. Se ele foi feito para decidir entre duas estruturas de navegação, e a decisão está tomada, ele acabou — mesmo que haja telas por polir.

O terceiro é o mais esquecido e o mais importante. Protótipos não são produtos; eles têm uma pergunta e uma vida útil.

### O erro que você vai cometer: iterar sobre a opinião de quem está mais perto

Depois do teste, você apresenta as descobertas à equipe. Alguém sênior discorda de uma delas: "acho que aquela pessoa era um caso isolado, todo mundo entende esse termo". A discussão vira opinião contra opinião, e a versão de quem tem mais autoridade prevalece.

O que se perdeu: o dado. Três participantes não entenderam o termo; nenhuma quantidade de convicção interna altera esse fato.

A defesa não é discutir mais forte — é ter registrado o comportamento em vez da conclusão. "Três de cinco pararam por mais de dez segundos ao chegar nesta tela, e dois perguntaram o que significava esta palavra" é muito mais difícil de contestar do que "as pessoas não entenderam o termo". Se houver gravação, um trecho de trinta segundos mostrando a hesitação encerra o debate mais rápido que qualquer argumento — ver um usuário real travando tem um efeito sobre a equipe que nenhum relatório reproduz.

E há o caso legítimo em que a objeção procede: se a amostra foi enviesada — cinco pessoas de um perfil que não é o do usuário principal —, a crítica é válida e a resposta correta é testar com o perfil certo, não descartar o achado.

### Exercício prático

**Objetivo:** conduzir uma rodada completa de iteração, com evidência.

1. Use os resultados do seu último teste. Liste todas as observações.
2. Para cada uma, escreva o diagnóstico — a causa provável — e o comportamento observado que sustenta esse diagnóstico.
3. Classifique cada problema em severidade (impediu / atrasou / incomodou) e frequência (quantos participantes).
4. Escolha no máximo quatro mudanças, sendo pelo menos duas do quadrante grave-e-frequente.
5. Salve versão, duplique a página, anote as mudanças com sua justificativa, e altere.
6. Reteste com três novos participantes, com a **mesma** tarefa.
7. Compare: os problemas corrigidos sumiram? Apareceu algum novo?

### Solução comentada

O passo 7 produz, com frequência desconcertante, um resultado misto: dois problemas resolvidos, um persistente, e um novo que não existia antes.

**O problema persistente** normalmente indica diagnóstico errado, não correção insuficiente. Se você aumentou o botão de filtro e as pessoas continuam não o encontrando, o problema nunca foi tamanho — é que elas não sabem que filtrar é possível ali, ou que o rótulo não corresponde ao que procuram. A resposta certa não é aumentar mais; é voltar ao passo 2 com uma hipótese diferente. Um sinal claro disso: se a correção "óbvia" falhou duas vezes, o diagnóstico está errado.

**O problema novo** é o custo real de qualquer mudança e a razão de limitar a quatro por rodada. Um exemplo típico: você moveu os filtros para uma posição mais visível, e agora eles empurraram a lista para baixo, deixando o primeiro resultado fora da área visível inicial — o que criou um problema de descoberta onde não havia. Com quatro mudanças, você identifica a causa em minutos. Com quinze, você tem um protótipo diferente e nenhuma explicação.

Vale um último comentário sobre o passo 6, e a insistência na **mesma tarefa**. É tentador ampliar o teste, já que você tem participantes disponíveis. Mas mudar a tarefa entre rodadas destrói a comparação: você não sabe se a melhora veio do desenho ou do fato de a nova tarefa ser mais fácil. Mantenha a tarefa fixa enquanto estiver medindo o efeito de uma mudança, e reserve as tarefas novas para uma rodada exploratória própria.

---
