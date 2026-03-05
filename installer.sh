sudo apt update
sudo apt upgrade -y

sudo apt install nginx -y
sudo apt install kiwix-tools kiwix-meta4


sudo mkdir -p /srv/library/zim
sudo mkdir -p /srv/library/pdf
sudo mkdir -p /srv/library/index
sudo chown -R $USER:$USER /srv/library

#mover todos los archivos zim a /srv/library/zim 



kiwix-manage /srv/library/library.xml add /srv/library/zim/*.zim
sudo nano /etc/systemd/system/kiwix.service > /dev/null <<EOF

[Unit]
Description=Kiwix Offline Server
After=network.target

[Service]
User=umiphos
ExecStart=/usr/bin/kiwix-serve --port=8080 --library /srv/library/zim
Restart=always

[Install]
WantedBy=multi-user.target
EOF




sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    location /pdf/ {
    alias /srv/library/pdf/;
    autoindex on;
    }
}


EOF

echo "Probando configuración nginx..."
sudo nginx -t

echo "Reiniciando servicios..."
sudo systemctl restart nginx
sudo systemctl start kiwix

echo "Instalación terminada."
echo "Accede a: http://localhost:8080"
