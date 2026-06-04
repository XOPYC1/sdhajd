#!/bin/bash

set -Eeuo pipefail

LOG_FILE="/var/log/node.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================="
echo "   MARZBAN NODE INSTALL"
echo "=============================="

# --- ROOT CHECK ---

if [ "$EUID" -ne 0 ]; then
echo "[ERROR] Запусти через root / sudo"
exit 1
fi

# --- SYSTEM UPDATE ---

echo "[STEP 1] Update system"
apt-get update && apt-get upgrade -y

# --- DEPENDENCIES (очищено от дублей) ---

echo "[STEP 2] Install dependencies"
apt install -y socat curl git ca-certificates

# --- DOCKER ---

echo "[STEP 3] Install Docker (if missing)"
if ! command -v docker >/dev/null 2>&1; then
curl -fsSL https://get.docker.com | sh
else
echo "[OK] Docker already installed"
fi

# --- NODE DIR ---

echo "[STEP 4] Setup directory"
mkdir -p /opt/marzban-node
cd /opt/marzban-node

# --- CLONE ---

echo "[STEP 5] Clone Marzban-node"
if [ ! -d "Marzban-node" ]; then
git clone https://github.com/Gozargah/Marzban-node
fi

cd Marzban-node

# --- CERT ---

echo "[STEP 6] Create cert file"

mkdir -p /var/lib/marzban-node

cat > /var/lib/marzban-node/ssl_client_cert.pem <<'EOF'
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjMxMDI3MTMzNzM5WhgPMjEyMzEwMDMxMzM3AzlaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtYx5XJIpk0oV
AVAWjEWXEWeIJ9fAYMiToo0alQYLACaraCV4YFokWvTzZUYJQMVKbizqtw2v1/Ew
dfJUw2EYyovAVTPw2XqNlOzrIQ3uc9EorEmf8H49F14IGAiLFmXjwdarYxymfWJd
Tkw7qlc6X5bLidQEmeecGjBZmRD3Vm6/QQ5fFZykjjQItHpXQ4zAPyinoIemIlc7
y/N/yQj8Ey2HlSGP7yyEGv6IQ7il1PMF4HgCSCJwG2cLpS6yIHTNp00sLxUNInn0
v3mlc/IPCvWyLAqqa1NV+QuwPMsAgsqAwrx4dWB5SM/o5ZcYfV50jUQXt8DiUOGw
6VSxp51u4/hZOlNvw8ptt0zSmdGjqYwPNy2uQeeHxAe0SVmc48MGbhHMuTwYy2n7
E508mMcYYfejv9qZ8axCWprFEvQmV7/XhXq1CQA1k0YTgE0dXwqrSkaAuSTXvTJS
Q5BgQghvENIovDakgigxRC6etEQgfLgMGFuX+C3XL2GzJv/HLPVrizVdpNcuTmng
rpTRujs9ah74gKQPVW5uLdNiUmHbU9ejDN+ry8ZxlxPaEX0uFilIodm3FIUlrYza
4019Xu3hultxf8am9Xw5flolkiDnsGAYFDVDHXENAnN3W9Kq3PEMoFLgfwiP88kq
Ub9eeKFiTh96gmMpF/YHr21tpF3/OHkCAwEAATAN3gkqhkiG9w0BAQOFAAOCAgEA
WUW6sMa62ZHnig4/WCRWLPc8EWVqNzLyNuY+IPNANHxgLxd0wQqokgGj7lx57Ai9
C8k5X5jbB5Y2AA04yMNXASwF9feTAmb/7e58EJulxgXf2or9eufG1AloKI3o/qiT
CNTwtKl1/HFagwYBIODD2fFtXKF05Wl0gjN2JFEKdnmfedbF3dGtw9U4nuVIP5u5
Tb00CSkDaadP7oivMnhFTqoy/DyEa5Jk+gbgNc105UIdD6h/TGqeP2xbuVed0uBb
+Cd7eR80jFYcvlhHTErYc3X7v+23Idvk/w+o2zQPSjEic66zhse4eJo5Htin/z+m
hdIByJ0ImBLVD5bzRm3wJC0XzftDeBmOL+6JqJqSqD1it4qX24yJW5XYWDImPC/H
viJgowzPytVORvlJizocQbHQTrZTtz+UbM6lVxp4mCZcNvh2HBiKtdHd6N2VVGnw
O9NPKLYQOuWIwhC+G42TU8K+KBHrKRj5ijfdTLrzan30jBUsQ/N3Li5bG7gty7RD
3lhHn24RdIV2ocZ+B6715e51q99x1BcBl+VP1hRv7+E262m2wxlNHqT00HZ3A7qR
YsyQuObDNBVzHwCUXNWLefg+2SS/F1AXsBmms3mTyj+K5iCNnYJvCU24uWfggqkx
Fz3uSaWgY1dMRMkB/uB8aCQV8SttwXf18qMIScJpqYg=
-----END CERTIFICATE-----
EOF

# --- START NODE ---

echo "[STEP 7] Start docker compose"
docker compose up -d

echo "=============================="
echo "[DONE] MARZBAN NODE READY"
echo "LOG: $LOG_FILE"
echo "=============================="
