from ranger.api.commands import Command
from collections import deque


class rcomics(Command):
    """
    :rename_comics by appending the folder name to the start of the selected files
    """
    def execute(self):
        import os
        files = [f.relative_path for f in self.fm.thistab.get_selection()]

        for file in files:
            album_dir = os.path.basename(os.path.dirname(os.path.realpath(file)))
            os.rename(file, '{prefix} - {filename}'.format(prefix=album_dir,
                                                           filename=file))
class mcomics(Command):
    """
    :move selected comic to a folder of the same name
    """
    def execute(self):
        import os
        files = [f.relative_path for f in self.fm.thistab.get_selection()]

        for file in files:
            album_dir = os.path.splitext(file)[0]
            os.makedirs(album_dir)
            os.rename(file, os.path.join(album_dir,
                                         file))

class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """
    def execute(self):
        import subprocess
        import os.path
        if self.quantifier:
            # match only directories
            command="find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        else:
            # match files and directories
            command="find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        fzf = self.fm.execute_command(command, universal_newlines=True, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


fd_deq = deque()
class fd_search(Command):
    """:fd_search [-d<depth>] <query>

    Executes "fd -d<depth> <query>" in the current directory and focuses the
    first match. <depth> defaults to 1, i.e. only the contents of the current
    directory.
    """

    def execute(self):
        import subprocess
        from ranger.ext.get_executables import get_executables
        if not 'fd' in get_executables():
            self.fm.notify("Couldn't find fd on the PATH.", bad=True)
            return
        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                depth = self.arg(1)
                target = self.rest(2)
            else:
                depth = '-d1'
                target = self.rest(1)
        else:
            self.fm.notify(":fd_search needs a query.", bad=True)
            return

        # For convenience, change which dict is used as result_sep to change
        # fd's behavior from splitting results by \0, which allows for newlines
        # in your filenames to splitting results by \n, which allows for \0 in
        # filenames.
        null_sep = {'arg': '-0', 'split': '\0'}
        nl_sep = {'arg': '', 'split': '\n'}
        result_sep = null_sep

        process = subprocess.Popen(['fd', result_sep['arg'], depth, target],
                    universal_newlines=True, stdout=subprocess.PIPE)
        (search_results, _err) = process.communicate()
        global fd_deq
        fd_deq = deque((self.fm.thisdir.path + os.sep + rel for rel in
            sorted(search_results.split(result_sep['split']), key=str.lower)
            if rel != ''))
        if len(fd_deq) > 0:
            self.fm.select_file(fd_deq[0])

class fd_next(Command):
    """:fd_next

    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_deq) > 1:
            fd_deq.rotate(-1) # rotate left
            self.fm.select_file(fd_deq[0])
        elif len(fd_deq) == 1:
            self.fm.select_file(fd_deq[0])

class fd_prev(Command):
    """:fd_prev

    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_deq) > 1:
            fd_deq.rotate(1) # rotate right
            self.fm.select_file(fd_deq[0])
        elif len(fd_deq) == 1:
            self.fm.select_file(fd_deq[0])


class fzf_rga_documents_search(Command):
    """
    :fzf_rga_search_documents
    Search in PDFs, E-Books and Office documents in current directory.
    Allowed extensions: .epub, .odt, .docx, .fb2, .ipynb, .pdf.

    Usage: fzf_rga_search_documents <search string>
    """
    def execute(self):
        if self.arg(1):
            search_string = self.rest(1)
        else:
            self.fm.notify("Usage: fzf_rga_search_documents <search string>", bad=True)
            return

        import subprocess
        import os.path
        from ranger.container.file import File
        command="rga '%s' . --rga-adapters=pandoc,poppler | fzf +m | awk -F':' '{print $1}'" % search_string
        fzf = self.fm.execute_command(command, universal_newlines=True, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            self.fm.execute_file(File(fzf_file))

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import *

class Default(ColorScheme):
    def use(self, context):
        fg, bg, attr = default_colors
        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                fg = white
                attr = bold
            else:
                attr = normal
            if context.empty or context.error:
                fg = black
            if context.border:
                attr = normal
                fg = default
            if context.media:
                if context.image:
                    fg = red
                else:
                    fg = yellow
            if context.container:
                attr |= normal
                fg = green
            if context.directory:
                attr |= normal
                fg = magenta
            elif context.executable and not \
                    any((context.media, context.container,
                        context.fifo, context.socket)):
                attr |= bold
                fg = red
            if context.socket:
                fg = black
            if context.fifo or context.device:
                fg = blue
                if context.device:
                    attr |= bold
            if context.link:
                fg = context.good and white or red
            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (red, white):
                    fg = black
                else:
                    fg = green
            if not context.selected and (context.cut or context.copied):
                fg = black
                attr |= bold
            if context.main_column:
                if context.selected:
                    attr |= normal
                if context.marked:
                    attr |= underline
                    fg = white
            if context.badinfo:
                if attr & reverse:
                    bg = red
                else:
                    fg = red

        elif context.in_titlebar:
            attr |= normal
            if context.hostname:
                attr |= normal
                fg = red
            elif context.directory:
                fg = red
            elif context.tab:
                if context.good:
                    bg = white
            elif context.link:
                fg = green

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = white
                elif context.bad:
                    fg = red
            if context.marked:
                attr |= bold | reverse
                fg = yellow
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = red

        if context.text:
            if context.highlight:
                attr |= bold

        if context.in_taskview:
            if context.title:
                fg = red

            if context.selected:
                attr |= normal

        return fg, bg, attr
