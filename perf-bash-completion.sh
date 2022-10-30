_perf_c2c() 
{
    if _perf_check @ "$CMD3"; then
        WORDS="record report" 
    elif [[ $CMD3 == record ]] && _perf_check -e --event; then
        WORDS=$( sudo $CMD c2c record -e list |& awk '{print $1}' ) 
    fi
}
_perf_diff() 
{
    if _perf_check -c --compute; then
        WORDS="delta ratio wdiff cycles delta-abs"
    elif _perf_check -s --sort; then
        WORDS=$SORT
    fi
}
_perf_ftrace() 
{
    if _perf_check -t --tracer; then
        WORDS="function_graph function"
    elif _perf_check --func-opts; then
        WORDS="call-graph irq-info"
    elif _perf_check --graph-opts; then
        WORDS="nosleep-time noirqs verbose thresh= depth="
    fi
}
_perf_kmem() 
{
    if _perf_check -s --sort; then
        WORDS="ptr callsite bytes hit pingpong frag page callsite bytes hit order migtype gfp"
    elif _perf_check @ "$CMD3"; then
        WORDS="record stat"
    elif [[ $CMD3 == record ]]; then
        _perf_record
    fi
}
_perf_kvm() 
{
    if _perf_check @ "$CMD3"; then
        WORDS="top record report diff buildid-list stat"
    elif [[ $CMD3 == top ]]; then _perf_top
    elif [[ $CMD3 == record ]]; then _perf_record
    elif [[ $CMD3 == report ]]; then _perf_report
    elif [[ $CMD3 == diff ]]; then _perf_diff
    elif [[ $CMD3 == stat && -z $CMD4 && -z $WORDS ]]; then
        WORDS="record report live"
    elif [[ $CMD3 == stat && $CMD4 == @(live|report) ]]; then
        _perf_check --event && WORDS="vmexit mmio ioport"
    fi
}
_perf_record() 
{
    if _perf_check --call-graph; then
        WORDS="fp dwarf lbr"
    fi
}
_perf_report() 
{
    if _perf_check -F --fields; then
        WORDS=$SORT
    elif _perf_check -g --call-graph; then
        WORDS="graph flat fractal folded none caller callee function address percent period count"
    elif _perf_check -s --sort; then
        WORDS=$SORT
    fi
}
_perf_lock() 
{
    if _perf_check @ "$CMD3"; then
        WORDS="record report script info"
    elif [[ $CMD3 == script ]]; then
        _perf_script
    elif [[ $CMD3 == report ]] && _perf_check -k --key; then
        WORDS="acquired contended avg_wait wait_total wait_max wait_min"
    fi
}
_perf_script()
{
    if _perf_check -F --fields; then
        WORDS="comm tid pid time cpu event trace ip sym dso addr symoff srcline period
        iregs uregs brstack brstacksym flags bpf-output brstackinsn brstackoff callindent
        insn insnlen synth phys_addr metric misc srccode ipc data_page_size code_page_size
        trace: sw: hw:"
    elif _perf_check @ "$CMD3"; then
        WORDS="record report"
    elif [[ $CMD3 == record ]]; then
        _perf_record
    fi
}
_perf_top() 
{ 
    if _perf_check -s --sort --fields; then
        WORDS=$SORT
    fi
}
_perf_mem() 
{
    if _perf_check -t --type; then
        WORDS="load store"
    elif _perf_check @ "$CMD3"; then
        WORDS="record report" 
    elif [[ $CMD3 == record ]] && _perf_check -e --event; then
        WORDS=$( sudo $CMD mem record -e list |& awk '{print $1}' )
    fi
}
_perf_sched() 
{
    if _perf_check @ "$CMD3"; then
        WORDS="record latency map replay script timehist"
    elif [[ $CMD3 == record ]]; then
        _perf_record
    elif [[ $CMD3 == script ]]; then
        WORDS="record report"
    elif [[ $CMD3 == latency ]] && _perf_check -s --sort; then
        WORDS="runtime switch avg max"
    fi
}
_perf_trace() 
{
    if _perf_check -F --pf; then
        WORDS="all maj min"
    elif _perf_check --call-graph; then
        WORDS="fp dwarf lbr"
    elif _perf_check @ "$CMD3"; then
        WORDS="record" 
    elif [[ $CMD3 == record ]]; then
        _perf_record
    fi
}
_perf_set_cmds()
{
    if [[ $PREV == -* && $CUR != -* ]]; then
        local COMP_LINE=${COMP_LINE%$PREV[ =]*}
    else
        local COMP_LINE=${COMP_LINE% *}
        COMP_LINE=${COMP_LINE/% -*([[:alnum:]_-])/}
    fi
    case $CMD2 in
        c2c|kmem|lock|sched|script|stat|timechart|trace) 
            CMD3=$( eval "sudo $COMP_LINE -h" |&
                sed -En '/Usage:/{ s/.* ([[:alnum:]_-]+)( [[{].*)?/\1/p }' )
            if [[ -z $CMD3 ]]; then
                echo; eval "sudo $COMP_LINE -h"
                return 1
            fi
            [[ $CMD2 == $CMD3 ]] && CMD3="" 
            ;;
        daemon|data|iostat) 
            [[ $COMP_LINE =~ " "+$CMD2" "+([-][[:alnum:]_-]+(" "+[^ -][^ ]*)?" "+)*([^ -][^ ]*) ]] &&
            CMD3=${BASH_REMATCH[3]}
            ;;
        kvm)
            local ARR=($( eval "sudo $COMP_LINE -h" |&
                sed -En '/Usage:/{ s/.*Usage: ([[:alnum:] _-]+)( [[{].*)?/\1/p }' ))
            [[ ${#ARR[@]} == 2 && ${ARR[1]} != $CMD2 ]] && CMD3=${ARR[1]}
            [[ ${#ARR[@]} == 4 ]] && { CMD3=${ARR[2]} CMD4=${ARR[3]} ;}
            ;;
        mem)
            [[ $COMP_LINE =~ $(echo ' record\b') ]] && CMD3=record
            [[ $COMP_LINE =~ $(echo ' report\b') ]] && CMD3=report
            ;;
        test)
            [[ $COMP_LINE =~ $(echo ' list\b') ]] && CMD3=list
    esac
    return 0
}
_perf_check()
{
    if [[ $1 == "@" ]]; then
        [[ -z $2 && ! $CUR$PREV$PREV_ == *[,=@]* && -z $WORDS ]]
    else
        case $# in
            1) [[ $PREV == $1 || ($LPRE == $1 && $PREV$CUR == *,*) ]] ;;
            2) [[ $PREV == @($1|$2) || ($LPRE == @($1|$2) && $PREV$CUR == *,*) ]] ;;
            3) [[ $PREV == @($1|$2|$3) || ($LPRE == @($1|$2|$3) && $PREV$CUR == *,*) ]] ;;
        esac
    fi
}
_init_comp_wordbreaks()
{
    if [[ $PROMPT_COMMAND == *";COMP_WORDBREAKS="* ]]; then
        [[ $PROMPT_COMMAND =~ ^:\ ([^;]+)\; ]]
        [[ ${BASH_REMATCH[1]} != "${COMP_WORDS[0]}" ]] && eval "${PROMPT_COMMAND%%$'\n'*}"
    fi
    if [[ $PROMPT_COMMAND != *";COMP_WORDBREAKS="* ]]; then
        PROMPT_COMMAND=": ${COMP_WORDS[0]};COMP_WORDBREAKS=${COMP_WORDBREAKS@Q};\
        "$'PROMPT_COMMAND=${PROMPT_COMMAND#*$\'\\n\'}\n'$PROMPT_COMMAND
    fi
}
_perf() 
{
    # It is recommended that every completion function starts with _init_comp_wordbreaks,
    # whether or not they change the COMP_WORDBREAKS variable afterward.
    _init_comp_wordbreaks
    [[ $COMP_WORDBREAKS == *:* ]] && COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}
    [[ $COMP_WORDBREAKS != *,* ]] && COMP_WORDBREAKS+=","

    local extglob_reset=$(shopt -p extglob)
    trap "$extglob_reset" RETURN
    shopt -s extglob

    local CUR=${COMP_WORDS[COMP_CWORD]} PREV=${COMP_WORDS[COMP_CWORD-1]} PREV_
    [[ ${COMP_LINE:COMP_POINT-1:1} = " " ]] && CUR=""
    [[ $PREV == "=" ]] && { PREV_=$PREV; PREV=${COMP_WORDS[COMP_CWORD-2]} ;}
    local IFS=$' \t\n' WORDS HELP
    local CMD=$1 CMD2 CMD3 CMD4
    local COMP_LINE2=${COMP_LINE:0:$COMP_POINT}
    local SCMDS=$( $CMD -h | sed -En '/perf commands are:/,/^$/{ //d; s/([[:alnum:]-]+).*/\1/; tX bZ; :X H;}; :Z ${ g; s/[ \n]+/ /g; p }' )" help"
    [[ $COMP_LINE2 =~ ^" "*$CMD" "+((-[hvp]|-vv|--help|--version|--paginate|--no-pager|--exec-path)" "+|((--buildid-dir|--debugfs-dir|--debug)" "+[^ -][^ ]*" "+))*(${SCMDS// /|})" " ]]
    CMD2=${BASH_REMATCH[5]}

    if [[ $CUR == -* ]]; then
        WORDS="-h --help"
        if [[ -z $CMD2 ]]; then
            WORDS=$( man $CMD | sed -En 's/^\s{,10}(-[[:alpha:]], -[^ ]+|-[^ ]+).*/\1/; tX; bZ; :X H; :Z ${ g; s/[ ,\n]+/ /g; p }' )
            COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
            return
        fi
    elif [[ $PREV == --debug ]]; then
        WORDS="verbose ordered-events data-convert stderr perf-event-open"
        COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
        return
    elif [[ -z $CMD2 && $PREV == @(--buildid-dir|--debugfs-dir) ]]; then
        :
    elif [[ -z $CMD2 ]]; then
        COMPREPLY=( $(compgen -W "$SCMDS" -- "$CUR") )
        return
    fi

    _perf_set_cmds || return

    if [[ $CUR == -* ]]; then
        if [[ $CMD2 == data ]]; then
            [[ $CMD3 == convert ]] &&
            WORDS+=" --to-ctf --to-json --tod -i --input -f --force -v --verbose --all"
        elif [[ $CMD2 == mem && $CMD3 == record ]]; then
            WORDS+=" -e --event -K --all-kernel -U --all-user -v --verbose --ldlat"
        else 
            HELP=$( sudo $CMD $CMD2 $CMD3 $CMD4 -h 2>&1 )
            WORDS+=" "$( <<< $HELP sed -En '/^ +-/{ s/^\s{,15}((-\w),?\s)?(--[[:alnum:]_-]+=?)?.*/\2 \3/p }' )
            [[ $WORDS == *--children* ]] && WORDS+=" --no-children"
            [[ $WORDS == *--demangle* ]] && WORDS+=" --no-demangle"
            [[ $WORDS == *--demangle-kernel* ]] && WORDS+=" --no-demangle-kernel"
        fi
    else
        [[ $COMP_LINE2 =~ .*" "(-[[:alnum:]-]+)(" "|"=") ]]
        local LPRE=${BASH_REMATCH[1]}
        local SORT="overhead overhead_sys overhead_us overhead_guest_sys overhead_guest_us
        overhead_children sample period pid comm dso symbol parent cpu socket srcline
        srcfile local_weight weight transaction trace symbol_size dso_size cgroup
        cgroup_id ipc_null time code_page_size local_ins_lat ins_lat p_stage_cyc dso_from
        dso_to symbol_from symbol_to mispredict abort in_tx cycles srcline_from srcline_to
        ipc_lbr symbol_daddr dso_daddr locked tlb mem snoop dcacheline symbol_iaddr
        phys_daddr data_page_size blocked"

        if _perf_check --itrace; then
            WORDS="i[period] b c r x w p o e[flags] d[flags] f m t a g[len] G[len] l[len]
        L[len] sNUMBER q PERIOD[ns|us|ms|i|t]"
        elif _perf_check --percentage; then
            WORDS="relative absolute"
        elif _perf_check -g --call-graph; then
            [[ $CMD2 != sched ]] &&
            WORDS="graph flat fractal folded none caller callee function address percent period count"
        elif _perf_check -M --disassembler-style; then
            WORDS="intel"
        elif _perf_check --stdio-color; then
            WORDS="always never auto"
        elif _perf_check --switch-on --switch-off; then
            WORDS=$( sudo $CMD evlist | sed -E '/^\s*#/d' )
        elif _perf_check -I --intr-regs; then
            [[ $CMD2 != @(sched|stat) ]] &&
            WORDS=$( sudo $CMD record -I? |& sed -En '/available registers:/{ s///p }' )
        elif _perf_check --user-regs; then
            WORDS=$( sudo $CMD record --user-regs=? |& sed -En '/available registers:/{ s///p }' )
        elif _perf_check -k --clockid; then
            WORDS="CLOCK_REALTIME CLOCK_REALTIME_ALARM CLOCK_REALTIME_COARSE CLOCK_TAI
            CLOCK_MONOTONIC CLOCK_MONOTONIC_COARSE CLOCK_MONOTONIC_RAW CLOCK_BOOTTIME
            CLOCK_BOOTTIME_ALARM CLOCK_PROCESS_CPUTIME_ID CLOCK_THREAD_CPUTIME_ID"
        elif _perf_check --affinity; then
            WORDS="node cpu"
        elif _perf_check -e --event --switch-output-event; then
            WORDS=$( sudo $CMD list --raw-dump )
        elif _perf_check --switch-output; then
            WORDS="signal size[BKMG] time[smhd]"
        fi
        case $CMD2 in
            annotate) ;;
            archive) ;;
            bench) _perf_check -f --format && WORDS="default simple" ;;
            buildid-cache) ;;
            buildid-list) ;;
            c2c) _perf_c2c ;;
            config) ;;
            daemon) _perf_check @ "$CMD3" && WORDS="start stop signal ping" ;;
            data) _perf_check @ "$CMD3" && WORDS="convert" ;;
            diff) _perf_diff ;;
            evlist) ;;
            ftrace) _perf_ftrace ;;
            inject) ;;
            iostat) _perf_check @ "$CMD3" && WORDS="list" ;;
            kallsyms) ;;
            kmem) _perf_kmem ;;
            kvm) _perf_kvm ;;
            list) _perf_check @ "$CMD3" && WORDS="hw sw cache tracepoint pmu sdt metric metricgroup event_glob" ;;
            lock) _perf_lock ;;
            mem) _perf_mem ;;
            probe) ;;
            record) _perf_record ;;
            report) _perf_report ;;
            sched) _perf_sched ;;
            script) _perf_script ;;
            stat) _perf_check @ "$CMD3" && WORDS="record report" ;;
            test) _perf_check @ "$CMD3" && WORDS="list" ;;
            timechart) _perf_check @ "$CMD3" && WORDS="record" ;;
            top) _perf_top ;;
            trace) _perf_trace ;;
        esac
    fi

    [[ $CUR == "," || ($CUR == "=" && $PREV == -*) ]] && CUR=""
    COMPREPLY=( $(compgen -W "$WORDS" -- "$CUR") )
    [ "${COMPREPLY: -1}" = "=" ] && compopt -o nospace
}

complete -o default -o bashdefault -F _perf perf

