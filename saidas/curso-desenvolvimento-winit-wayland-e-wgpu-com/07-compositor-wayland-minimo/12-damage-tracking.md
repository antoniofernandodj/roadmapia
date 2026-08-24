## Damage Tracking

Em um compositor Wayland, o **damage tracking** (rastreamento de regiões danificadas) é essencial para otimizar a renderização. Quando um cliente altera parte de uma surface, apenas as regiões modificadas ("damaged") precisam ser redesenhadas. Implementar isso corretamente evita redesenhar toda a tela a cada frame, economizando recursos de CPU e GPU.

### O Problema Básico

Suponha que temos uma surface de 800x600 pixels. Se o cliente modifica apenas um retângulo de 100x100 pixels no canto superior esquerdo, redesenhar toda a surface seria um desperdício. Precisamos rastrear apenas a região danificada (100x100) e atualizar o buffer correspondente.

### Implementação Básica

1. **Estrutura de Dados**: Começamos com um `DamageTracker` que armazena regiões danificadas como retângulos (x, y, largura, altura). Usamos um `Vec<Rectangle>` para armazenar múltiplas regiões.

   ```rust
   pub struct DamageTracker {
       regions: Vec<Rectangle>,
   }
   ```

2. **Acumulação de Danos**: Quando um cliente marca uma região como danificada, adicionamos ao tracker.

   ```rust
   pub fn add_damage(&mut self, rect: Rectangle) {
       self.regions.push(rect);
   }
   ```

3. **Limpeza de Danos**: Após o frame ser renderizado, limpamos as regiões acumuladas.

   ```rust
   pub fn clear_damage(&mut self) {
       self.regions.clear();
   }
   ```

### Erros Comuns

- **Regiões Não Limpas**: Se esquecer de chamar `clear_damage`, os danos acumulam-se indevidamente, causando redesenho desnecessário.

- **Regiões Sobrepostas**: Se duas regiões danificadas se sobrepõem, devem ser mescladas para evitar redundância.

### Exemplo Prático

Suponha que um cliente move um retângulo de (100,100) para (200,200). Marcamos apenas a região movida como danificada:

```rust
damage_tracker.add_damage(Rectangle::new(100, 100, 100, 100));
damage_tracker.add_damage(Rectangle::new(200, 200, 100, 100));
```

Ao renderizar, apenas essas duas regiões são redesenhadas, economizando recursos.

### Exercício Final

Implemente um `DamageTracker` que:

1. Aceite regiões danificadas.
2. Mescle regiões sobrepostas.
3. Limpe danos após renderização.