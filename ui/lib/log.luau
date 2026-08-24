--!nolint
-- Log de operações, em arquivo.
--
-- Existe porque uma produção de 200+ chamadas falha de formas que a tela não
-- consegue contar: uma leva de 429, um trecho que voltou vazio, um worker que
-- morreu num erro de script. Sem rastro, o sintoma é "gerou a pasta mas não
-- gerou os arquivos" — e não há como saber onde parou.
--
-- Vai para `saidas/roadmapia.log`, em append (`append_file` do glacier), então
-- sobrevive a fechar o app no meio. Todas as telas escrevem no MESMO arquivo:
-- o interesse é a linha do tempo de uma sessão, não a de uma tela.
--
-- Cada linha: `HH:MM:SS  NÍVEL  origem  mensagem`.

local L = {}

L.ARQUIVO = "saidas/roadmapia.log"

-- Hora do relógio (o `os` do Luau expõe `date`), com um fallback defensivo:
-- um log que explode por causa do carimbo não serve para diagnosticar nada.
local function carimbo()
    if os ~= nil and os.date ~= nil then
        local ok, t = pcall(os.date, "%H:%M:%S")
        if ok and type(t) == "string" then
            return t
        end
    end
    return "--:--:--"
end

--- Escreve uma linha. `origem` diz de onde veio (tela ou módulo), para o log
--- de seis workers concorrentes continuar legível.
function L.escrever(nivel, origem, mensagem)
    local linha = string.format("%s  %-5s %-10s %s\n", carimbo(), nivel, origem, tostring(mensagem))
    -- Sem checar o retorno: um log que aborta a operação que ele deveria
    -- observar seria pior que log nenhum.
    if append_file ~= nil then
        append_file(L.ARQUIVO, linha)
    end
end

function L.info(origem, msg)
    L.escrever("INFO", origem, msg)
end

function L.erro(origem, msg)
    L.escrever("ERRO", origem, msg)
end

function L.aviso(origem, msg)
    L.escrever("AVISO", origem, msg)
end

--- Marca o início de uma sessão, com o contexto que explica tudo que vem
--- depois (modelo e assunto mudam custo, tamanho e taxa de erro).
function L.sessao(origem)
    L.escrever("INFO", origem, string.rep("─", 60))
    L.escrever("INFO", origem, "sessão: tipo=" .. tostring(ctx.tipo)
        .. " modelo=" .. tostring(ctx.modelo)
        .. " assunto=" .. tostring(ctx.assunto))
end

--- Uma chamada à API, no formato que deixa uma produção inteira auditável:
--- `chamada <o quê> ok=<sim/não> custo=<US$> <detalhe>`.
function L.chamada(origem, oque, ok, custo, detalhe)
    L.escrever(
        ok and "INFO" or "ERRO",
        origem,
        string.format(
            "chamada %s ok=%s custo=%.5f %s",
            oque,
            tostring(ok),
            tonumber(custo) or 0,
            tostring(detalhe or "")
        )
    )
end

return L
