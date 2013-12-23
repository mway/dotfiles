function fish_prompt
    set c_uh (set_color 333)
    set c_cwd (set_color 0aa)
    set c_nrm (set_color normal)

    set p_uh (hostname | cut -d . -f 1)
    set p_cwd (prompt_pwd)
    
    echo $c_uh$USER@$p_uh$c_nrm $c_cwd$p_cwd$c_nrm' ❯ '
end
