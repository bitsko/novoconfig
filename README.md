scripts for novo

see https://github.com/novoworks/novo-release/

requires libcurl4, libjansson4 for ubuntu miner

------
node and cpu pool mining:

wget https://raw.githubusercontent.com/bitsko/novoconfig/main/novoconfigv3.sh && chmod +x novoconfigv3.sh

./novoconfigv3.sh

cd ~/.novo/bin

./novo.sh

-----

addresses generated with bsvjs can be imported into the novo wallet by running
./novo-cli importprivkey your_private_key_here
and the private key generated can be found in the ~/.novo/bin folder.
