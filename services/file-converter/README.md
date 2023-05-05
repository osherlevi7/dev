## Convert file to `.pdf` format using [libreoffice](https://www.libreoffice.org/)


#### Requirements
 - [docker](https://www.docker.com/)
 - [docker-compose](https://docs.docker.com/compose/)
 
#### Build and Run locally with `docker`
```bash
docker build -t file-converter .
```
```bash
docker run --rm -p 8000:80 file-converter
```
* same with `docker-compose`
```bash
docker-compose -f development/compose.yaml up --build
```

#### Development inside `docker`
* run inside docker with automatic reload on local code change
```bash
docker run -e ENVIRONMENT=development -p 8000:80 -v $(pwd):/app file-converter /start-reload.sh
```
* same with `docker-compose`
```bash
docker-compose -f development/compose-with-reload.yaml up --build
```


#### Development locally
* set `ENVIRONMENT` variable to `development`
```bash
export ENVIRONMENT=development
```

* install [libreoffice](https://www.libreoffice.org/download/download/)

* set environment variable `LIBREOFFICE` to your local libreoffice executable, e.g. for MacOS
```bash
export LIBREOFFICE=/Applications/LibreOffice.app/Contents/MacOS/soffice
```

* install development requirements
```bash
pip install -r development/requirements.txt
```

* run with uvicorn from inside `app` directory
```bash
uvicorn main:app --reload --port 8000
```

#### Examples are in `development/examples`
* move to `using_aiohttp` or `using_requests` and run
```bash
python convert.py 
```

#### Default Basic Auth credentials
- username: `FILE_CONVERTER_USERNAME`
- password: `FILE_CONVERTER_PASSWORD`
