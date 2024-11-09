FROM python:3.9-slim

WORKDIR /app

# Install system dependencies required for python-ldap
RUN apt-get update && apt-get install -y \
    python3-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"] 