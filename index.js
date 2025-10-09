const vosk = require('vosk');
const record = require('node-record-lpcm16');
const fs = require('fs');

// IMPORTANTE: Ajusta esta ruta a tu modelo descargado
const MODEL_PATH = "vosk-model-small-es-0.42"; 

// --- Configuración ---
const SAMPLE_RATE = 16000; 
const VOSK_LOG_LEVEL = -1; 
const ENCODING = 'linear'; 

// ... (Verificaciones de modelo y configuración de Vosk) ...

if (!fs.existsSync(MODEL_PATH)) {
    console.error(`ERROR: No se encontró el modelo: ${MODEL_PATH}`);
    console.error("Descarga un modelo (ej. 'vosk-model-small-es-0.42') y colócalo en esta carpeta.");
    process.exit(1);
}

vosk.setLogLevel(VOSK_LOG_LEVEL);
const model = new vosk.Model(MODEL_PATH);
const recognizer = new vosk.Recognizer({
    model: model,
    sampleRate: SAMPLE_RATE
});

console.log("==========================================");
console.log(`🎤 Modelo Vosk cargado: ${MODEL_PATH}`);
console.log(`🎧 Tasa de muestreo requerida: ${SAMPLE_RATE} Hz`);
console.log("📣 ¡Empieza a hablar! (Ctrl+C para salir)");
console.log("==========================================");

const recording = record.record({
    sampleRate: SAMPLE_RATE,
    channels: 1, 
    encoding: ENCODING,
    silence: '1.0', 
    threshold: 0.5, 
    verbose: false,
    recordProgram: 'sox'
});

recording.stream().on('data', (data) => {
    // 1. Envía el chunk de audio al reconocedor
    if (recognizer.acceptWaveform(data)) {
        // 2. Transcripción FINAL (AQUÍ ESTÁ LA CORRECCIÓN)
        const result = recognizer.result(); // <--- ELIMINADO JSON.parse()
        
        // El resultado es ahora un objeto JS, accedemos directamente a la propiedad 'text'
        if (result && result.text) { 
            process.stdout.write(`\n✅ FINAL: ${result.text}\n`);
        }
    } else {
        // 3. Transcripción PARCIAL (AQUÍ ESTÁ LA CORRECCIÓN)
        const partial = recognizer.partialResult(); // <--- ELIMINADO JSON.parse()
        
        // El resultado es ahora un objeto JS, accedemos directamente a la propiedad 'partial'
        if (partial && partial.partial) {
            process.stdout.clearLine(0);
            process.stdout.cursorTo(0);
            process.stdout.write(`... Parcial: ${partial.partial}`);
        }
    }
});

// ... (Resto del código de manejo de errores y limpieza) ...

recording.stream().on('error', (err) => {
    console.error(`\nError en la grabación: ${err.message}`);
    process.exit(1);
});

process.on('SIGINT', () => {
    console.log("\n\nSaliendo y liberando recursos...");
    record.stop();
    recognizer.free();
    model.free();
    process.exit();
});
