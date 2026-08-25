## Ética em Ciência da Computação

Um algoritmo de reconhecimento facial usado por departamentos policiais apresenta 90% de precisão para rostos brancos, mas apenas 65% para rostos negros. Essa disparidade não é um erro técnico — é um *problema ético* embutido no design do sistema. A ciência da computação lida com um tipo único de responsabilidade moral: quando códigos tomam decisões que afetam milhões, a ética precisa estar na arquitetura do software, não apenas nas intenções dos programadores.

### O que torna a ética computacional diferente?

Em outras áreas, como a medicina, os princípios éticos são consolidados há séculos (Hipócrates, Declaração de Helsinki). Na computação, três fatores criam desafios específicos:

1. **Escala automática**: Um algoritmo mal projetado pode replicar injustiças em milhões de casos antes que alguém perceba. Exemplo: sistemas de crédito que perpetuam discriminação racial através de proxies como CEP.
   
   ```python
   # Modelo fictício de aprovação de crédito com viés embutido
   def aprova_credito(renda, cep):
       if cep in zonas_ricas:  # Zonas historicamente brancas
           return renda > 3000
       else:
           return renda > 5000  # Barreira mais alta para outras áreas
   ```
   Saída real em um caso similar (ProPublica, 2016):
   ```
   Taxa de falsos positivos (liberar para inadimplentes):
   - Brancos: 23.5%
   - Negros: 44.9%
   ```

2. **Opacidade técnica**: Mesmo os criadores de sistemas de deep learning frequentemente não conseguem explicar como a IA toma certas decisões. Isso viola o princípio ético da *explicabilidade*.

3. **Dualidade radical**: Uma mesma tecnologia pode diagnosticar câncer ou criar deepfakes para difamação. O código é moralmente neutro, mas suas aplicações nunca são.

### Princípios operacionais

A ética em computação não se resume a listas de boas intenções. Requer frameworks implementáveis:

1. **Auditoria algorítmica**: Testar sistemas com dados desbalanceados *antes* da implantação. Exemplo prático:

   ```python
   def testa_viés(modelo, dados_teste):
       resultados = {}
       for grupo in ['homens', 'mulheres', 'brancos', 'negros']:
           subconjunto = dados_teste[dados_teste['grupo'] == grupo]
           acuracia = modelo.score(subconjunto)
           resultados[grupo] = acuracia
       return resultados
   ```
   Saída esperada para um modelo justo:
   ```
   {'homens': 0.82, 'mulheres': 0.81, 'brancos': 0.83, 'negros': 0.82}
   ```

2. **Princípio da reversibilidade**: Todo sistema deve incluir um mecanismo para desfazer decisões automáticas. Isso é especialmente crítico em:
   - Sistemas judiciais preditivos
   - Contratação automatizada
   - Diagnósticos médicos por IA

3. **Transparência escalonada**: Diferentes níveis de explicação conforme o público:
   - Usuário: "Seu crédito foi negado devido a baixa pontuação em relação a sua região"
   - Auditor: "O modelo ponderou CEP com peso 0.4 na decisão"
   - Desenvolvedor: Código fonte e dados de treinamento disponíveis

### O erro mais comum (e como corrigir)

A falácia do "lixo entra, lixo sai" ignora que vieses nos dados refletem injustiças do mundo real. Um dataset "realista" pode ser antiético. Correção:

```python
# ANTES (treinando com dados enviesados)
modelo.fit(dados_historicos)

# DEPOIS (abordagem ética)
dados_balanceados = aplicar_oversampling(
    dados_historicos,
    grupos_minoritarios
)
modelo_justo = TreinaComPenalidadePorViés(
    dados_balanceados,
    lambda: penalidade_por_desigualdade
)
```

Mensagem de erro típica em sistemas não auditados:
```
Warning: Detected 4x higher false positive rate for protected class
```

### Caso concreto: Alocação de vagas de estacionamento

Um município implementa um sistema inteligente para vagas prioritárias. O algoritmo original usa:
- Idade
- Histórico de multas
- Distância até hospitais

Problema: idosos em bairros pobres têm menos acesso a carros e registros formais de saúde. Solução ética:

1. Adicionar indicadores alternativos (visitas a postos de saúde)
2. Limitar peso do histórico de multas (enviesado por fiscalização desigual)
3. Garantir revisão humana para casos limítrofes

```python
def aloca_vaga_prioritaria(cidadao):
    pontos = 0
    pontos += 0.3 * normaliza(cidadao.idade, max=100)
    pontos += 0.2 * min(cidadao.visitas_saude / 10, 1)
    pontos -= 0.1 * min(cidadao.multas, 3)  # Peso limitado
    if 0.4 < pontos < 0.6:
        return revisao_manual(cidadao)
    return pontos > 0.5
```

### Exercício: Chatbot de atendimento ao público

Um chatbot governamental para informações sobre auxílio-desemprego está:
- Respondendo rapidamente perguntas em linguagem formal
- Falhando em entender variações linguísticas de regiões pobres

**Tarefa**: Proponha um protocolo de teste ético para identificar e corrigir vieses linguísticos. Inclua:

1. Método de coleta de dados representativos
2. Métrica de desempenho por grupo sociolinguístico
3. Mecanismo de fallback para casos de baixa confiança

**Solução comentada**:

```python
class TesteEticoChatbot:
    def __init__(self):
        self.dialetos = coleta_amostras_regionais()
        self.metricas = {}
    
    def roda_testes(self):
        for regiao, frases in self.dialetos.items():
            acertos = 0
            for frase in frases:
                resposta = chatbot.processa(frase)
                if valida_resposta(resposta, frase):
                    acertos += 1
            self.metricas[regiao] = acertos / len(frases)
        
        if min(self.metricas.values()) < 0.7:
            implementa_fallback_humano()
```

Princípios aplicados:
- Representatividade ativa na coleta de dados
- Limiar mínimo de desempenho para todos os grupos
- Correção proativa quando detectado viés