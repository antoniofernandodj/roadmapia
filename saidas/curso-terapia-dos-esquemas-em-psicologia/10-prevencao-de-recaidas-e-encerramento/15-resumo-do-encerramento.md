## Resumo do Encerramento

O encerramento em Terapia dos Esquemas não é um simples "fim", mas uma etapa ativa de consolidação. Imagine um paciente que, após 18 meses de terapia, conseguiu reduzir significativamente o esquema de Abandono/Instabilidade (Domínio 1). Durante o processo, ele aprendeu a identificar os gatilhos, como conflitos no trabalho, e a usar técnicas de enfrentamento, como a carta ao esquema. Agora, na fase final, o trabalho se concentra em garantir que essas conquistas sejam duradouras.

**Como saber se o paciente está pronto para o encerramento?**  
1. **Redução dos sintomas**: Escala de Esquemas Young (YSQ-S3) mostra pontuação abaixo do limiar clínico  
   ```python
   # Exemplo de avaliação numérica (dados fictícios)
   esquema_abandono = {
       'inicio_terapia': 85,  # Escala 0-100
       '6_meses': 60,
       'encerramento': 30
   }
   print(f"Evolução do esquema: {esquema_abandono}")
   # Saída: Evolução do esquema: {'inicio_terapia': 85, '6_meses': 60, 'encerramento': 30}
   ```

2. **Recursos internalizados**: O paciente demonstra uso espontâneo de técnicas como:
   - Diálogo com modos saudáveis
   - Flashcards de enfrentamento
   - Plano de ação para situações de risco

Um erro comum é encerrar quando há apenas melhora sintomática, sem consolidar as mudanças. A mensagem clínica típica seria:  
_"Paciente relata 'estar bem', mas evita sistematicamente situações que antes ativavam o esquema (ex: não se candidata a promoções por medo de fracasso)"_.  
A solução? Incluir na fase final exposições graduais monitoradas.

**Elementos-chave do encerramento bem-sucedido**:  
- Revisão do diário terapêutico mostrando padrões de enfrentamento  
- Simulações de situações desafiadoras (role-play gravado)  
   ```python
   # Protocolo de simulação (adaptado)
   situacoes = ['conflito familiar', 'feedback no trabalho', 'rejeição amorosa']
   for idx, cenario in enumerate(situacoes, 1):
       print(f"{idx}. Paciente demonstra estratégias para: {cenario}")
   # Saída:
   # 1. Paciente demonstra estratégias para: conflito familiar
   # 2. Paciente demonstra estratégias para: feedback no trabalho
   # 3. Paciente demonstra estratégias para: rejeição amorosa
   ```

**Exercício Prático**:  
Analise este extrato de sessão final e identifique se há indícios de preparo para encerramento:  

_"Paciente relatou discussão com parceiro sem recorrer a comportamentos de subjugação (Domínio 4). Trouxe registro de ter usado respiração diafragmática quando percebeu ativação do esquema. Questionado sobre possíveis recaídas, elaborou plano concreto: 'Se me sentir sobrecarregado, vou ligar para meu irmão antes de tomar decisões impulsivas'."_  

**Solução Comentada**:  
1. **Evidência de mudança**: Uso ativo de técnica respiratória e não subjugação  
2. **Consciência de gatilhos**: Reconheceu a ativação do esquema  
3. **Plano preventivo**: Estratégia específica com apoio social identificado  
4. **Indicador positivo**: Relato espontâneo de situação real bem manejada  

O encerramento efetivo ocorre quando o paciente transforma o conhecimento terapêutico em ações autônomas, como demonstrado no caso acima. Os protocolos estruturados (ex: 3 sessões focais para revisão) ajudam a formalizar essa transição sem criar dependência do terapeuta.