import sublime
try:
    from .github import *
except ValueError:
    from github import *


class GithubCopyLinkCommand(GithubWindowCommand):

    @require_file
    @with_repo
    def run(self, repo):
        sublime.status_message("Copied URL to clipboard")
        url = repo.browse_file_url(self.relative_filename())
        view = sublime.active_window().active_view()
        line_begin = view.rowcol(view.sel()[0].begin())[0] + 1
        line_end = view.rowcol(view.sel()[0].end())[0] + 1
        url += '#L%d' % line_begin
        if line_begin != line_end:
            url += '-L%d' % line_end
        sublime.set_clipboard(url)