#!/bin/bash
# select_firebase_env.sh
#
# Build Phase Script — copia el GoogleService-Info.plist correcto al bundle.
#
# ¿Por qué un script y no dos targets?
# Dos targets duplican toda la configuración de Xcode (entitlements,
# capabilities, assets). Un script con dos plists es más simple de mantener.
#
# Cómo agregar este script en Xcode:
#   1. Selecciona el target "Fooco" en Xcode
#   2. Build Phases → "+" → New Run Script Phase
#   3. Nómbrala "Select Firebase Environment"
#   4. Pega el contenido de este archivo en el editor de script
#   5. IMPORTANTE: mueve la fase ANTES de "Copy Bundle Resources"
#   6. En "Input Files" agrega:
#        $(SRCROOT)/Fooco/Config/GoogleService-Info-Dev.plist
#        $(SRCROOT)/Fooco/Config/GoogleService-Info-Prod.plist
#   7. En "Output Files" agrega:
#        $(BUILT_PRODUCTS_DIR)/$(PRODUCT_NAME).app/GoogleService-Info.plist
#
# Archivos requeridos en Fooco/Config/:
#   GoogleService-Info-Dev.plist   ← descargado de Firebase Fooco-Dev
#   GoogleService-Info-Prod.plist  ← descargado de Firebase Fooco-Prod
#   (ambos están en .gitignore — nunca commitear credenciales)

set -euo pipefail

# Directorio de configuración relativo al proyecto
CONFIG_DIR="${SRCROOT}/Fooco/Config"

# Destino en el bundle compilado
DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

echo "▸ Firebase environment: ${CONFIGURATION}"

if [ "${CONFIGURATION}" = "Release" ]; then
    SOURCE="${CONFIG_DIR}/GoogleService-Info-Prod.plist"
    echo "▸ Usando GoogleService-Info-Prod.plist (Producción)"
else
    SOURCE="${CONFIG_DIR}/GoogleService-Info-Dev.plist"
    echo "▸ Usando GoogleService-Info-Dev.plist (Desarrollo)"
fi

if [ ! -f "$SOURCE" ]; then
    echo "error: No se encontró ${SOURCE}"
    echo "error: Descarga el GoogleService-Info.plist desde Firebase Console"
    echo "error: y renómbralo según el ambiente (-Dev o -Prod)"
    exit 1
fi

cp -f "$SOURCE" "$DEST"
echo "▸ GoogleService-Info.plist copiado correctamente"
