## Influência da Política  

Quando um casal discute sobre divisão de tarefas domésticas, a conversa raramente começa com "o Estado influencia nossas escolhas". Mas políticas públicas moldam diretamente quem lava a louça, quem cuida dos filhos e até quem pode terminar um relacionamento.  

### Como as Leis Definem Poder Dentro dos Relacionamentos  

A CLT (Consolidação das Leis do Trabalho) garante licença-maternidade de 120 dias no Brasil, enquanto a licença-paternidade é de apenas 5 dias (20 dias em algumas empresas). Isso cria um desequilíbrio automático:  

1. **Reforço de papéis de gênero**: Com mais tempo em casa, a mulher assume naturalmente mais responsabilidades de cuidado, mesmo que o casal queira dividir igualmente.  
2. **Impacto na carreira**: A ausência prolongada do trabalho pressiona a mulher a priorizar a família, enquanto o homem mantém sua trajetória profissional ininterrupta.  

*Exemplo prático*:  

```python
class Casal:
    def __init__(self, parceiro_a, parceiro_b):
        self.licenca_maternidade = 120  # dias
        self.licenca_paternidade = 5    # dias

    def divisao_tarefas(self):
        if self.licenca_maternidade > self.licenca_paternidade:
            return "Parceiro A assume 73% das tarefas domésticas*"
        else:
            return "Divisão equilibrada"

casal_hetero = Casal("mulher", "homem")
print(casal_hetero.divisao_tarefas())  
```  

*Saída*:  
`Parceiro A assume 73% das tarefas domésticas*`  

*(*Dado real do IBGE, 2019)*  

### Políticas de Divórcio e Autonomia Financeira  

Até 1977, o divórcio era proibido no Brasil. Mesmo após legalizado, a Lei do Divórcio (nº 6.515/77) inicialmente exigia:  
- Separação judicial prévia por 1 ano  
- Apenas uma chance de divórcio por vida  

Isso mantinha casais em relacionamentos fracassados, muitas vezes por dependência econômica. A Emenda Constitucional nº 66/2010 eliminou esses requisitos, impactando diretamente:  

- **Taxa de divórcios**: Saltou de 1,8 para 3,1 por mil habitantes em 5 anos (IBGE).  
- **Casamentos subsequentes**: 30% dos divórcios em 2019 envolveram divisão de bens, afetando decisões de novos casamentos.  

### Impostos e Status Conjugal  

A declaração conjunta de IR permite isenções, mas penaliza mulheres em certos casos:  

| Situação               | Homem (R$) | Mulher (R$) |  
|------------------------|------------|------------|  
| Solteiro               | 2.500      | 2.500      |  
| Casado (declaração conjunta)| 3.000      | **1.800*** |  

*(*Valores fictícios ilustrando a disparidade comum quando um cônjuge tem renda menor)*  

### Exercício Prático  

**Cenário**: Um projeto de lei propõe igualar licenças parentais para 60 dias.  

1. Liste 3 efeitos imediatos em relacionamentos heterossexuais:  
   - [ ] Redução da pressão sobre mulheres na escolha de carreira  
   - [ ] Aumento de conflitos sobre divisão de cuidados com filhos  
   - [ ] Mudança na percepção de "trabalho de mãe" vs. "trabalho de pai"  

2. Qual seria um efeito colateral econômico?  
   - [ ] Aumento de custos para empregadores  
   - [ ] Redução de impostos para famílias  
   - [ ] Nenhum impacto  

*Solução*:  

1. Todos os itens estão corretos. A igualização força uma renegociação de papéis, podendo gerar tensões iniciais (item 2), mas também oportunidades de equilíbrio (itens 1 e 3).  

2. O efeito colateral direto é o aumento de custos para empresas (item 1), que precisarão cobrir salários durante as licenças estendidas. Países como Suécia compensam isso com incentivos fiscais.