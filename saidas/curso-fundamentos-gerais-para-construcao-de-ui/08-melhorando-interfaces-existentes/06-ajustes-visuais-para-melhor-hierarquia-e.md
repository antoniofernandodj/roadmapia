## Ajustes visuais para melhor hierarquia e legibilidade

Existe uma categoria de melhoria com uma propriedade rara: alto impacto percebido, custo baixo e risco praticamente zero. São os ajustes que não mudam uma linha de lógica, não movem nenhum elemento de lugar e não exigem reaprendizado — apenas alteram peso, tamanho, cor e espaço.

Em sistemas construídos por equipes de desenvolvimento sem participação de design, essa é quase sempre a intervenção de melhor retorno. E ela pode ser feita em um arquivo de estilos, sem tocar em componente nenhum.

### O diagnóstico do desfoque

Antes de ajustar, é preciso ver o problema. A técnica mais rápida: tire uma captura da tela e aplique um desfoque de seis a oito pixels. O que continua distinguível é o que domina a varredura pré-atentiva.

Em telas de sistemas internos, o resultado costuma ser sempre o mesmo: o que sobrevive ao desfoque é a **moldura** — a barra lateral colorida, o cabeçalho escuro, as bordas da tabela — e o **conteúdo** vira uma massa cinza uniforme. A tarefa real do usuário desapareceu.

Isso não acontece por descuido. A moldura foi construída uma vez, com atenção; o conteúdo é gerado dinamicamente com estilos padrão. O resultado é uma interface que destaca o cenário e apaga os atores.

### As seis correções que mais rendem

**1. Baixe o contraste da moldura.** A correção mais eficiente quase nunca é destacar o conteúdo — é apagar o que compete com ele. Uma barra lateral azul-forte reduzida a cinza claro com texto escuro, um cabeçalho de 80 pixels reduzido a 56 e sem cor de fundo. Sem tocar no conteúdo, ele sobe um degrau na hierarquia, porque hierarquia é relativa.

**2. Estabeleça uma escala tipográfica com degraus grandes.** O erro típico é ter cinco tamanhos entre 14 e 18 pixels, o que produz hierarquia invisível. Substitua por uma escala com saltos perceptíveis:

```
texto-xs   12px   rótulos, legendas
texto-sm   14px   apoio, metadados
texto-md   16px   corpo (14px em interfaces densas)
texto-lg   20px   títulos de seção
texto-xl   28px   título da página
```

Cinco degraus bastam para qualquer sistema. Se você tem oito, três são acidentais.

**3. Reduza a paleta de cinzas.** Um sistema maduro costuma ter oito a doze tons de cinza em uso, quase todos acidentais. Quatro resolvem: texto principal, texto secundário, borda, fundo. Cada tom a menos é uma decisão a menos e uma inconsistência a menos.

**4. Adote uma escala de espaçamento.** Múltiplos de 4 ou 8, e nada fora disso. O ganho maior não é a consistência estética — é que a proximidade passa a comunicar agrupamento de forma confiável. Quando os espaços variam entre 11, 13 e 15 pixels, o olho não consegue inferir o que pertence a quê.

**5. Substitua bordas por espaço.** A maioria das linhas divisórias de uma interface existe para compensar espaçamento insuficiente. Remova as bordas de uma tabela e aumente a altura da linha: a leitura melhora e a tela fica visualmente mais leve. Bordas só se justificam quando o espaço disponível é realmente escasso.

**6. Dê identidade à coluna de identidade.** Em qualquer lista ou tabela, existe uma coluna pela qual a pessoa reconhece a linha — nome, número, título. Ela deve ter peso maior (semibold, ou o tom mais escuro de texto); as demais vão para o cinza secundário. É uma alteração de uma linha de CSS que costuma cortar substancialmente o tempo de localização.

### Legibilidade: os números que importam

Alguns valores têm base em pesquisa e evitam discussão:

| Propriedade | Valor recomendado | Consequência de errar |
|---|---|---|
| Contraste texto/fundo | mínimo 4,5:1 (texto normal), 3:1 (texto grande) | Falha de acessibilidade; ilegível sob luz forte |
| Entrelinha do corpo | 1,4 a 1,6 vezes o tamanho da fonte | Olho pula ou repete linhas |
| Comprimento de linha | 45 a 75 caracteres | Perde-se o ponto de retorno à esquerda |
| Alinhamento de texto corrido | à esquerda | Justificado cria rios de espaço irregular |
| Texto em maiúsculas | apenas rótulos curtos | Remove o contorno da palavra, que ajuda no reconhecimento |
| Tamanho mínimo de corpo | 14px (desktop denso), 16px (web) | Ilegível para parte dos usuários |

O primeiro item merece um comentário. Contraste insuficiente é o problema de acessibilidade mais comum em sistemas corporativos, e quase sempre vem do mesmo lugar: texto cinza claro sobre fundo branco, escolhido porque "fica mais elegante". Ferramentas de verificação levam segundos e existem como extensão de navegador — não há razão para não verificar.

### O erro que você vai cometer: melhorar o visual e piorar a densidade

Você aplica tudo: espaçamento generoso, tipografia maior, cards com respiro, cores suaves. A tela fica visivelmente melhor em qualquer captura de tela, e a equipe aprova.

Duas semanas depois, os operadores reclamam. Onde cabiam vinte linhas agora cabem oito, e uma tarefa que era feita sem rolar exige três rolagens. Você melhorou a estética e piorou o trabalho.

O ponto que se perde: densidade é uma troca entre facilidade para o novato e eficiência para o experiente. Em um sistema de uso ocasional, o espaçamento generoso vence. Em um sistema de uso contínuo, oito horas por dia, densidade é produtividade — e o usuário quase sempre pede mais densidade, não menos.

A régua para sistemas de uso intensivo:

```
Corpo de texto        13–14px
Altura de linha de tabela  28–36px
Altura de campo       28–32px
Espaço entre campos   8–12px
Espaço entre grupos   16–24px
```

E a verificação obrigatória: conte quantas linhas cabem na resolução mais apertada do seu parque de máquinas — não na sua. Se antes cabiam vinte e agora cabem doze, a mudança tem um custo que precisa ser justificado.

### Sequenciando as mudanças

Ajustes visuais têm uma vantagem que vale explorar: podem ser aplicados em fatias pequenas, sem risco. Uma ordem que funciona:

1. **Contraste e acessibilidade primeiro.** Corrige um problema real, é indiscutível e não gera debate estético.
2. **Escala de espaçamento.** Muda pouco visualmente, mas prepara o terreno para tudo o mais.
3. **Escala tipográfica e redução de cinzas.** Aqui a diferença começa a aparecer.
4. **Redução do contraste da moldura.** É a que mais muda a percepção geral e a que mais gera reação — deixe para quando as anteriores já tiverem construído confiança.
5. **Hierarquia dentro de listas e formulários.** O ganho de tempo real.

Aplicar tudo de uma vez produz um "antes e depois" impressionante e uma discussão longa. Aplicar em cinco entregas produz o mesmo resultado com metade da resistência.

### Exercício prático

**Objetivo:** aplicar ajustes visuais mensuráveis a uma tela existente.

1. Escolha uma tela densa de um sistema real — uma listagem, de preferência.
2. Faça o teste do desfoque e anote o que sobrevive.
3. Inventarie: quantos tamanhos de fonte, quantos tons de cinza e quantos valores de espaçamento diferentes a tela usa? Conte de verdade, com o inspetor do navegador.
4. Aplique as seis correções, usando apenas CSS, sem mover elementos de lugar.
5. Meça: quantas linhas cabiam antes e quantas cabem depois, na mesma resolução?
6. Peça a três pessoas que encontrem um registro específico nas duas versões, alternando a ordem entre elas, e cronometre.

### Solução comentada

O passo 3 costuma produzir números que ninguém acredita antes de contar: onze tamanhos de fonte, catorze tons de cinza, nove valores de espaçamento — em uma única tela. Não é desleixo; é o acúmulo natural de dezenas de pequenas decisões tomadas por pessoas diferentes ao longo de anos, cada uma razoável isoladamente.

Reduzir esses números para cinco, quatro e seis raramente piora a tela e quase sempre a melhora, e o mecanismo é o que você já conhece: hierarquia depende de degraus perceptíveis, e onze tamanhos entre 12 e 20 pixels não formam degraus, formam ruído.

O passo 6 é o que transforma o exercício em argumento. A medição de tempo costuma mostrar ganhos que parecem desproporcionais à mudança — e é justamente esse o achado que convence uma equipe cética. "Mudei o peso de uma coluna e o CSS de espaçamento, e o tempo de localização caiu de 14 para 9 segundos, com três pessoas" é um resultado difícil de contestar e barato de reproduzir.

Uma ressalva metodológica sobre o passo 6, que vale para qualquer comparação desse tipo: alterne a ordem entre os participantes. Quem vê a versão A primeiro está aprendendo a tela, e será mais rápido na B por efeito de aprendizado, independentemente do desenho. Com três pessoas, faça duas começarem por uma versão e uma pela outra — não elimina o efeito, mas impede que ele produza sozinho a conclusão que você queria encontrar.

---
