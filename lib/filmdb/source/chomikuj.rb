# coding: utf-8

module FilmDb

  module Source

    # Source::Chomikuj
    # - takes service specific uri
    # - finds all movies information on given service page
    # - provides iterator, which yields all found movies
    #   with their page-specific properties
    #
    class Chomikuj

      def initialize(uri)
        FilmDb.logger.info 'Fetching page ..'
        @document  = HtmlPage.new(uri).document
        @page      = create_page
      end

      # For each movie found - yields movie attributes:
      #    {:title => 'XXX', :size => '200'}
      #
      def all_movies
        return unless @document

        @document.css(@page.selector).map do |element|
          @page.fields(element)
        end
      end

      def each_movie(&block)
        all_movies.map { |m| yield(m) }
      end

      private

      def create_page
        if @document.css('.noFile').empty?
          FileListPage.new
        else
          FolderListPage.new
        end
      end

    end

    module ChomikujPage

      def sanitize_title(original_title)
        ChomikujSanitizer.clean(original_title)
      end

      def find_first(element, selector)
        element.css(selector).first.content.strip
      end

    end

    class FolderListPage
      include ChomikujPage

      def selector
        '#foldersList a'
      end

      def fields(element)
        { title: sanitize_title(element.content.strip) }
      end
    end

    class FileListPage
      include ChomikujPage

      def selector
        '#FilesListContainer .fileItemContainer'
      end

      def fields(element)
        {
          title: sanitize_title(find_first(element, '.filename').strip),
          size:  find_first(element, '.fileinfo li:nth-last-child(2)')
        }
      end
    end

    # TODO: rename (and move from here) to MovieTitleSanitizer
    class ChomikujSanitizer

      TO_REMOVE = %w{
        .BRRiP MX PL.DVDRiP.XviD.AC3-PBWT PL.DVDRiP.XViD-J25
        DVDRip.XviD-LEKTOR HDRip.XviD-LEKTOR PL.PDTV.XViD-Zet -max184
        PLSUBBED.BRRip.XviD-BiDA DVDRiP DVDRip XViD PSiG XviD.AC3-PBWT
        XviD AC3-PBWT 480p AC3-MORS PL.DVDRiP.X XviD.Zet XviD-max184 XviD-Zet
        .-Zet XviD-BiDA XviD PDTV .ViD-aX HDRip BDrip PL.DVDRip.XviD-max184
        BDRip-max184 .BDRip.-BiDA .BRRip-BiDA .BRRip .BRRip.XviD .BDRip.XviD
        -GHW -BiDA .-BiDA DRip-BiDA .HDTV TVRip
        lektor Lektor lekyor .napisy SUBBED.B SUBBED -LEKTOR 2012.PLDUB
        PL.DVDRip.XviD-Zet
        -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny
        --oryginalny --orginalny orginalny
        .pl PL IVO(1).avi ivo IVO Ivo 2012.PL dubbing.pl.avi Dubbing
        chomikuj Chomikuj.avi .avi -- .--cam cam.avi ==
        .rmvb DVDrip.rmvb Rmvb
      }

      def self.clean(str)
        raise ArgumentError.new('String to sanitize not given!') if str.nil?

        str.gsub(/#{TO_REMOVE.join('|')}/, '')
          .gsub(/[-\s\.]+$|20\d\d.*$|\(.*\d+.*\).*/, '')
          .strip
      end
    end

  end
end