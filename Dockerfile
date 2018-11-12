# base image
FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base

# .pfx certificate to be copied across
ENV SSL_CERTIFICATE=dev.api.pfx
ENV SSL_PASSWORD=crypticpwd
ENV SSL_DIR=./DevOps/ssl/
# dotnet specific envs
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80;https://+:443
ENV Kestrel:Certificates:Default:Path=/var/ssl/${SSL_CERTIFICATE}
ENV Kestrel:Certificates:Default:Password=${SSL_PASSWORD}
ENV Kestrel:Certificates:Default:AllowInvalid=true

WORKDIR /app

# setup ssl certs if exists
RUN mkdir /var/ssl/
COPY ${SSL_DIR} /var/ssl/
RUN [ -f /var/ssl/${SSL_CERTIFICATE} ] && \
    cert=$(echo ${SSL_CERTIFICATE} | sed s/.pfx//) && \
    openssl pkcs12 -in /var/ssl/${SSL_CERTIFICATE} -passin pass:${SSL_PASSWORD} -passout pass:${SSL_PASSWORD} -nocerts -out /usr/local/share/ca-certificates/${cert}.key && \
    openssl pkcs12 -in /var/ssl/${SSL_CERTIFICATE} -passin pass:${SSL_PASSWORD} -passout pass:${SSL_PASSWORD} -clcerts -nokeys -out /usr/local/share/ca-certificates/${cert}.crt && \
    update-ca-certificates

EXPOSE 80
EXPOSE 443

# build image
FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src

# restore
COPY src/HelloHttp.csproj .
RUN dotnet restore HelloHttp.csproj

# build
COPY ./src/*.cs ./
COPY ./src/*.json ./
RUN dotnet build HelloHttp.csproj --no-restore -c Release -o /app

# publish
RUN dotnet publish HelloHttp.csproj --no-build -c Release -o /app

# final image
FROM base AS final
WORKDIR /app
COPY --from=build /app .

ENTRYPOINT ["dotnet", "HelloHttp.dll"]
