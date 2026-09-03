#!/bin/sh
set -e

# Garante comando padrão caso nenhum argumento tenha sido passado
if [ $# -eq 0 ]; then
    set -- node dev/run-standalone.mjs
fi

# Se as credenciais do Cloudflare R2 estiverem definidas, ativa a replicação do Litestream
if [ -n "$LITESTREAM_ACCESS_KEY_ID" ] && [ -n "$CLOUDFLARE_ACCOUNT_ID" ] && [ -n "$R2_BUCKET_NAME" ]; then
    echo "[Litestream] Restaurando banco de dados a partir do Cloudflare R2 (se existir)..."
    litestream restore -if-replica-exists -config /etc/litestream.yml /data/omniroute.db || true

    echo "[Litestream] Iniciando réplica e executando OmniRoute..."
    exec litestream replicate -config /etc/litestream.yml -exec "/app/check-permissions.sh $*"
else
    echo "[Litestream] Variáveis do R2 não configuradas. Iniciando sem backup remoto..."
    exec /app/check-permissions.sh "$@"
fi
