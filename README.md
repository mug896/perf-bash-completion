## Perf Bash Completion

Copy contents of `perf-bash-completion.sh` file to `~/.bash_completion`.  
open new terminal and try auto completion.

> I have made this script based on help message of perf.


```sh
bash$ lsb_release -a
Description:    Ubuntu 22.04.1 LTS
Release:        22.04
Codename:       jammy

bash$ perf -v
perf version 5.15.39

bash$ perf [tab]
annotate       config         help           list           sched          trace
archive        daemon         inject         lock           script         version
bench          data           iostat         mem            stat           
buildid-cache  diff           kallsyms       probe          test           
buildid-list   evlist         kmem           record         timechart      
c2c            ftrace         kvm            report         top 
```

