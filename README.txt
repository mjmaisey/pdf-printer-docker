CUPS PDF Printer - Docker
========================

A Docker container running a CUPS print server with a PDF backend.
Printing any document to this printer saves it as a PDF file on the host.


DIRECTORY STRUCTURE
-------------------
  config/printer.conf   -- Printer configuration (name, etc.)
  pdfs/                 -- PDF output files land here
  Dockerfile            -- Container image definition (Ubuntu 24.04 + CUPS)
  docker-compose.yml    -- Compose file with bind mounts and port mapping
  entrypoint.sh         -- Container startup script


QUICK START
-----------
1. (Optional) Edit config/printer.conf to set your desired printer name:

     PRINTER_NAME=MyPDFPrinter

2. Start the container:

     docker compose up -d

3. The printer is now available via IPP at:

     ipp://localhost:631/printers/<PRINTER_NAME>

4. The CUPS web interface is available at:

     http://localhost:631


CONFIGURATION
-------------
config/printer.conf supports the following key:

  PRINTER_NAME=<name>
    The name of the printer as it appears in CUPS and on the network.
    Default: PDF-Printer
    Changes require a container restart to take effect.


PRINTING
--------
From Linux/macOS (command line):

  lp -h localhost:631 -d PDF-Printer /path/to/file.pdf

From Windows:
  Add a network printer pointing to:
    http://localhost:631/printers/<PRINTER_NAME>
  using the IPP protocol (Windows IPP printer wizard).

From any app:
  Select the printer named <PRINTER_NAME> on the CUPS server at
  localhost:631 or <host-ip>:631.


PDF OUTPUT
----------
All printed PDFs are saved to the pdfs/ folder on the host.
Filenames are derived from the print job name.


PORTS
-----
  631/tcp   CUPS web interface and IPP printing


NOTES
-----
- The config/ volume is mounted read-only inside the container.
- The pdfs/ volume is mounted read-write; CUPS writes directly to it.
- Authentication is disabled by default — suitable for local/trusted networks.
  To enable basic auth, change DefaultAuthType in entrypoint.sh to:
    DefaultAuthType Basic
  and set a CUPS admin password inside the container:
    docker exec -it cups-pdf-printer passwd root
