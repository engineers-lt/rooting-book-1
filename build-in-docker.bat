@echo off
docker run -t --rm -v %cd%/articles:/book vvakame/review /bin/sh -c "cd /book && review-pdfmaker config.yml"
pause
