from flask import Flask
from mainui import mainui
from api import api
import sqlite3

app = Flask(__name__)
app.config.from_pyfile('application.cfg', silent=True)
app.register_blueprint(mainui)
app.register_blueprint(api, url_prefix='/api')


if __name__ == '__main__':
    if(app.config.get('PORT')):
        app.run(port=app.config.get('PORT'))
    else:
        app.run()

def connect_db():
    return sqlite3.connect(app.config['DATABASE'])

def init_db():
    with app.app_context():
        db = connect_db()
        with app.open_resource('elidmx.sql', mode='r') as f:
            db.cursor().executescript(f.read())
        db.commit()
