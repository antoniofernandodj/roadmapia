-- Prova o modelo de concorrência que a produção do roadmapia usa:
-- N workers via `after`, cada um num laço com `fetch` (que suspende).
--
-- O pool NÃO parte do `init`: o motor DESCARTA timers e fetches pedidos ali
-- (só `streams` sobrevive — ver GlacierUI::install_component). O gatilho é um
-- `UiClick` sintético que o example despacha no primeiro frame, igual ao
-- clique em "Produzir" no app real.
--
-- O resultado vai para arquivo, não para `print`: stdout num pipe é
-- bufferizado e se perde quando o processo é morto.
local WORKERS = 3
local TAREFAS = 6
local fila, ativos, feitos, ordem = {}, 0, 0, {}

local function anotar(linha)
    write_file(ctx.saida, linha)
end

function init()
    ctx.status = "aguardando gatilho"
end

function comecar()
    if ativos > 0 or feitos > 0 then return end
    anotar("gatilho recebido, largando " .. WORKERS .. " workers")
    for i = 1, TAREFAS do fila[i] = i end
    ativos = WORKERS
    ctx.status = "produzindo"
    for w = 1, WORKERS do after((w - 1) * 50, "trabalhador") end
end

function trabalhador()
    while true do
        local t = table.remove(fila, 1)   -- pop atômico: nada suspende aqui
        if t == nil then break end
        local res = fetch("https://api.ipify.org?format=json")  -- suspende
        feitos = feitos + 1
        table.insert(ordem, t .. (res.ok and "ok" or "ERRO"))
        ctx.status = "feitos " .. feitos
        anotar("parcial feitos=" .. feitos .. " ordem=" .. table.concat(ordem, ","))
    end
    ativos = ativos - 1
    if ativos <= 0 then
        anotar("POOL-RESULTADO feitos=" .. feitos .. " ordem=" .. table.concat(ordem, ",")
               .. " sobrou=" .. #fila)
    end
end
