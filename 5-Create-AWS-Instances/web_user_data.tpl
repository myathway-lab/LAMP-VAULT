#!/bin/bash
set -e
sudo hostnamectl set-hostname LAMP-WEB
sudo apt-get update -y
sudo apt-get install apache2 -y 
sudo apt-get install php libapache2-mod-php php-mysql php-curl php-gd php-json php-zip gpg wget -y
sudo apt install mysql-client -y
sudo wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault


# Create the Vault agent configuration file
sudo cat <<EOF > /etc/vault.d/vault-agent.hcl
exit_after_auth = false
pid_file = "/var/run/vault-agent.pid"

auto_auth {
  method "aws" {
      mount_path = "auth/aws"
      config = {
          type = "iam"
          role = "vault-role-for-aws-ec2role"
      }
  }

  sink "file" {
      config = {
          path = "/var/www/html/vault-token-via-agent"
      }
  }
}

vault {
  address = "${vault_addr}"
}

template {
  source      = "/etc/vault.d/db-creds-template.hcl"
  destination = "/var/www/html/db-creds.json"  
}
EOF

sudo chown vault:vault /etc/vault.d/vault-agent.hcl
sudo chmod 600 /etc/vault.d/vault-agent.hcl


# Read the DB role creds
sudo cat <<EOF > /etc/vault.d/db-creds-template.hcl
{
  "username": "{{ with secret "database/creds/db-role" }}{{ .Data.username }}{{ end }}",
  "password": "{{ with secret "database/creds/db-role" }}{{ .Data.password }}{{ end }}"
}
EOF

sudo chown vault:vault /etc/vault.d/db-creds-template.hcl
sudo chmod 600 /etc/vault.d/vault-agent.hcl



##Run vault agent as service 
sudo cat <<EOF > /etc/systemd/system/vault-agent.service
[Unit]
Description=Vault Agent
After=network.target

[Service]
Environment="VAULT_NAMESPACE=admin"
Environment="VAULT_ADDR=${vault_addr}"

ExecStart=/usr/bin/vault agent -config=/etc/vault.d/vault-agent.hcl
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable vault-agent
sudo systemctl start vault-agent


#Configure PHP code for dynamic DB cred 
sudo cat <<'EOF' > /var/www/html/phptest.php
<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);


// Path to the JSON file with database credentials

$credsFile = '/var/www/html/db-creds.json';

// Read the JSON file
$json = file_get_contents($credsFile);
if ($json === false) {
    die("Failed to read credentials file.");
}

$creds = json_decode($json, true);
if ($creds === null) {
    die("Failed to decode JSON.");
}

// Debugging output
echo "Username: " . htmlspecialchars($creds['username']) . "<br>";
echo "Password: " . htmlspecialchars($creds['password']) . "<br>";

// Database connection parameters
$servername = "${db_ip}"; // e.g., "localhost" or your server IP
$username = $creds['username'];
$password = $creds['password'];
$dbname = "lamp"; // the name of your database

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to the database.";
?>
EOF
              
sudo systemctl restart vault-agent.service 
sudo systemctl restart apache2