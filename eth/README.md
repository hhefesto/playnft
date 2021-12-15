# ETH local development

## To start local network:
``` sh
$ cd path/to/playNFT
$ nix develop -c $SHELL
...
$ cd eth
$ yarn startg # then on your browser go to Metamask, Settings, Advanced, Reset Account
...
$ # on a new shell (yarn startg will keep a shell running)
$ yarn migrate # And look for something like "contract address: 0xD940ca1D900538ED8fb1a303b3eaA5a1fE24aAcD" and copy the 42 char number and put it in `playNFT/elm/constants.js` (replacing whatever is there)
$ # profit
```

## To give yourself funds:
``` sh
$ # start local eth network and then:
$ cd path/to/playNFT
$ nix develop -c $SHELL # if not already there
$ cd eth
$ yarn console # the next command you get `to` address in metamask, and `from` address from one of the multiple accounts with 100 eth that get displayed right after doing `yarn startg`, and that should give your account 10 eth
truffle(development)> web3.eth.sendTransaction({ from:"0xfd8c58E84f095810820f567bC5417C3bA5902454",to:"0xd69E5c706B3F0E3E121D4686130E513A0E6729C7", value:9999999999999999999 });
```
