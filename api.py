import time
import threading
from flask import render_template, Blueprint
import MySQLdb
from decorators import async
import requests


api = Blueprint('api', __name__)
api.config = {}

CHANNELS = 24 #will make this dynamic when intergrating DB

sendingActive = False

@api.record
def record_params(setup_state):
  app = setup_state.app
  api.config = dict([(key,value) for (key,value) in app.config.iteritems()])

@api.route('/')
def index():
    #should return general data about scenenames categories etc
    # as a json format
    return "Test"

@api.route('/channel/<int:chanid>/value/<int:value>')
@api.route('/channel/<int:chanid>/value/<int:value>/fade/<int:fadetime>')
def changeChannel(chanid, value, fadetime=0):
    channel = query_db("SELECT * FROM channels WHERE cid = %s", [chanid])[0]['cnumber']

    data = []
    for i in range(CHANNELS):
        data.append(None)

    data[channel-1] = int(value)
    startScene(data, fadetime=fadetime)
    return str(data)

@api.route('/scene/<int:sceneid>/value/<int:value>')
@api.route('/scene/<int:sceneid>/value/<int:value>/fade/<int:fadetime>')
def changeScene(sceneid, value, fadetime=0):
    allChannels = query_db("SELECT * FROM scene_channels_full WHERE sceneid = %s", [sceneid])
    data = []
    data.extend([None] * (CHANNELS - len(data)))

    for row in allChannels:
        data[row["cnumber"]-1] = int(row["percent"] * value /100)

    startScene(data, fadetime=fadetime)
    return str(data)

@api.route('/stack/<int:sceneid>/value/<int:value>')
@api.route('/stack/<int:sceneid>/value/<int:value>/fade/<int:fadetime>')
def changeStack(stack, value, fadetime=0):

    return "nope"


# Database shisazt
def connect_db():
    return MySQLdb.connect(host=api.config['DB_HOST'],    # your host, usually localhost
                         user=api.config['DB_USER'],         # your username
                         passwd=api.config['DB_PASS'],  # your password
                         db=api.config['DB_NAME'])        # name of the data base

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


# Functions and variables about actually sending data to olad

TICK_INTERVAL = 100 #send data ever x ms
UNIVERSE = 1 # DMX universe

currentLightValues = [] #set of values to send
currentLightTimecodes = [] # which thread controls what

# Pad arrays (to stop errors from occuring)
currentLightValues.extend([0] * (CHANNELS - len(currentLightValues)))
currentLightTimecodes.extend([0] * (CHANNELS - len(currentLightTimecodes)))

oldLightValues = [] # to check that we aren't sending the same list each time

sendingActive = False

def startScene(endstate, fadetime=0, timestamp=None):
    if sendingActive == False:
        restartSending()

    toChange = 0
    changeAmount = [] #amount to change by each frame

    tickgoal = int(fadetime/TICK_INTERVAL)
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
            if currentLightTimecodes[i] < timestamp:
                currentLightTimecodes[i] = timestamp
                toChange = toChange + 1
        else:
            #changeAmount.append(light)
            currentLightValue = currentLightValues[i]
            if fadetime == 0:
                changeAmount.append(light - currentLightValue)
            else:
                changeAmount.append((light - currentLightValue)/tickgoal)

            if currentLightTimecodes[i] < timestamp:
                currentLightTimecodes[i] = timestamp
                toChange = toChange + 1

    if toChange == 0:
        return "None to change"
    sendFrame(tickgoal, changeAmount, timestamp)

def sendFrame(tickgoal, diff, timestamp):
    # send new set of values to currentLightValues

    for i in range(len(currentLightValues)):
        if currentLightTimecodes[i] == timestamp:
            currentLightValues[i] = currentLightValues[i] + diff[i]

    # if we have gone through this as many times as we need to don't do it again
    # otherwise do do it again
    tickgoal = tickgoal - 1
    if tickgoal >= 1:
        threading.Timer(TICK_INTERVAL/1000, sendFrame, [tickgoal, diff, timestamp]).start()

def sendData():
    if sendingActive:
        threading.Timer(TICK_INTERVAL/1000, sendData).start()
        # So the old version of this used the annoying ola wrapper
        # but due to issues with threading that would not work in this version
        # so I'm using their JSON api
        d = ','.join(str(x) for x in currentLightValues)
        print(d)
        requests.post('http://127.0.0.1:9090/set_dmx', data = {'u':'1', 'd':d})
    else:
        print "Sending Finished"

def DmxSent(True):
    if not sendingActive:
        #wrapper.Stop()
        print("death")

def restartSending():
    global sendingActive
    sendingActive = True
    #wrapper.Run()
    sendData()

def stopSending():
    sendingActive = False


if __name__ == '__main__':
    #wrapper.Run()
    sendData()
