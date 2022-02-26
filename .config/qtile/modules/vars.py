import os
import socket
from libqtile.config import Group
from libqtile import layout, bar, widget, hook

mod = "mod4"
alt = "mod1"
terminal = "alacritty"
browser = "brave"

groups = [Group("DEV", layout='monadtall'),
          Group("WWW", layout='monadtall'),
          Group("SYS", layout='monadtall'),
          Group("DOC", layout='monadtall'),
          Group("VBOX", layout='monadtall'),
          Group("CHAT", layout='monadtall'),
          Group("MUS", layout='monadtall'),
          Group("VID", layout='monadtall'),
          Group("GFX", layout='floating')]

groups = [Group(i, layout="monadtall") for i in "123456789"]

my_font = "Mononoki Nerd Font"
my_bar_font = "Ubuntu Nerd Font Bold"
prompt = "{0}@{1}: ".format(os.environ["USER"], socket.gethostname())
