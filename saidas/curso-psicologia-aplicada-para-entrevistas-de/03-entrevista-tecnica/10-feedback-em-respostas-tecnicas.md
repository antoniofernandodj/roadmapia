## Feedback em respostas técnicas

Você acabou de sair de uma entrevista técnica onde explicou um conceito complexo, mas o entrevistador fez uma cara confusa e mudou de assunto rapidamente. O que deu errado? Como melhorar sem repetir o mesmo erro na próxima? A resposta está no **ciclo de feedback**, a ferramenta que transforma respostas técnicas medianas em explicações de alto impacto.

### O que acontece quando falta feedback

Imagine esta cena real:

**Entrevistador:** "Como você resolveria um problema de concorrência em um banco de dados?"  
**Candidato:** "Usaria transactions com isolation level Serializable para evitar dirty reads."  
*Silêncio. O entrevistador anota algo rapidamente e pula para a próxima pergunta.*

O problema aqui não é o conteúdo técnico - a resposta está correta. Mas o candidato **não percebeu** que:

1. O entrevistador franziu a testa ao ouvir "Serializable" (pode ser overkill para o caso)
2. Não exemplificou com um cenário real
3. Não explicou as alternativas (como Read Committed)

Sem captar essas pistas, o candidato perde a chance de ajustar sua resposta em tempo real.

### Como coletar feedback durante a entrevista

Existem três tipos de sinais que você deve monitorar:

1. **Verbais explícitos**:  
   "Não entendi essa parte sobre dirty reads" → pedido claro para reexplicar

2. **Verbais sutis**:  
   "Hum... interessante" com tom hesitante → dúvida não expressa

3. **Não-verbais**:  
   - Entrevistador consultando o relógio → perdendo interesse  
   - Aproximação do corpo para frente → engajamento na explicação  

**Técnica de verificação**: A cada 2-3 frases técnicas, insira um gancho como:  
"Fez sentido até aqui ou quer que eu detalhe alguma parte específica?"  

Isso dá ao entrevistador a abertura para direcionar seu foco.

### Transformando feedback em respostas melhores

Quando identificar um sinal de confusão, aplique o **método LER**:

1. **Legitimizar**: "É uma ótima pergunta, muitos se confundem nesse ponto"  
2. **Exemplificar**: "Vou mostrar com um caso que enfrentei no projeto X..."  
3. **Reformular**: "Em outras palavras, o que acontece é..."

Veja a diferença na prática:

**Antes (sem feedback):**  
"O algoritmo tem complexidade O(n²) porque..."

**Depois (com ajuste):**  
*[Notando expressão confusa]*  
"Posso reexplicar a complexidade com um exemplo? Imagine que..."  
*[Desenha no ar]*  
"É como ter que comparar cada item com todos os outros - por isso n vezes n."

### Erros comuns e correções

1. **Ignorar sinais não-verbais**  
   *Erro:* Continuar falando por 5 minutos enquanto o entrevistador olha para o celular  
   *Correção:* "Gostaria que eu fosse mais direto ao ponto ou prefere os detalhes técnicos?"

2. **Defender-se do feedback**  
   *Erro:* "Mas no meu curso ensinaram assim!"  
   *Correção:* "Entendo sua preocupação, na época fizemos testes com..."

3. **Excesso de ajustes**  
   *Erro:* Mudar completamente a resposta a cada olhar confuso  
   *Correção:* Manter o núcleo técnico, só adaptar a forma de explicar

### Exercício prático

Analise esta troca real e identifique 3 oportunidades perdidas de feedback:

**Entrevistador:** "Explique como funciona HTTPS."  
**Candidato:** "Usa TLS sobre HTTP com handshake assimétrico para criptografar-"  
**Entrevistador:** *[Interrompe]* "Ok, e se o certificado estiver vencido?"  
**Candidato:** "Aí mostra aquela tela vermelha no browser."  
**Entrevistador:** *[Suspira]* "Vamos para a próxima..."

**Solução comentada:**

1. **Primeira pista**: Interrupção abrupta → sinal de explicação muito técnica  
   *Ajuste:* "Quer que eu comece com uma visão mais geral antes dos detalhes?"

2. **Segunda pista**: Pergunta sobre caso específico (certificado) → interesse nesse tópico  
   *Ajuste:* "Sobre certificados, posso detalhar o fluxo completo de validação?"

3. **Terceira pista**: Suspiro → frustração com resposta curta  
   *Ajuste:* "Além da tela vermelha, o browser faz X, Y, Z para proteger o usuário..."

### O poder do feedback estruturado

Após cada entrevista técnica, anote:

1. Quais perguntas geraram mais dúvidas no entrevistador  
2. Em quais momentos você percebeu desatenção  
3. Que termos técnicos precisaram ser reexplicados  

Com esse registro, você cria um **mapa de pontos cegos** na sua comunicação técnica. Na próxima entrevista, já começa antecipando essas necessidades de explicação.