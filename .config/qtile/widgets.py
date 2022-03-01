from modules.vars import *
from libqtile import qtile
from libqtile import layout, bar, widget, hook
from libqtile.config import Click, Drag, Group, KeyChord, Key, Match, Screen

class MyWidgets:
    def __init__(self):
        self.colors = [
            ["#282c34", "#282c34"],
            ["#1c1f24", "#1c1f24"],
            ["#dfdfdf", "#dfdfdf"],
            ["#ff6c6b", "#ff6c6b"],
            ["#98be65", "#98be65"],
            ["#da8548", "#da8548"],
            ["#51afef", "#51afef"],
            ["#c678dd", "#c678dd"],
            ["#46d9ff", "#46d9ff"],
            ["#a9a1e1", "#a9a1e1"],
        ]

        self.separator_emoji = widget.TextBox(
            text = '',
            font = my_bar_font,
            background = self.colors[0],
            foreground = self.colors[3],
            padding = -7,
            fontsize = 48
        )

        self.separator_space = widget.Sep(
            linewidth = 0,
            padding = 6,
            foreground = self.colors[2],
            background = self.colors[0]
        )

        self.separator_pipe = widget.TextBox(
            text = '|',
            font = my_bar_font,
            background = self.colors[0],
            foreground = '474747',
            padding = 2,
            fontsize = 14
        )


    def init_widgets_list(self):
        return [
            self.separator_space,
            widget.Image(
                   filename = "~/.config/qtile/icons/python-white.png",
                   scale = "False",
                   mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(terminal)}
            ),
            self.separator_space,
            widget.GroupBox(
                   font = "Ubuntu Nerd Font",
                   fontsize = 11,
                   margin_y = 3,
                   margin_x = 0,
                   padding_y = 5,
                   padding_x = 3,
                   borderwidth = 3,
                   active =self.colors[2],
                   inactive =self.colors[7],
                   rounded = False,
                   highlight_color =self.colors[1],
                   highlight_method = "line",
                   this_current_screen_border =self.colors[-1],
                   this_screen_border =self.colors[5],
                   other_current_screen_border =self.colors[-1],
                   other_screen_border =self.colors[5],
                   foreground =self.colors[2],
                   background =self.colors[0]
            ),
            self.separator_pipe,
            widget.CurrentLayoutIcon(
                   custom_icon_paths = [os.path.expanduser("~/.config/qtile/icons")],
                   foreground =self.colors[2],
                   background =self.colors[0],
                   padding = 0,
                   scale = 0.7
            ),
            widget.CurrentLayout(
                   foreground =self.colors[2],
                   background =self.colors[0],
                   padding = 5
            ),
            self.separator_pipe,
            widget.TaskList(
                font=my_bar_font,
                foreground =self.colors[2],
                background =self.colors[0],
                parse_text = lambda x: '',
                icon_size=17,
                fontsize=17,
                border=self.colors[-1],
                margin=0,
                rounded=False,
                padding_x=2,
                padding_y=-1,
                txt_floating='',
                txt_minimized='',
                txt_maximized='',
            ),
#            widget.WindowName(
#                   foreground =self.colors[6],
#                   background =self.colors[0],
#                   padding = 0
#            ),
            widget.Systray(
                   background =self.colors[0],
                   padding = 5
            ),
            self.separator_pipe,
            widget.Net(
                   interface = "enp9s0",
                   format = 'Net: {down} ↓↑ {up}',
                   foreground =self.colors[2],
                   background =self.colors[0],
                   padding = 5
            ),
            self.separator_pipe,
            widget.Memory(
                  foreground = self.colors[2],
                  background = self.colors[0],
                  mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(terminal + ' -e htop')},
                  fmt = 'Mem: {}',
                  padding = 5
            ),

        ]

    def init_widgets_screen(self):
        '''
        Function that returns the widgets in a list.
        It can be modified so it is useful if you  have a multimonitor system
        '''
        widgets_screen = self.init_widgets_list()
        return widgets_screen

    def init_widgets_screen2(self):
        '''
        Function that returns the widgets in a list.
        It can be modified so it is useful if you  have a multimonitor system
        '''
        widgets_screen2 = self.init_widgets_screen()
        return widgets_screen2

    def init_screen(self):
        '''
        Init the widgets in the screen
        '''
        return [Screen(top=bar.Bar(widgets=self.init_widgets_screen(), opacity=1.0, size=18)),
                Screen(top=bar.Bar(
                    widgets=self.init_widgets_screen2(), opacity=1.0, size=18))
                ]