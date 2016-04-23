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

@mainui.route('/addcat/<name>')
def addCategory(name):
    query_db("INSERT INTO categories ('category') values (?)", [name])
    return "OK"

@mainui.route('/edit/channel/<int:chanid>',  methods=['GET', 'POST'])
@mainui.route('/edit/channel/new',  methods=['GET', 'POST'])
def editChannel(chanid=None):

    if request.method == "POST":
        cnumber = request.form.get('number', "None")
        cname = request.form.get('name', "None")
        catid = request.form.get('category', "None")

        if chanid == None:
            try:
                query_db("INSERT INTO channels ('cname', 'cnumber', 'chancategoryid') VALUES (?,?,?)", [cname, cnumber, catid])
                chanid = query_db("SELECT cid FROM channels where cnumber = ?", [cnumber])
            except:
                flash("Database error, probs not unique values")
                categories = query_db("SELECT * FROM categories")
                return render_template("editchannel.html", cid=chanid, cname=cname, cnumber=cnumber, categories=categories, catid=catid)

        else:
            try:
                query_db("UPDATE channels SET 'cname' = ?, 'cnumber' = ?, 'chancategoryid' = ? WHERE cid = ?", [cname, cnumber, catid, cnumber])
            except:
                flash("Database error, probs not unique values")
                categories = query_db("SELECT * FROM categories")
                return render_template("editchannel.html", cid=chanid, cname=cname, cnumber=cnumber, categories=categories, catid=catid)

        flash("Channel '"+cname+"' saved to database")
        return redirect( url_for('mainui.index') )

    categories = query_db("SELECT * FROM categories")

    if(chanid != None):
        channel = query_db("SELECT * FROM channels WHERE cid = ?", [chanid])[0]
        cname = channel["cname"]
        cnumber = channel["cnumber"]
        return render_template("editchannel.html", cid=chanid, cname=cname, cnumber=cnumber, categories=categories)

    return render_template("editchannel.html", cid=chanid, categories=categories)

@mainui.route('/delete/channel/<int:chanid>')
def deleteChannel(chanid):
    query_db("DELETE FROM channels WHERE cid = ?", [chanid])
    flash("Channel Deleted")
    return redirect(url_for('mainui.index'))

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
