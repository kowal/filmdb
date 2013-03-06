module MoviesReport
  class Sanitizer

    TO_REMOVE = %w{ .BRRiP MX DVDRiP DVDRip XViD PSiG XviD.AC3-PBWT XviD AC3-PBWT 480p AC3-MORS
                     XviD.Zet XviD-Zet .-Zet XviD-BiDA .XviD .PDTV .BDRip-max184 .BRRip-BiDA ..BRRip .-BiDA DRip-BiDA .HDTV TVRip
                     lektor Lektor lekyor .napisy SUBBED.B SUBBED -LEKTOR
                     -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
                     .pl PL ivo IVO Ivo
                     chomikuj Chomikuj.avi .avi dubbing.pl.avi
    }

    def self.clean(str)
      str.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '').gsub(/\(\d+\)/, '')
    end
  end
end