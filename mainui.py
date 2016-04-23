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


@mainui.route('/delete/category/<int:catid>')
def deleteCategory(catid):
    # Everything is set up to delete via the foriegn keys
    query_db("DELETE FROM categories WHERE id = ?", [catid])
    flash("Category Deleted")
    return redirect(url_for('mainui.index'))


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


@mainui.route('/edit/scene/<int:sceneid>',  methods=['GET', 'POST'])
@mainui.route('/edit/scene/new',  methods=['GET', 'POST'])
def editScene(sceneid=None):

    if request.method == "POST":
        channels = map( int, request.form.get('channels', "").split(',') )
        values = map( int, request.form.get('values', "").split(',') )

        # CLEAN CHANNELS AND VALUES

        category = request.form["category"]
        name = request.form["name"]

        if sceneid != None:
            query_db("UPDATE scenes SET sname = ?, scenecategoryid = ? WHERE stid = ?", [name, category, sceneid])
            query_db("DELETE FROM scene_channels WHERE sceneid = ?", [sceneid])
        else:
            query_db("INSERT INTO scenes ('sname', 'scenecategoryid') VALUES (?,?)", [name, category])
            sceneid = query_db("SELECT sid from scenes where sname = ?", [name])[0]["sid"]

        for i in range(len(channels)):
            query_db("INSERT INTO scene_channels ('sceneid', 'channelid', 'percent') VALUES (?,?,?)", [sceneid, channels[i], values[i]])

        flash("Scene Saved")
        return redirect(url_for("mainui.index"))

    categories = query_db("SELECT * FROM categories")
    channels = query_db("SELECT * FROM channel_with_category ORDER BY cnumber")
    if(sceneid != None):
        scene = query_db("SELECT * FROM scenes WHERE sid = ?", [sceneid])[0]
        name = scene["sname"]
        schannels = query_db("SELECT * FROM scene_channels_full WHERE sceneid = ? ORDER BY cnumber", [sceneid])
        # run though channels and place s channel values there
        n = 0
        for i in range(len(schannels)):
            schan = schannels[i]
            noMatch = True
            while noMatch:

                if schan["cnumber"] == channels[n]["cnumber"]:
                    channels[n]["percent"] = schan["percent"]
                    noMatch = False
                n = n + 1

        return render_template("editscene.html", sceneid=sceneid, name=name, channels=channels, categories=categories)

    return render_template("editscene.html", sceneid=sceneid, categories=categories, channels=channels)


@mainui.route('/delete/scene/<int:sceneid>')
def deleteScene(sceneid):
    query_db("DELETE FROM scenes WHERE sid = ?", [sceneid])
    flash("Scene Deleted")
    return redirect(url_for('mainui.index'))


@mainui.route('/edit/stack/<int:stackid>',  methods=['GET', 'POST'])
@mainui.route('/edit/stack/new',  methods=['GET', 'POST'])
def editStack(stackid=None):

    if request.method == "POST":
        scenes = map( int, request.form.get('scenes', "").split(',') )
        values = map( int, request.form.get('values', "").split(',') )
        print(request.form.get('beatlist', "") + "death")
        beats = map( int, request.form.get('beatlist', "").split(',') )

        category = request.form["category"]
        name = request.form["name"]

        if stackid != None:
            query_db("UPDATE stacks SET stname = ?, stackcategoryid = ? WHERE stid = ?", [name, category, stackid])
            query_db("DELETE FROM stack_scenes WHERE stackid = ?", [stackid])
        else:
            query_db("INSERT INTO stacks ('stname', 'stackcategoryid') VALUES (?,?)", [name, category])
            stackid = query_db("SELECT stid from stacks where stname = ?", [name])[0]["stid"]

        for i in range(len(scenes)):
            query_db("INSERT INTO stack_scenes ('stackid', 'sceneid', 'beats', 'stackorder', 'percent') VALUES (?,?,?,?,?)", [stackid, scenes[i], beats[i], i, values[i]])

        flash("Stack Saved")
        return redirect(url_for("mainui.index"))

    categories = query_db("SELECT * FROM categories")
    scenes = query_db("SELECT * FROM scene_with_category")
    if(stackid != None):
        stack = query_db("SELECT * FROM stacks WHERE stid = ?", [stackid])[0]
        name = stack["stname"]
        stscenes = query_db("SELECT * FROM stack_scenes_full WHERE stackid = ?", [stackid])
        return render_template("editstack.html", stackid=stackid, name=name, stscenes=stscenes, scenes=scenes, categories=categories)

    return render_template("editstack.html", stackid=stackid, categories=categories, scenes=scenes)


@mainui.route('/delete/stack/<int:stackid>')
def deleteStack(stackid):
    # Everything is set up to delete via the foriegn keys
    query_db("DELETE FROM stacks WHERE stid = ?", [stackid])
    flash("Stack Deleted")
    return redirect(url_for('mainui.index'))

# Database shisazt
def connect_db():
    return sqlite3.connect(mainui.config['DATABASE'])

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

@mainui.before_request
def before_request():
    g.db = connect_db()
    g.db.execute("PRAGMA foreign_keys = ON")

@mainui.teardown_request
def teardown_request(exception):
    g.db.commit()
    db = getattr(g, 'db', None)
    if db is not None:
        db.close()

def query_db(query, args=(), one=False):
    g.db.row_factory = dict_factory
    cur = g.db.execute(query, args)
    rv = cur.fetchall()
    cur.close()
    return (rv[0] if rv else None) if one else rv
