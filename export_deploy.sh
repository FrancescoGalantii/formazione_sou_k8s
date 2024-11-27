#!/bin/bash

DEPLOYMENT_NAME="$1"
NAMESPACE="$2"


error_exit() {
    echo "Errore: $1"
    exit 1
}


if [[ -z "$DEPLOYMENT_NAME" || -z "$NAMESPACE" ]]; then
    error_exit "Uso: $0 <nome-deployment> <namespace>"
fi


DEPLOYMENT_YAML=$(kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o yaml 2>/dev/null)

if [[ $? -ne 0 || -z "$DEPLOYMENT_YAML" ]]; then
    error_exit "Impossibile recuperare il deployment $DEPLOYMENT_NAME nel namespace $NAMESPACE."
fi


if ! echo "$DEPLOYMENT_YAML" | grep -q "livenessProbe:"; then
    error_exit "Il deployment $DEPLOYMENT_NAME non contiene 'livenessProbe'."
fi

if ! echo "$DEPLOYMENT_YAML" | grep -q "readinessProbe:"; then
    error_exit "Il deployment $DEPLOYMENT_NAME non contiene 'readinessProbe'."
fi


if ! echo "$DEPLOYMENT_YAML" | grep -q "limits:"; then
    error_exit "Il deployment $DEPLOYMENT_NAME non contiene 'limits' nelle risorse."
fi

if ! echo "$DEPLOYMENT_YAML" | grep -q "requests:"; then
    error_exit "Il deployment $DEPLOYMENT_NAME non contiene 'requests' nelle risorse."
fi


EXPORT_FILE="${DEPLOYMENT_NAME}_export.yaml"
echo "$DEPLOYMENT_YAML" > "$EXPORT_FILE"
echo "Deployment esportato con successo in $EXPORT_FILE."
echo "------------------------------------------------------------------------------"
sleep 2
echo "il livenessProbe ha superato il controllo"
echo "------------------------------------------------------------------------------"
sleep 2
echo "il readinessProbe ha superato il controllo"
echo "------------------------------------------------------------------------------"
sleep 2
echo "limits e requests hanno superato i controlli"
echo "------------------------------------------------------------------------------"
sleep 2
echo "Tutti i controlli superati per il deployment $DEPLOYMENT_NAME."
echo "------------------------------------------------------------------------------"
exit 0
