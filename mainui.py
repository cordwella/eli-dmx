from flask import Flask, request, session, redirect, url_for, \
    abort, render_template, flash, send_from_directory
import MySQLdb

app = Flask(__name__)
app.config.from_pyfile('application.cfg', silent=True)

@app.route('/')
def index():
    channels = query_db("SELECT * FROM channel_with_category")
    scenes = query_db("SELECT * FROM scene_with_category")
    stacks = query_db("SELECT * FROM stack_with_category")

    return render_template('index.html', channels=channels, scenes=scenes, stacks=stacks)

# Database shisazt
def connect_db():
    return MySQLdb.connect(host=app.config['DB_HOST'],    # your host, usually localhost
                         user=app.config['DB_USER'],         # your username
                         passwd=app.config['DB_PASS'],  # your password
                         db=app.config['DB_NAME'])        # name of the data base

def query_db(query, values=0):
    """ Query DB & commit """
    db = connect_db()
    cur = db.cursor(MySQLdb.cursors.DictCursor)
    if isinstance(values, (list, tuple)):
        cur.execute(query, values)
    else:
        cur.execute(query)
    output = cur.fetchall()
    db.commit()
    db.close()
    return output


if __name__ == '__main__':
    app.run()
