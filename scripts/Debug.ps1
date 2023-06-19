# You can spare repeatedly entering passwords if you do the followings in your powershell session:
# . windows\UserCredential.ps1
# . windows\CredentialProvider.ps1
# then just perform (but do not .-source):
# scripts\Debug.ps1

. $PSScriptRoot\..\windows\Environment.ps1

. $RepoToolsDir\PxProxy.ps1

#ShowTodo