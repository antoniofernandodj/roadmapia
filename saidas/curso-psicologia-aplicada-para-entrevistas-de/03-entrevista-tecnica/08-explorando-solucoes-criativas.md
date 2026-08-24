## Explorando soluções criativas

O maior risco em entrevistas técnicas não é errar a resposta, é dar uma resposta genérica que se dissolve na multidão. Imagine dois candidatos respondendo à pergunta clássica *"Como você melhoraria o tempo de carregamento deste site?"*:

**Candidato A:**  
"Eu implementaria cache, comprimiria imagens e usaria um CDN."

**Candidato B:**  
"Antes de sair otimizando, eu mediria. Usaria o Lighthouse para identificar se o gargalo está no TTFB, renderização ou download. Já vi casos onde o problema era um terceiro script de analytics bloqueando a thread principal - substituí por um snippet assíncrono e ganhei 1.2s. Para imagens, testaria WebP com fallback para JPEG progressive load. Mas meu diferencial seria negociar com marketing: será que precisamos mesmo desse carrossel hero de 4MB?"

O entrevistador lembrará do B. Criatividade técnica não é inventar soluções mágicas, é mostrar pensamento adaptativo dentro de restrições reais.

### O ciclo da solução criativa

1. **Entenda o problema por trás da pergunta**  
   Perguntas técnicas avaliam como você pensa, não só o que sabe. Se perguntarem *"Como implementaria um carrinho de compras?"*, o subtexto é: você considera concorrência, atomicidade, falhas?

   Exemplo real de má interpretação:  
   *Candidato:* "Usaria um array para os itens e calcularia o total com reduce."  
   *Entrevistador:* "E se dois usuários adicionarem o mesmo item com estoque=1?"  
   *Candidato:* "Ah, não tinha pensado nisso..."

   Correção:  
   "Para evitar race conditions, usaria transações no banco de dados ou otimistic locking. No front, poderia implementar um reserva temporária enquanto finaliza a compra, como fazem as companhias aéreas."

2. **Mostre o leque de opções**  
   Criatividade é explorar alternativas antes de decidir. Para *"Como estruturaria uma lista de posts com likes?"*:

   - Opção 1: SQL tradicional com COUNT e GROUP BY
   - Opção 2: Materialized view atualizada assincronamente
   - Opção 3: Sistema de eventos com incremento em Redis
   - *"Escolheria a 3 para escalar, mas começaria com a 1 por simplicidade, deixando o caminho aberto para migração."*

3. **Incorpore aprendizados reais**  
   Dê vida à teoria com casos concretos (sem expor segredos):

   *"Uma vez reduzimos 30% do uso de memória trocando o formato de serialização de JSON para MessagePack, mas tivemos que pesar a legibilidade nos logs. Hoje, em um cenário com microserviços, talvez optasse por gRPC."*

### Armadilhas comuns

- **Ficção científica**: "Criaria uma IA que prevê o estoque" (sem explicar como)  
  Melhor: *"Testaria um modelo simples de regressão linear com dados históricos antes de investir em soluções complexas."*

- **Solução de balcão**: "Só refatoraria tudo em Rust"  
  Melhor: *"Começaria identificando os hotspots com profiling. Já migrei um módulo crítico para Rust usando WebAssembly, mas o deploy foi 10x mais caro que otimizar o JavaScript existente."*

### Exercício prático

**Pergunta:** "Como você implementaria um sistema de buscas por tags em um blog?"

Solução básica:  
```sql
SELECT * FROM posts 
WHERE tags LIKE '%javascript%';
```

**Desafio:** Melhore considerando:
- Performance com milhões de posts
- Busca por múltiplas tags
- Relevância (posts com mais tags correspondentes primeiro)

**Solução comentada:**  
"Primeiro, normalizaria o modelo para evitar LIKE, que é O(n):"

```sql
-- Estrutura otimizada
CREATE TABLE posts (
  id SERIAL PRIMARY KEY
);

CREATE TABLE tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE
);

CREATE TABLE post_tags (
  post_id INT REFERENCES posts(id),
  tag_id INT REFERENCES tags(id),
  PRIMARY KEY (post_id, tag_id)
);

-- Busca eficiente
SELECT p.* FROM posts p
JOIN post_tags pt ON p.id = pt.post_id
JOIN tags t ON pt.tag_id = t.id
WHERE t.name IN ('javascript', 'react')
GROUP BY p.id
ORDER BY COUNT(pt.tag_id) DESC;
```

"Para escalar, adicionaria um índice invertido no Elasticsearch, mantendo o Postgres como fonte da verdade. Já implementei um sistema assim onde o cache de tags populares em Redis reduziu 80% das consultas."