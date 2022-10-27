## Perf Bash Completion

Copy contents of `perf-bash-completion.sh` file to `~/.bash_completion`.  
open new terminal and try auto completion !


```sh
bash$ hostnamectl
Operating System: Ubuntu 22.04.1 LTS
          Kernel: Linux 5.15.0-43-generic
    Architecture: x86-64

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

> please leave an issue above if you have any problems using this script.

