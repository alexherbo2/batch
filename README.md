# Batch

[![Build Status](https://travis-ci.org/alexherbo2/batch.svg)](https://travis-ci.org/alexherbo2/batch)
[![IRC](https://img.shields.io/badge/IRC-%23batch-blue)](https://webchat.freenode.net/#batch)

###### [Usage](#usage) | [Configuration](#configuration) | [Options](#options) | [Contributing](CONTRIBUTING)

> Command-line program for [batch processing].

[![Batch demo](https://img.youtube.com/vi_webp/QN4mrZXYHPo/maxresdefault.webp)](https://youtu.be/QN4mrZXYHPo)

## Dependencies

- [Crystal]

## Installation

``` sh
make build # Build bin/batch
make install # Install bin/batch and scripts into ~/.local/bin
```

You can download [binary release](https://github.com/alexherbo2/batch/releases) for your OS.

## Usage

``` sh
batch
```

Opens a list of elements in an external editor.

Elements can be received from the argument list or `stdin`.

**Example** – Running **Batch** with [Star Platinum], [Magician’s Red], [Hermit Purple], [Hierophant Green], [Silver Chariot] and [The Fool]:

`input.txt`

```
Star Platinum
Magician’s Red
Hermit Purple
Hierophant Green
Silver Chariot
The Fool
```

Edit the file:

`input.txt`

```
star-platinum

hermit-purple

silver-chariot

```

After you edit and save the file, it will generate a shell script
which does batch actions according to the changes you did in the file.

`output.sh`

``` sh
# This file will be executed when you close the editor.
# Please double-check everything, clear the file to abort.

map() {
  echo map "$1" → "$2"
}
map 'Star Platinum' 'star-platinum'
map 'Hermit Purple' 'hermit-purple'
map 'Silver Chariot' 'silver-chariot'

drop() {
  echo drop "$1"
}
drop 'Magician’s Red'
drop 'Hierophant Green'
drop 'The Fool'
```

This shell script is opened in an editor for you to review.
After you close it, it will be executed.

## Configuration

``` sh
batch_rename() {
  batch --map 'rename "$1" "$2"' "$@"
}

batch_convert() {
  batch --map 'convert "$1" "$2"' "$@"
}

batch_relink() {
  batch --map 'relink "$1" "$2"' "$@"
}

alias rn=batch_rename
alias cv=batch_convert
alias rl=batch_relink
```

## Options

```
--pick / -p command
  Run command on unchanged elements.

--map / -m command
  Run command on modified elements.

--drop / -d command
  Run command on deleted elements.

--editor command
  Configure editor.
  If command contains spaces, command must include "${@}" (including the quotes)
  to receive the argument list.

--no-confirm
  Do not ask for confirmation.

--version / -v
  Display version number and quit

--help / -h
  Display a help message and quit.
```

[Batch processing]: https://en.wikipedia.org/wiki/Batch_processing
[Crystal]: https://crystal-lang.org
[Star Platinum]: https://jojo.fandom.com/wiki/Star_Platinum
[Magician’s Red]: https://jojo.fandom.com/wiki/Magician's_Red
[Hermit Purple]: https://jojo.fandom.com/wiki/Hermit_Purple
[Hierophant Green]: https://jojo.fandom.com/wiki/Hierophant_Green
[Silver Chariot]: https://jojo.fandom.com/wiki/Silver_Chariot
[The Fool]: https://jojo.fandom.com/wiki/The_Fool
