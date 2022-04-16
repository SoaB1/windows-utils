Import-Module oh-my-posh
Set-PoshPrompt -Theme test-01

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord

# Remove Alias region
Remove-Alias cat
Remove-Alias cp
Remove-Alias history
Remove-Alias ls
Remove-Alias mv
Remove-Alias pwd
Remove-Alias rm
Remove-Alias rmdir
# endregion

# Alias regeion
function ll {
    ls.exe -l $args
}
#Git Start a branch on day.
function gstart {
    git.exe checkout target; git.exe pull origin target; git.exe checkout -b test-`date +%Y%m%d`;dc up -d
}
#Git End a branch on day.
function gend {
    git.exe checkout target; git.exe merge --squash test-`date +%Y%m%d`;git.exe commit %1
}

# endregion