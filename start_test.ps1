$cwd = Get-Location
cd .\sb_api
iex -S mix phx.server
cd $cwd