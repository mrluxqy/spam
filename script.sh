#!/bin/bash

# Función para mostrar texto en colores
function print_color() {
    local color_code=$1
    shift
    echo -e "\e[${color_code}m$@\e[0m"
}

# Mostrar bienvenida en ASCII
function bienvenida_ascii() {
    clear
    print_color 32 "====================================="
    print_color 36 "       BIENVENIDO AL BOT MANAGER      "
    print_color 32 "====================================="
    print_color 34 "     Preparando el entorno...         "
    print_color 32 "====================================="
}

# Función para instalar dependencias según la plataforma seleccionada
function instalar_dependencias() {
    # Preguntar al usuario qué tipo de instalación desea
    print_color 33 "Selecciona una opción:"
    print_color 33 "1) Termux"
    print_color 33 "2) Linux"
    print_color 33 "3) CMD (Windows)"
    read -p "Ingresa tu opción (1, 2 o 3): " opcion

    case $opcion in
        1)
            print_color 33 "Instalación para Termux seleccionada."
            pkg update && pkg upgrade -y
            pkg install python jq -y
            ;;
        2)
            print_color 33 "Instalación para Linux seleccionada."
            sudo apt update && sudo apt upgrade -y
            sudo apt install python3 python3-pip jq -y
            ;;
        3)
            print_color 33 "Instalación para CMD seleccionada."
            print_color 34 "En Windows (CMD), asegúrate de haber instalado Python manualmente."
            
            # Verificar y actualizar pip
            print_color 36 "Verificando y actualizando pip..."
            python.exe -m pip install --upgrade pip

            # Instalar paquetes de Python: telethon, schedule y jq
            print_color 36 "Instalando paquetes de Python: jq, telethon y schedule..."
            pip install jq telethon schedule
            print_color 32 "Paquetes de Python instalados correctamente."
            ;;
        *)
            print_color 31 "Opción inválida. Saliendo..."
            exit 1
            ;;
    esac

    print_color 32 "Dependencias instaladas correctamente."
}

# Función para preguntar al usuario
function preguntar() {
    local mensaje=$1
    read -p "$mensaje: " respuesta
    echo $respuesta
}

# Crear o modificar config.json y actualizar grupos_a_evitar
function modificar_config_json() {
    # Verificar si el archivo config.json existe
    if [ ! -f "config.json" ]; then
        print_color 31 "Error: El archivo config.json no existe. El script se detendrá."
        exit 1
    fi

    # Leer el contenido del archivo config.json
    config_json=$(cat config.json)

    # Obtener lista de grupos_a_evitar del archivo JSON
    grupos_a_evitar=$(echo "$config_json" | jq -r '.grupos_a_evitar')

    # Pedir la cantidad de bots
    cantidad_bots=$(preguntar "¿Cuántos bots deseas configurar? (máx 10)")
    if [[ $cantidad_bots -gt 10 ]]; then
        cantidad_bots=10
    fi

    # Pedir los datos de los bots y actualizar el JSON
    for ((i=1; i<=cantidad_bots; i++)); do
        grupo_origen_id=$(preguntar "Ingresa el ID del grupo de origen para el bot $i")
        tu_numero_telefono=$(preguntar "Ingresa el número de teléfono para el bot $i (ejemplo: +51912345678)")

        # Actualizar el JSON con los datos del bot
        config_json=$(echo "$config_json" | jq --argjson grupo "$grupo_origen_id" --arg telefono "$tu_numero_telefono" \
        '.["grupo_origen_id'"$i"'"] = $grupo | .["tu_numero_telefono'"$i"'"] = $telefono')

        # Agregar el grupo a grupos_a_evitar si no está en la lista
        if [[ $grupos_a_evitar != *"$grupo_origen_id"* ]]; then
            grupos_a_evitar=$(echo "$grupos_a_evitar" | jq --argjson grupo "$grupo_origen_id" '. += [$grupo]')
        fi
    done

    # Actualizar grupos_a_evitar en el JSON principal
    config_json=$(echo "$config_json" | jq --argjson grupos "$grupos_a_evitar" '.["grupos_a_evitar"] = $grupos')

    # Pedir los minutos para el schedule
    minutos=$(preguntar "¿Cada cuántos minutos deseas reenviar los mensajes? (ejemplo: 3)")

    # Agregar los minutos al JSON
    config_json=$(echo "$config_json" | jq --argjson minutos "$minutos" '.["minutos"] = $minutos')

    # Escribir los cambios en el archivo config.json
    echo "$config_json" > config.json
    print_color 32 "El archivo config.json ha sido actualizado correctamente."
}

# Mostrar bienvenida
bienvenida_ascii

# Instalar dependencias necesarias
instalar_dependencias

# Modificar el archivo config.json (no se ejecutan bots en esta versión)
modificar_config_json

# Finalización
print_color 32 "Script ejecutado correctamente. Se ha actualizado el config.json."
