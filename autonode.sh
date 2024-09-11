#!/bin/bash


curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 20

sudo npm i -g yarn

sudo rm /usr/local/bin/docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

git clone https://github.com/CATProtocol/cat-token-box
cd cat-token-box
yarn install
yarn build

cd ./packages/tracker/
sudo chmod 777 docker/data
sudo chmod 777 docker/pgdata
docker-compose up -d


cd ../../
sudo docker build -t tracker:latest .
sudo docker run -d \
    --name tracker \
    --add-host="host.docker.internal:host-gateway" \
    -e DATABASE_HOST="host.docker.internal" \
    -e RPC_HOST="host.docker.internal" \
    -p 3000:3000 \
    tracker:latest


cd packages/cli


rm config.json
cat <<EOF > config.json
{
  "network": "fractal-mainnet",
  "tracker": "http://78.47.40.206:3000",
  "dataDir": ".",
  "maxFeeRate": 100,
  "rpc": {
      "url": "http://78.47.40.206:8332",
      "username": "bitcoin",
      "password": "opcatAwesome"
  }
}
EOF



cat <<EOF > mint.sh
#!/bin/bash

command="yarn cli mint -i 45ee725c2c5993b3e4d308842d87e973bf1951f5f7a804b21e4dd964ecd12d6b_0 5 --fee-rate 1000"

while true; do
    # Komutu çalıştır ve hata kontrolünü hemen yap
    $command
    result=$?

    if [ $result -ne 0 ]; then
        echo "Komut başarısız oldu, hata kodu: $result"
        exit 1
    fi

    sleep 1
done
EOF

chmod +x mint.sh
