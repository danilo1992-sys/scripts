// 1. Limpiamos la consola para el video
console.clear();
console.log(
  "%c[*] INICIANDO AUDITORÍA WEBRTC (STUN)...",
  "color: cyan; font-weight: bold;",
);

// 2. Configuramos la conexión al servidor STUN de Google
const configuracion = {
  iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
};
const pc = new RTCPeerConnection(configuracion);

// 3. Creamos un canal falso para forzar la recolección de IPs (ICE candidates)
pc.createDataChannel("");
pc.createOffer().then((oferta) => pc.setLocalDescription(oferta));

// 4. Escuchamos los candidatos que devuelve el navegador
pc.onicecandidate = (evento) => {
  if (evento.candidate) {
    // Extraemos la IP de la cadena de texto del candidato
    const ip = evento.candidate.candidate.split(" ")[4];

    // Filtramos IPs locales (192.168.x.x, 10.x.x.x, etc.) para aislar la pública
    if (!ip.match(/^(192\.168|10\.|172\.(1[6-9]|2\d|3[0-1]))/)) {
      console.log(
        "%c=========================================",
        "color: red; font-weight: bold;",
      );
      console.log(
        "%c[PELIGRO] ¡FUGA DE DATOS DETECTADA!",
        "color: red; font-size: 16px; font-weight: bold;",
      );
      console.log(
        "%c[!] El navegador ignoró el proxy. Tu IP real es:",
        "color: red; font-size: 14px;",
      );
      console.log(
        "%c>>> " + ip + " <<<",
        "color: yellow; font-size: 20px; font-weight: bold; background: red; padding: 5px;",
      );
      console.log(
        "%c=========================================",
        "color: red; font-weight: bold;",
      );
    }
  }
};

// Si después de unos segundos no sale nada, asumimos que está bloqueado
setTimeout(() => {
  if (pc.iceGatheringState !== "complete") {
    console.log(
      "%c[SEGURO] Tráfico UDP/WebRTC bloqueado o enrutado con éxito.",
      "color: #00ff00; font-weight: bold; font-size: 14px;",
    );
  }
}, 3000);
