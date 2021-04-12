#Indicar la imagen de DockerHub a utilizar, en este caso Debian
FROM debian

#Establecer variables de zona y para que no nos salgan errores de frontend
ENV TZ=Europe/Madrid
ENV DEBIAN_FRONTEND=noninteractive

#Directorio por defecto
WORKDIR /var/www/html
COPY modsec.conf /var/www/html/

#Instalación de paquestes
RUN apt-get update -y -qq >/dev/null \
     && apt-get install -y nano bison build-essential ca-certificates curl dh-autoreconf doxygen flex gawk git iputils-ping libcurl4-gnutls-dev libexpat1-dev libgeoip-dev liblmdb-dev libpcre3-dev libpcre++-dev libssl-dev libtool libxslt1-dev libgd-dev libxml2 libxml2-dev libyajl-dev locales lua5.3-dev pkg-config wget zlib1g-dev zlibc nginx php7.3-fpm >/dev/null \    
     && apt-get purge --auto-remove \
     && apt-get clean \
     && rm -r /var/lib/apt/lists/* \
     && mkdir /etc/nginx/ssl \
     && bash modsec.conf

#Copia de los archivos de la página, el entrypoint, el fichero de configuración de apache y el fichero de configuración de modsecurity
COPY public_html /var/www/html/public_html
COPY index.php /var/www/html/index.php
COPY nginx.conf /etc/nginx/nginx.conf
COPY modsecurity.conf-recommened /etc/nginx/modsec/modsecurity.conf
COPY main.conf /etc/nginx/modsec/main.conf
COPY default /etc/nginx/sites-available/default
COPY ssl-cert-snakeoil.pem /etc/nginx/ssl/ssl-cert-snakeoil.pem
COPY ssl-cert-snakeoil.key /etc/nginx/ssl/ssl-cert-snakeoil.key


RUN chmod 400 /etc/nginx/ssl/ssl-cert-snakeoil.key \
    && ldconfig

#Indicar el entrypoint
CMD service php7.3-fpm start && nginx -g "daemon off;"
