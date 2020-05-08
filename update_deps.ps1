$cwd = Get-Location
(Get-ChildItem . -Directory) -match "^\w" | foreach {
    cd $_.FullName
    mix deps.update --all
}
cd $cwd