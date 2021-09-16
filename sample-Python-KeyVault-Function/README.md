A simple example - accessing Key Vault from a [python http triggered function](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-python). Originally wanted to do this with MSI, but sadly, [no MSI support just yet](https://github.com/Azure/Azure-Functions/issues/1066). When MSI is available it should look something like [this](https://github.com/Microsoft/csa-misc-utils/blob/master/sample-Python-KeyVault-Function/init-with-msi.py). I don't do much python so if looking at this makes your insides hurt, please let me know [Twitter](https://twitter.com/azureandchill) [GitHub](https://github.com/jpda).

## to publish:
because certain dependencies are binary, you have to build in a docker container - `--build-native-deps` does this for you during publish

to create a service principal for rbac assignment to KV secrets, use `az ad sp create-for-rbac --name 'a-recognizable-name' --skip-assignment`

to publish from local, login to azure cli `az login` and set your subscription to the one containing your function, then

`func azure functionapp publish <your function app> --build-native-deps`
