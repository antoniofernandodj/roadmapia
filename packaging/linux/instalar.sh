#!/bin/sh
# Instalador do roadmapia para Linux (pacote portátil .tar.gz).
#
# Padrão: `~/.local` — sem sudo, sem tocar em nada do sistema. `--sistema`
# instala em `/usr/local` para todos os usuários. Nos dois casos o layout é o
# do FHS, que é o que o `ui_dir()` do app procura:
#
#     <prefixo>/bin/roadmapia
#     <prefixo>/share/roadmapia/ui/
#
# O binário sobe um nível a partir de si mesmo e acha `../share/roadmapia/ui` —
# por isso não há wrapper de shell nem variável de ambiente para configurar.
set -eu

APP=roadmapia
ORIGEM=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PREFIXO="$HOME/.local"
SUDO=""
ACAO=instalar

for arg in "$@"; do
    case "$arg" in
        --sistema)  PREFIXO=/usr/local; [ "$(id -u)" = 0 ] || SUDO=sudo ;;
        --remover)  ACAO=remover ;;
        --prefixo=*) PREFIXO=${arg#--prefixo=} ;;
        -h|--help)
            cat <<AJUDA
uso: ./instalar.sh [opções]

  (sem opção)     instala em ~/.local          (não pede sudo)
  --sistema       instala em /usr/local        (pede sudo)
  --prefixo=DIR   instala em DIR
  --remover       remove o que foi instalado
AJUDA
            exit 0 ;;
        *) echo "opção desconhecida: $arg (use --help)" >&2; exit 2 ;;
    esac
done

BIN="$PREFIXO/bin/$APP"
COMPARTILHADO="$PREFIXO/share/$APP"
DESKTOP="$PREFIXO/share/applications/$APP.desktop"

if [ "$ACAO" = remover ]; then
    $SUDO rm -f  "$BIN" "$DESKTOP"
    $SUDO rm -rf "$COMPARTILHADO"
    command -v update-desktop-database >/dev/null 2>&1 &&
        $SUDO update-desktop-database "$PREFIXO/share/applications" 2>/dev/null || true
    echo "$APP removido de $PREFIXO."
    echo
    echo "Ficaram no disco, de propósito:"
    echo "  configuração : ~/.config/$APP/config.ini"
    echo "  obras geradas: a pasta 'saidas' de onde você rodou o app"
    exit 0
fi

# Um pacote incompleto instala e só falha ao abrir, numa janela vazia. Melhor
# recusar aqui, onde ainda dá para dizer o que faltou.
[ -f "$ORIGEM/$APP" ]        || { echo "ERRO: $APP não está nesta pasta." >&2; exit 1; }
[ -f "$ORIGEM/ui/inicio.gv" ] || { echo "ERRO: a pasta 'ui' não está nesta pasta — pacote incompleto." >&2; exit 1; }

$SUDO mkdir -p "$PREFIXO/bin" "$COMPARTILHADO" "$PREFIXO/share/applications"
$SUDO install -m 755 "$ORIGEM/$APP" "$BIN"
# `ui/` é espelhado, não mesclado: um arquivo que sumiu entre versões não pode
# ficar para trás e ser carregado como se ainda existisse.
$SUDO rm -rf "$COMPARTILHADO/ui"
$SUDO cp -r "$ORIGEM/ui" "$COMPARTILHADO/ui"

$SUDO sh -c "cat > '$DESKTOP'" <<AREA
[Desktop Entry]
Type=Application
Name=roadmapia
Comment=Gera roadmaps, cursos e guias com IA
Exec=$BIN
Terminal=false
Categories=Education;Office;
AREA

command -v update-desktop-database >/dev/null 2>&1 &&
    $SUDO update-desktop-database "$PREFIXO/share/applications" 2>/dev/null || true

echo "Pronto."
echo
echo "  binário     : $BIN"
echo "  ui/         : $COMPARTILHADO/ui"
echo "  configuração: ~/.config/$APP/config.ini"
echo

case ":$PATH:" in
    *":$PREFIXO/bin:"*) echo "Rode '$APP', ou procure no menu de aplicativos." ;;
    *) echo "AVISO: $PREFIXO/bin não está no PATH. Rode '$BIN', ou acrescente:"
       echo "       export PATH=\"$PREFIXO/bin:\$PATH\"" ;;
esac
