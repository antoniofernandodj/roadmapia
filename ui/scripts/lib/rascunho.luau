--!nolint
-- Rascunho do esboço em disco: sobrevive a fechar o app no meio da revisão.
--
-- `ctx.esboco_json` (e os campos que `revisao.luau:confirmar()` precisa —
-- tipo/assunto/slug base) só vivem em memória; fechar o app no meio da
-- revisão os perde (foi o que aconteceu uma vez: um esboço de 11 capítulos,
-- já pago à IA, sumiu ao reabrir). Este módulo espelha esses campos num
-- arquivo PRÓPRIO, fora do `storage` (que é por-componente — `perguntas` e
-- `revisao` gravariam em arquivos DIFERENTES, um não enxerga o do outro) —
-- assim qualquer tela que gera ou edita o esboço grava no MESMO lugar, e só
-- `inicio` precisa ler de volta, para oferecer "continuar".
--
-- Vale por UMA obra de cada vez: gravar substitui o rascunho anterior, e
-- `limpar()` roda tanto ao confirmar o plano (virou um `Plano` de verdade em
-- `saidas/`, o rascunho não serve mais) quanto ao começar uma entrevista nova
-- (ver `inicio.luau:refinar()` — o esboço antigo não serve para o assunto
-- novo, mesma lógica que já zerava `ctx.esboco_json` em memória).

local RASCUNHO = {}

RASCUNHO.ARQUIVO = "saidas/.rascunho-esboco.json"

--- Grava (substitui) o rascunho. Síncrono — `write_file` não suspende a
--- corrotina, então dá para chamar de qualquer handler sem virar `async`.
--- Não faz nada se não há esboço ainda (nada a guardar).
function RASCUNHO.salvar(esboco_json: string?, tipo: string?, assunto: string?, slug_base: string?)
    if (esboco_json or "") == "" then
        return
    end
    local envelope = json.encode({
        esboco_json = esboco_json,
        tipo = tipo or "",
        assunto = assunto or "",
        slug_base = slug_base or "",
    })
    write_file(RASCUNHO.ARQUIVO, envelope)
end

--- Lê o rascunho do disco, se houver — `nil` se não há arquivo, se está
--- vazio (ver `limpar`) ou corrompido. SUSPENDE a corrotina (via
--- `fetch("file://…")`, a única forma de ler um arquivo local aqui): só
--- chame de dentro de uma ação despachada (inclusive `init` — o motor drena
--- corrotinas de qualquer função que despacha, não só cliques).
function RASCUNHO.carregar(): any?
    local res = fetch("file://" .. RASCUNHO.ARQUIVO)
    if not res.ok then
        return nil
    end
    local ok, v = pcall(json.decode, res.body)
    if not ok or type(v) ~= "table" or type(v.esboco_json) ~= "string" or v.esboco_json == "" then
        return nil
    end
    return v
end

--- Apaga o rascunho: plano confirmado, ou entrevista nova começando (o
--- esboço em memória já é zerado nesses dois pontos — isto zera a cópia em
--- disco pela mesma razão). Não há `delete_file`; um arquivo vazio não
--- decodifica como esboço válido, então `carregar()` já trata isso como
--- "nada salvo".
function RASCUNHO.limpar()
    write_file(RASCUNHO.ARQUIVO, "")
end

return RASCUNHO
