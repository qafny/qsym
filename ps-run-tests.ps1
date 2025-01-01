# This is a powershell script to run the QSym tests.
# Don't forget to run: "Set-ExecutionPolicy RemoteSigned" on your local machine.
# see: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4
# and: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-7.4

cabal test --test-show-detail=streaming --enable-profiling --profiling-detail=all-functions @Args