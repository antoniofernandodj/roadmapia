## Integração com sistemas de áudio

Aplicativos gráficos modernos frequentemente precisam reproduzir áudio, desde notificações simples até players de mídia completos. No ecossistema Wayland, essa integração não é tratada pelo protocolo principal, mas sim através de sistemas externos como PipeWire ou PulseAudio. Vamos implementar um tocador de áudio mínimo que demonstre a integração prática.

O principal desafio é que o Wayland não possui protocolo nativo para áudio - isso é intencional, pois segue a filosofia Unix de "fazer uma coisa bem". Para áudio, usamos PipeWire (o padrão emergente) ou PulseAudio (legado). Aqui está um exemplo com libpulse (API simples do PulseAudio):

```c
#include <pulse/simple.h>
#include <pulse/error.h>

#define SAMPLE_RATE 44100
#define FORMAT PA_SAMPLE_S16LE
#define CHANNELS 2

int main() {
    pa_simple *stream = NULL;
    int error;
    const char *dev = "wayland-audio-sink"; // Dispositivo virtual para Wayland

    // Configuração do stream de áudio
    pa_sample_spec ss = {
        .format = FORMAT,
        .rate = SAMPLE_RATE,
        .channels = CHANNELS
    };

    // Cria conexão com o servidor de áudio
    stream = pa_simple_new(NULL,           // Servidor padrão
                          "Wayland Player",// Nome do cliente
                          PA_STREAM_PLAYBACK,
                          dev,             // Dispositivo de saída
                          "Music",         // Descrição do stream
                          &ss,             // Especificação do sample
                          NULL,            // Mapa de canais (padrão)
                          NULL,            // Atributos de buffer (padrão)
                          &error);

    if (!stream) {
        fprintf(stderr, "Falha ao conectar: %s\n", pa_strerror(error));
        return 1;
    }

    // Gera um tom de teste (440Hz) - na prática seria seu dado de áudio real
    int16_t buffer[1024];
    for (int i = 0; i < 1024; i++) {
        buffer[i] = 32767 * sin(440.0 * 2 * M_PI * i / SAMPLE_RATE);
    }

    // Reproduz o buffer em loop
    while (1) {
        if (pa_simple_write(stream, buffer, sizeof(buffer), &error) < 0) {
            fprintf(stderr, "Erro na escrita: %s\n", pa_strerror(error));
            break;
        }
    }

    pa_simple_free(stream);
    return 0;
}
```

Para compilar:
```bash
gcc -o wayland-audio audio.c -lpulse-simple -lpulse -lm
```

Erro comum: esquecer de verificar se o serviço de áudio está ativo. Se o PulseAudio/PipeWire não estiver rodando, você verá:
```
Falha ao conectar: Connection refused
```

A solução é iniciar o serviço ou usar o fallback correto:
```c
// Tenta PipeWire primeiro, depois PulseAudio
stream = pa_simple_new("pipewire", "Wayland Player", PA_STREAM_PLAYBACK,
                      NULL, "Music", &ss, NULL, NULL, &error);
if (!stream) {
    stream = pa_simple_new(NULL, "Wayland Player", PA_STREAM_PLAYBACK,
                          NULL, "Music", &ss, NULL, NULL, &error);
}
```

Para aplicativos avançados, PipeWire oferece integração mais profunda com Wayland através da API libpipewire. Este exemplo mostra como monitorar dispositivos de áudio:

```c
#include <pipewire/pipewire.h>

static void on_core_info(void *userdata, const struct pw_core_info *info) {
    printf("Conectado ao PipeWire v%s\n", info->version);
}

int main() {
    pw_init(NULL, NULL);

    struct pw_main_loop *loop = pw_main_loop_new(NULL);
    struct pw_context *context = pw_context_new(pw_main_loop_get_loop(loop), NULL, 0);
    struct pw_core *core = pw_context_connect(context, NULL, 0);

    // Monitora eventos do core
    static const struct pw_core_events core_events = {
        .version = PW_VERSION_CORE_EVENTS,
        .info = on_core_info,
    };
    pw_core_add_listener(core, &core_events.core_listener, &core_events);

    pw_main_loop_run(loop); // Entra no loop principal

    // Limpeza
    pw_core_disconnect(core);
    pw_context_destroy(context);
    pw_main_loop_destroy(loop);
    pw_deinit();

    return 0;
}
```

A saída será algo como:
```
Conectado ao PipeWire v0.3.45
```

### Exercício Prático

Implemente um visualizador de forma de onda que mostre em tempo real o áudio sendo reproduzido. Use PipeWire para capturar o stream de saída global e desenhe a forma de onda usando Cairo em uma janela Wayland.

Solução comentada:

1. Primeiro, configure um stream PipeWire para monitorar o áudio global:
```c
struct pw_stream *stream = pw_stream_new_simple(
    "audio-monitor",
    pw_properties_new(
        PW_KEY_MEDIA_TYPE, "Audio",
        PW_KEY_MEDIA_CATEGORY, "Capture",
        PW_KEY_MEDIA_ROLE, "DSP",
        NULL),
    &stream_events,
    NULL);
```

2. Conecte ao nó de monitoramento global:
```c
pw_stream_connect(
    stream,
    PW_DIRECTION_INPUT,
    PW_ID_ANY,
    PW_STREAM_FLAG_MAP_BUFFERS |
    PW_STREAM_FLAG_RT_PROCESS,
    NULL, 0);
```

3. No callback de processamento, desenhe a forma de onda:
```c
static void on_process(void *userdata) {
    struct pw_buffer *buf = pw_stream_dequeue_buffer(stream);
    float *samples = buf->buffer->datas[0].data;
    
    // Configuração do Cairo
    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_paint(cr);
    cairo_set_source_rgb(cr, 0, 1, 0);
    
    // Desenha a forma de onda
    cairo_move_to(cr, 0, height/2);
    for (int i = 0; i < buf->buffer->datas[0].chunk->size; i += 10) {
        float y = samples[i] * height/2;
        cairo_line_to(cr, i, height/2 - y);
    }
    cairo_stroke(cr);
    
    wl_surface_commit(surface);
    pw_stream_queue_buffer(stream, buf);
}
```