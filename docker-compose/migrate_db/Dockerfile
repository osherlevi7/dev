FROM python:3.12-slim

COPY  migrate_db.py /usr/local/bin/migrate_db.py
COPY  requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt

ENTRYPOINT ["python", "/usr/local/bin/migrate_db.py"]
