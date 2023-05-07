# Run demo

Launch application
```
export SAASFORM_LOGIN_URL=http://192.168.50.242:7000/login
dotnet build
dotnet run
```

Visit https://192.168.50.242:5001 (Not protected).

Visit https://192.168.50.242:5001/protected => You will be redirected to Saasform login page (if not authenticated yet) => Log into Saasform => When you come back you will be authenticated.