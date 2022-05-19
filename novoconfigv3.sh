#!/usr/bin/env bash
# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/novoconfigv3.sh && chmod +x novoconfigv3.sh && ./novoconfigv3.sh

echo "downloading and configuring novo..."
echo "use at your own risk"
echo "press Ctrl+C to abort"
sleep 5
IFS= read -r -p "enter a username for novod"$'\n>' username
IFS= read -r -p "enter a rpc password for novod"$'\n>' rpcpassword
IFS= read -r -p "how many CPU threads to mine with?"$'\n>' threads
IFS= read -r -p "enter a name for your cpu pool miner"$'\n>' minerName

#turn tx indexing on with "index" as pos. param.
index=0; if [[ "$@" =~ "index" ]]; then index=1; fi
#version of binary
vrs="0.1.2"
mvrs="0.1.0"
novoDir="$HOME/.novo"
novoBin="$HOME/.novo/bin"
novoDL="$novoBin/dl"
poolScript="$novoBin/novo.sh"
minerConf="$novoBin/solo_cfg.json"
poolConf="$novoBin/pool_cfg.json"
novoConf="$HOME/.novo/novo.conf"
bsvAddy="miningAddress.txt"
minerDL="novominer-$mvrs-x86_64-linux-gnu.tar.gz"
nodeDL="novo-$vrs-x86_64-linux-gnu.tar.gz"
gitUrl="https://github.com/novobitcoin/novobitcoin-release/releases/download"
if [[ ! -d "$novoDir" ]]; then mkdir -p "$novoDir"; fi
if [[ ! -d "$novoBin" ]]; then mkdir -p "$novoBin"; fi
if [[ ! -d "$novoDL" ]]; then mkdir -p "$novoDL"; fi
read -p "press s to give an address to mine to, j to generate a keypair with bsv-js (not a novo generated address!), or N to leave blank and edit $novoBin/cfg.json later"$'\n>' sjn
case $sjn in
    [Ss]* ) read -r -p "what address to send the mined tokens to?" whataddress
            miningAddress=$whataddress
            ;;
    [Jj]* ) if [ ! $(command -v npm) ]; then echo "install npm"; exit 0; fi
            if [ ! -d node_modules/bsv/ ]; then
                npm i --prefix "$(pwd)" bsv --save; fi
            if [ "$(npm list bsv | awk NR==2 | tr -dc '0-9' | cut -c 1)" == "2" ];then
                vkey=PrivKey && pkey=PubKey; fi
            if [ "$(npm list bsv | awk NR==2 | tr -dc '0-9' | cut -c 1)" == "1" ];then
                vkey=PrivateKey && pkey=PublicKey; fi
                node<<<"var bsv = require('bsv'); var privateKey = bsv.$vkey.fromRandom(); var publicKey = bsv.$pkey.from$vkey(privateKey); console.log(bsv.Address.from$pkey(publicKey).toString(),privateKey.toString())" | tee -a "$novoBin"/"$bsvAddy"
                miningAddress=$(awk 'END{ print $1 }'<"$novoBin"/"$bsvAddy")
            ;;
    [Nn]* ) miningAddress=Your_Address_Here;;
    * ) echo "Please give an address after selecting s, or generate an address using j, or configure later in ~/.novo/bin/cfg.json by choosing n";;
esac
if [ ! -f "$novoConf" ]; then
        echo "port=8666"$'\n'"rpcport=8665"$'\n'"rpcuser=$username"$'\n'"rpcpassword=$rpcpassword" > "$novoConf"
        if [[ "$index" == 1 ]]; then echo "txindex=1" >> "$novoConf"; fi; fi
if [ ! -f "$minerConf" ]; then
        echo "{"$'\n'"  \"url\" : \"http://127.0.0.1:8665\","$'\n'"  \"user\" : \"$username\","$'\n'\
                " \"pass\" : \"$rpcpassword\","$'\n'"  \"algo\" : \"sha256dt\","$'\n'\
                " \"threads\" : \"$threads\","$'\n'"  \"coinbase-addr\": \"$miningAddress\""$'\n'"}" \
                > "$minerConf"; fi
if [ ! -f "$poolConf" ]; then
        echo "{"$'\n'"  \"url\" : \"stratum+tcp://mine.bit90.io:3042\","$'\n'"  \"user\" : \"$miningAddress.$minerName\","$'\n'\
                " \"algo\" : \"sha256dt\","$'\n'"  \"threads\" : \"$threads\""$'\n'"}" \
                > "$poolConf"; fi
if [ ! -f "$poolScript" ]; then
        echo "#!/usr/bin/env bash"$'\n'"$novoBin/novod --printtoconsole &"$'\n'"nbsvid=\"\$!\""$'\n'\
        "$novoBin/novominer -c $novoBin/pool_cfg.json"$'\n'\
        "kill \"\$nbsvid\""$'\n'"echo \"shutting down\"" > "$poolScript"
        chmod +x "$poolScript"; fi
if [ ! -f "$novoDL"/"$nodeDL" ]; then wget "$gitUrl"/v"$vrs"/"$nodeDL" -P "$novoDL"; fi
if [ ! -f "$novoDL"/"$minerDL" ]; then wget "$gitUrl"/v"$mvrs"/"$minerDL" -P "$novoDL"; fi
tar -xzf "$novoDL"/"$nodeDL" -C "$novoDL"
tar -xzf "$novoDL"/"$minerDL" -C "$novoDL"
cp "$novoDL"/novo-"$vrs"/bin/* "$novoBin"/
cp "$novoDL"/novominer/bin/* "$novoBin"/
rm -r "$novoDL"
echo "to run novo and cpu pool miner at the same time:"
echo "use $poolScript"
