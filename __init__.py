from flask import Flask
from mainui import mainui
from api import api, restartSending

app = Flask(__name__)
app.config.from_pyfile('application.cfg', silent=True)
app.register_blueprint(mainui)
app.register_blueprint(api, url_prefix='/api')


if __name__ == '__main__':
    app.run()
