# Getting started

Start a common Flask project (see the (official doc)[https://flask.palletsprojects.com/en/1.1.x/installation/#install-virtualenv] for details)

```bash
python3 -m venv venv
. venv/bin/activate

pip install -r requirements.txt

FLASK_APP=src/main.py SAASFORM_SERVER='http://192.168.50.242:7000' flask run
```

Visit [http://192.168.50.242:7000].