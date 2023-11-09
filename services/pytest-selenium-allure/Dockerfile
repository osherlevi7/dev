# Build stage
FROM python:3.9.6-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libssl-dev \
        libffi-dev && \
    pip install --no-cache-dir --user -r requirements.txt
# Production stage
FROM selenium/standalone-chrome:3.141.59-20210525
# Create a non-root user and switch to that user
RUN groupadd -r selenium && useradd -r -g selenium selenium
USER selenium
WORKDIR /selenium-automation
COPY --from=build --chown=selenium:selenium /root/.local /root/.local
COPY . .
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
     unzip \
     xvfb \
     libxi6 \
     libgconf-2-4 \
     default-jdk \
     wget \
     google-chrome-stable \
     python3-pip \
     gnupg1 \
     gnupg2 \
  && curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google-chrome.list \
  && wget -q -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip \
  && mkdir -p /opt/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/chromedriver \
  && rm /tmp/chromedriver_linux64.zip \
  && chmod +x /opt/chromedriver/chromedriver \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt \
  && apt-get remove -y --auto-remove unzip wget gnupg1 gnupg2 \
  && rm -rf /var/lib/apt/lists/* /tmp/*
# Run the application as the non-root user
USER selenium
CMD ["pytest"]