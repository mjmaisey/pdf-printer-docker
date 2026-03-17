FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PRINTER_NAME=PDF-Printer

RUN apt-get update && apt-get install -y \
    cups \
    cups-pdf \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /pdfs /run/cups

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 631

ENTRYPOINT ["/entrypoint.sh"]
