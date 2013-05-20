module MoviesReport

  module Source

    # Source::Chomikuj
    # - takes service specific uri
    # - finds all movies information on given service page
    # - provides iterator, which yields all found movies with their page-specific properties
    #   (i.e. title + size + comment)
    #
    class Chomikuj

      def initialize(uri)
        @document  = HtmlPage.new(uri).document
        @page_type = @document.css('.noFile').empty? ? :file_list : :folder_list
        @page      = predefined_page_info(@page_type)
      end

      def each_movie(&block)
        return unless @document

        @document.css(@page[:selector]).map do |el|
          # build properties structure: [ [ 'title', 'XXX' ], [ 'size', '200' ] ]
          movie_properties = @page[:fields].map { |field, value_proc| [field, value_proc.call(el) ]}

          # yield properties as hashes: {:title => 'XXX', :size => '200'}
          yield(Hash[movie_properties])
        end
      end

      private

      def predefined_page_info(page_name)
        {
          folder_list: {
            selector: '#foldersList a',
            fields: {
              title: ->(el) { sanitize_title(el.content.strip) }
            }
          },
          file_list: {
            selector: '#FilesListContainer .fileItemContainer',
            fields: {
              title: ->(el) { sanitize_title(el.css('.filename').first.content.strip) },
              size:  ->(el) { el.css('.fileinfo li:nth-last-child(2)').first.content }
            }
          }
        }[page_name]
      end

      def sanitize_title(original_title)
        ChomikujSanitizer.clean(original_title)
      end

    end

    class ChomikujSanitizer

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