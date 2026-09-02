## Testes rápidos para validar melhorias

Você propôs quinze correções. Algumas são óbvias — contraste insuficiente, campo obrigatório inútil — e não precisam de validação. Outras envolvem trocas: mais densidade contra mais clareza, menos passos contra mais certeza, um rótulo novo contra o que as pessoas já aprenderam. Essas precisam ser verificadas antes de virarem produção, e o teste precisa caber no tempo que você tem, que é pouco.

A boa notícia é que melhorar uma interface existente permite formas de validação que um produto novo não permite: existe uma versão atual funcionando, com usuários reais e dados de uso. Isso viabiliza comparação direta, que é o tipo de evidência mais persuasivo.

### Cinco formatos, do mais barato ao mais caro

**1. Teste dos cinco segundos (10 minutos, 3 pessoas).** Mostre a tela por cinco segundos, esconda, e pergunte: o que é isto? o que dá para fazer aqui? o que mais chamou atenção? Valida hierarquia visual e clareza. É o teste certo para verificar ajustes de peso, tamanho e contraste.

**2. Teste do primeiro clique (15 minutos, 5 pessoas).** Uma tela estática, uma tarefa, uma pergunta: onde você clicaria primeiro? Valida rótulos, posição e descoberta. Existe correlação forte entre acertar o primeiro clique e concluir a tarefa, o que faz deste um teste de ótimo custo-benefício.

**3. Comparação A/B moderada (30 minutos, 5 pessoas).** Mesma tarefa nas duas versões, alternando a ordem entre participantes. Mede tempo, conclusão e hesitações. É o formato que produz o argumento mais forte para uma proposta interna.

**4. Tree testing (1 tarde, 15 pessoas, remoto).** Apenas a estrutura de menus, sem interface. Valida mudanças de arquitetura antes de qualquer implementação.

**5. Teste A/B em produção (semanas, milhares de usuários).** O padrão-ouro para efeito real, e o mais caro: exige implementar as duas versões, instrumentação e volume suficiente. Reserve para mudanças de alto impacto e alto risco.

Os quatro primeiros cabem em um dia. Comece por eles.

### A comparação com a versão atual

O formato 3 merece detalhamento, porque é o mais usado nesse contexto e o mais fácil de fazer mal.

**O protocolo:**

1. Prepare as duas versões navegáveis — a atual e a proposta. A atual pode ser o sistema real; a proposta, um protótipo.
2. Escreva **uma** tarefa, como situação, sem palavras da interface.
3. Recrute cinco a seis participantes que correspondam ao perfil do usuário.
4. Alterne a ordem: metade começa pela versão atual, metade pela proposta.
5. Cronometre do momento em que a tela aparece até a conclusão.
6. Anote hesitações maiores que três segundos e onde cada pessoa clicou primeiro.
7. Ao final das duas, pergunte qual preferiu e **por quê** — a justificativa vale mais que a preferência.

**A armadilha da ordem** é o ponto crítico. Quem faz a tarefa duas vezes é mais rápido na segunda, independentemente da versão, porque já entendeu o problema. Sem alternar a ordem, você mede aprendizado e chama de melhoria.

Com seis participantes alternados, o efeito não desaparece, mas deixa de produzir sozinho a conclusão. Se a versão proposta vence em ambos os subgrupos — entre os que a viram primeiro e entre os que a viram depois —, o resultado é confiável.

### O que medir, e o que os números significam

| Métrica | Como obter | O que indica |
|---|---|---|
| Taxa de conclusão sem ajuda | Contagem | O mais importante; abaixo disso, nada mais importa |
| Tempo até a conclusão | Cronômetro | Eficiência; comparável só entre versões da mesma tarefa |
| Acerto do primeiro clique | Observação | Clareza de rótulo e posição |
| Número de hesitações | Contagem de pausas > 3 s | Onde a interface não responde à dúvida |
| Erros e retornos | Contagem | Caminhos ambíguos |
| Preferência declarada | Pergunta final | O menos confiável; use como contexto, não como decisão |

A última linha merece cuidado. Preferência declarada contradiz o desempenho observado com frequência incômoda: as mesmas pessoas que dizem preferir a versão com mais opções costumam ser mais rápidas e errar menos na versão com menos. Quando os dois divergem, o comportamento é o dado; a preferência é uma informação sobre percepção, que importa para adoção mas não para usabilidade.

### O erro que você vai cometer: testar com quem já viu a proposta

Faltam participantes, o prazo aperta, e você recruta duas pessoas da equipe que acompanharam o trabalho. Elas concluem a tarefa rapidamente na versão nova e confirmam a melhoria.

O dado não vale nada, por dois motivos somados. Elas conhecem a proposta, então não estão descobrindo a interface — estão executando algo que já entenderam. E têm interesse no resultado, ainda que inconscientemente: ninguém quer ser quem derruba o trabalho do colega.

O mesmo vale, em grau menor, para qualquer pessoa da mesma equipe. E vale especialmente para você: autotestar um desenho que você fez mede a sua familiaridade com ele.

O contorno, quando realmente não há usuários disponíveis: recrute pessoas de outras áreas da empresa, que não conhecem o sistema nem o projeto. Não substitui o usuário real — falta o conhecimento de domínio, e algumas dificuldades que elas terão não afetariam quem trabalha ali. Mas encontra os problemas de descoberta, rótulo e clareza, que são a maioria. Declare a limitação ao apresentar: "testado com cinco pessoas de outras áreas, não com operadores" é honesto e ainda assim útil.

### Quando não vale testar

Três casos em que a validação custa mais do que rende:

- **A correção não tem trade-off.** Aumentar contraste insuficiente, corrigir um rótulo que estava errado, adicionar estado de foco. Não há hipótese a refutar; implemente.
- **O custo de implementar é menor que o de testar.** Se a mudança é de uma linha e reversível, implemente atrás de uma flag e observe o uso real — dado de produção supera dado de laboratório.
- **A mudança é obrigatória.** Correções de acessibilidade que atendem a norma não estão em discussão.

### Exercício prático

**Objetivo:** validar uma melhoria proposta com comparação controlada.

1. Escolha uma das suas propostas que envolva uma troca real — densidade, número de passos, mudança de rótulo estabelecido.
2. Prepare as duas versões navegáveis.
3. Escreva a tarefa como situação, sem palavras da interface.
4. Recrute seis pessoas que não participaram do projeto, alternando a ordem das versões.
5. Meça: conclusão sem ajuda, tempo, primeiro clique, hesitações. Pergunte preferência e o porquê ao final.
6. Analise por subgrupo: o resultado se mantém entre os que viram cada versão primeiro?
7. Escreva a conclusão em três frases, incluindo o que o teste **não** permite afirmar.

### Solução comentada

O passo 6 é o que separa uma medição de uma confirmação de expectativa, e o resultado às vezes é desconfortável: a versão proposta vence entre quem a viu depois e empata — ou perde — entre quem a viu primeiro. Isso é o efeito de aprendizado aparecendo com clareza, e significa que boa parte do ganho aparente não vem do desenho.

Quando isso acontece, a conclusão honesta não é "a proposta não funciona". É "o teste, com seis pessoas, não conseguiu distinguir o efeito do desenho do efeito de aprendizado". A resposta é aumentar a amostra, ou usar um desenho entre participantes — cada pessoa vê apenas uma versão, o que elimina o aprendizado ao custo de precisar de mais gente.

O passo 7, dizer o que o teste não permite afirmar, é o hábito que mais constrói credibilidade profissional a longo prazo. Um teste com seis pessoas em protótipo não permite afirmar que "a nova versão vai aumentar a conversão em 12%". Permite afirmar que "seis de seis concluíram sem ajuda na nova versão, contra três de seis na atual, e o tempo médio caiu de 47 para 29 segundos". A segunda frase é menor e é verdadeira — e quando ela se confirma em produção, a próxima proposta sua é ouvida com mais atenção.

Um detalhe do passo 5 que costuma render mais que o cronômetro: a pergunta "por quê" depois da preferência. As justificativas frequentemente apontam algo que nenhuma métrica capturou — "essa aqui parece mais confiável", "na outra eu não sabia se tinha salvado". A segunda frase, em particular, é um achado de feedback ausente que o tempo de conclusão não revelaria, porque a pessoa concluiu a tarefa: ela só não teve certeza de que havia concluído.

---
