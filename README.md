# CUPS PDF Printer — Docker

A Docker container running a CUPS print server with a PDF backend.
Printing any document to this printer saves it as a PDF file on the host.

## Directory Structure

```
config/printer.conf   # Printer configuration (name, etc.)
pdfs/                 # PDF output files land here
Dockerfile            # Container image definition (Ubuntu 24.04 + CUPS)
docker-compose.yml    # Compose file with bind mounts and port mapping
entrypoint.sh         # Container startup script
```

## Quick Start

1. *(Optional)* Edit `config/printer.conf` to set your desired printer name:

   ```
   PRINTER_NAME=MyPDFPrinter
   ```

2. Start the container:

   ```bash
   docker compose up -d
   ```

3. The printer is now available via IPP at:

   ```
   ipp://localhost:631/printers/<PRINTER_NAME>
   ```

4. The CUPS web interface is available at: <http://localhost:631>

## Configuration

`config/printer.conf` supports the following key:

| Key | Default | Description |
|---|---|---|
| `PRINTER_NAME` | `PDF-Printer` | Name of the printer as it appears in CUPS and on the network |

Changes require a container restart to take effect.

## Printing

**Linux / macOS (command line)**

```bash
lp -h localhost:631 -d PDF-Printer /path/to/file.pdf
```

**Windows**

Add a network printer pointing to:
```
http://localhost:631/printers/<PRINTER_NAME>
```
using the IPP protocol (Windows IPP printer wizard).

**Any application**

Select the printer named `<PRINTER_NAME>` on the CUPS server at `localhost:631` or `<host-ip>:631`.

## PDF Output

All printed PDFs are saved to the `pdfs/` folder on the host. Filenames are derived from the print job name.

## Ports

| Port | Protocol | Purpose |
|---|---|---|
| `631` | TCP | CUPS web interface and IPP printing |

## Notes

- The `config/` volume is mounted read-only inside the container.
- The `pdfs/` volume is mounted read-write; CUPS writes directly to it.
- Authentication is disabled by default — suitable for local/trusted networks.
  To enable basic auth, change `DefaultAuthType` in `entrypoint.sh` to `Basic`
  and set a password inside the container:
  ```bash
  docker exec -it cups-pdf-printer passwd root
  ```
