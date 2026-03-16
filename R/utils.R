.onAttach <- function(libname, pkgname) {
    packageStartupMessage(
        "sdmbench: Tools for benchmarking Species Distribution Models\n",
        "============================================================\n",
        "For more information visit https://github.com/boyanangelov/sdmbench\n",
        "To start the GUI: run_sdmbench()"
    )
}
