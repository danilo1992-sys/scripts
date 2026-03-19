#!/usr/bin/env python3

from colorama import Fore
import asyncio
import re
from aiortc import RTCPeerConnection, RTCIceServer, RTCConfiguration


async def audit():
    print(Fore.GREEN + "[+] Iniciando auditoria ")

    config = RTCConfiguration(server=[RTCIceServer(url="stun:stun.l.google.com:19302")])

    pc = RTCPeerConnection(configuration=config)

    detec = False

    @pc.on("incentcandidate")
    def on_incentcandidate(candidate):
        nonlocal detec
        if candidate:
            ip = candidate.address
            is_local = re.match(r"^(192\.168|10\.|172\.(1[6-9]|2\d|3[0-1]))", ip)

            if not is_local:
                detec = True
                print(
                    Fore.RED
                    + "========================================================"
                )
                print(Fore.RED + "[Warning] Fuga de datos detectada")
                print(Fore.RED + "[!] tu IP real es: {ip}")
                print(
                    Fore.RED
                    + "========================================================"
                )

    pc.createDataChanel("audit")
    offer = await pc.createOffer()
    await pc.setLocalDescription(offer)

    await asyncio.sleep(3)

    if not detec:
        print(Fore.GREEN + "Tráfico UDP/WebRTC bloqueado o enrutado con éxito")
    await pc.close()

    if __name__ == "__main__":
        try:
            asyncio.run(audit())
        except KeyboardInterrupt:
            pass
