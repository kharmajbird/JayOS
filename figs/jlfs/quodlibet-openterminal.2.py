#!/usr/bin/python

import gtk
from qltk import ErrorMessage
from plugins.songsmenu import SongsMenuPlugin
from qltk.entry import ValidatingEntry
import util
import config
import os

class BrowseFolders(SongsMenuPlugin):
    PLUGIN_ID = 'Open Terminal'
    PLUGIN_NAME = _('Open Terminal')
    PLUGIN_DESC = "Open a terminal at this location"
    PLUGIN_ICON = 'gtk-about'
    PLUGIN_VERSION = '0.1'

    def plugin_songs(self, songs):
        c = os.getcwd()
        d = dict.fromkeys([song('~dirname') for song in songs]).keys()[0]
        os.chdir(d)
        os.system('x-terminal-emulator')
        os.chdir(c)
