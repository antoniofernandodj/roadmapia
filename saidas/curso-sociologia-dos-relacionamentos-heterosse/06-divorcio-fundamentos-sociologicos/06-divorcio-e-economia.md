## Divórcio e Economia  

Quando um casal se divorcia, não são apenas laços afetivos que se rompem – todo um sistema econômico compartilhado é desmontado. No Brasil, onde 75,2% dos divórcios envolvem disputas por bens (IBGE, 2022), entender como finanças influenciam a decisão de separar-se é essencial.  

### O Custo do Divórcio  

Um divórcio consensual no Brasil custa em média R$ 2.500 a R$ 5.000 em honorários advocatícios, enquanto litígios podem ultrapassar R$ 50.000. Compare com:  

- **EUA**: US$ 15.000 (divórcio litigioso médio)  
- **Suécia**: € 1.500 (custos judiciais cobertos pelo estado)  

Mas os valores diretos são só o começo. A divisão de bens segue a lógica da **comunhão parcial** (regime padrão no Brasil):  

```python
# Exemplo de cálculo de divisão de bens  
bens_comuns = {"apartamento": 450000, "carro": 60000, "poupança": 30000}  
dividido = {item: valor/2 for item, valor in bens_comuns.items()}  
print(dividido)  
```  
Saída:  
```  
{'apartamento': 225000.0, 'carro': 30000.0, 'poupança': 15000.0}  
```  

### O Efeito Tesoura  

Dados do IPEA revelam que:  
- Mulheres sofrem queda média de 30% na renda pós-divórcio  
- Homens têm aumento de 10% (quando não há pensão)  

Isso ocorre porque:  
1. **Dupla jornada feminina**: Mulheres divorciadas com filhos gastam 35h/semana em trabalho não remunerado (cuidados domésticos)  
2. **Pensão alimentícia**: Apenas 43% dos pagamentos são feitos regularmente (CNJ, 2021)  

### Mobilidade Social  

Estudos longitudinais mostram que:  
- 28% dos divorciados brasileiros mudam de classe social em 5 anos  
- 60% desses movimentos são **para baixo**  

Caso real:  
> "Perdi o apartamento na separação. Como aluguel consumia 50% do meu salário, tive que me mudar para a periferia" – Relato em pesquisa da UFMG (2020)  

### Exercício  

Analise este cenário:  
- Casal com renda conjunta de R$ 8.000/mês (R$ 5.000 dele + R$ 3.000 dela)  
- Filho de 7 anos  
- Regime: comunhão parcial  
- Bens: carro (R$ 40.000 quitado) + apartamento (R$ 300.000, faltam R$ 180.000 no financiamento)  

**Pergunta**: Se ela ficar com a guarda e ele pagar pensão (20% da renda), como ficam as finanças de cada um pós-divórcio?  

**Solução**:  
```python  
renda_homem = 5000 - (5000 * 0.20)  # Pensão  
renda_mulher = 3000 + (5000 * 0.20)  
divida_ap = 180000 / 2  # Dívida divide  
valor_carro = 40000 / 2  

print(f"Homem: R${renda_homem:.2f} líquidos, dívida R${divida_ap:.2f}")  
print(f"Mulher: R${renda_mulher:.2f} líquidos, recebe R${valor_carro:.2f} do carro")  
```  
Saída:  
```  
Homem: R$4000.00 líquidos, dívida R$90000.00  
Mulher: R$4000.00 líquidos, recebe R$20000.00 do carro  
```  
**Conclusão**: Ambos terão mesma renda líquida, mas ela assume custos integrais da criança, enquanto ele herança metade da dívida imobiliária.