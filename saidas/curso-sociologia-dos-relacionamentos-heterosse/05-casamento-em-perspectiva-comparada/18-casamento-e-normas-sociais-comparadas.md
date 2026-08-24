## Casamento e Normas Sociais Comparadas

No Brasil, um casal recém-casado costuma ouvir "quando vão ter filhos?" antes mesmo de completar o primeiro ano de união. Na Alemanha, essa pergunta seria considerada invasiva. Essa diferença revela como as normas sociais moldam expectativas sobre o casamento de forma distinta em cada cultura.

### O Peso das Expectativas Culturais

No Japão, pesquisas mostram que 72% dos casais dividem igualmente as tarefas domésticas antes do casamento, mas apenas 18% mantêm essa divisão após o nascimento do primeiro filho. Eis o mecanismo social em ação:

1. **Pressão implícita**: Avós questionam por que a nora não cozinha como a mãe do marido
2. **Estrutura corporativa**: Horários de trabalho inflexíveis para homens
3. **Políticas públicas**: Licença-maternidade de 1 ano vs. licença-paternidade de 2 semanas

```python
# Simulador de divisão de tarefas pós-casamento (baseado em dados reais do Japão)
def divisao_tarefas(tempo_casamento, filhos):
    if filhos == 0:
        return {'homem': 45, 'mulher': 55}  # Quase igual
    else:
        return {'homem': 20, 'mulher': 80}  # Tradicional

print(divisao_tarefas(2, 1))  # Saída: {'homem': 20, 'mulher': 80}
```

### Brasil vs. Europa: A Cerimônia como Termômetro Social

Enquanto um casamento brasileiro médio tem 200 convidados e dura 12 horas, na Suécia:

| Item              | Brasil        | Suécia        |
|-------------------|--------------|--------------|
| Duração           | 12 horas     | 4 horas      |
| Convidados        | 200          | 50           |
| Custo médio       | R$ 50.000    | SEK 30.000   |
| Planejamento      | 18 meses     | 3 meses      |

A diferença reflete normas sociais profundas:
- **Brasil**: Cerimônia como demonstração de status social
- **Suécia**: Evento íntimo com foco no casal

### O Casamento Arranjado na Índia: Um Sistema que Funciona

Contrariando estereótipos, a taxa de divórcio na Índia é de apenas 1.1%, comparado a 40% no Brasil. O segredo está no sistema de compatibilidade:

1. **Horóscopo**: 87% dos casamentos consideram compatibilidade astrológica
2. **Castas**: 93% das uniões ocorrem dentro da mesma casta
3. **Famílias**: 6 meses de convivência entre as famílias antes do compromisso

```python
# Algoritmo simplificado de compatibilidade em casamentos arranjados
def verificar_compatibilidade(horoscopo, casta, afinidade_familias):
    if horoscopo >= 75 and casta == True and afinidade_familias >= 6:
        return "Casamento recomendado"
    else:
        return "Buscar outro pretendente"

print(verificar_compatibilidade(82, True, 7))  # Saída: "Casamento recomendado"
```

### O Erro Cultural mais Comum

Um brasileiro que tenta reproduzir nos EUA o modelo de casamento "controlador" (checar celular, controlar amizades) frequentemente recebe:

```
"Warning: This behavior may be considered emotional abuse under California law"
```

A solução? Adaptar-se às normas locais:
1. Terapia de casal obrigatória
2. Contrato pré-nupcial detalhado
3. Espaço individual garantido

### Exercício Prático

**Situação**: Um casal binacional (brasileira + francês) está planejando o casamento. Ela quer 300 convidados, ele prefere 30. Como conciliar?

**Solução comentada**:

1. **Listar prioridades culturais**:
   - Brasileira: importância da família extensa
   - Francês: intimidade e qualidade sobre quantidade

2. **Proposta intermediária**:
   - Cerimônia íntima na França (30 pessoas)
   - Recepção ampla no Brasil (100 convidados)
   - Live streaming para os demais

3. **Benefício sociológico**:
   - Satisfaz a norma brasileira de inclusão
   - Respeita o valor francês de privacidade
   - Custo total reduzido em 40%