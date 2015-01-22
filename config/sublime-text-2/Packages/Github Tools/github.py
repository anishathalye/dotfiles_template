import sublime, sublime_plugin, re, os, json
from os.path import dirname, normpath, join
from functools import wraps
from pprint import pformat

DEFAULT_SETTINGS = {
    'debug_mode': False,
    'github_hostnames': ['github.com']
}

plugin_dir = os.path.abspath(os.path.dirname(__file__))
settings = {}
debug_mode = DEFAULT_SETTINGS['debug_mode']
github_hostnames = DEFAULT_SETTINGS['github_hostnames']

def plugin_loaded():
    global settings, debug_mode, github_hostnames
    settings = sublime.load_settings('Github Tools.sublime-settings')
    if settings.get('debug_mode'):
        debug_mode = settings.get('debug_mode')
    if settings.get('github_hostnames'):
        github_hostnames = settings.get('github_hostnames')


class NotAGitRepositoryError(Exception):
    pass


class NotAGithubRepositoryError(Exception):
    pass


class NoRemoteError(Exception):
    def __init__(self, branch):
        self.branch = branch


class GitCommandError(Exception):
    pass


class GitRepo(object):
    def __init__(self, path):
        self.path = path

        if not self.is_git():
            raise NotAGitRepositoryError("No repository at '%s'" % self.path)

        try:
            remote_alias = self.git('config branch.%s.remote' % self.branch)
        except GitCommandError:
            raise NoRemoteError(self.branch)

        self.info = self.get_info(remote_alias)

        if not self.info:
            raise NotAGithubRepositoryError("Failed to read url of remote '%s'" % remote_alias)

        log("Parsed GIT repo: ", pformat(self.info))

    def git(self, command):
        os.chdir(self.path)
        log("Executing `git %s` at %s." % (command, self.path))

        f = os.popen("git %s" % command)
        output = f.read().strip()
        exit_code = f.close()

        if exit_code:
            raise GitCommandError("Failed to execute `git %s` at %s" %
                                  (command, self.path))
        return output

    def get_info(self, remote_alias):
        remote = self.git('config remote.%s.url' % remote_alias)
        return self.parse_remote(remote_alias, remote)

    def path_from_rootdir(self, filename):
        rootdir = normpath(self.git("rev-parse --show-toplevel"))
        if self.path != rootdir:
            _, _, path_from_rootdir = self.path.partition(rootdir)
            full_path = join(path_from_rootdir, filename.strip('/'))
            return full_path
        return filename

    @property
    def branch(self):
        return self.parse_branch(self.git("branch"))

    @property
    def revision(self):
        return self.git("rev-parse HEAD")

    def parse_branch(self, branches):
        p = re.compile("\* (.+)")
        m = p.findall(branches)
        return m[0] if m else None

    def is_git(self):
        os.chdir(self.path)
        code = os.system('git rev-parse')
        return not code

    def parse_remote(self, remote_alias, remote):
        for hostname in github_hostnames:
            if remote.startswith('git@' + hostname):
                return self.parse_ssh_remote(remote_alias, remote)
            if remote.startswith('https://' + hostname) or remote.startswith('http://' + hostname):
                return self.parse_http_remote(remote_alias, remote)

    def parse_ssh_remote(self, remote_alias, remote):
        uri = strip_suffix(remote[4:], '.git')
        account = uri.split('/')[-2]
        name = uri.split('/')[-1]

        return {
            'remote_alias': remote_alias,
            'protocol': 'ssh',
            'web_uri': uri.replace(':', '/'),
            'remote_uri': remote,
            'repository_name': name,
            'account': account,
            'username': '',
            'password': ''
        }

    def parse_http_remote(self, remote_alias, remote):
        cut_left = 8
        if remote.startswith('http:'):
            cut_left = 7
        remote_uri = remote[cut_left:].split("@")[-1]
        uri = strip_suffix(remote[cut_left:], '.git')
        web_uri = uri.split("@")[-1]
        name = web_uri.split('/')[-1]
        account = web_uri.split('/')[-2]
        username, password = extract_http_auth_credentials(uri)

        return {
            'remote_alias': remote_alias,
            'protocol': 'http',
            'web_uri': web_uri,
            'remote_uri': remote_uri,
            'repository_name': name,
            'account': account,
            'username': username,
            'password': password
        }

    def parse_heads(self, heads):
        f = lambda l: tuple(re.split("\s", l.replace('refs/heads/', ''))[::-1])
        return dict(map(f, heads.splitlines()))

    def browse_file_url(self, filename):
        return git_browse_file_url(self.info['web_uri'],
                                   self.path_from_rootdir(filename), self.branch)

    def blame_file_url(self, filename):
        return git_blame_file_url(
            self.info['web_uri'], self.path_from_rootdir(filename),
            self.revision)

    def repository_url(self):
        return git_repository_url(self.info['web_uri'])

    def issues_url(self):
        return git_issues_url(self.info['web_uri'])

    def pulls_url(self):
        return git_pulls_url(self.info['web_uri'])

    @property
    def name(self):
        return self.info['repository_name']


class GithubWindowCommand(sublime_plugin.WindowCommand):
    def rootdir(self):
        if self.filename():
            return dirname(self.filename())
        return self.first_folder()

    def first_folder(self):
        print(self.window.folders())
        return self.window.folders()[0]

    def relative_filename(self):
        _, _, filename = self.filename().partition(self.rootdir())
        return filename

    def filename(self):
        if self.window.active_view():
            return self.window.active_view().file_name()
        return None

    @property
    def repository(self):
        return GitRepo(self.rootdir())


def strip_suffix(txt, suffix):
    if txt.endswith(suffix):
        return txt[:-len(suffix)]
    return txt


def log(*lines):
    if not debug_mode:
        return

    for line in lines:
        print(line)


def copy_and_open_default_settings():
    user_settings_path = join(sublime.packages_path(), 'User',
                              'Github Tools.sublime-settings')

    if not os.path.exists(user_settings_path):
        with open(user_settings_path, 'w') as f:
            json.dump(DEFAULT_SETTINGS, f, sort_keys=True,
                      indent=4, separators=(',', ': '))

    sublime.active_window().open_file(user_settings_path)


def extract_http_auth_credentials(uri):
    username = password = ''
    if '@' in uri:
        username, password = (uri.split('@')[0].split(':') + [''])[:2]
    return (username, password)


def require_file(func):
    @wraps(func)
    def wrapper(self):
        if self.filename():
            return func(self)
        sublime.message_dialog("Please open a file first.")
    return wrapper


def with_repo(func):
    @wraps(func)
    def wrapper(self):
        try:
            return func(self, self.repository)
        except (NotAGitRepositoryError, NotAGithubRepositoryError) as err:
            sublime.message_dialog("Github repository not found: %s" % err)
        except (NoRemoteError) as e:
            sublime.message_dialog(
                "The current branch %s has no upstream branch." % e.branch)

    return wrapper


def git_browse_file_url(repository, filepath, branch='master'):
    return "https://%s/blob/%s%s" % (repository, branch, filepath)


def git_blame_file_url(repository, filepath, revision):
    return "https://%s/blame/%s%s" % (repository, revision, filepath)


def git_issues_url(repository):
    return "https://%s/issues" % (repository)


def git_pulls_url(repository):
    return "https://%s/pulls" % (repository)


def git_repository_url(repository):
    return "https://%s" % (repository)


def git_compare_url(repository, branch):
    return "https://%s/compare/%s?expand=1" % (repository, branch)
