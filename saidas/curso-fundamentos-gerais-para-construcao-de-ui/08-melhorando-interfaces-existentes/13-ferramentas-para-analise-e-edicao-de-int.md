## Ferramentas para análise e edição de interfaces existentes

Melhorar uma interface que já existe tem uma vantagem que projetar do zero não tem: o objeto de estudo está rodando, e você pode medi-lo. Boa parte do trabalho de diagnóstico deste capítulo — contar tons de cinza, verificar contraste, encontrar onde as pessoas travam, testar uma alteração antes de propô-la — se faz com ferramentas que você já tem instaladas ou que custam nada.

Esta é uma caixa de ferramentas prática, organizada pelo que cada uma responde.

### Inspeção: o que a tela realmente é

**DevTools do navegador.** Para sistemas web, é a ferramenta mais poderosa da lista e a mais subutilizada por quem vem de outra área. O que ela resolve aqui:

- **Aba Elements + Computed**: os valores reais de fonte, cor, espaçamento e contraste de qualquer elemento. É como você conta os onze tons de cinza sem adivinhar.
- **Editar CSS ao vivo**: altere peso, tamanho e espaçamento diretamente na página em produção e veja o efeito imediatamente. É a forma mais rápida de testar uma hipótese visual — leva segundos e não exige branch, build nem deploy.
- **Emulação de dispositivo**: larguras diferentes, densidade de pixel, e simulação de conexão lenta.
- **Emulação de deficiência visual**: no painel Rendering, é possível simular protanopia, deuteranopia, tritanopia e visão embaçada. O "embaçado" faz, com um clique, o mesmo teste do desfoque que você usaria para diagnosticar hierarquia.
- **Aba Lighthouse**: relatório automático com uma seção de acessibilidade que encontra contraste insuficiente, rótulos ausentes e ordem de cabeçalhos quebrada.

Para uma proposta de ajuste visual, o fluxo mais eficiente é: edite o CSS ao vivo na tela real, tire uma captura, desfaça. Você acabou de produzir um "antes e depois" sobre dados reais em cinco minutos, sem prototipar nada.

**Extensões de acessibilidade.** `axe DevTools` e `WAVE` são as duas mais usadas, ambas gratuitas na versão básica. Rodam na página e listam violações com a referência à norma. Encontram contraste, rótulos de formulário ausentes, texto alternativo faltando e problemas de estrutura — a maior parte do que uma auditoria manual levaria horas para achar.

**Verificadores de contraste.** O `WebAIM Contrast Checker` (web) e o `Colour Contrast Analyser` (aplicativo desktop, funciona sobre qualquer coisa na tela, inclusive aplicações nativas) resolvem a verificação pontual. O segundo é a saída para quem trabalha com desktop GUI, onde as extensões de navegador não alcançam.

**Ferramentas de captura com medição.** Para sistemas desktop, qualquer captura de tela mais um editor com régua resolve. `ShareX` (Windows) e `Flameshot` (Linux) fazem captura com anotação embutida, que é o suficiente para documentar um problema com a medida marcada em cima.

### Medição: onde as pessoas travam

**Analytics de produto.** Se o sistema tiver instrumentação — Google Analytics, Matomo, PostHog, Plausible —, os relatórios de funil e de fluxo de navegação respondem às perguntas de abandono e de idas e voltas. Vale insistir com a equipe para instrumentar, mesmo que minimamente: sem isso, todo diagnóstico depende de observação, que é cara.

**Mapas de calor e gravação de sessão.** Ferramentas como Hotjar, Clarity (gratuito) e PostHog gravam sessões anonimizadas e produzem mapas de clique. Dois achados que elas entregam e nenhuma outra fonte entrega: cliques em elementos **não clicáveis** — que revelam expectativa frustrada — e o "clique de raiva", a repetição rápida no mesmo ponto, que indica falta de feedback.

Um cuidado necessário: gravação de sessão envolve dados de pessoas. Verifique a política da empresa, mascare campos sensíveis e não use em telas com dados pessoais sem tratamento adequado.

**Chamados de suporte.** A fonte mais barata e mais ignorada. Não precisa de ferramenta nova — precisa de exportar a lista dos últimos três meses e agrupar por assunto em uma planilha.

### Teste: validar antes de implementar

**Optimal Workshop, Maze, UserTesting.** Fazem card sorting, tree testing e teste de primeiro clique remotamente. Todas têm planos gratuitos limitados que dão para uma rodada de tree testing com quinze participantes.

**Papel.** Card sorting em cartões físicos e tree testing com a estrutura impressa funcionam perfeitamente e custam uma folha. Para equipes pequenas e usuários presenciais, é mais rápido que configurar uma ferramenta.

**Gravador de tela.** OBS Studio, ou o gravador nativo do sistema. Trinta segundos de um usuário travando é a peça de evidência mais persuasiva que existe em uma reunião.

### Edição: propor a mudança

**Figma / Lunacy.** Já cobertos no capítulo anterior. Para melhorias, o uso mais eficiente é diferente do de um projeto novo: em vez de reconstruir a tela do zero, **cole a captura de tela real** como fundo e desenhe a alteração por cima. Leva minutos, mantém o contexto e produz um antes-e-depois honesto.

**O próprio navegador.** Para alterações puramente de estilo, editar o CSS ao vivo e capturar é mais rápido e mais fiel que qualquer protótipo — porque usa os dados reais, o volume real e a fonte real do sistema.

### O erro que você vai cometer: montar o ferramental antes de ter a pergunta

O impulso, ao começar um trabalho de melhoria, é organizar o instrumental: instalar as extensões, configurar o analytics, criar conta nas plataformas de teste, montar um arquivo de design com a biblioteca de componentes. Uma semana depois, o ferramental está impecável e nenhum problema foi diagnosticado.

O sintoma é reconhecível: você está lendo a documentação de uma ferramenta antes de ter formulado a pergunta que ela responderia.

A ordem inversa funciona melhor. Formule a pergunta, escolha a ferramenta mais simples que a responde, e só troque de ferramenta quando a simples não der conta:

| Pergunta | Comece por |
|---|---|
| Este texto tem contraste suficiente? | Verificador de contraste — 30 segundos |
| Quantos estilos diferentes esta tela usa? | DevTools, aba Computed |
| As pessoas encontram esta função? | Perguntar a três pessoas |
| Onde elas abandonam o fluxo? | Chamados de suporte, se não houver analytics |
| Esta mudança visual melhora? | Editar CSS ao vivo e comparar |
| Esta estrutura de menu é compreensível? | Tree testing em papel com oito pessoas |

Todas as linhas dessa tabela custam menos de uma hora, e nenhuma exige ferramenta paga. As ferramentas sofisticadas entram quando o problema já está delimitado e a resposta simples não bastou.

### Exercício prático

**Objetivo:** produzir um diagnóstico completo de uma tela usando apenas ferramentas gratuitas, em duas horas.

1. Escolha uma tela de um sistema web real.
2. Com o DevTools, inventarie: quantos tamanhos de fonte, tons de texto e valores de espaçamento a tela usa.
3. Rode uma extensão de acessibilidade e registre as violações encontradas, separando as de contraste das demais.
4. Use a emulação de visão embaçada para o teste do desfoque, e anote o que sobrevive.
5. Use a emulação de deuteranopia e verifique se alguma informação depende só de cor.
6. Edite o CSS ao vivo aplicando três correções de hierarquia, e capture antes e depois.
7. Monte um documento de uma página com os cinco achados e as duas capturas.

### Solução comentada

O passo 5 é o que produz o achado mais frequentemente ignorado, e vale detalhar por quê.

A emulação de deuteranopia — a deficiência de visão de cores mais comum, que afeta cerca de 8% dos homens — costuma revelar que uma informação inteira depende de um único canal. Os casos clássicos: status indicados apenas por um ponto verde ou vermelho; linhas de tabela destacadas apenas por cor de fundo; campos com erro marcados apenas por borda vermelha; gráficos com séries distinguidas só pela legenda de cor.

O que torna esse achado especialmente útil em uma proposta é que ele é indiscutível. Diferente de uma questão de hierarquia visual, sobre a qual duas pessoas podem discordar de boa-fé, "com deuteranopia, o status aprovado e o rejeitado são visualmente idênticos" é uma demonstração — e a captura da tela simulada encerra a discussão. É também, com frequência, a correção mais barata da lista: adicionar um ícone ou um texto ao lado da cor resolve, sem mudar nada mais.

O passo 6, editar o CSS ao vivo, tem uma vantagem sobre prototipar que costuma passar despercebida na primeira vez: as capturas de antes e depois mostram **os dados reais** do sistema, com os nomes longos, os valores estranhos e o volume verdadeiro. Um protótipo com dados escolhidos por você sempre carrega a suspeita de ter sido feito para funcionar. A tela real, alterada apenas no estilo, não carrega essa suspeita — e é por isso que ela convence mais, apesar de custar menos trabalho.

---
