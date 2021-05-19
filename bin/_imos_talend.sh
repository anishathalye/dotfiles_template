# zsh tools

export TALEND_JOBS_DIR="/mnt/ebs/talend/jobs"
export TALEND_USER=talend


# runs a talend job
# $1 - name of job to run
function talend_run() {
    local talend_job=$1; shift
    sudo -u $TALEND_USER $TALEND_JOBS_DIR/$talend_job/bin/${talend_job}.sh
}
alias talend_run='var=$(ls $TALEND_JOBS_DIR | fzf); talend_version $var'

# triggers liquibase migrations for event driven talend job
# $1 - name of job to run
function talend_liqui() {
    local talend_job=$1; shift
    local talend_regex="___${talend_job}___"
    sudo -u $TALEND_USER /mnt/ebs/talend/bin/talend-trigger -c /mnt/ebs/talend/etc/trigger.conf --delete -f $talend_regex,$talend_regex
}
alias talend_liqui='var=$(ls $TALEND_JOBS_DIR | fzf); talend_liqui $var'

# runs a talend job urgently, or moves it forward in queue
# $1 - name of job to run urgently
function talend_urgent() {
    local talend_job=$1; shift

    talend_run $talend_job
    local -i talend_job_id=`_get_tsp_id $talend_job`

    if [ $talend_job_id -eq -1 ]; then
        echo "Job '$talend_job' is not in queue, we've just queued it, how can that be?!"
    else
        echo "Making job '$talend_job' with ID '$talend_job_id' urgent (move to head of queue)"
        sudo -u $TALEND_USER tsp -u $talend_job_id
    fi
}
alias talend_urgent='var=$(ls $TALEND_JOBS_DIR | fzf); talend_urgent $var'

# run all talend jobs
function talend_run_all() {
    local talend_job=$1; shift
    echo -n "This will queue all talend jobs, are you sure you want to do it (yes/no)? "
    local resp; read resp

    if [ x"$resp" != x ] && [ "$resp" = "yes" ]; then
        echo "Queueing all jobs!"
        for job in `ls -1 $TALEND_JOBS_DIR | xargs`; do
            talend_run $job
        done
    else
        echo "Not queueing anything!"
    fi
}

# change directory to talend job directory
# $1 - name of job to change directory to
function talend_cd() {
    local talend_job=$1; shift
    cd $TALEND_JOBS_DIR/$talend_job
}
alias talend_cd='var=$(ls $TALEND_JOBS_DIR | fzf); talend_cd $var'

# show log for a talend job
# $1 - name of job to show log for
function talend_log() {
    local talend_job=$1; shift
    less $TALEND_JOBS_DIR/$talend_job/log/console.log
}
alias talend_log='var=$(ls $TALEND_JOBS_DIR | fzf); talend_log $var'

# returns tsp id of job or -1 if it doesn't exist
# $1 - name of job
function _get_tsp_id() {
    local job_name=$1; shift
    local job_id=`talend_show_queued | grep "\b$job_name\b" | cut -d' ' -f1`
    if [ x"$job_id" = x ]; then
        echo -1
    else
        echo $job_id
    fi
}

# dequeues a talend job
# $1 - name of job to dequeue
function talend_dequeue() {
    local talend_job=$1; shift
    local -i talend_job_id=`_get_tsp_id $talend_job`
    if [ $talend_job_id -eq -1 ]; then
        echo "Job '$talend_job' is not in queue"
    else
        echo "Removing job '$talend_job' with ID '$talend_job_id' from queue"
        sudo -u $TALEND_USER tsp -r $talend_job_id
    fi
}
alias talend_dequeue='var=$(ls $TALEND_JOBS_DIR | fzf); talend_dequeue $var'

# shows jobs with given status
# $1 - status of jobs
function _talend_show_jobs() {
    local status=$1; shift
    sudo -u $TALEND_USER tsp -l | tr -s ' ' | cut -d' ' -f1,2,4 | grep "\b$status\b" | sed -e 's/\[//' -e 's/\].*//g'
}

# shows all jobs with status
function talend_show() {
    sudo -u $TALEND_USER tsp -l | tr -s ' ' | cut -d' ' -f1,2,4 | grep -v "\bfinished\b" | grep -v '^ID' | sed -e 's/\[//' -e 's/\].*//g'
}

# shows jenkins build version
# $1 - name of job to show version of
function talend_version() {
    local talend_job=$1; shift
    cat $TALEND_JOBS_DIR/$talend_job/java/build.properties
}
alias talend_version='var=$(ls $TALEND_JOBS_DIR | fzf); talend_version $var'

alias talend_show_running='_talend_show_jobs running'
alias talend_show_queued='_talend_show_jobs queued'
