const vosk = require('vosk');
const fs = require('fs');
const { spawn } = require('child_process');

// IMPORTANTE: Ajusta esta ruta a tu modelo descargado
const MODEL_PATH = "vosk-model-small-es-0.42"; 
// Dirección del stream RTMP
const RTMP_URL = "rtmp://127.0.0.1:1935/live/streamkey";

// --- Configuración de Vosk ---
const SAMPLE_RATE = 16000; 
const VOSK_LOG_LEVEL = -1; 

// --- 1. Verificaciones y Carga de Modelo Vosk ---

if (!fs.existsSync(MODEL_PATH)) {
    console.error(`❌ ERROR: No se encontró el modelo: ${MODEL_PATH}`);
    console.error("Descarga un modelo (ej. 'vosk-model-small-es-0.42') y colócalo en esta carpeta.");
    process.exit(1);
}

vosk.setLogLevel(VOSK_LOG_LEVEL);
const model = new vosk.Model(MODEL_PATH);
const recognizer = new vosk.Recognizer({
    model: model,
    sampleRate: SAMPLE_RATE
});

// --- 2. Configuración y Lanzamiento de FFmpeg ---

// Comando FFmpeg para extraer, formatear y enviar el audio
const FFmpeg_COMMAND = 'ffmpeg';
const FFmpeg_ARGS = [
    // Entrada RTMP
    '-i', RTMP_URL,
    // Opciones de salida para Vosk (PCM 16000Hz, Mono, 16bit Little-Endian)
    '-vn', // No incluir vídeo (V-ideo N-o)
    '-f', 's16le', // Formato de datos binarios raw (signed 16-bit little-endian)
    '-acodec', 'pcm_s16le', // Códec PCM 16-bit
    '-ac', '1', // Audio de 1 canal (mono)
    '-ar', SAMPLE_RATE.toString(), // Tasa de muestreo (16000 Hz)
    // Redirigir la salida binaria a stdout
    'pipe:1' 
];

// Lanza el proceso hijo de FFmpeg
const ffmpegProcess = spawn(FFmpeg_COMMAND, FFmpeg_ARGS);

// --- 3. Mensajes Iniciales ---
//console.log("=================================================");
console.log(`unika::Modelo Vosk cargado: ${MODEL_PATH}`);
console.log(`unika::Escuchando stream RTMP: ${RTMP_URL}`);
//console.log(`unika::Tasa de muestreo requerida: ${SAMPLE_RATE} Hz`);
//console.log("unika::Procesando audio... (Ctrl+C para salir)");
//console.log("=================================================");

// --- 4. Conectar la Salida de FFmpeg a Vosk ---

ffmpegProcess.stdout.on('data', (data) => {
    // 'data' es el chunk de audio raw (PCM) enviado por FFmpeg
    if (recognizer.acceptWaveform(data)) {
        // Transcripción FINAL
        const result = recognizer.result(); 
        if (result && result.text) { 
            console.log(`unika::FINAL: ${result.text}\n`);
        }
    } else {
        // Transcripción PARCIAL
        const partial = recognizer.partialResult(); 
        if (partial && partial.partial) {
            console.log(`unika::Parcial: ${partial.partial}`);
        }
    }
});

// --- 5. Manejo de Errores y Salida ---

ffmpegProcess.stderr.on('data', (data) => {
    // FFmpeg envía mensajes de log y errores a stderr.
    // Opcional: Descomenta si necesitas depurar problemas con FFmpeg.
    // console.error(`[FFmpeg Log]: ${data.toString().trim()}`);
});

ffmpegProcess.on('error', (err) => {
    console.error(`\n❌ ERROR al iniciar FFmpeg: ${err.message}`);
    console.error("Asegúrate de que FFmpeg esté instalado y accesible en tu PATH.");
    process.exit(1);
});

ffmpegProcess.on('close', (code) => {
    console.log(`\nFFmpeg terminó con código de salida ${code}.`);
    recognizer.free();
    model.free();
    console.log("Recursos Vosk liberados.");
    process.exit(code || 0);
});

process.on('SIGINT', () => {
    console.log("\n\nSaliendo y deteniendo FFmpeg...");
    // Envía la señal de interrupción a FFmpeg para que termine su proceso
    ffmpegProcess.kill('SIGINT');
});
