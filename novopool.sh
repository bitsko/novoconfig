#!/usr/bin/env bash
# lets get this bread


echo "downloading and configuring novobitcoin pool miner..."
echo "mine.bit90.io"
echo "closed source binary file:"
echo "use at your own risk in an isolated environment"
echo "press Ctrl+C to abort"
sleep 5

echo "updating OS"
sudo apt update
echo "checking/installing dependencies"
sudo apt install libjansson4 libcurl4 2>/dev/null

IFS= read -r -p "enter a address for your miner"$'\n>' miningAddress
IFS= read -r -p "enter a name for your miner"$'\n>' minerName
IFS= read -r -p "how many CPU threads to mine with?"$'\n>' threads
#version of binary
vrs="0.1.0"
novoBin="$HOME/novo-miner"
novoDL="$novoBin/dl"
runScript="$novoBin/npool.sh"
quietScript="$novoBin/npoolq.sh"
minerConf="$novoBin/cfg.json"
minerDL="novominer-$vrs-x86_64-linux-gnu.tar.gz"
gitUrl="https://github.com/novobitcoin/novobitcoin-release/releases/download"
if [[ ! -d "$novoBin" ]]; then mkdir -p "$novoBin"; fi
if [[ ! -d "$novoDL" ]]; then mkdir -p "$novoDL"; fi
if [ ! -f "$minerConf" ]; then
        echo "{"$'\n'"  \"url\" : \"stratum+tcp://:mine.bit90.io:3042\","$'\n'"  \"user\" : \"$miningAddress.$minerName\","$'\n'\
                " \"algo\" : \"sha256dt\","$'\n'"  \"threads\" : \"$threads\""$'\n'"}" \
                > "$minerConf"; fi
if [ ! -f "$runScript" ]; then
        echo "#!/usr/bin/env bash"$'\n'\
        "$novoBin/novominer -c $novoBin/cfg.json"$'\n'\
        "echo \"shutting down\"" > "$runScript"
        chmod +x "$runScript"; fi
if [ ! -f "$quietScript" ]; then
        echo "#!/usr/bin/env bash"$'\n'\
        "$novoBin/novominer -q -c $novoBin/cfg.json"$'\n' > "$quietScript"
        chmod +x "$quietScript"; fi
if [ ! -f "$novoDL"/"$minerDL" ]; then wget "$gitUrl"/v"$vrs"/"$minerDL" -P "$novoDL"; fi
tar -xzf "$novoDL"/"$minerDL" -C "$novoDL"
cp "$novoDL"/novominer/bin/* "$novoBin"/
rm -r "$novoDL"
echo "to pool mine on mine.bit90.io"
echo "use $runScript"
echo "or $quietScript"
