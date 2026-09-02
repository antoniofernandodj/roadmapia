## Unidades systemd relevantes para sessões gráficas

Quando você inicia uma sessão gráfica no Linux, vários componentes precisam ser carregados na ordem correta: o gerenciador de login, o servidor gráfico (Xorg ou Wayland), o ambiente de desktop e os aplicativos de sessão. O systemd é responsável por coordenar esse processo, garantindo que cada serviço seja iniciado apenas quando suas dependências estiverem prontas. Para isso, ele utiliza unidades específicas que controlam o fluxo de inicialização gráfica. Vamos explorar as mais importantes.

### `display-manager.service`

O `display-manager.service` é a unidade que inicia o gerenciador de login, como GDM, LightDM ou SDDM. Ele é o ponto de entrada para a sessão gráfica. Quando você ativa o `graphical.target`, o systemd automaticamente habilita o `display-manager.service` para carregar o gerenciador de login configurado.

Para verificar o status do serviço:

```bash
systemctl status display-manager.service
```

Se o serviço falhar, você verá uma mensagem como:

```
● display-manager.service - Display Manager
   Loaded: loaded (/usr/lib/systemd/system/display-manager.service; enabled; vendor preset: enabled)
   Active: failed (Result: exit-code) since Tue 2023-10-10 14:30:00 UTC; 5min ago
  Process: 1234 ExecStart=/usr/bin/gdm (code=exited, status=1/FAILURE)
 Main PID: 1234 (code=exited, status=1/FAILURE)
```

Neste caso, você pode reiniciar o serviço com:

```bash
sudo systemctl restart display-manager.service
```

### `graphical.target`

O `graphical.target` é o alvo (target) que representa o estado final de uma sessão gráfica completa. Ele depende de várias outras unidades, incluindo o `display-manager.service`. Quando você inicia o sistema em modo gráfico, o systemd ativa o `graphical.target`, que por sua vez inicia todos os serviços necessários.

Para verificar se o sistema está rodando no `graphical.target`:

```bash
systemctl get-default
```

Se o sistema estiver configurado para iniciar em modo gráfico, o comando retornará:

```
graphical.target
```

Se você quiser mudar para o modo gráfico manualmente, use:

```bash
sudo systemctl isolate graphical.target
```

### `xorg.service`

Se você estiver usando o Xorg como servidor gráfico, o `xorg.service` é responsável por inicializá-lo. Ele depende do `display-manager.service` para garantir que o gerenciador de login esteja funcionando antes de tentar carregar o Xorg.

Para verificar o status do `xorg.service`:

```bash
systemctl status xorg.service
```

Se o serviço estiver falhando, você pode tentar reiniciá-lo:

```bash
sudo systemctl restart xorg.service
```

### `wayland.service`

Para sistemas que utilizam Wayland, o `wayland.service` desempenha um papel semelhante ao `xorg.service`. Ele gerencia a inicialização do servidor Wayland e depende do `display-manager.service` para funcionar corretamente.

Para verificar o status do `wayland.service`:

```bash
systemctl status wayland.service
```

Se você encontrar problemas, pode tentar reiniciar o serviço:

```bash
sudo systemctl restart wayland.service
```

### `dbus.service`

O `dbus.service` é essencial para a comunicação entre os componentes gráficos. Ele fornece o sistema de mensagens D-Bus, que é usado pelo gerenciador de login, servidor gráfico e ambiente de desktop para se comunicar.

Para garantir que o `dbus.service` esteja funcionando:

```bash
systemctl status dbus.service
```

Se o serviço estiver inativo, você pode iniciá-lo com:

```bash
sudo systemctl start dbus.service
```

### `systemd-logind.service`

O `systemd-logind.service` gerencia sessões de usuário, incluindo sessões gráficas. Ele monitora o estado de login dos usuários e gerencia recursos como limites de CPU e memória para processos gráficos.

Para verificar o status do `systemd-logind.service`:

```bash
systemctl status systemd-logind.service
```

Se o serviço estiver falhando, você pode tentar reiniciá-lo:

```bash
sudo systemctl restart systemd-logind.service
```

### Exercício Prático

Suponha que você configurou um novo ambiente gráfico usando LightDM e Wayland, mas a sessão não está iniciando corretamente. Use os comandos acima para diagnosticar e resolver o problema.

#### Solução Comentada

1. Verifique o status do `display-manager.service` para garantir que o LightDM está funcionando:

   ```bash
   systemctl status display-manager.service
   ```

2. Se o LightDM estiver falhando, reinicie o serviço:

   ```bash
   sudo systemctl restart display-manager.service
   ```

3. Verifique o status do `wayland.service` para garantir que o Wayland está sendo inicializado:

   ```bash
   systemctl status wayland.service
   ```

4. Se o Wayland estiver falhando, reinicie o serviço:

   ```bash
   sudo systemctl restart wayland.service
   ```

5. Certifique-se de que o `dbus.service` está ativo, pois ele é essencial para a comunicação entre LightDM e Wayland:

   ```bash
   systemctl status dbus.service
   ```

6. Se o `dbus.service` estiver inativo, inicie-o:

   ```bash
   sudo systemctl start dbus.service
   ```

Após seguir esses passos, tente iniciar a sessão gráfica novamente. Se o problema persistir, consulte os logs do systemd para diagnóstico adicional.