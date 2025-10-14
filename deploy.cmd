rm -rf build/gh-pages/* 
cp -R build/web/* build/gh-pages/
cd build/gh-pages
git add -A
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M')"
git push origin gh-pages
