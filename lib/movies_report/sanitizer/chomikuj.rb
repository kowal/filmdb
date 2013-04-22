module MoviesReport
  module Sanitizer
    class Chomikuj

      TO_REMOVE = %w{ .BRRiP MX PL.DVDRiP.XviD.AC3-PBWT PL.DVDRiP.XViD-J25 DVDRip.XviD-LEKTOR HDRip.XviD-LEKTOR PL.PDTV.XViD-Zet
                       PLSUBBED.BRRip.XviD-BiDA DVDRiP DVDRip XViD PSiG XviD.AC3-PBWT XviD AC3-PBWT 480p AC3-MORS PL.DVDRiP.X 
                       XviD.Zet XviD-max184 XviD-Zet .-Zet XviD-BiDA XviD PDTV .ViD-aX HDRip BDrip PL.DVDRip.XviD-max184 -max184
                       BDRip-max184 .BDRip.-BiDA .BRRip-BiDA .BRRip .BRRip.XviD .BDRip.XviD -GHW -BiDA .-BiDA DRip-BiDA .HDTV TVRip
                       lektor Lektor lekyor .napisy SUBBED.B SUBBED -LEKTOR 2012.PLDUB PL.DVDRip.XviD-Zet
                       -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
                       .pl PL IVO(1).avi ivo IVO Ivo 2012.PL dubbing.pl.avi Dubbing
                       chomikuj Chomikuj.avi .avi
                       -- .--cam cam.avi ==
      }

      def self.clean(str)
        raise ArgumentError.new('String to sanitize not given!') if str.nil?

        str.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '').gsub(/\(.*\d+.*\).*/, '').strip
      end
    end
  end
end