# 

Set-Location C:\scripts\o365\AutoSPOStorageQuota

$env:Path



echo "# AutoSPOStorageQuota" >> README.md
git init
git add README.md
  git config --global user.email "Vladilen@Karassev.com"
  git config --global user.name "Vladilen Karassev"
git commit -m "first commit"
git remote add origin https://github.com/VladilenK/AutoSPOStorageQuota.git
git push -u origin master




git --help
git --version

Set-Location C:\scripts\o365\AutoSPOStorageQuota
git add .\AutoSPOStorageQuota.ps1
git commit -m $("version " + (Get-Date).ToString() ) 
git push -u origin master

