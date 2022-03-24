# novoconfig

in an isolated environment such as a machine just for this task or a virtual machine, and at your own risk running binaries without public source code-

and using a linux machine and bash with npm installed:

-----

sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt -y upgrade

sudo apt install nodejs npm libjansson4 libcurl4 -y

mkdir ~/.novo-bitcoin

nano ~/.novo-bitcoin/novo.conf

port=8666
rpcport=8665
rpcuser=youputausernamehere
rpcpassword=youputabigasspasswordhere

wget https://raw.githubusercontent.com/bitsko/novoconfig/main/novoconfig.sh && chmod +x novoconfig.sh

./novoconfig.sh

during this installation, you can press j at some point, and it will install an addr generator and paste one out for you at the end 

cd ~/.novo-bitcoin

./nbsv.sh

-----

addresses generated with bsvjs can be imported into the novobitcoin wallet by running
./novobitcoin-cli importprivkey your_private_key_here
and the private key generated can be found in the ~/.novo-bitcoin/bin folder.
