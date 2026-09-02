## Métricas de acessibilidade básicas

Imagine que você está avaliando uma interface para garantir que pessoas com diferentes habilidades possam usá-la sem obstáculos. O desafio não é apenas saber se o design está bonito ou funcional para o usuário médio, mas verificar se ele atende a critérios mínimos de acessibilidade — um aspecto essencial para incluir todas as pessoas, independentemente de limitações visuais, motoras, cognitivas ou auditivas.

Como desenvolvedor que está migrando para UX, você já sabe que as métricas são parâmetros para avaliar a experiência do usuário. No caso da acessibilidade, as métricas básicas servem para detectar barreiras comuns, sem exigir conhecimento aprofundado em normas técnicas como WCAG. São indicadores simples e práticos que mostram se a interface é minimamente acessível e onde precisam ser feitas melhorias.

### Por que medir acessibilidade?

Sem métricas, a avaliação da acessibilidade fica no achismo ou na opinião de poucos. Métricas básicas permitem identificar problemas que, se ignorados, excluem pessoas do uso da interface. Além disso, ajudam a priorizar correções e a mostrar resultados concretos para a equipe e stakeholders.

### Métricas simples e importantes para acessibilidade

Aqui estão alguns indicadores básicos que você pode aplicar já na fase de protótipo ou na primeira versão da interface, usando apenas observação, ferramentas gratuitas e testes rápidos com usuários:

#### 1. **Contraste de cores**

O contraste entre texto e fundo é crucial para pessoas com baixa visão ou daltonismo. Uma métrica simples é verificar se a combinação de cores usada atinge uma relação mínima de contraste.

- **Como medir:** Use ferramentas online gratuitas, como o [Contrast Checker](https://webaim.org/resources/contrastchecker/).
- **Indicador:** A cor do texto deve ter contraste suficiente com o fundo, idealmente um índice de pelo menos 4,5:1 para texto normal e 3:1 para texto grande.

**Erro comum:** Texto com contraste baixo gera aviso visual como:

```
Warning: Low contrast ratio (2.8:1). Text may be unreadable for users with visual impairments.
```

**Correção:** Ajuste a cor do texto ou do fundo até atingir o contraste mínimo.

#### 2. **Tamanho do texto**

Fontes muito pequenas dificultam a leitura, especialmente para pessoas com baixa acuidade visual.

- **Como medir:** Observe se o texto principal tem, no mínimo, 14 pixels ou 12 pontos em protótipos e interfaces web/mobile.
- **Indicador:** Textos com tamanho menor que 12px devem ser evitados.

**Erro comum:** Texto com 10px pode aparecer ilegível e gerar reclamações de usuários em testes.

**Correção:** Aumente o tamanho do texto para um valor legível, mantendo harmonia visual.

#### 3. **Elementos clicáveis com área mínima**

Usuários com mobilidade reduzida ou que usam dispositivos touch precisam que botões e links tenham áreas suficientemente grandes para serem acionados com facilidade.

- **Como medir:** Verifique se botões e links possuem ao menos 44x44 pixels (recomendação comum).
- **Indicador:** Áreas menores que isso são difíceis de tocar e aumentam erros de interação.

**Erro comum:** Botão de 20x20px gera dificuldade de clique, causando frustração e erros.

**Correção:** Redimensione os elementos interativos para área mínima recomendada.

#### 4. **Uso de rótulos e indicações visuais claras**

Para pessoas com deficiência cognitiva ou que utilizam leitores de tela, é fundamental que os elementos tenham rótulos textuais e indicações visuais evidentes.

- **Como medir:** Verifique se todos os botões, campos de formulário e links possuem textos descritivos e se estados como "ativo", "erro" ou "selecionado" estão visualmente evidentes.
- **Indicador:** Ausência de rótulos explícitos ou feedback visual claro prejudica a compreensão.

**Erro comum:** Campos de formulário sem rótulo ou apenas com placeholder, que desaparece após digitar.

**Correção:** Use rótulos permanentes e mensagens de erro visíveis.

#### 5. **Navegação por teclado**

Usuários que não usam mouse dependem de navegação via teclado (tabulação).

- **Como medir:** Teste a interface pressionando a tecla Tab para navegar entre os elementos e verifique se a ordem é lógica e se o foco é visível.
- **Indicador:** Elementos fora da ordem natural ou sem destaque no foco dificultam o uso.

**Erro comum:** Foco invisível ou saltos erráticos no teclado causam confusão.

**Correção:** Ajuste a ordem de tabulação e implemente destaque visual no foco.

### Aplicando as métricas básicas em um exemplo prático

Considere o protótipo de uma tela de login simples, com:

- Campo para e-mail
- Campo para senha
- Botão de "Entrar"
- Link para "Esqueci minha senha"

**Passo 1: Verificar contraste**

Usando o Contrast Checker, você encontra que o botão "Entrar" tem texto azul claro sobre fundo branco, com contraste 2.5:1 — abaixo do mínimo.

**Solução:** Mude o texto para azul escuro, atingindo 5.0:1, ou adicione um fundo escuro com texto branco.

**Passo 2: Avaliar tamanho do texto**

O texto dos campos está em 11px. É pequeno para leitura confortável.

**Solução:** Aumente para 14px.

**Passo 3: Área clicável**

O botão "Entrar" mede 30x30px, pequeno para toque em dispositivos móveis.

**Solução:** Redimensione para 44x44px.

**Passo 4: Rótulos**

Os campos têm placeholders, mas não rótulos fixos. Usuários podem esquecer o que cada campo pede após começar a digitar.

**Solução:** Adicione rótulos acima dos campos.

**Passo 5: Navegação por teclado**

Testando com Tab, o foco pula do campo de e-mail direto para o link "Esqueci minha senha", ignorando o campo senha.

**Solução:** Corrija a ordem de tabulação para e-mail → senha → entrar → esqueci minha senha.

### Como usar essas métricas na prática

- **No protótipo:** Faça verificações visuais e interativas rápidas com as métricas.
- **Em testes com usuários:** Observe se pessoas com diferentes perfis conseguem ler, clicar e navegar sem dificuldade.
- **Como relatório:** Anote problemas e melhorias sugeridas, usando dados simples (exemplo: "contraste do botão: 2.5:1, mínimo recomendado: 4.5:1").

### Exercício prático

Pegue sua interface ou protótipo atual e faça:

1. Teste o contraste de todas as cores utilizadas em textos e botões, usando uma ferramenta online.
2. Meça o tamanho do texto principal e dos elementos secundários.
3. Verifique se todos os botões e links têm área clicável mínima de 44x44px.
4. Confirme se todos os elementos interativos possuem rótulos claros e feedback visual.
5. Navegue pela interface usando apenas o teclado (Tab) e observe se a navegação é lógica e o foco está visível.

**Solução comentada:**

- Para o contraste, ajuste cores até obter o mínimo recomendado.
- Aumente o tamanho do texto para pelo menos 14px.
- Redimensione botões pequenos para 44x44px.
- Adicione rótulos permanentes para campos sem texto fixo.
- Reorganize a ordem de tabulação para seguir a sequência natural do fluxo da interface.
- Teste novamente todas as etapas após as correções para garantir melhorias.

---

Essas métricas básicas não substituem uma avaliação completa, mas são ferramentas acessíveis para garantir que seu design considere a diversidade dos usuários desde as primeiras etapas. Incorporar esses cuidados melhora significativamente a experiência e evita retrabalhos caros no futuro. A acessibilidade é uma responsabilidade de todo profissional de UI/UX, e começar pelo simples já faz toda a diferença.