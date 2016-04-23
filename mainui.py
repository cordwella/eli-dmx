from flask import request, session, redirect, url_for, \
    render_template, flash, Blueprint, g
import sqlite3

mainui = Blueprint('mainui', __name__)
mainui.config = {}

## Overide to allow access to configuration values
@mainui.record
def record_params(setup_state):
  app = setup_state.app
  mainui.config = dict([(key,value) for (key,value) in app.config.iteritems()])

# Pages
@mainui.route('/')
def index():
    channels = query_db("SELECT * FROM channel_with_category")
    scenes = query_db("SELECT * FROM scene_with_category")
    stacks = query_db("SELECT * FROM stack_with_category")
    bpm = query_db("SELECT value FROM settings WHERE name='bpm'")[0]["value"]
    fadetime = query_db("SELECT value FROM settings WHERE name='fadetime'")[0]["value"]

    return render_template('index.html', channels=channels, scenes=scenes, stacks=stacks, fadetime=fadetime, bpm=bpm)

@mainui.route('/test')
def test():
    bpm = query_db("SELECT value FROM settings WHERE name='bpm'")[0]["value"]
    fadetime = query_db("SELECT value FROM settings WHERE name='fadetime'")[0]["value"]
    return "bpm: " + str(bpm) +" fade :" + str(fadetime)
## when editing scenes, stacks etc, delete all of them in the db and then re add them
# as defined in ui
# this is not the most efficent solution however given time constraints
# im tired

# Database shisazt
def connect_db():
    return sqlite3.connect(mainui.config['DATABASE'])

@mainui.before_request
def before_request():
    g.db = connect_db()
    g.db.execute("PRAGMA foreign_keys = ON")
    g.db.row_factory = sqlite3.Row

@mainui.teardown_request
def teardown_request(exception):
    g.db.commit()
    db = getattr(g, 'db', None)
    if db is not None:
        db.close()

def query_db(query, args=(), one=False):
    cur = g.db.execute(query, args)
    rv = cur.fetchall()
    cur.close()
    return (rv[0] if rv else None) if one else rv
