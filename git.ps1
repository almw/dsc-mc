  git config --global user.email "xxxx@gmail.com"
  git config --global user.name "xxx xxxx"

echo "# dsc-mc" >> README.md
git init
git add README.md
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/almw/dsc-mc.git
git push -u origin main