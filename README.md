# ELi-DMX

ELi-DMX is lightweight python-based lighting control software build on top of the Open Lighting Arcitecture. It was originally designed as an android app and associated server files, however I rebuilt it as a Flask based webapp to reduce confusion and allow it to be controlled from any sort of device.

This new version adds channel editing and stack editing, as well as in app addition of categories, and stacks (or chases). It also reduces dependencies by being a self contained python app, with the data being stored in a sqlite file.

ELi-DMX has only been tested in Ubuntu 14.04 and 16.04.

### Libaries in use

ELi-DMX makes use of a number of open-source libraies to get the job done.
[Bootstrap](http://getbootstrap.com) is used here under the terms of the MIT license.
[jQuery](https://jquery.org) is used here under the terms of the MIT license.
The Sortable.js is also used under the MIT License.


## Installation

First install python and the [Open Lighting Architecture](https://www.openlighting.org/). Make sure that the http server for OLA is installed (if you are apt-getting it should install). ELi-DMX runs on Python 2.7.

Instructions for installing OLA are [here](https://www.openlighting.org/ola/getting-started/downloads/), and more specific instructions for Ubuntu are [here](http://opendmx.net/index.php/The_Newbie_Guide_for_OLA_on_Ubuntu). Then use the OLA webapp to set up a universe, it should be universe 1 for ELi-DMX however this can be changed inside the api.py file of ELi-DMX.

Clone this repo into a folder of your choice, and then install the python libraries for sqlite3 (this may already be installed with your python install), and [Flask](http://flask.pocoo.org/). Make sure that the python script will be able to read and write in the folder it is in.

The next step is to set up the configuration file, and then the database.

In the folder that you have downloaded ELi-DMX to create a file named `application.cfg`. It should read somewhat like this:

```
DATABASE = 'data.db'
SECRET_KEY = "your secret key"
PORT = 80
```

Changing DATABASE will change where the sqlite database file is stored, secret key is nessacary for Flask to run, and the PORT value is optional but will change the http port that it runs on.

The only set up left to do is setting up the sqlite file. In the terminal navigate to the folder that ELi-DMX is saved in then enter the python interpreter.

```
cd \path\to\folder\elidmx
python
```

Once inside the python interpreter run these commands.

```
from __init__ import init_db
init_db()
```

You should receive a message saying that the database has been created. If this has worked the software is all set up! Yay

## Use
First make sure that olad is running. olad is the OLA daemon which handles the requests to the DMX controller, it can be started by running `olad` in a terminal window. You can test this by going to localhost:9090. IMPORTANT: Make sure you are not on the channel setting page in the site, this will try to override ELi-DMX and your lights will flicker.

Start the server by in the terminal navigating to the folder that Eli-DMX is contained in. Then run the command `python __init__.py`. (Note that certian port numbers such as 80 will require sudo to run). This will start the server.

Then just navigate to your computer's IP address in your web browser (with a port if your set port is not 80) and you can start using the app. On the first time you access the site it may take a little while longer to load jQuery and Bootstrap.

### Adding and Editing Data

#### Adding/Editing channels
To add a channel click on the 'add channel' button in the nav bar, enter the channel's name, it's DMX address ('DMX Channel number') and any category it is a part of. Hitting save will add the channel to the database, and redirect you back to the main page.

To edit a channel click 'edit' by the channel's name on the main page. Make your changes and hit save to save. If you change a channel's DMX address this will be automatically updated for whichever scenes they are in.

A channel can be deleted by clicking the button next to the edit sign.

#### Adding/Editing Scenes
To add a channel click on the 'Add Scene' button in the nav bar.

Then enter the scene's name and it's category.

To add channels to the scene just drag the slider bars, and then hit save.

A channel can be deleted by clicking the button next to the edit sign.

#### Adding/Editing Stacks
To add a channel click on the 'Add stack' button in the nav bar.

Stacks are built of series of scenes, each with a specified 'beat' value, determining the time it is active (when controlling the stack you can change the beats per minute). Drag the scene from the 'All scenes' side over to the 'Scenes in Current Stack' to add it to the stack, then drag the slider for brightness and specify the number of beats. A scene can be removed by clicking the little red 'x' symbol.

A channel can be deleted by clicking the button next to the edit sign.

#### Adding Categories
Currently the UI allows for categories to be added but not removed. This will be fixed in later versions. To add a category just click on the 'Add Category' button and enter the name in.

### Controlling the lights
To control the lights once set up simply drag the sliders for the channel, scene or chase. Unlike, other control systems (like most lighting boards) ELi-DMX prioritizes the last sent command, so be aware of this for lights in multiple scenes or stacks.

If you are using LED lights will a 'main' dimmer channel and colored channels, I would advise that you put these all on one scene and only change when absolutely necessary and instead focus on controlling induvidual color channels.

The time of a fade can be set by the slider on the bottom right, and the beats per minute setting can be changed on the bottom left. The BPM setting only affects stacks as their timing interval is set in BPM. The fadetime will also be used within the stack.

### Backups, and switching systems out
One of the good outcomes of using sqlite is that if you are wishing to switch computer, or switch from one lighting setup to another it is simply a matter of copying files over. The name for the sqlite file that the app will use is set in application.cfg, so to change the file it points to it is only a matter of changing that variable and restarting the app. If you are wishing to start afresh with a new database you will need to follow some of the instructions around 'Creating the database' in the installation section above.

## Final Notes
I would advise keeping ELi-DMX to an internal private wi-fi network as it has no password protection.

Currently there is no support for blind recording of scenes and stacks.
