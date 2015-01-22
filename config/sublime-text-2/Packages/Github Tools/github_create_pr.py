import sublime, sublime_plugin, webbrowser
try:
    from .github import *
except ValueError:
    from github import *


class GithubCreatePrCommand(GithubWindowCommand):
    @with_repo
    def run(self, repo):
        webbrowser.open_new_tab(git_compare_url(repo.info['web_uri'], repo.branch))
