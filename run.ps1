.\DevOps\ssl\generate.ps1 -alias "local" -dns ("localhost", "*.local") -path .\DevOps\ssl
docker-compose up --build
