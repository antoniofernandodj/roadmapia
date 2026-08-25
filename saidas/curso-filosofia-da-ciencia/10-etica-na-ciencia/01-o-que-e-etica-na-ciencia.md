## O que é Ética na Ciência?

Um laboratório de bioengenharia desenvolve uma técnica para edição genética em embriões humanos. A tecnologia funciona, mas surge a questão: *deveríamos* usá-la? Esse dilema não é sobre eficácia científica, mas sobre valores — e é aqui que a ética na ciência entra. Ela examina os princípios que guiam o que a ciência *pode* fazer versus o que ela *deve* fazer.

### O Mecanismo da Ética Científica
A ética na ciência opera em três níveis interligados:

1. **Intrínseco**: Valores embutidos no método científico. Por exemplo, a obrigação de reportar dados negativos em um estudo clínico, mesmo que prejudiquem os resultados esperados. Um pesquisador que omite falhas em um teste de medicamento viola esse princípio, comprometendo a integridade do conhecimento produzido.

2. **Extrínseco**: Impacto da ciência na sociedade. Considere o desenvolvimento de algoritmos de reconhecimento facial: a tecnologia em si pode ser matematicamente impecável, mas seu uso em vigilância em massa levanta questões sobre privacidade e discriminação.

3. **Procedural**: Regras que governam a prática científica. O caso clássico é o plagiarismo — copiar resultados de outros pesquisadores não é apenas antiético, mas corrói o sistema de revisão por pares.

### O Erro Mais Comum (e Seu Custo)
Muitos cientistas assumem que "se é tecnicamente possível, então é ético". Essa falácia ficou evidente no Experimento Tuskegee (1932-1972), onde pesquisadores americanos negaram tratamento para sífilis a homens negros sem seu consentimento, apenas para estudar a progressão da doença. O resultado foi não apenas um desastre humano, mas um dano duradouro à confiança pública na ciência.

```python
# Analogia em código: a lacuna entre "poder" e "dever"
def editar_genoma(embriao):
    if tecnica_disponivel():  # Pode fazer?
        return True
    elif impacto_social_aceitavel():  # Deve fazer?
        return "Requer revisão ética"
    else:
        raise EthicsViolation("Interrompido: risco de eugenia")

# Saída esperada ao testar um caso controverso:
>>> editar_genoma(embriao_humano)
"Requer revisão ética"
```

### Ferramentas da Ética Científica
Para navegar essas questões, a filosofia oferece estruturas:

- **Utilitarismo**: Avalia ações pelo benefício líquido à sociedade. Útil em debates sobre vacinas, onde o desconforto individual é superado pelo bem coletivo.
- **Deontologia**: Foca em deveres universais, como o princípio de nunca tratar pessoas como meios para fins científicos.
- **Ética da Virtude**: Examina o caráter do cientista — honestidade, humildade intelectual e coragem para questionar resultados próprios.

### Exercício Prático
Um artigo científico sobre inteligência artificial afirma: "Nosso modelo atingiu 94% de precisão". Ao revisar os dados suplementares, você descobre que a taxa cai para 68% em populações não ocidentais. Como agir?

**Solução ética:**
1. Reportar a discrepância aos editores da revista
2. Sugerir a inclusão da limitação no corpo do artigo
3. Propor testes adicionais com conjuntos de dados diversos

Ignorar o problema seria tecnicamente fácil, mas epistemicamente corrupto — distorceria o conhecimento disponível para outros pesquisadores.