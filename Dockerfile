FROM debian:jessie-slim
MAINTAINER Joakim Karlsson <jk@patientsky.com>

RUN apt-get update \
  && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF


RUN echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list \
  && echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
  && echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
  && apt-get update \
  && apt-get install -y binutils mono-devel ca-certificates-mono fsharp mono-vbnc nuget referenceassemblies-pcl mono-devel apache2 libapache2-mod-mono mono-apache-server4 mono-xsp4-base --no-install-recommends \
  && a2enmod mod_mono \
  && service apache2 stop \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/tmp/* \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/mono/registry /etc/mono/registry/LocalMachine \
  && sed -ri ' \
      s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
      s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
      ' /etc/apache2/apache2.conf
  
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
ADD ./config/apache2-site.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
