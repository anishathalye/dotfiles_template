import sublime, sublime_plugin
try:
    from .github import copy_and_open_default_settings
except ValueError:
    from github import copy_and_open_default_settings


class GithubPluginSettings(sublime_plugin.WindowCommand):
    def run(self):
        copy_and_open_default_settings()
