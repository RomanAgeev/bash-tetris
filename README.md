# bash-tetris
A simple Tetris game written exclusively in bash.

<img src="screenshot.png" width="300px"/>


### How to Run on Mac

```bash
# install bash 5
brew install bash
# install gdate
brew install coreutils
# run the game
bash ./tetris.sh
```
The `bash 5` is needed for the following features:

* The millisecond `read` timeout.
* The `$COLUMNS` and `$LINES` variables.

The `gdate` is needed to take timestamps.

### Alternative Shapes

An alternative shape set can be chosen by specifying the corresponding config file:

```bash
bash ./tetris.sh ./shapes/pentamino.cfg
```
