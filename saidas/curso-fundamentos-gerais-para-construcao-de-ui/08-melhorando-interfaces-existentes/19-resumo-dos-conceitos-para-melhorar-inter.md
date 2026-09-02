## Resumo dos conceitos para melhorar interfaces existentes

Este capítulo tratou do trabalho que ocupa a maior parte da vida profissional de quem atua com interface: não criar do zero, mas melhorar o que já existe, tem usuários, funciona e não pode parar.

O ponto de partida foi a avaliação heurística — um método de inspeção que confronta a interface com princípios estabelecidos e produz uma lista de problemas em horas, sem depender de acesso a usuários. As dez heurísticas de Nielsen deram o vocabulário; o procedimento deu o rigor: cenários definidos, duas passagens, registro em quatro campos, severidade classificada de 0 a 4 combinando frequência, impacto e persistência. E o limite ficou claro: inspeção encontra problemas potenciais; teste encontra problemas reais.

A identificação de pontos de atrito complementou a inspeção com evidência de comportamento. Quatro fontes — dados de uso, chamados de suporte, observação direta e as adaptações improvisadas dos usuários — enxergam coisas diferentes, e usar apenas uma produz uma lista enviesada. Dados mostram onde as pessoas param; observação mostra onde elas sofrem. A distinção mais útil do trecho foi entre carga intrínseca e carga estranha: interface só remove a segunda, e o teste que as separa é observar onde o tempo é gasto — pensando ou operando.

A aplicação dos princípios cognitivos transformou diagnóstico em correção com explicação de mecanismo. O catálogo ligou sintoma a princípio e a correção típica, e a advertência foi tão importante quanto o catálogo: princípios descrevem mecanismos, não prescrevem soluções. Aplicar a lei de Hick sem verificar se a causa era quantidade — e não semelhança de rótulos — produz correções que pioram.

A revisão da arquitetura existente trouxe as quatro medições que precedem qualquer proposta — inventário, frequência, tree testing e origem do tráfego — e a escala de intervenção em quatro níveis: renomear, reordenar, reagrupar, reestruturar. A recomendação foi contraintuitiva e sustentada por resultado: aplicar os dois primeiros níveis e medir de novo antes de subir, porque a maior parte dos erros de localização em sistemas maduros vem de nomes, não de estrutura.

Os ajustes visuais mostraram a categoria de melhoria com melhor relação entre impacto e risco: nenhuma linha de lógica muda, nenhum elemento sai do lugar. O teste do desfoque diagnostica; as seis correções — baixar o contraste da moldura, escala tipográfica com degraus grandes, poucos cinzas, escala de espaçamento, espaço no lugar de bordas, e peso na coluna de identidade — resolvem a maior parte. Com a ressalva de densidade: em sistemas de uso contínuo, espaçamento generoso é custo, não qualidade.

A simplificação de fluxos aplicou três perguntas a cada passo — é necessário? precisa ser da pessoa? precisa ser agora? — e desmontou a regra dos três cliques. Contagem de cliques não é métrica: as pessoas percorrem sete passos claros e desistem no terceiro ambíguo. Tempo até a conclusão e taxa de conclusão sem ajuda medem o que importa. E atrito deliberado permanece onde o custo do erro supera o custo do passo.

Padrões e consistência trataram do custo somado das divergências acumuladas por equipes diferentes ao longo de anos. O inventário transforma "está inconsistente" em lista de tarefas; os critérios de escolha são frequência, convenção externa e acessibilidade — nunca gosto. E a advertência: consistência é para o que é igual, diferença é para o que é diferente. Apagar uma divergência que carregava significado é perda, não ganho.

Os testes rápidos deram cinco formatos, dos dez minutos às semanas, com destaque para a comparação moderada entre a versão atual e a proposta — e para a armadilha da ordem, que faz o efeito de aprendizado se disfarçar de melhoria quando os participantes não são alternados. Preferência declarada apareceu como o dado menos confiável, útil para adoção e não para usabilidade.

A documentação estabeleceu a unidade que sobrevive à priorização: uma proposta por problema, em nove campos, independente das demais — o oposto do projeto de redesenho, que é aprovado ou recusado em bloco e por isso é adiado. A comunicação traduziu cada termo técnico para consequência observável, ordenou a apresentação em problema-evidência-impacto-proposta, e preparou resposta para as três objeções que sempre chegam.

As ferramentas mostraram quanto se resolve sem custo: DevTools para inventariar estilos e editar CSS ao vivo sobre dados reais, emulação de visão embaçada e de deuteranopia para diagnóstico em um clique, extensões de acessibilidade, gravação de sessão, e papel para card sorting e tree testing. Com a ordem certa: a pergunta primeiro, a ferramenta mais simples depois.

Os cuidados com sistemas legados nomearam quem paga a conta de qualquer mudança — o usuário fluente — e as práticas que tornam a alteração reversível: uma mudança por dimensão, compatibilidade com links e documentação existentes, chave de ativação, grupo piloto, linha de base medida antes e critério de reversão definido antes. E a regra da cerca: descubra por que aquilo existe antes de remover.

A integração ao ciclo de desenvolvimento resolveu o obstáculo final — entrar na fila — com quatro caminhos usados simultaneamente: manutenção sem priorização, carona no trabalho já planejado, percentual fixo de capacidade e item de roadmap com número. Mais os pontos de integração que impedem a dívida nova: critérios na definição de pronto, revisão visual, presença no refinamento e componentes compartilhados.

Os exemplos práticos e a lista de erros comuns convergiram no critério que atravessa o capítulo: o desconforto ao olhar uma tela é um bom detector e um péssimo diagnosticador. Quase todo erro deste capítulo começa quando a sensação de que algo está ruim é tomada como conhecimento sobre a causa.

O que você leva daqui é a capacidade de pegar um sistema em produção, diagnosticar com mais de uma fonte, propor a intervenção proporcional, validar quando há troca envolvida, comunicar em linguagem de quem decide e medir o resultado. O próximo capítulo trata do que sustenta tudo isso na prática: a comunicação e a colaboração com as pessoas que precisam concordar, implementar e conviver com essas mudanças.

---
