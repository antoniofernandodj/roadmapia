VERSION := $(shell grep '^version' Cargo.toml | head -1 | cut -d'"' -f2)
APP     := roadmapia

BOLD  := \033[1m
RESET := \033[0m
GREEN := \033[32m
CYAN  := \033[36m
RED   := \033[31m

export CARGO_TERM_COLOR := never

.DEFAULT_GOAL := help

# O app NÃO é autocontido: os `.gv`, o `.gss` e os `.luau` de `ui/` são lidos em
# runtime (é o que dá o hot-reload). Todo pacote daqui carrega o `ui/` junto, e
# todo alvo de pacote CONFERE que ele foi junto — um .zip sem `ui/` abre uma
# janela vazia, que é o jeito mais caro de descobrir o erro.
UI_DIR := ui

# ── Build ─────────────────────────────────────────────────────────────────────

.PHONY: build
build: ## Compila em modo release (Linux)
	cargo build --release

.PHONY: run
run: ## Roda em modo debug
	cargo run

.PHONY: check
check: ## Verifica templates, estilos, Luau e simulações de fluxo (`--check`)
	cargo run --quiet -- --check

# ── Qualidade ─────────────────────────────────────────────────────────────────

.PHONY: fmt
fmt: ## Formata o código com rustfmt
	cargo fmt --all

.PHONY: fmt-check
fmt-check: ## Verifica formatação sem modificar arquivos
	cargo fmt --all -- --check

.PHONY: clippy
clippy: ## Roda o clippy com warnings como erro
	cargo clippy --all-targets -- -D warnings

.PHONY: luau
luau: ## Type-check dos scripts Luau com luau-lsp
	@command -v luau-lsp >/dev/null 2>&1 || \
		(echo "$(RED)luau-lsp não encontrado$(RESET) — https://github.com/JohnnyMorganz/luau-lsp" && exit 1)
	luau-lsp analyze --platform=standard --definitions=glacier.d.luau \
		$(UI_DIR)/scripts/*.luau $(UI_DIR)/scripts/lib/*.luau

.PHONY: lint
lint: fmt-check clippy luau check ## Tudo que precisa passar antes de commitar

# ── Windows (cross-compile a partir do Linux) ─────────────────────────────────

WIN_TARGET   := x86_64-pc-windows-msvc
WIN_BIN      := target/$(WIN_TARGET)/release/$(APP).exe
WIN_DIST_DIR := dist/$(APP)-windows
WIN_DIST_ZIP := dist/$(APP)-$(VERSION)-windows.zip

# `+crt-static` embute a CRT: sem isso o .exe exige o Visual C++ Redistributable
# instalado na máquina de destino, e falha com uma caixa de erro que não diz
# qual DLL faltou.
WIN_RUSTFLAGS := -C target-feature=+crt-static

.PHONY: win-deps
win-deps: ## Instala cargo-xwin e o target MSVC, se faltarem
	@command -v cargo-xwin >/dev/null 2>&1 || \
		(echo "$(BOLD)Instalando cargo-xwin...$(RESET)" && cargo install cargo-xwin)
	@rustup target list --installed | grep -q '^$(WIN_TARGET)$$' || \
		rustup target add $(WIN_TARGET)

.PHONY: windows
windows: win-deps ## Compila o .exe para Windows via cargo-xwin
	RUSTFLAGS="$(WIN_RUSTFLAGS)" cargo xwin build --release --target $(WIN_TARGET)
	@echo ""
	@echo "$(GREEN)Executável Windows:$(RESET)"
	@ls -lh $(WIN_BIN)

.PHONY: windows-dist
windows-dist: windows ## Monta o .zip do Windows (exe + ui/ + instalador)
	@command -v zip >/dev/null 2>&1 || \
		(echo "$(RED)Instale 'zip' (sudo apt install zip)$(RESET)" && exit 1)
	@rm -rf $(WIN_DIST_DIR) $(WIN_DIST_ZIP)
	@mkdir -p $(WIN_DIST_DIR)
	@cp $(WIN_BIN) $(WIN_DIST_DIR)/
	@# `ui/` INTEIRO, não sub-pasta por sub-pasta: copiar item a item faz este
	@# alvo esquecer em silêncio um diretório novo (foi assim que o rustploy
	@# perdeu `views/scripts/` por meses).
	@cp -r $(UI_DIR) $(WIN_DIST_DIR)/
	@# O storage do glacier é estado da máquina de quem desenvolveu, não do
	@# pacote — e o .glacier-storage carrega preferências antigas.
	@rm -rf $(WIN_DIST_DIR)/$(UI_DIR)/.glacier-storage
	@rm -rf $(WIN_DIST_DIR)/$(UI_DIR)/scripts/.glacier-storage
	@cp packaging/windows/instalar.bat $(WIN_DIST_DIR)/
	@cp packaging/windows/desinstalar.bat $(WIN_DIST_DIR)/
	@# CRLF: o LEIA-ME é aberto no Notepad, que até o Windows 10 mostrava um
	@# arquivo LF como uma linha só.
	@sed 's/$$/\r/' packaging/windows/LEIA-ME.txt > $(WIN_DIST_DIR)/LEIA-ME.txt
	@$(MAKE) --no-print-directory conferir-pacote DIR=$(WIN_DIST_DIR)
	@cd dist && zip -qr $(notdir $(WIN_DIST_ZIP)) $(notdir $(WIN_DIST_DIR))
	@echo ""
	@echo "$(GREEN)Pacote Windows:$(RESET)"
	@ls -lh $(WIN_DIST_ZIP)
	@echo "  Descompactar e rodar $(APP).exe, ou instalar.bat para instalar de verdade."

# ── Linux ─────────────────────────────────────────────────────────────────────

LIN_DIST_DIR := dist/$(APP)-linux
LIN_DIST_TGZ := dist/$(APP)-$(VERSION)-linux-x86_64.tar.gz

.PHONY: linux-dist
linux-dist: build ## Monta o .tar.gz portátil do Linux (binário + ui/ + instalador)
	@rm -rf $(LIN_DIST_DIR) $(LIN_DIST_TGZ)
	@mkdir -p $(LIN_DIST_DIR)
	@cp target/release/$(APP) $(LIN_DIST_DIR)/
	@cp -r $(UI_DIR) $(LIN_DIST_DIR)/
	@rm -rf $(LIN_DIST_DIR)/$(UI_DIR)/.glacier-storage
	@rm -rf $(LIN_DIST_DIR)/$(UI_DIR)/scripts/.glacier-storage
	@cp packaging/linux/instalar.sh $(LIN_DIST_DIR)/
	@chmod +x $(LIN_DIST_DIR)/instalar.sh
	@cp packaging/linux/LEIA-ME.txt $(LIN_DIST_DIR)/
	@$(MAKE) --no-print-directory conferir-pacote DIR=$(LIN_DIST_DIR)
	@cd dist && tar czf $(notdir $(LIN_DIST_TGZ)) $(notdir $(LIN_DIST_DIR))
	@echo ""
	@echo "$(GREEN)Pacote Linux:$(RESET)"
	@ls -lh $(LIN_DIST_TGZ)

.PHONY: deb
deb: ## Gera o .deb (binário em /usr/bin, ui/ em /usr/share/roadmapia)
	@command -v cargo-deb >/dev/null 2>&1 || \
		(echo "$(BOLD)Instalando cargo-deb...$(RESET)" && cargo install cargo-deb)
	@rm -rf $(UI_DIR)/.glacier-storage $(UI_DIR)/scripts/.glacier-storage
	cargo deb -o dist/
	@echo ""
	@echo "$(GREEN)Pacote .deb:$(RESET)"
	@ls -lh dist/*.deb

# Vazio quando já se está como root (container/CI); senão usa sudo.
SUDO := $(shell [ "$$(id -u)" = 0 ] || command -v sudo)

.PHONY: install
install: deb ## Instala no sistema via dpkg (usa sudo)
	$(SUDO) dpkg -i $$(ls dist/$(APP)_*.deb | tail -1)
	@command -v update-desktop-database >/dev/null 2>&1 && \
		$(SUDO) update-desktop-database /usr/share/applications || true
	@echo "$(GREEN)Instalado.$(RESET) Rode '$(APP)' ou procure no menu de aplicativos."

.PHONY: uninstall
uninstall: ## Remove o pacote instalado (usa sudo)
	$(SUDO) dpkg -r $(APP) || true

.PHONY: reinstall
reinstall: uninstall install ## Remove e reinstala

# ── Conferência de pacote ─────────────────────────────────────────────────────

# Um pacote sem `ui/` compila, empacota, instala e abre — numa janela vazia. O
# erro só aparece na máquina de quem baixou, sem nenhuma mensagem que aponte a
# causa. Então cada alvo de pacote termina aqui, e falha ALTO.
.PHONY: conferir-pacote
conferir-pacote:
	@test -n "$(DIR)" || (echo "$(RED)conferir-pacote precisa de DIR=$(RESET)" && exit 1)
	@for f in $(UI_DIR)/inicio.gv $(UI_DIR)/app.gss $(UI_DIR)/scripts/inicio.luau \
	          $(UI_DIR)/scripts/lib/openrouter.luau; do \
		test -f "$(DIR)/$$f" || \
			(echo "$(RED)PACOTE INCOMPLETO: falta $$f em $(DIR)$(RESET)" && exit 1); \
	done
	@n=$$(find $(DIR)/$(UI_DIR) -name '*.luau' | wc -l); \
		test "$$n" -ge 9 || \
			(echo "$(RED)PACOTE INCOMPLETO: só $$n .luau (esperava 9+)$(RESET)" && exit 1); \
		echo "$(GREEN)  pacote ok$(RESET) — $$n scripts .luau, templates e estilos presentes"

# ── Limpeza ───────────────────────────────────────────────────────────────────

.PHONY: clean
clean: ## Remove artefatos de build
	cargo clean

.PHONY: clean-dist
clean-dist: ## Remove só os pacotes gerados
	rm -rf dist

# ── Info ──────────────────────────────────────────────────────────────────────

.PHONY: version
version: ## Exibe a versão atual
	@echo "$(VERSION)"

.PHONY: help
help: ## Lista todos os targets disponíveis
	@echo ""
	@echo "$(BOLD)$(APP) $(VERSION) — targets disponíveis$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { \
		printf "  $(CYAN)%-16s$(RESET) %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)
	@echo ""
