#!/bin/bash
set -e

PRINTER_NAME="${PRINTER_NAME:-PDF-Printer}"

echo "Configuring CUPS with printer: $PRINTER_NAME"

# --- Ensure output directory is writable by cups-pdf ---
chmod 777 /pdfs

# --- Write cups-pdf config to output directly into /pdfs ---
cat > /etc/cups/cups-pdf.conf << EOF
Out /pdfs
AnonDirName /pdfs
EOF

# --- Write cupsd.conf ---
cat > /etc/cups/cupsd.conf << 'EOF'
LogLevel warn
MaxLogSize 0

Listen 0.0.0.0:631
Listen /run/cups/cups.sock
ServerAlias *

Browsing Yes
BrowseLocalProtocols dnssd

DefaultAuthType None
WebInterface Yes

<Location />
  Order allow,deny
  Allow all
</Location>

<Location /admin>
  Order allow,deny
  Allow all
</Location>

<Location /admin/conf>
  Order allow,deny
  Allow all
</Location>

<Policy default>
  <Limit All>
    Order deny,allow
  </Limit>
</Policy>
EOF

# --- Start CUPS in background for initial setup ---
/usr/sbin/cupsd

echo "Waiting for CUPS to start..."
for i in $(seq 1 30); do
    if [ -S /run/cups/cups.sock ]; then
        break
    fi
    sleep 1
done
echo "CUPS socket ready."

# --- Find the cups-pdf PPD ---
PPD=$(find /usr/share/ppd -iname "CUPS-PDF*.ppd" 2>/dev/null | head -1)
if [ -z "$PPD" ]; then
    echo "ERROR: Could not find CUPS-PDF PPD file." >&2
    exit 1
fi
echo "Using PPD: $PPD"

# --- Remove existing printer if present (handles container restart) ---
lpadmin -x "$PRINTER_NAME" 2>/dev/null || true

# --- Add the PDF printer ---
lpadmin -p "$PRINTER_NAME" -E -v cups-pdf:/ -P "$PPD" -o media=A4
lpadmin -d "$PRINTER_NAME"
cupsaccept "$PRINTER_NAME"
cupsenable "$PRINTER_NAME"

echo "Printer '$PRINTER_NAME' is ready."
echo "CUPS web interface: http://localhost:631"
echo "PDF files will be written to: /pdfs"

# --- Restart CUPS in foreground ---
PID_FILE=/run/cups/cupsd.pid
if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    sleep 1
fi

exec /usr/sbin/cupsd -f
