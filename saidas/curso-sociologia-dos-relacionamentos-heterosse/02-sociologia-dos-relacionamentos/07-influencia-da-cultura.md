## Influência da Cultura

Um casal brasileiro planeja o casamento. Ele quer uma festa simples no civil; ela sonha com 200 convidados, igreja e vestido de princesa. O conflito não é sobre gostos pessoais, mas sobre **scripts culturais** internalizados – modelos de comportamento que aprendemos como "o certo" desde a infância. 

### O que a Cultura Faz com Seus Relacionamentos

Cultura opera em três níveis nos relacionamentos heterossexuais:

1. **Ritualização** (como se faz):  
   No Brasil, o pedido de casamento com joias é norma – tente propor sem anel e ouvirá "Mas não vai pedir direito?". Compare com:  
   - Japão: famílias negociam casamentos arranjados em encontros formais (omiai)  
   - Suécia: 25% dos casais coabitam sem jamais formalizar a união  

   ```python
   # Simulador de aceitação social para rituais de casamento
   def aceitacao_ritual(pais, ritual):
       normas = {
           'BR': ['anel_compromisso', 'vestido_branco', 'padrinho'],
           'SE': ['cohabitacao', 'separacao_bens'],
           'JP': ['omiai', 'cerimonia_xintoista']
       }
       return ritual in normas.get(pais, [])
   
   print(aceitacao_ritual('BR', 'festa_seresta'))  # False - não é script cultural dominante
   ```

2. **Hierarquia de Valores**:  
   Pesquisa Datafolha (2022) mostra o que brasileiros priorizam em relacionamentos:  
   - 61% fidelidade  
   - 23% compatibilidade sexual  
   - 11% divisão igualitária de tarefas  
   Esses percentuais invertem-se na França, onde reciprocidade emocional lidera.

3. **Mecanismo de Punição/Recompensa**:  
   Quando um homem diz "minha esposa não cozinha bem", a reação social varia brutalmente por cultura:  
   - Brasil: "Coitado, passa fome?" (ridicularização)  
   - Itália: "Ensina ela, não é difícil" (pressão educativa)  
   - Noruega: "E você, cozinha o quê?" (contra-ataque)  

### Case: Por que Brasileiras se Casam de Branco

A tradição do vestido branco, importada da rainha Vitória em 1840, só se consolidou no Brasil nos anos 1950 com:  
1. **Hollywood**: Filmes mostrando noivas glamourosas  
2. **Indústria Têxtil**: Campanhas associando branco à pureza  
3. **Igreja Católica**: Endosso como símbolo de castidade  

Um experimento social atual:  
- Noiva usando vermelho em casamento urbano: "ousada!"  
- Mesmo vestido no interior conservador: "desrespeitosa"  

### O Erro Cultural mais Comum

Assumir que **seu** modelo cultural é universal. Exemplo clássico:  
- Brasileiro acha natural comemorar 6 meses de namoro  
- Alemão considera isso excessivo ("Por que não esperar 1 ano?")  

Quando o conflito surge, a reação típica é:  
```python
reacao = lambda cultura: "Eles são frios" if cultura == 'estrangeira' else "Nós somos intensos"
```
Isso gera o fenômeno **choque cultural conjugal** – a decepção quando o parceiro não segue seu manual invisível.

### Exercício Prático

Analise este diálogo real de um fórum de relacionamentos:  

**Caso**:  
"Meu namorado alemão esqueceu nosso aniversário de 3 meses. Disse que na cultura dele só comemoram anos. Devo terminar?"  

**Solução passo a passo**:  
1. Identifique os scripts em conflito:  
   - BR: Celebração de meses como prova de amor  
   - DE: Eventos anuais como marco suficiente  

2. Decodifique o significado real:  
   - Para ela: "Ele não valoriza nossa relação"  
   - Para ele: "Estou poupando energia para o que importa"  

3. Proposta de resolução:  
   - Negociar um ritual híbrido (ex.: mensagens românticas mensais + presentes anuais)  
   - Estabelecer quais marcos são importantes para **ambos**  

```python
def resolver_conflito_cultural(origem1, origem2, evento):
    hibridos = {
        ('BR','DE'): {'aniversario': 'mensagens + presente_anual'},
        ('JP','BR'): {'natal': 'jantar_familia + troca_obon'}
    }
    return hibridos.get((origem1, origem2), {}).get(evento, "Dialogar sobre expectativas")
```

**Saída esperada**:  
`'mensagens + presente_anual'` – uma solução que preserva as necessidades emocionais de ambos sem imposição cultural.