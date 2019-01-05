desc "convert images"
task :images do
  ## macOSならsipsコマンドを使い、それ以外ではImageMagickを使う
  has_sips = File.exist?("/usr/bin/sips")
  ## 高解像度の画像をもとに低解像度の画像を作成する
  for src in Dir.glob("images_highres/**/*.{png,jpg,jpeg}")
    ## 低解像度の画像を作成済みなら残りの処理をスキップ
    dest = src.sub("images_highres/", "images_lowres/")
    next if File.exist?(dest) && File.mtime(src) == File.mtime(dest)
    ## 必要ならフォルダを作成
    dir = File.dirname(dest)
    mkdir_p dir if ! File.directory?(dir)
    ## 高解像度の画像のDPIを変更（72dpi→360dpi）
    if has_sips
      sh "sips -s dpiHeight 360 -s dpiWidth 360 #{src}"
    else
      sh "convert -density 360 -units PixelsPerInch #{src} #{src}"
    end
    ## 低解像度の画像を作成（72dpi、横幅1/5）
    if has_sips
      `sips -g pixelWidth #{src}` =~ /pixelWidth: (\d+)/
      option = "-s dpiHeight 72 -s dpiWidth 72 --resampleWidth #{$1.to_i / 5}"
      sh "sips #{option} --out #{dest} #{src}"
    else
      sh "convert -density 72 -units PixelsPerInch -resize 20% #{src} #{dest}"
    end
    ## 低解像度の画像のタイムスタンプを、高解像度の画像と同じにする
    ## （＝画像のタイムスタンプが違ったら、画像が更新されたと見なす）
    File.utime(File.atime(dest), File.mtime(src), dest)
  end
  ## 高解像度の画像が消されたら、低解像度の画像も消す
  for dest in Dir.glob("images_lowres/**/*").sort().reverse()
    src = dest.sub("images_lowres/", "images_highres/")
    rm_r dest if ! File.exist?(src)
  end
end
