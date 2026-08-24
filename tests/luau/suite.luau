--!nocheck
-- Orquestra as suítes Luau. Roda DENTRO do interpretador do glacier (via
-- `roadmapia --check`), e não num `lua` do sistema, por três motivos:
--
--   1. é o mesmo interpretador da produção — o teste passa a exercitar o
--      `json` de verdade, o `require` de verdade e a mesma versão de Luau;
--   2. permite que as bibliotecas testadas usem ANOTAÇÃO DE TIPO Luau, que
--      não é Lua 5.4 válido e quebraria um runner externo;
--   3. dispensa ter um `lua` instalado.
--
-- `--!nocheck` aqui e nas suítes: elas trocam globais do motor por dublês de
-- propósito (é o que um harness faz), e o type checker não tem como aprovar
-- isso. As bibliotecas TESTADAS seguem verificadas normalmente.

local linhas = {}
local falhas = 0

-- API que as suítes usam. Global porque cada suíte é um módulo `require`d.
function conferir(condicao, nome, detalhe)
    if condicao then
        table.insert(linhas, "  ok    " .. nome)
    else
        falhas += 1
        table.insert(linhas, "  FALHOU " .. nome .. (detalhe and ("  — " .. detalhe) or ""))
    end
end

function rodar()
    linhas = {}
    falhas = 0

    require("fila").rodar()
    require("openrouter_casos").rodar()

    ctx.teste_saida = table.concat(linhas, "\n")
    ctx.teste_falhas = tostring(falhas)
    ctx.teste_total = tostring(#linhas)
    ctx.teste_resumo = tostring(#linhas - falhas) .. "/" .. tostring(#linhas)
end
