PascWallet (PAWA) for PascalCoin is a simple GUI
build on the original PascalCoin source code.

Version 0.3b

WARNING _ BETA TEST VERSION !!!!!!!!!!!!
----------------------------------------

Don't use it unless you know what you are doing.


Compiled by Lazarus 1.6.4 and FPC 3.0.2

Testets under both  Linux Mint 18.1 and Windows 10
 - but there may be a lot of unknown bugs :)



Compile in same directory as PascalCoin Wallet.
Just add the files and directories to PascalCoin

Directories:
Synapse
Units
Wallet (<-- add)

And place PascWallet.lpi etc. in same dir as the
other project files.


Known issues:

UFRMMemoText.pas has "Text" as variable but Lazarus
complains because "Text" is a keyword.

Work around compile PascalCoin Wallet first or
change "Text" to "Txt" in UFRMMemoText.pas






