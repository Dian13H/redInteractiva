# Script de configuración de redes en GNU/Linux

Script que permite gestionar y configurar interfaces de red en un sistema Linux de forma interactiva. Proporciona una serie de funciones para mostrar el estado de las interfaces del dispositivo, cambiar su estado (activarlas o desactivarlas), conectarse a redes cableadas o inalámbricas, configurar la red de manera estática o dinámica y guardar los cambios de forma permanente.

## Funciones

### 1. Mostrar interfaces de red disponibles
Muestra las interfaces de red disponibles en el sistema y su estado (UP/DOWN).

### 2. Cambiar el estado de una interfaz
Permite activar o desactivar una interfaz de red. Se solicita el nombre de la interfaz y la opción (up o down).

### 3. Conectarse a una red cableada
Conecta una interfaz de red cableada a una red mediante DHCP (Protocolo de configuración dinámica de host).

### 4. Conectarse a una red inalámbrica
Conecta una interfaz de red inalámbrica a una red Wi-Fi. Pide la interfaz inalámbrica que se desea conectar, escanea las redes disponibles y permite ingresar el nombre de la red (SSID) y la contraseña.

### 5. Configurar la red de forma estática o dinámica
Permite configurar una interfaz de red con una dirección IP estática o dinámica (mediante DHCP). Se solicita la dirección IP, máscara de subred, puerta de enlace y servidor DNS en caso de configurar de forma estática.

### 6. Guardar la configuración y hacerla permanente
Guarda la configuración de la interfaz de red seleccionada y la hace permanente.

## Requisitos

- Linux con acceso de superusuario (sudo).
- Herramientas `ip`, `awk`, `grep`, `iw`, `dhclient` y `wpa_supplicant` deben estar instaladas.

## Descarga y uso

1. Clonar este repositorio a la máquina:

    ```bash
    git clone https://github.com/tu_usuario/gestion-red-linux.git
    ```

2. Dar permisos de ejecución al script:

    ```bash
    chmod +x redInteractiva.sh
    ```

3. Ejecutar el script:

    ```bash
    ./redInteractiva.sh
    ```

4. El script mostrará un menú con las opciones disponibles. Ingresar el número correspondiente para ejecutar la opción deseada, posteriormente saldrán más opciones dentro del menú interactivo. 


## Contribuciones
Las contribuciones son bienvenidas. Si tienes mejoras o correcciones, por favor crea un pull request o abre un issue.
