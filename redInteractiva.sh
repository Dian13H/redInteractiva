#!/bin/bash

#mostrar las interfaces de red disponibles y su estado (UP/DOWN)
ver_interfaces() {
    echo ""
    echo "Interfaces de red disponibles en el equipo y su estado:"
    ip -o link show | awk '{print $2, $9}' | grep -E 'UP|DOWN'
    echo ""
}

#cambiar el estado de la interfaz (UP/DOWN)
cambiar_estado_interfaz() {
    echo ""
    read -p "Nombre de la interfaz: " interface
    if ! ip link show "$interface" &>/dev/null; then
        echo "Error: la interfaz $interface no existe"
        return
    fi
    read -p "¿Quieres activar (up) o desactivar (down) la interfaz? (up/down): " state
    if [[ "$state" =~ ^(up|down)$ ]]; then
        sudo ip link set "$interface" "$state" && echo "Estado de la interfaz $interface cambiado a $state"
    else
        echo "Error: opción no válida, usa 'up' o 'down'"
    fi
    echo ""
}

#conectarse a una red cableada
conexion_wired() {
    read -p "Nombre de la interfaz cableada: " interface
    if ! ip link show "$interface" &>/dev/null; then
        echo "Error: la interfaz $interface no existe"
        return
    fi
    sudo dhclient "$interface" && echo "Conectado a la red cableada con la interfaz $interface"
    echo ""
}

#conectarse a una red inalámbrica
conexion_wireless() {
    echo ""
    read -p "Nombre de la interfaz inalámbrica: " interface
    if ! ip link show "$interface" &>/dev/null; then
        echo "Error: la interfaz $interface no existe"
        return
    fi
    echo "Escaneando redes disponibles"
    redes=$(sudo iw dev "$interface" scan | grep "SSID:" | sed 's/^.*SSID: //' | sort -u)
    if [[ -z "$redes" ]]; then
        echo "No se encontraron redes disponibles"
        return
    fi
    echo "$redes"
    read -p "Introduce el nombre de la red (SSID): " ssid
    echo -n "Introduce la contraseña de la red (dejar vacío si es abierta): "
    read -r password
    echo ""
    
    WPA_CONF=$(mktemp)
    echo "network={" > "$WPA_CONF"
    echo "    ssid=\"$ssid\"" >> "$WPA_CONF"
    
    cifrado=$(sudo iw dev "$interface" scan | awk '/SSID: '$ssid'/{found=1} found && /RSN|WPA|WEP/ {print; exit}')
    if echo "$cifrado" | grep -q "RSN"; then
        echo "    key_mgmt=WPA-PSK" >> "$WPA_CONF"
        echo "    psk=\"$password\"" >> "$WPA_CONF"
    elif echo "$cifrado" | grep -q "WPA"; then
        echo "    key_mgmt=WPA-PSK" >> "$WPA_CONF"
        echo "    psk=\"$password\"" >> "$WPA_CONF"
    elif echo "$cifrado" | grep -q "WEP"; then
        echo "    key_mgmt=NONE" >> "$WPA_CONF"
        echo "    wep_key0=\"$password\"" >> "$WPA_CONF"
    else
        echo "    key_mgmt=NONE" >> "$WPA_CONF"
    fi
    echo "}" >> "$WPA_CONF"
    
    sudo wpa_supplicant -B -i "$interface" -c "$WPA_CONF"
    sudo dhclient "$interface"
    
    if iw dev "$interface" link | grep -q "$ssid"; then
        echo "Conectado a la red inalámbrica $ssid"
    else
        echo "Error: No se pudo conectar a $ssid"
    fi
    
    rm -f "$WPA_CONF"
    echo ""
}

#configurar la red de forma estática o dinámica
config_red() {
    read -p "Nombre de la interfaz: " interface
    if ! ip link show "$interface" &>/dev/null; then
        echo "Error: la interfaz $interface no existe"
        return
    fi
    read -p "¿Quieres configurar la red de forma estática o dinámica? (1=estática, 2=dinámica): " config_type
    if [ "$config_type" == "1" ]; then
        read -p "Introduce la dirección IP: " ip_address
        read -p "Introduce la máscara de red: " netmask
        read -p "Introduce la puerta de enlace: " gateway
        read -p "Introduce el DNS: " dns
        sudo ip addr add "$ip_address/$netmask" dev "$interface" && sudo ip route add default via "$gateway"
        echo "nameserver $dns" | sudo tee /etc/resolv.conf > /dev/null
    elif [ "$config_type" == "2" ]; then
        sudo dhclient "$interface"
    else
        echo "Opción no válida"
        return
    fi
    echo "Configuración de red exitosa"
    echo ""
}

#guardar la configuración y hacerla permanente
guardar_config() {
    read -p "Nombre de la interfaz para guardar: " interface
    if ! ip link show "$interface" &>/dev/null; then
        echo "Error: la interfaz $interface no existe"
        return
    fi
    sudo ip link set "$interface" up
    echo "Configuración guardada de forma exitosa"
    echo ""
}

while true; do
    echo "1. Mostrar interfaces de red disponibles"
    echo "2. Cambiar el estado de la interfaz (up/down)"
    echo "3. Conectarse a una red cableada"
    echo "4. Conectarse a una red inalámbrica"
    echo "5. Configurar la red (estática o dinámica)"
    echo "6. Guardar la configuración y hacerla permanente"
    echo "7. Salir"
    read -p "Selecciona una opción: " choice

    case $choice in
        1) ver_interfaces ;;
        2) cambiar_estado_interfaz ;;
        3) conexion_wired ;;
        4) conexion_wireless ;;
        5) config_red ;;
        6) guardar_config ;;
        7) exit 0 ;;
        *) echo "Opción no válida." ;;
    esac
    echo ""
done

