## Configurando variáveis de ambiente

As variáveis de ambiente são essenciais para configurar o comportamento de aplicativos e serviços durante a inicialização de uma sessão gráfica. Elas podem ser usadas para definir caminhos de arquivos, configurações de idioma, preferências de tema e muito mais. Quando você inicia uma sessão gráfica, essas variáveis são carregadas antes que qualquer aplicativo seja executado, permitindo que eles funcionem corretamente desde o primeiro momento.

### Exportando variáveis no `.xinitrc` e `.xsession`

Tanto o `.xinitrc` quanto o `.xsession` podem ser usados para exportar variáveis de ambiente. A sintaxe básica é a mesma: você usa o comando `export` seguido pelo nome da variável e seu valor. Por exemplo, para definir a variável `LANG` para o idioma português do Brasil, você pode adicionar a seguinte linha ao seu arquivo de inicialização:

```bash
export LANG=pt_BR.UTF-8
```

Vamos considerar um exemplo prático onde você deseja definir o tema GTK e o ícone para o ambiente gráfico. Suponha que você tenha instalado o tema "Adwaita-dark" e o conjunto de ícones "Papirus". Você pode configurar isso adicionando as seguintes linhas ao seu `.xinitrc` ou `.xsession`:

```bash
export GTK_THEME=Adwaita-dark
export ICON_THEME=Papirus
```

Após salvar o arquivo, reinicie a sessão gráfica para que as alterações entrem em vigor.

### Erro comum: esquecer de exportar a variável

Um erro comum é definir a variável sem usar o comando `export`. Por exemplo, se você escrever:

```bash
GTK_THEME=Adwaita-dark
```

em vez de:

```bash
export GTK_THEME=Adwaita-dark
```

a variável não será disponibilizada para os processos filhos, o que significa que os aplicativos gráficos não a usarão. Isso pode levar a inconsistências visuais ou funcionais no ambiente gráfico.

### Variáveis específicas para ambientes gráficos

Alguns ambientes gráficos têm variáveis específicas que podem ser configuradas. Por exemplo, se você estiver usando o ambiente KDE Plasma, pode definir a variável `KDE_FULL_SESSION` para indicar que está em uma sessão completa do KDE:

```bash
export KDE_FULL_SESSION=true
```

Isso pode ser útil para garantir que certas aplicações ou scripts se comportem corretamente em um ambiente KDE.

### Testando variáveis de ambiente

Para verificar se suas variáveis de ambiente estão sendo carregadas corretamente, você pode usar o comando `printenv` em um terminal dentro da sessão gráfica. Por exemplo:

```bash
printenv GTK_THEME
```

Isso deve retornar `Adwaita-dark` se a variável foi configurada corretamente.

### Exercício: Configurando o tema GTK e o ícone

Crie um arquivo `.xinitrc` ou `.xsession` que configure o tema GTK como "Adwaita-dark" e o conjunto de ícones como "Papirus". Em seguida, reinicie a sessão gráfica e verifique se as configurações foram aplicadas corretamente usando o comando `printenv`.

**Solução:**

```bash
export GTK_THEME=Adwaita-dark
export ICON_THEME=Papirus
```

Após reiniciar a sessão, execute:

```bash
printenv GTK_THEME
printenv ICON_THEME
```

Você deve ver `Adwaita-dark` e `Papirus` como saídas, respectivamente.