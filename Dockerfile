FROM python:3.10.11-slim-bullseye

WORKDIR /app

RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    apt-get clean && \
    apt-get update -o Acquire::Check-Valid-Time=false && \
    apt-get install --no-install-recommends -y \
    libpq-dev wget gcc g++ make cmake build-essential python3-dev git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Python仮想環境
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# pip / wheel の更新
# setuptoolsはここでは更新しない
RUN pip install --no-cache-dir --upgrade pip wheel

# requirements
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# pkg_resources対策：setuptoolsのバージョンを固定
RUN pip install --no-cache-dir --force-reinstall setuptools==80.9.0

# SuperAGIソース
COPY . .

RUN python superagi/tool_manager.py || true
RUN chmod +x install_tool_dependencies.sh || true

CMD ["celery", "-A", "superagi.worker", "worker", "--beat", "--loglevel=info"]
