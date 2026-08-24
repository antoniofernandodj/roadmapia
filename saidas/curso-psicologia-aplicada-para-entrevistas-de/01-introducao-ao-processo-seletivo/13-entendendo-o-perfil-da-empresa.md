## Entendendo o perfil da empresa

Imagine chegar a uma entrevista falando sobre sua paixão por inovação radical quando a empresa valoriza estabilidade e processos consolidados. Ou citar exemplos de trabalho individual em uma cultura que celebra colaboração extrema. Esses desalinhamentos surgem quando não deciframos o DNA da organização — e o resultado é a rejeição, mesmo com competência técnica.

O perfil da empresa não é um detalhe. É o critério invisível que define quem "se encaixa". Veja como desvendar isso na prática:

### 1. Decifre a linguagem dos valores declarados
Quando a Microsoft diz "Growth Mindset" ou o Nubank prega "Don't Settle", essas não são frases de efeito. São códigos que revelam:

```python
# Exemplo: Análise de valores corporativos
valores_nubank = ["Don't Settle", "We're Nubank", "We build bravely"]
valores_tradicional = ["Excelência", "Tradição", "Hierarquia clara"]

def detectar_cultura(valores):
    if any("bravely" in v.lower() or "settle" in v.lower() for v in valores):
        return "Cultura disruptiva (busca perfis questionadores)"
    elif "hierarquia" in " ".join(valores).lower():
        return "Cultura estruturada (prefere aderência a processos)"
    
print(detectar_cultura(valores_nubank))  # Saída: Cultura disruptiva
print(detectar_cultura(valores_tradicional))  # Saída: Cultura estruturada
```

A saída mostra como valores moldam expectativas: enquanto uma quer "construtoras de novos caminhos", a outra busca "seguidores de métodos comprovados".

### 2. Leia as entrelinhas da comunicação institucional
Analise o tom das redes sociais e releases:

- Empresa A: "Nossa equipe bateu recordes com trabalho incansável nos finais de semana" → Cultura de sacrifício
- Empresa B: "Implementamos sextas-feiras sem reuniões para equilíbrio" → Preocupação com bem-estar

### 3. Mapeie os padrões dos funcionários
No LinkedIn, observe:

```python
# Padrões em perfis de colaboradores
perfil_colaborador = {
    "tempo_medio_empresa": 2.5,  # Em anos
    "palavras_chave_perfil": ["agilidade", "MVP", "fail fast"],
    "formacao_comum": "Engenharia + MBA"
}

if perfil_colaborador["tempo_medio_empresa"] < 3:
    print("Alta rotatividade/Cultura de alta pressão")
if "fail fast" in perfil_colaborador["palavras_chave_perfil"]:
    print("Tolerância a erros desde que iterativos")
```

### 4. Identifique os tabus organizacionais
Uma fintech evitará frases como "sempre fizemos assim". Já uma multinacional centenária pode desconfiar de "quebramos todas as regras".

**Erro comum:** Dizer "adoro desafios que exigem mudanças constantes" em uma empresa que opera em mercados regulados e preza estabilidade. O entrevistador pensará: "Este candidato trará instabilidade".

### Exercício prático
Analise a página de carreiras do Itaú (https://carreiras.itau/) e do Mercado Livre (https://www.mercadolivre.com.br/carreiras). Compare:

1. Quantas vezes "inovação" aparece vs. "segurança"?
2. Como são as fotos dos times (trajes formais/casuais? ambientes rígidos/descontraídos?)
3. Que histórias de funcionários são destacadas?

**Solução comentada:**
No Itaú, termos como "solidez" e "longo prazo" predominam, com fotos de escritórios tradicionais. Já no Mercado Livre, "velocidade" e "reinvenção" são frequentes, com imagens de espaços colaborativos. Isso indica que o primeiro valoriza perfis metódicos, enquanto o segundo busca adaptabilidade.