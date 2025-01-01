# QSym

The project designs a symbolic execution engine for quantum programs based on Qafny.

## Issues

### Error: "<stdout>: commitBuffer: invalid argument (invalid character XX)" on Windows

> Also may present as a lexer issue on a UTF-8 character.

This is a strange issue, mostly due to the long-standing lack of support for UTF-8 on Windows. A potential fix is enabling the new UTF-8 option in Windows settings. Go to the *language settings*, click *Administrative language settings*, then *Change system locale…* and tick the *Beta: Use Unicode UTF-8 for worldwide language support option*. This will require a restart. If that doesn't work, here are some resources that could help:

- [Using UTF-8 in the Windows Terminal](https://akr.am/blog/posts/using-utf-8-in-the-windows-terminal)
- [terminal haskell package](https://hackage.haskell.org/package/terminal)
- [UTF-8 input/output in from Haskell in Windows](https://stackoverflow.com/questions/66928909/utf-8-input-output-in-from-haskell-in-windows)
- [Haskell with UTF-8](https://serokell.io/blog/haskell-with-utf8)

### Error:  Ambiguous type variable ‘a0’ arising from a use of ‘pretty’, especially when using the QSym.Logic.SMT module

Don't forget to enable the haskell option "OverloadedStrings".

GHCi:
```
ghci> :set -XOverloadedStrings
```
Haskell Source:
```haskell
{-# LANGUAGE OverloadedStrings #-}
```