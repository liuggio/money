# Changelog

## 1.2.2
- Add Money.Config module for dealing with configuration tree (currency -> gloabal -> defaults)
- Doc for how-to add currency specific config

## 1.2.1

- Add Money.abs/1
- Add Money.neg/1
- Fix issues with Money.divide/2 and negative values [#57]
- Changes for clean compile on Elixir 1.4.1
- Changed sigil functions to macros for compile time expansion [#59]

## 1.2.0

- Add formatting option to hide fractional units [#47]
- Allow underscores in sigil [#48]

### 1.1.3

- Fix parsing amounts without a leading digit [#46]

### 1.1.2

- Bug fix: to_string with negative [#42]

### 1.1.1

- No changes

## 1.1.0

- Add formatting options [#36]
- Update parse to handle negative values [#39]
- Add support for Money.cast/1 for existing Money struct [#33]
- Add support for Money sigil ~M [#32]
- Add optional support for Phoenix.HTML.Safe [#29]

## 1.0.0

Initial release
