alias pipeline_log_tailf='var=$(find /mnt/ebs/log/pipeline -type f -name "*.log" | \
    fzf --preview "( [[ -f {} ]] && (tail -50 {} || cat {}))" ) && \
    (grc tail -f $var || tail -f $var)'

alias pipeline_log_tailf_task='var=$(find $PIPELINE_TASK_LOG_PATH -type f -name "task*.log" | \
    fzf --preview "( [[ -f {} ]] && (tail -50 {} || cat {}))" ) && \
    (grc tail -f $var || tail -f $var)'

alias pipeline_ls_error_dir='var=$(find $ERROR_DIR -maxdepth 1 -type d | \
    fzf --preview "\
    ( [[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || \
    ( [[ -d {} ]] && (tree -C {} | less)) || \
    echo {} 2> /dev/null | head -200") \
    && ls $var'

alias pipeline_cd_error_dir='var=$(find $ERROR_DIR -maxdepth 1 -type d | \
    fzf --preview "\
    ( [[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || \
    ( [[ -d {} ]] && (tree -C {} | less)) || \
    echo {} 2> /dev/null | head -200") \
    && cd $var'

alias pipeline_cd_incoming_dir='var=$(find $INCOMING_DIR -maxdepth 3 -type d | \
    fzf --preview "\
    ( [[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || \
    ( [[ -d {} ]] && (tree -C {} | less)) || \
    echo {} 2> /dev/null | head -200") \
    && cd $var'

# retrieve all logs for any UUID in a pipeline task log
# $1 UUID value
function pipeline_log_uuid() {
    local uuid=$1;

    local log_file_path=$(find $PIPELINE_TASK_LOG_PATH -type f -name "task*.log" | fzf --multi=1)
    grep $uuid $log_file_path
}

# retrieve specific log output for failed file in pipeline
# $1 error file path
function pipeline_log_error_file() {
    # list files in ALL $ERROR_DIR with a uuid at the end
    local uuid_regexp='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
    local list_all_error_files=$(find $ERROR_DIR -type f)
    local file_input=$(echo $list_all_error_files | grep -E .$uuid_regexp | \
    fzf --multi=1 \
    --preview \
    '
    ( (echo {} | grep -q -E "*\.nc$") && ncdump -h {}) || \
    ( (echo {} | grep -q -E "*\.nc\..*") && ncdump -h {}) || \
    ( (echo {} | grep -q -E "*.zip.$uuid_regexp") && zip -sf {}) || \
    ( (echo {} | grep -q -E "*.zip$") && zip -sf {}) || \
    ( (echo {} | grep -q -E "*.manifest.$uuid_regexp") && bat {}) || \
    ( (echo {} | grep -q -E "*.manifest$") && bat {}) || \
    ( (echo {} | grep -q -E "*.(log|xml|txt).$uuid_regexp") && bat {}) || \
    ( (echo {} | grep -q -E "*.(log|xml|txt)$") && bat {}) || \
    ( [[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || \
    ' 
    )

    if [ -z "$file_input" ]
        then
        echo "no file selected"
        return 1
    fi

    local uuid_file=`echo "$file_input" | grep -o -E $uuid_regexp`
    local pipeline_name=`basename $(dirname $(readlink -f $file_input))`

    # find uuid entries in corresponding pipeline task log
    sed -E "0,/$uuid_file/d;/IncomingFileStateManager.*FILE_(SUCCESS|IN_ERROR)/q" $PIPELINE_TASK_LOG_PATH/tasks.$pipeline_name.log
}

alias talend_cd='var=$(find /mnt/ebs/talend/jobs -maxdepth 1 -type d | fzf --multi=1) && cd $var'


