import time
import threading
from flask import render_template, Blueprint, g
import requests
import sqlite3

api = Blueprint('api', __name__)
api.config = {}

CHANNELS = 24 #will make this dynamic when intergrating DB
TICK_INTERVAL = 100 #send data ever x ms
UNIVERSE = 1 # DMX universe
try:
    bpm = int(query_db("SELECT value FROM settings where name = 'bpm'")[0]['value'])
except:
    bpm = 60

try:
    globalFadetime = int(query_db("SELECT value FROM settings where name = fadetime")[0]['value']) #note this currently only applies to stacks
except:
    globalFadetime = 0
sendingActive = False
currentStacks = {}

currentLightValues = [] #set of values to send
currentLightTimecodes = [] # which thread controls what

# Pad arrays (to stop errors from occuring)
currentLightValues.extend([float(0)] * (CHANNELS - len(currentLightValues)))
currentLightTimecodes.extend([0] * (CHANNELS - len(currentLightTimecodes)))

oldLightValues = [] # to check that we aren't sending the same list each time

sendingActive = False


@api.record
def record_params(setup_state):
  app = setup_state.app
  api.config = dict([(key,value) for (key,value) in app.config.iteritems()])

@api.route('/')
def index():
    #should return general data about scenenames categories etc
    # as a json format
    # also the current global fade time and the state of the chases
    return "Test"

@api.route('/all/<int:value>')
@api.route('/all/<int:value>/fade/<int:fadetime>')
def changeAll(value, fadetime=0):
    data = []
    data.extend([value] * CHANNELS)

    startScene(data, fadetime=fadetime)
    return str(data)


@api.route('/channel/<int:chanid>/value/<int:value>')
@api.route('/channel/<int:chanid>/value/<int:value>/fade/<int:fadetime>')
def changeChannel(chanid, value, fadetime=0):
    channel = query_db("SELECT * FROM channels WHERE cid = ?", [chanid])[0]['cnumber']

    data = []
    for i in range(CHANNELS):
        data.append(None)

    data[channel-1] = int(value)
    startScene(data, fadetime=fadetime)
    return str(data)

@api.route('/scene/<int:sceneid>/value/<int:value>')
@api.route('/scene/<int:sceneid>/value/<int:value>/fade/<int:fadetime>')
def changeScene(sceneid, value, fadetime=0):
    allChannels = query_db("SELECT * FROM scene_channels_full WHERE sceneid = ?", [sceneid])
    data = []
    data.extend([None] * (CHANNELS - len(data)))

    for row in allChannels:
        data[row["cnumber"]-1] = int(row["percent"] * value /100)

    startScene(data, fadetime=fadetime)
    return str(data)

@api.route('/stack/<int:stackid>/value/<int:value>')
@api.route('/stack/<int:stackid>/value/<int:value>/fade/<int:fadetime>')
def changeStack(stackid, value, fadetime=0):
    stack = query_db("SELECT * FROM stack_scenes_order WHERE stackid = ?", [stackid])
    global globalFadetime
    globalFadetime = fadetime

    stackdata = []
    timestamp = time.time()
    applicLights = []

    for row in stack:
        # note we don't need to keep track of
        sceneid = row["sceneid"]
        allChannels = query_db("SELECT * FROM scene_channels_full WHERE sceneid = ?", [sceneid])
        sceneData =dict()
        sceneData['beats'] = row["beats"]
        data = []
        data.extend([None] * (CHANNELS - len(data)))

        for channelRow in allChannels:
            data[channelRow["cnumber"]-1] = int(float(channelRow["percent"]) * float(row["percent"]) * value * 0.0001)
            applicLights.append(channelRow["cnumber"]-1)
            currentLightTimecodes[channelRow["cnumber"]] = timestamp

        sceneData['channels'] = data

        stackdata.append(sceneData)

    try:
        currentpos = currentStacks[stackid]["position"]
        currentbeat = currentStacks[stackid]["beat"]
    except:
        currentpos = 0
        currentbeat = 0
        currentStacks[stackid] = {"position":0, "beat":0}

    doStack(stackdata, stackid, timestamp, applicLights, currentpos=currentpos, currentbeat=currentbeat)
    return str(stackdata) + str(applicLights)

@api.route('/fade/<int:fadetime>')
def changeFadetime(fadetime):
    global globalFadetime
    globalFadetime = fadetime
    test = query_db("UPDATE settings SET value = ? WHERE name = 'fadetime'", [fadetime])

    return "Fadetime = " + str(globalFadetime) + str(test)

@api.route('/bpm/<int:beats>')
def changeBPM(beats):
    global bpm
    bpm = beats
    query_db("UPDATE settings SET value = ? WHERE name = 'bpm'", [bpm])
    return "Bpm = " + str(bpm)


def doStack(stackdata, stackid, timestamp, applicablelights, currentpos=0, currentbeat=0):
    stillActive = False
    for i in applicablelights:
        if currentLightTimecodes[i] <= timestamp:
            stillActive = True
            continue

    if stillActive == False:
        del currentStacks[stackid]
        return "Finished (ran out of lights)"

    try:
        currentScene = stackdata[currentpos]['channels']
        currentSceneBeats = stackdata[currentpos]['beats']
    except IndexError:
        currentpos = 0
        currentScene = stackdata[currentpos]['channels']
        currentSceneBeats = stackdata[currentpos]['beats']

    if currentbeat == 0:
        # do current scene and set all other applicable lights to 0 (on same fadetime)
        backScene = []
        backScene.extend([None] * (CHANNELS))

        for i in applicablelights:
            if currentScene[i] == None:# not in currentScene
                backScene[i] = 0
            # add to backscene
        #print("About to start new scenes")
        #print(str(currentScene))
        #print(str(backScene))
        startScene(backScene, fadetime=globalFadetime, timestamp=timestamp)
        startScene(currentScene, fadetime=globalFadetime, timestamp=timestamp)
        #print(str(currentLightValues))

    # add to currentper based on beats and bpm etc
    currentbeat = currentbeat + 1
    if currentbeat >= currentSceneBeats:
        currentbeat = 0
        currentpos = currentpos + 1

    currentStacks[stackid] = {"position":currentpos, "beat":currentbeat}

    # schedule scene in 1 beat
    wait = 60/bpm
    #print("test" + str(currentbeat) + " " + str(currentpos))
    threading.Timer(wait, doStack, [stackdata, stackid, timestamp, applicablelights], {'currentpos': currentpos, 'currentbeat':currentbeat}).start()

    return "Nope"

def startScene(endstate, fadetime=0, timestamp=None):
    if sendingActive == False:
        restartSending()

    toChange = 0
    changeAmount = [] #amount to change by each frame

    tickgoal = int(fadetime/TICK_INTERVAL + 0.5)
    if tickgoal < 1:
        tickgoal = 1

    if timestamp == None:
        timestamp = time.time()

    for i in range(len(endstate)):
        light = endstate[i]
        if light == None:
            changeAmount.append(0)
        elif light == currentLightValues[i]:
            changeAmount.append(0)
            #while not a change this signals that whatever previous process had control over it
            if currentLightTimecodes[i] <= timestamp:
                currentLightTimecodes[i] = timestamp
                toChange = toChange + 1
        else:
            #changeAmount.append(light)
            currentLightValue = currentLightValues[i]
            if fadetime == 0:
                changeAmount.append(float(light - currentLightValue))
            else:
                changeAmount.append(float((light - currentLightValue)/tickgoal))

            if currentLightTimecodes[i] <= timestamp:
                currentLightTimecodes[i] = timestamp
                toChange = toChange + 1

    if toChange == 0:
        return "None to change"
    sendFrame(tickgoal, changeAmount, timestamp)

def sendFrame(tickgoal, diff, timestamp):
    # send new set of values to currentLightValues

    for i in range(len(currentLightValues)):
        if currentLightTimecodes[i] == timestamp:
            currentLightValues[i] = float(currentLightValues[i] + diff[i])

    # if we have gone through this as many times as we need to don't do it again
    # otherwise do do it again
    tickgoal = tickgoal - 1
    if tickgoal >= 1:
        # this here will only work if you multiply, and will fail if you divide, why WHO KNOWS
        wait = TICK_INTERVAL * 0.001
        threading.Timer(wait , sendFrame, [tickgoal, diff, timestamp]).start()

def sendData():
    if sendingActive:
        threading.Timer((TICK_INTERVAL * 0.001), sendData).start()
        # So the old version of this used the annoying ola wrapper
        # but due to issues with threading that would not work in this version
        # so I'm using their JSON api
        d = ','.join(str(int(x+0.5)) for x in currentLightValues)
        #print(str(currentLightValues))
        requests.post('http://127.0.0.1:9090/set_dmx', data = {'u':'1', 'd':d})
    else:
        print "Sending Finished"


def restartSending():
    global sendingActive
    sendingActive = True
    #wrapper.Run()
    sendData()

def stopSending():
    sendingActive = False

def connect_db():
    return sqlite3.connect(api.config['DATABASE'])

@api.before_request
def before_request():
    g.db = connect_db()
    g.db.execute("PRAGMA foreign_keys = ON;")
    g.db.row_factory = sqlite3.Row

@api.teardown_request
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



if __name__ == '__main__':
    sendData()
