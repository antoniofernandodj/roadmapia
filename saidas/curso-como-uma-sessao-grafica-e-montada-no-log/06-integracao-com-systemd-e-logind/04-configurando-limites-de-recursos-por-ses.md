## Configurando limites de recursos por sessão

Quando múltiplos usuários compartilham uma máquina Linux, é comum precisar controlar quanto CPU, memória ou outros recursos cada sessão gráfica pode consumir. O systemd, através de sua integração com o `systemd-logind`, oferece mecanismos nativos para essa finalidade sem exigir configurações complexas de cgroups.

**Problema prático:** Imagine um servidor de desenvolvimento com 3 engenheiros conectados simultaneamente via sessões gráficas. Se um deles roda um processo pesado de compilação, pode tornar as sessões dos outros praticamente inutilizáveis. 

A solução está no arquivo `/etc/systemd/logind.conf` e em arquivos de configuração específicos por usuário. Veja como limitar recursos para a sessão gráfica do usuário "desenvolvedor":

1. Crie um arquivo de configuração override:
```bash
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo nano /etc/systemd/system/user@.service.d/limits.conf
```

2. Adicione estes parâmetros (exemplo para limitar CPU e memória):
```ini
[Service]
CPUQuota=50%
MemoryLimit=4G
```

3. Recarregue as configurações:
```bash
sudo systemctl daemon-reload
```

**Como isso funciona na prática:**
- `CPUQuota=50%` garante que processos da sessão não usem mais que metade de um núcleo CPU
- `MemoryLimit=4G` impede que a sessão exceda 4GB de RAM

Para verificar os limites aplicados após o login:
```bash
systemd-run --scope --user sleep 1000 &
systemctl --user status $!
```

A saída mostrará algo como:
```
● run-r12345abc.scope
   Memory: 125.6M (limit: 4.0G)
   CPU: 12ms (limit: 50%)
```

**Erro comum:** Esquecer de recarregar as configurações após a modificação. Se fizer isso, verá:
```
Warning: user@1000.service changed on disk, configuration updates suppressed until reloaded.
```

**Tipos de limites disponíveis:**
- `TasksMax`: Número máximo de processos
- `IODeviceWeight`: Prioridade de acesso a dispositivos de armazenamento
- `BlockIO*`: Limites para operações de bloco

Para configurações temporárias (útil para testes), use o `systemd-run`:
```bash
systemd-run --scope --user --property=CPUQuota=30% --property=MemoryLimit=2G meu_script_pesado.sh
```

**Exercício:** Configure um limite de 30% de CPU e 2GB de RAM para seu usuário atual, faça login em uma nova sessão gráfica e verifique se os limites estão aplicados corretamente usando `systemctl status`.

**Solução comentada:**
1. Crie o arquivo de override:
```bash
mkdir -p ~/.config/systemd/user/user@.service.d
echo '[Service]
CPUQuota=30%
MemoryLimit=2G' > ~/.config/systemd/user/user@.service.d/limits.conf
```

2. Ative as mudanças:
```bash
systemctl --user daemon-reload
```

3. Verifique com:
```bash
systemd-run --scope --user sleep 300 &
systemctl --user status $!
```