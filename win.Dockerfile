# base image
#FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
FROM microsoft/dotnet:2.2-sdk AS base
# admin required for accessing SSL certificates
#USER ContainerAdministrator
ENV ASPNETCORE_ENVIRONMENT=Production
# default to http only, specify ASPNETCORE_* environment variables and volumes to load ssl certificates for https functionality
ENV ASPNETCORE_URLS=http://+:80
WORKDIR /app

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
# copy ssl certs if exists
RUN [ -d ~/.ssl ] && \
    #cp ~/.ssl/*.key /usr/local/share/ca-certificates && \
    #cp ~/.ssl/*.crt /usr/local/share/ca-certificates && \
    openssl pkcs12 -in ~/.ssl/localhost.pfx -nocerts -out ~/.ssl/localhost.key && \
    openssl pkcs12 -in ~/.ssl/localhost.pfx -clcerts -nokeys -out ~/.ssl/localhost.crt
#RUN update-ca-certificates
#ENTRYPOINT ["dotnet", "HelloHttp.dll"]
