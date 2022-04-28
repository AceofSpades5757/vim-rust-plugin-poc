" Plugin:      Rust Vim Plugin POC
" Author:      Kyle L. Davis <AceofSpades5757.github@gmail.com>
" Version:     0.0.4
" Modified:    2022 Apr 28
" Description:
"
"     Vim plugin written in Rust.
"

let g:loaded_vim_rust_plugin = 1


python3 << EOF
import subprocess
from pathlib import Path


plugin_directory: Path = Path(vim.eval('expand("<sfile>")')).absolute().parent.parent
binary: Path = plugin_directory / 'target/release/vim-plugin.exe'


def build() -> None:
    process = subprocess.run(
        'cargo build --release'.split(),
        cwd=plugin_directory,
    )
    if process.returncode != 0:
        raise RuntimeError("Unable to build Rust plugin.")


if not binary.exists():
    build()
assert binary.exists(), "Binary was not created."
EOF

let s:binary = py3eval('str(binary)')

" PLUGIN STYLE
"
" 1. Start Server
" 2. Connect to Server
" 3. Do Work
" 4. Stop (Optional)
"

" Config
let s:max_startup_time = 5
let s:max_work_time = 5


" 1. Start Server
if !exists('job_id')
    let s:job_id = 0
    let s:job_options = {}
endif
let s:job = job_start([s:binary], s:job_options)

" 2. Connect to Server
" Needs time to wait for server startup

let s:ch_address = 'localhost:8765'
let s:ch_options = {}
let s:channel = ch_open(s:ch_address, s:ch_options)

let s:count_ = 0
while ch_status(s:channel) == "fail"

    " Waiting to Connect
    if s:count_ >= s:max_startup_time
        break
    endif
    let s:count_ += 1
    sleep 1

    " Try Again
    let s:channel = ch_open(s:ch_address, s:ch_options)

endwhile

" 3. Work
"
" Should have a set timer to run.

let s:count_ = 0
while ch_status(s:channel) == "open"
    " Rust Plugin is doing work
    if s:count_ >= s:max_work_time
        break
    endif
    let s:count_ += 1
    sleep 1
endwhile

" 4. Stop
"
" This shouldn't be necessary with the new style.

"if job_status(s:job) != "dead"
    "call job_stop(s:job)
"endif
