$cwd = Get-Location
Get-ChildItem . -Directory | foreach {
    cd $_.FullName
    mix test
}
cd $cwd