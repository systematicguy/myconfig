# You can spare repeatedly entering passwords if you do the followings in your powershell session:
# . helpers\UserCredential.ps1
# . helpers\CredentialProvider.ps1
# then just perform (but do not .-source):
# scripts\Debug.ps1

. $PSScriptRoot\..\windows\Environment.ps1

#. $RepoRoot\scripts\TestUserCredential.ps1

. $RepoToolsDir\GitConfig.ps1

#ShowTodo