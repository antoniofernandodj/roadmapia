--!nolint
-- Onde o app grava: a pasta de saída e os arquivos internos dentro dela.
--
-- A pasta vem do Rust em `ctx.dir_saidas` (`~/Documents/roadmapia`, ver
-- `config::dir_saidas`): o Luau do glacier não lê o ambiente, e um caminho
-- relativo dependeria de onde o app foi aberto — o app instalado, aberto pelo
-- menu, gravava em `~/saidas`.
--
-- Sem a chave (o `--check` e as suítes não a definem), cai em `saidas/`
-- relativo, que é onde os testes gravam e limpam.

local C = {}

C.PADRAO = "saidas"

--- A pasta de saída, sem barra no fim.
function C.saidas(): string
    local d = (type(ctx) == "table") and ctx.dir_saidas or nil
    if type(d) ~= "string" or d == "" then
        return C.PADRAO
    end
    return (string.gsub(d, "[/\\]+$", ""))
end

--- `<pasta de saída>/<nome>`.
function C.em(nome: string): string
    return C.saidas() .. "/" .. nome
end

return C
