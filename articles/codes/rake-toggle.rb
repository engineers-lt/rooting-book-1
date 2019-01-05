namespace "images" do

  desc "toggle image directories ('images_{lowres,highres}')"
  task :toggle do
    link = File.readlink("images")
    rm "images"
    if link == "images_lowres"
      ln_s "images_highres", "images"
    else
      ln_s "images_lowres", "images"
    end
  end

end
