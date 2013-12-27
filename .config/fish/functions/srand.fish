function srand 
    set -l len $argv[1]

    if test -z $len
        set len 64
    end

    echo (cat /dev/urandom | env LC_CTYPE=C tr -cd "[:alnum:]" | head -c $len)
end

