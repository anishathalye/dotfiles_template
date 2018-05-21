# export PATH="/usr/local/bin:/usr/local/Cellar/perl/5.14.4/bin:$PATH"
export no_proxy="localhost"

source ~/perl5/perlbrew/etc/bashrc
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"
export PERL5LIB=$PERL5LIB:~/perl5/src/WebService-HabitRPG/lib

# export PYTHONPATH=/usr/local/lib/python2.7/site-packages

export NETHACKOPTIONS="color,gender:female"

