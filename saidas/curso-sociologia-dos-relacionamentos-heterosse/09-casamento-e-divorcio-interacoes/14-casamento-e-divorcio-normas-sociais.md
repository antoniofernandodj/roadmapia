## Casamento e Divórcio: Normas Sociais

Imagine um casal que decide se divorciar após 5 anos de casamento. A família dele diz que "casamento é para sempre" e corta contato. A família dela oferece apoio, dizendo que "felicidade vem primeiro". Os amigos dividem-se entre quem acha "egoísmo" e quem defende "autonomia". Este conflito não é pessoal - é a norma social em ação.

### O que são normas sociais no contexto conjugal?

Normas sociais são regras não escritas que ditam o comportamento esperado em relacionamentos. No Brasil, elas operam em três níveis:

1. **Pressão pré-casamento**: "Aos 30, você deveria estar casado"
2. **Controle marital**: "Mulher decente não sai sem o marido"
3. **Barreiras ao divórcio**: "Você vai destruir a família"

Dados do IBGE (2022) mostram como essas normas se materializam:
- 68% dos brasileiros acham que casais devem ter filhos
- Em divórcios, 73% das mulheres relatam críticas por "quebrar a família"

### Como as normas moldam decisões conjugais

**Exemplo 1: O custo social do divórcio**

```python
# Simulando pressão social em divórcios
class Pessoa:
    def __init__(self, idade, religiao, regiao):
        self.idade = idade
        self.religiao = religiao  # 1=Cristã, 2=Outras, 3=Nenhuma
        self.regiao = regiao  # 1=Norte, 2=Nordeste, 3=Sudeste, 4=Sul, 5=Centro-Oeste

def aceitacao_divorcio(pessoa):
    base = 50  # Pontuação neutra
    # Ajustes por fatores sociais
    if pessoa.religiao == 1: base -= 20
    if pessoa.regiao in [2,4]: base -= 15
    if pessoa.idade > 60: base -= 25
    return max(0, base)  # Não pode ser negativo

maria = Pessoa(35, 1, 2)  # 35 anos, cristã, Nordeste
print(f"Aceitação do divórcio: {aceitacao_divorcio(maria)}%")
```

Saída:
```
Aceitação do divórcio: 15%
```

Este modelo simplificado mostra como religião, região e idade reduzem a aceitação social do divórcio. Na prática, isso significa:

- Menos rede de apoio pós-divórcio
- Dificuldade para recasamento
- Estigma sobre os filhos do casal

**Exemplo 2: O mito do "casamento perfeito"**

Pesquisas mostram que 62% dos brasileiros acreditam que "o amor conjugal deve ser incondicional". Quando a realidade não corresponde:

1. O casal tenta se adequar à norma
2. Surge culpa por não corresponder ao ideal
3. A demora para buscar ajuda profissional (média de 6 anos)

### Normas em transformação

Apesar da persistência desses padrões, há mudanças em curso:

| Ano | Taxa de divórcio (por 1000 hab) | Casamentos homoafetivos (%) |
|-----|----------------------------------|-----------------------------|
| 2000| 1.3                              | 0                           |
| 2010| 2.6                              | 3.2                         |
| 2020| 3.8                              | 12.7                        |

Fonte: IBGE/CNJ

Esses números revelam:
- A norma do "casamento indissolúvel" perde força
- Novos modelos conjugais ganham espaço
- As gerações mais jovens redefinem expectativas

### Quando as normas causam conflitos

Um caso real do Tribunal de Justiça de SP (Processo 1002467-44.2020) mostra como normas desatualizadas criam problemas:

- O casal queria divórcio consensual
- O juiz exigiu terapia "para salvar a família"
- O processo demorou 3 anos (média é 1 ano)
- Ambos desenvolveram depressão

Este caso exemplifica o **descompasso** entre normas sociais e direitos individuais.

### Exercício Prático

Analise esta situação:

"Carlos (40) e Ana (38) estão casados há 12 anos. Ele quer filhos; ela não. A família dele diz que 'mulher completa é mãe'. Os amigos dela afirmam que 'ninguém deve ceder nisso'."

1. Quais normas sociais estão em conflito?
2. Como isso afeta a decisão do casal?
3. Que estratégias poderiam reduzir essa pressão?

**Solução comentada:**

1. Normas em conflito:
   - Expectativa reprodutiva feminina
   - Ideal de sacrifício conjugal
   - Nova norma de autonomia individual

2. Impactos:
   - Pressão para Ana ceder causa ressentimento
   - Carlos sente-se traído pela quebra de expectativa
   - Risco de divórcio por conflito irresolúvel

3. Estratégias:
   - Buscar redes de apoio não familiares
   - Terapia focada em decisão conjunta
   - Explicitar acordos para familiares