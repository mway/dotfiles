function vim
    if test -e /Applications/MacVim.app/Contents/MacOS/Vim
        /Applications/MacVim.app/Contents/MacOS/Vim -p $argv
    else
        vim -p $argv
    end
end
