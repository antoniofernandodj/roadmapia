## Uso das ferramentas Lunacy e Figma no projeto final

Ao chegar na etapa de execução do projeto final de UI/UX, a escolha e o domínio das ferramentas de design são decisivos para garantir fluidez no fluxo de trabalho e qualidade na entrega. Lunacy e Figma são duas ferramentas populares, cada uma com suas características que influenciam diretamente a forma como você cria, organiza e compartilha seus wireframes e protótipos. Compreender como integrá-las ao seu processo evita perda de tempo, retrabalho e problemas de comunicação com equipes.

### Por que usar Lunacy e Figma juntos?

Lunacy é um editor gráfico gratuito, leve e com excelente desempenho offline, especialmente útil para criação e edição de arquivos Sketch em sistemas Windows, mas também disponível para macOS e Linux. Sua compatibilidade com arquivos Sketch permite aproveitar recursos que muitas vezes não estão disponíveis em outras ferramentas gratuitas, como suporte a vetores e efeitos avançados. Já o Figma é uma plataforma colaborativa online que facilita o trabalho em equipe, prototipagem interativa e versionamento automático.

No projeto final, usar Lunacy para a etapa inicial de criação dos wireframes e layouts traz agilidade e controle local, enquanto o Figma pode ser usado para montar protótipos interativos, compartilhar com stakeholders e coletar feedbacks. Esse fluxo híbrido combina o melhor dos dois mundos: rapidez na criação e eficiência na colaboração.

### Fluxo prático integrado

1. **Criação inicial com Lunacy**

   Comece o projeto estruturando os wireframes de baixa e média fidelidade no Lunacy. Sua interface leve permite trabalhar com rapidez, sem depender da conexão com internet, e oferece suporte nativo a símbolos (componentes) reutilizáveis, facilitando a manutenção de consistência visual.

   Exemplo prático: ao criar uma tela de cadastro, use formas básicas para campos e botões, mantendo o foco na hierarquia e fluxo, sem se preocupar com cores ou imagens. Organize os elementos em grupos e crie símbolos para botões que serão reutilizados em várias telas.

2. **Exportação e importação para Figma**

   Ao finalizar os wireframes no Lunacy, exporte-os em formato `.svg` ou `.png` para importar no Figma. Embora o Figma suporte importação direta de `.sketch`, a compatibilidade nem sempre é perfeita, por isso a exportação em SVG preserva vetores e facilita edição posterior.

   Erro comum: importar arquivos pesados ou com muitos efeitos pode travar o Figma. Para evitar isso, simplifique elementos no Lunacy antes de exportar, removendo sombras ou máscaras complexas.

3. **Montagem do protótipo e interatividade no Figma**

   No Figma, organize as telas importadas em uma sequência lógica para construir o fluxo de navegação. Use os recursos de prototipagem para criar hotspots clicáveis, simular transições simples e validar a experiência do usuário.

   Código completo da interação no Figma (representação visual):

   - Selecione um botão na tela "Cadastro"
   - No painel de prototipagem, conecte o botão à tela "Confirmação"
   - Configure a interação como "On Click" com animação "Dissolver"

4. **Colaboração e feedback**

   Uma vantagem do Figma é a possibilidade de compartilhar o protótipo via link, permitindo que colegas, stakeholders e usuários testem a navegação e deixem comentários diretamente na interface. Isso torna o processo iterativo mais rápido e transparente.

   Atenção: Evite fazer alterações estruturais no protótipo via Figma; reserve essa etapa para ajustes de fluxo e interatividade. Alterações visuais e detalhamentos devem voltar para o Lunacy, para manter a organização e controle de versões.

### Evitando erros comuns na integração

- **Erro:** Tentar criar protótipos complexos com animações avançadas no Lunacy, que não suporta essas funcionalidades.  
  **Correção:** Use o Lunacy apenas para criação estática e edição de wireframes; deixe a prototipagem interativa para o Figma.

- **Erro:** Ignorar a organização dos arquivos ao importar para o Figma, resultando em telas embaralhadas e difícil manutenção.  
  **Correção:** Nomeie suas telas e organize-as em páginas ou frames no Figma, mantendo o fluxo lógico do usuário.

- **Erro:** Dependência exclusiva do Figma sem conexão estável, causando atrasos.  
  **Correção:** Use o Lunacy para trabalhar offline e faça upload das versões para o Figma quando estiver online, garantindo continuidade.

### Comparação rápida entre Lunacy e Figma no projeto final

| Aspecto                | Lunacy                              | Figma                                 |
|-----------------------|----------------------------------|-------------------------------------|
| Trabalho offline       | Sim                              | Não (requer conexão)                 |
| Colaboração em tempo real | Limitada                        | Total, com comentários e edição coletiva |
| Prototipagem interativa | Não suportada                    | Suportada com recursos avançados    |
| Compatibilidade com Sketch | Alta                           | Boa, mas com limitações             |
| Facilidade de exportação | Sim, vários formatos             | Sim, principalmente para web        |

### Exercício prático

**Objetivo:** Integrar Lunacy e Figma no seu projeto final criando um fluxo simples de cadastro.

1. No Lunacy, crie as telas principais do fluxo: Tela Inicial, Formulário de Cadastro e Tela de Confirmação. Use apenas formas básicas, mantendo a hierarquia visual clara e sem cores chamativas.

2. Exporte essas telas em formato SVG.

3. Importe os arquivos SVG no Figma, organize as telas na área de trabalho e crie interações básicas: ao clicar no botão "Cadastrar" na tela de formulário, o protótipo deve navegar para a tela de confirmação.

4. Compartilhe o link do protótipo com um colega ou familiar e peça um feedback sobre o fluxo.

5. Com base no retorno, faça ajustes no Lunacy e atualize os arquivos no Figma.

---

**Solução comentada:**

- O uso do Lunacy para criar as telas iniciais aproveita seu desempenho offline e ferramentas de edição vetorial, evitando distrações com design visual complexo.

- Exportar em SVG mantém a qualidade dos elementos para importação no Figma, onde a prototipagem pode ser feita com facilidade.

- No Figma, a conexão entre telas e a definição de interações simples validam o fluxo, tornando tangível a experiência do usuário.

- Compartilhar protótipos via link facilita o feedback rápido e a colaboração, essencial para iterar e aprimorar antes da entrega final.

- Ajustes iterativos entre Lunacy e Figma reforçam a importância de usar cada ferramenta em sua melhor função, otimizando o processo e a qualidade do projeto.

Esse fluxo integrado prepara você para trabalhar em ambientes reais, onde múltiplas ferramentas são usadas em conjunto para criar soluções de UI/UX eficientes, colaborativas e centradas no usuário.