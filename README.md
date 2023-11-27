# N2Pool

N2Pool is a decentralized pool for Nevocoin mining.

# Contents
- [Pool mining vs Solo mining vs N2Pool mining](#pool-mining-vs-solo-mining-vs-N2Pool-mining)
- [Features](#features)
- [How payouts work in N2Pool](#how-payouts-work-in-N2Pool)
- [Default N2Pool parameters](#default-N2Pool-parameters)
- [Nevocoin version support](#monero-version-support)
- [How to mine on N2Pool](#how-to-mine-on-N2Pool)
  - [General Considerations](#general-considerations)
  - [GUI for N2Pool](#gui-for-N2Pool)
  - [GNU/Linux](#gnulinux)
  - [Windows](#windows)
- [Build instructions](#build-instructions)
- [Donations](#donations)

## Pool mining vs Solo mining vs N2Pool mining

Here's the comparison table of the different ways of mining. While pool mining is the easiest to setup, it centralizes Nevocoin network and pool admin gets full power over your hashrate and your unpaid funds. Solo mining is 100% independent and the best for the network. N2Pool mining has all the advantages of solo mining, but also makes regular payouts possible.

|Pool type|Payouts|Fee|Min. payout|Centralized?|Stability|Control|Setup
|-|-|-|-|-|-|-|-|
|Centralized pool|Regular|0-3%|>0.05 NEVO|Yes|Less stable due to pool server outages|Pool admin controls your mined funds, what you mine and can execute network attacks|Only miner software is required
|Solo|Rare|0%|20 NEVO or more|No|As stable as your Nevocoin node|100% under your control|Nevocoin node + optional miner
|**N2Pool**|Regular|0%|~0.035 NEVO|No|As stable as your Nevocoin node|100% under your control|Nevocoin node(s) + N2Pool node(s) + optional miner(s)

## Features

* Decentralized: no central server that can be shutdown/blocked. N2Pool uses a separate blockchain to merge mine with Nevocoin. Pool admin can't go rogue or be pressured to do an attack on the network because there is no pool admin!
* Permissionless: there is no one to decide who can mine on the pool and who can't.
* Trustless: there is no pool wallet, funds are never in custody. All pool blocks pay out to miners directly.
* PPLNS payout scheme
* **0% fee**
* **0 NEVO payout fee**
* **~0.035 NEVO minimal payout**
* Fast block times, down to 1 second
* Uncle blocks are supported to avoid orphans - all your shares will be accounted for!
* Configurable PPLNS window size and block time
* Advanced mempool picking algorithm, it creates blocks with better reward than what nevocoind solo mining does
* Password protected private pools
* Highly reliable configurations are supported (multiple N2Pool nodes mining to the same wallet, each N2Pool node can use multiple Nevocoin nodes and switch on the fly if an issue is detected)

## How payouts work in N2Pool

First you need to find a pool share. This share will stay in [PPLNS](https://en.wikipedia.org/wiki/Mining_pool#Pay-per-last-N-shares) window for up to 720 pool blocks (6 hours, auto adjustable to balance payout sizes and frequency). The moment N2Pool finds a Nevocoin block and you have at least 1 pool share in PPLNS window, you'll get a payout! Nevocoin block reward is split between all miner wallets in PPLNS window. Each miner gets a part of block reward proportional to the total difficulty of his/her shares in PPLNS window.

**NOTE** If N2Pool doesn't have enough hashrate to find Nevocoin blocks faster than every 6 hours on average, **not all your pool shares will result in a payout**. Even if pool hashrate is higher, bad luck can sometimes result in a share going through PPLNS window without a payout. But in the long run it will be compensated by other shares receiving multiple payouts - your payouts will average out to what you'd get with regular pool mining.

## Default N2Pool parameters

* Block time: 10 seconds
* PPLNS window: up to 720 blocks (6 hours, auto adjustable to balance payout sizes and frequency)
* Minimum payout = Nevocoin block reward/720

## Nevocoin version support

In order to continue mining on N2Pool, you must update both Nevocoin and N2Pool software to the latest available versions as soon as they are released.

## How to mine on N2Pool

### General Considerations

- In order to mine on N2Pool, a synced Nevocoin node using the latest version of nevocoind is required. If you don't currently have one, you can download the official Nevocoin binaries, start `nevocoind` on your PC and wait until it's fully synced.
- It is highly recommended that you create a separate restricted user account (in your OS) for mining. While N2Pool has been battle-tested for a long time now, any software may have unknown bugs/vulnerabilities. 
- You have to use a primary wallet address (the one starting with `Ne`) for mining. Subaddresses and integrated addresses are not supported, just like with nevocoind solo mining.
- You can add the `--mini` parameter to your N2Pool command to connect to the **N2Pool-mini** sidechain.
- Check that ports 44231 (Nevocoin p2p port) and 41518/41519 (N2Pool/N2Pool mini p2p port) are open in your firewall to ensure better connectivity. If you're mining from a computer behind NAT (like a router) you could consider forwarding the ports to your local machine.
- You can connect multiple miners to the same N2Pool node. The more the better!
- The steps below assume that you run everything on the same machine. If it's not the case, change `127.0.0.1` to appropriate IP addresses for your setup. 
- It is highly recommended to create a new mainnet wallet for N2Pool mining because **wallet addresses are public on N2Pool**.

### GNU/Linux

1. Download the latest N2Pool binaries [here](https://github.com/SChernykh/N2Pool/releases/latest).
   -  Alternatively, grab the latest source code for N2Pool and [build it](#build-instructions).
2. Download the latest XMRig (linux-static-x64) binary [here](https://github.com/xmrig/xmrig/releases/latest).
3. Prepare enough huge pages (each of monerod/N2Pool/XMRig needs them): 
```
sudo sysctl vm.nr_hugepages=3072
```
4. Check that ports 18080 (Nevocoin p2p port) and 41518/41519 (N2Pool/N2Pool mini p2p port) are open in your local firewall to ensure better connectivity. 
5. Start `monerod` with the following command/options: 
```
./monerod --zmq-pub tcp://127.0.0.1:44233 --out-peers 32 --in-peers 64 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist
``` 
**Note:**
The `--zmq-pub` option is required for N2Pool to work properly.

`--out-peers 32 --in-peers 64` is needed to (1) have many connections to other nodes and (2) limit incoming connection count because it can grow uncontrollably and cause problems when it goes above 1000 (open files limit in Linux). If your network connection's **upload** bandwidth is less than **10 Mbit**, use `--out-peers 8 --in-peers 16` instead.

`--add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080` is needed to have guaranteed good working nodes in your connected peers.

`--disable-dns-checkpoints` is needed to avoid periodical lags when DNS is updated (it's not needed when mining)

`--enable-dns-blocklist` is needed to ban known bad nodes


6. Start N2Pool with the following command/options:
```
./N2Pool --host 127.0.0.1 --wallet YOUR_WALLET_ADDRESS
```
7. Wait until the initial N2Pool sync is finished (shouldn't take more than 5-10 minutes).
8. Start XMRig with the following command/options:
 ```
 ./xmrig -o 127.0.0.1:3333
 ```
   - Note that you don't need to specify your wallet address for XMRig. **Wallet addresses set in XMRig config will be ignored!** 
   - To set a custom fixed difficulty for your miner (for example, 10000), instead start XMRig with the following options: 
   ```
   ./xmrig -u x+10000 -o 127.0.0.1:3333
   ```
9. XMRig should connect and start mining!

**Additional Information:** 
- For a more in-depth beginner friendly walk-through with the option of using Docker, please see SethForPrivacy's guide at: https://sethforprivacy.com/guides/run-a-N2Pool-node/
- You can check the N2Pool.log for any warnings or errors using the following command: 
```
grep -E 'WARNING|ERROR' N2Pool.log
```
- N2Pool has verbose logging by default, you can reduce it by using "loglevel N" command where N is between 0 and 6. Default loglevel is 3.
  - You can use `logrotate` with a config like this to control logfile growth:
 ```
<path-to-logfile>
{
rotate 7
daily
missingok
delaycompress
nocreate
}
 ```

### Windows 

**Note:** *Windows SmartScreen may block incoming connections by files that are "Downloaded from the Internet". You can allow 'N2Pool.exe' and 'monerod.exe' by double-clicking them, clicking "More Info", then click "Run Anyway" and then closing them immediately so you can run them from the command line. Advanced users can use the PowerShell cmdlet `Unblock-File` to remove this flag.*

1. Download the latest N2Pool binaries [here](https://github.com/SChernykh/N2Pool/releases/latest).
    - Alternatively, grab the latest source code for N2Pool and [build it](#build-instructions).
2. Download the latest XMRig binary [here](https://github.com/xmrig/xmrig/releases/latest).
3. Expand the N2Pool binaries into an appropriate location (`%USERPROFILE%/bin` or `C:/bin/` are good options)
4. Expand XMRig binary into an appropriate location (the same folder as N2Pool is fine). 
5. Prepare huge pages to work properly (each of monerod/N2Pool/XMRig needs them): 
   - On Windows 10 or above, run XMRig at least once as Administrator (right-click Run As Administrator)
   - On earlier versions of Windows, you'll need to run XMRig as Administrator at least once per login.
6. Create "Nevocoin" folder inside extracted N2Pool folder and copy Nevocoin binaries there.
7. Open a command prompt and navigate to the folder where you extracted N2Pool.

**Note:** *When running the below commands, Windows Firewall may prompt to allow connections, click "Allow" if prompted.*

8. Start `monerod` with the following command/options: 
```
.\Nevocoin\monerod.exe --zmq-pub tcp://127.0.0.1:44233 --out-peers 32 --in-peers 64 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist
```
**Note:**
The `--zmq-pub` option is required for N2Pool to work properly.

`--out-peers 32 --in-peers 64` is needed to (1) have many connections to other nodes and (2) limit incoming connection count because it can grow uncontrollably and cause problems when it goes above 1000 (open files limit in Linux). If your network connection's **upload** bandwidth is less than **10 Mbit**, use `--out-peers 8 --in-peers 16` instead.

`--add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080` is needed to have guaranteed good working nodes in your connected peers.

`--disable-dns-checkpoints` is needed to avoid periodical lags when DNS is updated (it's not needed when mining)

`--enable-dns-blocklist` is needed to ban known bad nodes

9. Start N2Pool with the following command/options:
```
.\N2Pool.exe --host 127.0.0.1 --wallet YOUR_WALLET_ADDRESS --mini
```
10. Wait until the initial N2Pool sync is finished (shouldn't take more than 5-10 minutes).
11. Start XMRig with the following command/options:
```
.\xmrig.exe -o 127.0.0.1:3333
```
   - Note that you don't need to specify your wallet address for XMRig. **Wallet addresses set in XMRig config will be ignored!** 
   - To set a custom fixed difficulty for your miner (for example, 10000), instead start XMRig with the following options: 
     ```
     xmrig.exe -u x+10000 -o 127.0.0.1:3333
     ```
12. XMRig should connect and start mining!
13. *(Optional but highly recommended)* You can create a Quickstart by creating a batch (.bat) file with the following contents and placing it in your N2Pool directory along with `xmrig.exe`.
```
@ECHO OFF
start cmd /k %~dp0\Nevocoin\monerod.exe --zmq-pub tcp://127.0.0.1:44233 --out-peers 32 --in-peers 64 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist
ECHO Wait until the Nevocoin daemon shows fully synced before continuing. This can take some time. Type 'status' in other window to check progress.
PAUSE
start cmd /k %~dp0\N2Pool.exe --wallet YOUR_WALLET_ADDRESS --mini
ECHO Wait until the daemon shows fully synced before continuing. This can take some time.
PAUSE
%~dp0\xmrig.exe -o 127.0.0.1
```

## Build instructions
Only 64-bit builds are supported, in particular ARMv7 or older CPUs are not supported. The reason is that RandomX hashing algorithm is too slow in 32-bit mode, and N2Pool needs to check new blocks very fast to keep up with other nodes.

Please see the relevant instructions for your platform:

### Ubuntu 20.04

Run the following commands to install the necessary prerequisites, clone this repo, and build N2Pool locally on Ubuntu 20.04:
```
sudo apt update && sudo apt install git build-essential cmake libuv1-dev libzmq3-dev libsodium-dev libpgm-dev libnorm-dev libgss-dev libcurl4-openssl-dev libidn2-0-dev
git clone --recursive https://github.com/SChernykh/N2Pool
cd N2Pool
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### [Arch Linux](https://archlinux.org/packages/community/x86_64/N2Pool/)

```
pacman -S N2Pool
```

### [Nix/NixOS](https://nixos.org)

This is a flake only project. So you have to use [nixUnstable with nix flakes](https://nixos.wiki/wiki/Flakes) to build or install N2Pool. 
The commands below use the new flake specific reference-format, so be sure to also set `ca-references` in `--experimental-features`.

Because this project has submodules which are not fixed in _nixUnstable_ yet you have to use the `nix/master` branch:
```
nix shell github:nixos/nix/master
```

Run the binary:
```
nix run git+https://github.com/SChernykh/N2Pool?ref=master&submodules=1
```

Run the binary with arguments:
```
nix run git+https://github.com/SChernykh/N2Pool?ref=master&submodules=1 -- --help
```

### Windows

N2Pool binary (Visual Studio Community 2019 build):
*NOTE: You need to have the "Desktop Development with C++" module installed.*
```
git clone --recursive https://github.com/SChernykh/N2Pool
cd N2Pool
mkdir build
cd build
cmake .. -G "Visual Studio 16 2019"
```
then open generated build\N2Pool.sln in Visual Studio and build it there

Alternatively, you can select "Clone a repository" within the GUI, then select "Build" from the menu. 

### macOS

Run the following commands to install the necessary prerequisites, clone this repo, and build N2Pool locally on your Mac:
```
brew update && brew install git cmake libuv zmq libpgm curl
git clone --recursive https://github.com/SChernykh/N2Pool
cd N2Pool
mkdir build && cd build
cmake ..
make -j$(sysctl -n hw.logicalcpu)
```

### FreeBSD

Run the following commands to install the necessary prerequisites, clone this repo, and build N2Pool locally on FreeBSD:
```
pkg install git cmake libuv libzmq4 curl
git clone --recursive https://github.com/SChernykh/N2Pool
cd N2Pool
mkdir build && cd build
cmake ..
make
```

### Android (Termux)

Run the following commands to install the necessary prerequisites, clone this repo, and build N2Pool locally in Termux:
```
pkg install git build-essential cmake libuv libzmq libcurl
git clone --recursive https://github.com/SChernykh/N2Pool
cd N2Pool
mkdir build && cd build
cmake ..
make -j$(nproc)
```

## Donations

If you'd like to support further development of Nevocoin N2Pool, you're welcome to send any amount of XMR to the following address:

```
44MnN1f3Eto8DZYUWuE5XZNUtE3vcRzt2j6PzqWpPau34e6Cf4fAxt6X2MBmrm6F9YMEiMNjN6W4Shn4pLcfNAja621jwyg
```
