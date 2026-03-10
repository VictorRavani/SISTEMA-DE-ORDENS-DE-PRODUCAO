FROM python:3.8-slim

# Configuração do timezone e diretório de trabalho
ENV TZ=America/Sao_Paulo
WORKDIR /app

# Atualizar e instalar dependências necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    unixodbc-dev \
    gcc \
    g++ \
    make \
    curl \
    gnupg \
    software-properties-common \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    tzdata \
    apt-transport-https && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar timezone
RUN echo $TZ > /etc/timezone && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Configurar repositório Microsoft e instalar drivers MSSQL
RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
    apt-get install -y unixodbc-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Atualizar PATH para incluir ferramentas MSSQL
ENV PATH="$PATH:/opt/mssql-tools/bin"

# Atualizar pip e instalar dependências críticas separadamente
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir numpy pandas

# Adicionar arquivos de dependências da aplicação
ADD ./requirements.txt /app

# Instalar dependências da aplicação
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copiar arquivos da aplicação
COPY ./ /app

# Comando padrão para execução da aplicação
CMD ["uwsgi", "--ini", "wsgi.ini"]

