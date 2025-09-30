module MoviesHelper
  def embed_url(url)
    return url unless url.present?
    
    # YouTube
    if url.match?(/youtube\.com\/watch\?v=(.+)/)
      video_id = url.match(/watch\?v=([^&]+)/)[1]
      return "https://www.youtube.com/embed/#{video_id}"
    elsif url.match?(/youtu\.be\/(.+)/)
      video_id = url.match(/youtu\.be\/([^?]+)/)[1]
      return "https://www.youtube.com/embed/#{video_id}"
    end
    
    # Vimeo
    if url.match?(/vimeo\.com\/(\d+)/)
      video_id = url.match(/vimeo\.com\/(\d+)/)[1]
      return "https://player.vimeo.com/video/#{video_id}"
    end
    
    # Dailymotion
    if url.match?(/dailymotion\.com\/video\/([^_]+)/)
      video_id = url.match(/video\/([^_]+)/)[1]
      return "https://www.dailymotion.com/embed/video/#{video_id}"
    end
    
    # URL directe (MP4, etc.)
    url
  end
end