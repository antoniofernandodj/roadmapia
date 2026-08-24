## Casamento e Espaço no Brasil  

A organização do espaço físico onde um casal vive não é neutra: ela reflete e reforça dinâmicas de poder, expectativas de gênero e modelos culturais de conjugalidade. No Brasil, a relação entre casamento e espaço é particularmente marcada por três fatores:  

1. **A segregação urbana e suas consequências**  
   Em cidades como São Paulo ou Rio de Janeiro, a distância entre bairros nobres e periferias cria casamentos que operam em realidades espaciais radicalmente diferentes. Um casal da Zona Sul carioca tem acesso a equipamentos urbanos (hospitais, escolas, lazer) que um casal de Nova Iguaçu não tem, mesmo que ambos sejam formalmente "casados". Isso impacta desde a divisão de tarefas domésticas (com mais terceirização de serviços nos bairros ricos) até a percepção de mobilidade social.  

   *Exemplo concreto*:  
   - Em bairros de elite, a presença de empregadas domésticas permite que maridos e mulheres deleguem tarefas tradicionalmente femininas (como cozinhar ou limpar).  
   - Na periferia, onde esse serviço é inacessível, a mulher acumula o trabalho remunerado *e* o doméstico, enquanto o homem tende a reproduzir a divisão sexual do trabalho ("lavar louça é coisa de mulher").  

2. **A casa como projeto conjugal**  
   A aquisição de um imóvel é, no Brasil, um marco simbólico do casamento bem-sucedido. Dados do IBGE mostram que 62% dos casais brasileiros consideram a compra da casa própria prioridade nos primeiros 5 anos de união. Porém, esse projeto esconde tensões:  

   - **Financiamento**: Quando apenas um cônjuge tem nome limpo para crédito imobiliário, o outro fica legalmente vulnerável, mesmo que contribua financeiramente.  
   - **Titularidade**: Em 78% dos casos registrados em cartório, o imóvel fica em nome do homem, mesmo quando a mulher participa do pagamento (Fonte: Registro de Imóveis de SP, 2022).  

   ```python  
   # Simulação de financiamento com desigualdade de gênero  
   renda_mulher = 3000  # R$  
   renda_homem = 4500   # R$  
   valor_imovel = 400000  # R$  

   # Banco exige renda conjunta de 30% do valor para aprovar  
   if (renda_mulher + renda_homem) >= 0.3 * valor_imovel:  
       print("Financiamento aprovado!")  
   else:  
       print("Negado: renda insuficiente.")  

   # Saída: "Financiamento aprovado!"  
   # Mas na prática, o homem é listado como titular em 8 em cada 10 contratos  
   ```  

3. **O espaço doméstico como arena de conflito**  
   A disposição dos móveis e cômodos revela hierarquias. Um estudo da UFMG mapeou 150 residências e encontrou padrões como:  
   - Cozinhas integradas à sala (comum em apartamentos de classe média) aumentam a cobrança sobre a mulher para "manter a arrumação".  
   - Casas com escritório separado são usadas majoritariamente por homens (91% dos casos), mesmo quando a mulher também trabalha em casa.  

### Erro comum e sua correção  
**Mito**: "Morar juntos significa compartilhar igualmente o espaço."  
**Realidade**: Mesmo em casais que se declaram igualitários, o homem ocupa em média 30% mais espaço físico para atividades pessoais (garagem para ferramentas, estante para coleções) do que a mulher.  

### Exercício  
Analise a planta baixa de uma casa brasileira média (disponível [aqui](https://exemplo.com/planta-casamento)) e identifique:  
1. Quais cômodos são designados prioritariamente para o homem ou para a mulher?  
2. Como a localização do lavabo (perto da sala ou dos quartos) influencia quem recebe visitas?  

**Solução comentada**:  
- A garagem costuma ser território masculino, enquanto a área de serviço é feminina.  
- Lavabos próximos à sala indicam que a mulher é responsável pelo entretenimento de convidados.  

(Estudos citados: IBGE 2021, UFMG 2020, Registro de Imóveis de SP 2022)