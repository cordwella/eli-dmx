from flask import request, session, redirect, url_for, \
    render_template, flash, Blueprint
import MySQLdb

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

    return render_template('index.html', channels=channels, scenes=scenes, stacks=stacks)

## when editing scenes, stacks etc, delete all of them in the db and then re add them
# as defined in ui
# this is not the most efficent solution however given time constraints
# im tired

# Database shisazt
def connect_db():
    return MySQLdb.connect(host=mainui.config['DB_HOST'],    # your host, usually localhost
                         user=mainui.config['DB_USER'],         # your username
                         passwd=mainui.config['DB_PASS'],  # your password
                         db=mainui.config['DB_NAME'])        # name of the data base

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
