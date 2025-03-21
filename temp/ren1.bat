@echo off
for %%f in (*.formatted.end) do (
    set "filename=%%~nf"
    for /f "delims=. tokens=1" %%a in ("%%filename%%") do (
        ren "%%f" "%%a.sh"
    )
)
