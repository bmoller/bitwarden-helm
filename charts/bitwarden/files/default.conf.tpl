server {
  listen 8080 default;
  server_name {{ .Values.domain }};

  include /etc/nginx/security-headers-ssl.conf;
  include /etc/nginx/security-headers.conf;

  location / {
    proxy_pass http://bitwarden-web:5000/;
    include /etc/nginx/security-headers-ssl.conf;
    include /etc/nginx/security-headers.conf;
    add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https://haveibeenpwned.com https://www.gravatar.com; child-src 'self' https://*.duosecurity.com https://*.duofederal.com; frame-src 'self' https://*.duosecurity.com https://*.duofederal.com; connect-src 'self' wss://bitwarden.example.com https://api.pwnedpasswords.com https://2fa.directory; object-src 'self' blob:;";
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Robots-Tag "noindex, nofollow";
  }

  location /alive {
    return 200 'alive';
    add_header Content-Type text/plain;
  }

  location = /app-id.json {
    proxy_pass http://bitwarden-web:5000/app-id.json;
    include /etc/nginx/security-headers-ssl.conf;
    include /etc/nginx/security-headers.conf;
    proxy_hide_header Content-Type;
    add_header Content-Type $fido_content_type;
  }

  location = /duo-connector.html {
    proxy_pass http://bitwarden-web:5000/duo-connector.html;
  }

  location = /u2f-connector.html {
    proxy_pass http://bitwarden-web:5000/u2f-connector.html;
  }

  location = /sso-connector.html {
    proxy_pass http://bitwarden-web:5000/sso-connector.html;
  }

  location /attachments/ {
    proxy_pass http://bitwarden-attachments:5000/;
  }

  location /api/ {
    proxy_pass http://bitwarden-api:5000/;
  }

  location /icons/ {
    proxy_pass http://bitwarden-icons:5000/;
  }

  location /notifications/ {
    proxy_pass http://bitwarden-notifications:5000/;
  }

  location /notifications/hub {
    proxy_pass http://bitwarden-notifications:5000/hub;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
  }

  location /events/ {
    proxy_pass http://bitwarden-events:5000/;
  }

  location /sso {
    proxy_pass http://bitwarden-sso:5000;
    include /etc/nginx/security-headers-ssl.conf;
    include /etc/nginx/security-headers.conf;
    add_header X-Frame-Options SAMEORIGIN;
  }

  location /identity {
    proxy_pass http://bitwarden-identity:5000;
    include /etc/nginx/security-headers-ssl.conf;
    include /etc/nginx/security-headers.conf;
    add_header X-Frame-Options SAMEORIGIN;
  }

  location /admin {
    proxy_pass http://bitwarden-admin:5000;
    include /etc/nginx/security-headers-ssl.conf;
    include /etc/nginx/security-headers.conf;
    add_header X-Frame-Options SAMEORIGIN;
  }

  location /portal {
    proxy_pass http://bitwarden-portal:5000;
    include /etc/nginx/security-headers-ssl.conf;
    include /etc/nginx/security-headers.conf;
    add_header X-Frame-Options SAMEORIGIN;
  }
}
