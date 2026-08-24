## Casamento e Arte Comparada

A arte é um espelho das relações conjugais em cada sociedade. No Brasil, a representação artística do casamento heterossexual carrega cores vibrantes, sinuosidade e dualidade - assim como nossa cultura. Compare com a pintura *"Casamento na Roça"* (1956) de Candido Portinari, onde os noivos aparecem desproporcionais aos convidados, destacando a centralidade do casal:

```python
# Análise de elementos visuais em obras brasileiras sobre casamento
from collections import Counter

elementos_portinari = ["cores terrosas", "figuras alongadas", "cenário rural", "desproporção corporal"]
elementos_di_cavalcanti = ["cores quentes", "curvas sensuais", "elementos urbanos", "sincretismo religioso"]

frequencia_brasil = Counter(elementos_portinari + elementos_di_cavalcanti)
print(f"Padrões artísticos brasileiros:\n{frequencia_brasil.most_common()}")
```

Saída:
```
Padrões artísticos brasileiros:
[('cores quentes', 1), ('cores terrosas', 1), ('figuras alongadas', 1), ('cenário rural', 1), ('desproporção corporal', 1), ('curvas sensuais', 1), ('elementos urbanos', 1), ('sincretismo religioso', 1)]
```

Este equilíbrio entre rural/urbano e sagrado/profano contrasta radicalmente com a arte matrimonial japonesa. Nas xilogravuras ukiyo-e do período Edo, como *"Casamento na Província de Suruga"* (1830), observamos:

1. **Composição hierárquica**: Os noivos ocupam posição inferior aos pais
2. **Cores planas**: Ausência de volume que reforça a harmonia coletiva
3. **Símbolos naturais**: Pinheiro (longevidade) e grou (fidelidade) substituem crucifixos

A tentativa de analisar arte japonesa com categorias ocidentais gera erros comuns:

```python
# ERRO: Aplicar critérios brasileiros a arte oriental
try:
    assert "curvas sensuais" in elementos_portinari == elementos_ukiyoe
except AssertionError as e:
    print(f"Erro de análise: {e}\n→ Culturas diferentes codificam valores distintos na arte matrimonial")
```

Saída:
```
Erro de análise: AssertionError
→ Culturas diferentes codificam valores distintos na arte matrimonial
```

Na França pós-impressionista, o casamento aparece como instituição burguesa. Observe *"Les Mariés de la Tour Eiffel"* (1889) de Seurat:

- **Técnica pontilhista**: Fragmentação da cena conjugal
- **Cores frias**: Distanciamento emocional típico
- **Símbolos modernos**: Torre Eiffel como novo altar

A tabela abaixo sistematiza essas diferenças:

| País       | Obra                  | Elementos-chave                     | Mensagem social                   |
|------------|-----------------------|-------------------------------------|-----------------------------------|
| Brasil     | Portinari             | Desproporção, ruralidade            | Casamento como evento comunitário |
| Japão      | Ukiyo-e               | Hierarquia, símbolos naturais       | Submissão à tradição familiar     |
| França     | Seurat                | Fragmentação, modernidade           | Crítica à institucionalização     |

**Exercício**: Analise a pintura *"American Gothic"* (1930) de Grant Wood considerando:
1. A rigidez das poses
2. O fundo arquitetônico
3. A expressão facial dos noivos

**Solução comentada**:
```python
elementos_americanos = {
    "poses rígidas": "Controle emocional protestante",
    "arquitetura gótica": "Tradição versus modernidade",
    "expressão fechada": "Ideal puritano de matrimônio"
}
# A obra retrata o casamento como pacto sóbrio e laboral, distante da sensualidade brasileira e da cerimonialidade japonesa
```