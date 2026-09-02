## Contribuindo para o projeto Wayland

O Wayland é um projeto aberto que depende de contribuições da comunidade. Se você quer ajudar a moldar o futuro dos gráficos no Linux, aqui está como participar efetivamente:

### Encontrando problemas para resolver

Comece explorando issues marcadas como "good first issue" no GitLab do Wayland. Por exemplo, ao executar:

```bash
git clone https://gitlab.freedesktop.org/wayland/wayland.git
cd wayland
grep -r "good first issue" ./
```

Você encontrará problemas como "Implementar validação adicional no protocolo XDG-shell v6" - um excelente ponto de partida para entender o código-base.

### Configurando o ambiente de desenvolvimento

Antes de contribuir com código, configure seu ambiente para compilar o Wayland a partir do source:

```bash
sudo apt install meson ninja-build libexpat1-dev libffi-dev
meson builddir
ninja -C builddir
```

Se encontrar erros como:

```
error: Dependency "libwayland-server" not found
```

Instale os pacotes de desenvolvimento necessários com `sudo apt install libwayland-dev`.

### Enviando patches corretamente

O Wayland segue um processo rigoroso de revisão. Ao enviar um patch:

1. Crie um branch dedicado:
```bash
git checkout -b fix-xdg-shell-validation
```

2. Escreva uma mensagem de commit no formato correto:
```
xdg-shell: Add validation for size hints

Add missing validation for minimum/maximum size hints in xdg-shell v6
protocol implementation. Fixes #123.

Signed-off-by: Seu Nome <seu@email.com>
```

3. Use `git format-patch` para criar o patch:
```bash
git format-patch -1 HEAD
```

### Revisando código de outros contribuidores

Mesmo que você não envie patches, pode ajudar revisando código. Instale o `git-review` e comente em MRs (Merge Requests) abertas:

```bash
sudo apt install git-review
git review -d 1234  # Onde 1234 é o ID do MR
```

Comentários úteis incluem:
- "Esta mudança quebra compatibilidade com clientes existentes?"
- "Faltam testes para este caso de borda"
- "O protocolo XML precisa ser atualizado para refletir esta mudança"

### Relatando bugs eficientemente

Ao encontrar um bug, colete informações úteis antes de reportar:

```bash
WAYLAND_DEBUG=1 weston-info > weston-debug.log 2>&1
```

Inclua no relatório:
1. Versão exata do compositor (`weston --version`)
2. Logs de depuração
3. Passos para reproduzir
4. Comportamento esperado vs. observado

### Mantendo-se atualizado

Assine a lista de discussão wayland-devel para acompanhar desenvolvimentos:

```bash
echo "subscribe wayland-devel" | mailx -s "" lists.freedesktop.org
```

Participe das reuniões quinzenais no IRC (#wayland no Freenode), onde decisões sobre novos protocolos são discutidas.

### Exercício: Enviando uma correção de documentação

1. Encontre um erro na documentação do protocolo wayland.xml
2. Corrija o erro localmente
3. Envie um patch seguindo o processo acima
4. Poste o link do MR no IRC para revisão

Solução comentada:
```bash
# 1. Encontre um comentário XML incorreto em protocol/wayland.xml
# 2. Edite o arquivo, por exemplo:
sed -i 's/<!-- Wrong comment -->/<!-- Corrected comment -->/' protocol/wayland.xml

# 3. Crie o commit e envie
git add protocol/wayland.xml
git commit -s -m "wayland.xml: Fix incorrect protocol comment"
git format-patch -1 HEAD
# Envie o patch para wayland-devel@lists.freedesktop.org
```