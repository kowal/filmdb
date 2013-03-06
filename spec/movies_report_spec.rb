# coding: utf-8

require 'spec_helper'

# To update fixtures/expected/*.yml, run following JS in browser:
#
#     $.map($('PATTERN'), function(el, idx) { return $(el).text().trim() })
#
describe MoviesReport do
  context 'run on chomikuj page' do
    it "should find movies included in the page" do
      site = 'chomikuj'

      VCR.use_cassette(site, :record => :new_episodes) do
        expected_movies = YAML::load(File.open("fixtures/expected/chomikuj.yml"))
        report = MoviesReport::DSL.parse_html "http://chomikuj.pl/mocked-page"
        actual_movies = report.map { |m| m[:title] }

        expect(actual_movies).to include(*expected_movies)
      end
    end
  end
end

=begin


TODO: Add specs for title sanitizer:

Examples:

=== http://chomikuj.pl/POLSKI-LEKTOR

"'Państwo w Państwie - City State (2011) PL.DVDRiP.X ViD-aX  Lektor PL.avi' => 'Państwo w Państwie - City State  ..X ViD-aX'"
"'Potrzask  Brake (2012) PL.DVDRip.XviD-BiDA  Lektor  PL.avi' => 'Potrzask  Brake  .-BiDA'"
"'Saga Zmierzch Przed świtem. Część 2 The Twilight S aga Breaking Dawn Part 2 (2012) PL.BDRip.XviD-BiD  A Lektor PL.avi' => 'Saga Zmierzch Przed świtem. Część 2 The Twilight S aga Breaking Dawn Part 2  .BDRip-BiD  A'"
"'Aladyn i Lampa Ĺšmierci  Aladdin And the Death Lam p (2012) PL.DVDRip.XviD-Zet  Lektor PL.avi' => 'Aladyn i Lampa Ĺšmierci  Aladdin And the Death Lam p  .-Zet'"
"'Otwarte Drzwi  Doors Open (2012) HDTV.XviD-LEKTOR. PL.IVO.avi' => 'Otwarte Drzwi  Doors Open '"
"'Sąsiedzi  The Neighbors (2012) HDRip.XviD-LEKTOR.P L.IVO.avi' => 'Sąsiedzi  The Neighbors  HDRip.P L'"
"'Ucieczka  Flukt (2012) BDrip.XviD. Lektor PL IVO.avi' => 'Ucieczka  Flukt  BDrip'"
"'Życie Pi  The Life of Pi (2012) BRRip.XviD-BiDA  D ubbing PL.avi' => 'Życie Pi  The Life of Pi (2012-BiDA  D ubbing'"
"'Mój Największy Koszmar  Mon pire cauchemar (2011)  PL.BRRip.XviD-BiDA  Lektor PL.avi' => 'Mój Największy Koszmar  Mon pire cauchemar   .BRRip-BiDA'"
"'Nieustraszony 2 - Dabangg 2 (2012) DVDRip.XviD-LEK TOR.PL.IVO.avi' => 'Nieustraszony 2 - Dabangg 2  -LEK TOR'"
"'Mistrz  The Master (2012) DVDRip.XviD-LEKTOR.PL.IV O.avi' => 'Mistrz  The Master  ..IV O'"
"'Kompania Braci  Company of Heroes (2013) BRRip.Xvi D-LEKTOR.PL.IVO.avi' => 'Kompania Braci  Company of Heroes (2013.Xvi D'"
"'A Werewolf Boy  Neuk-dae-so-nyeon (2012) HDRip.Xvi D-LEKTOR.PL.IVO.avi' => 'A Werewolf Boy  Neuk-dae-so-nyeon  HDRip.Xvi D'"
"'Fun Size (2012) PL.DVDRip.XviD-Zet  Lektor PL.avi' => 'Fun Size  .-Zet'"
"'Nasze Dzieci  A perdre la raison  Our Children (20 11) DVDRip.XviD-LEKTOR.PL.IVO.avi' => 'Nasze Dzieci  A perdre la raison  Our Children (20 11)'"
"'Sugar Man  Searching for Sugar Man (2012) BRRip.Xv iD-LEKTOR.PL.IVO.avi' => 'Sugar Man  Searching for Sugar Man (2012.Xv iD'"
"'Nono, het Zigzag Kind (2012) DVDRip.XviD-LEKTOR.PL .IVO.avi' => 'Nono, het Zigzag Kind '"
"'Mroczna Prawda - A Dark Truth (2012) PL.DVDRip.Xvi D-BiDA  Lektor PL.avi' => 'Mroczna Prawda - A Dark Truth  ..Xvi'"
"'Hindenburg (2011) PL.BRRip.XviD-max184  Lektor PL  (CZ 1, CZ 2)(1).avi' => 'Hindenburg  .BRRip-max184     (CZ 1, CZ 2)'"
"'Delikatność  La Delicatesse (2011) PL.BRRip.XviD-B iDA  Lektor PL(1).avi' => 'Delikatność  La Delicatesse  .BRRip-B iDA   '"
"'Charlie  The Perks of Being a Wallflower (2012) PL .DVDRip.XviD-Zet  Lektor PL.avi' => 'Charlie  The Perks of Being a Wallflower   .-Zet'"
"'Take This Waltz (2011) PL.BRRip.XviD-BiDA  Lektor  PL.avi' => 'Take This Waltz  .BRRip-BiDA'"
"'Kosmiczna Gorączka Heatstroke (2008) PL.DVDRip.Xv  iD-BiDA Lektor PL.avi' => 'Kosmiczna Gorączka Heatstroke  ..Xv  i'"
"'Albert Nobbs 2011 PL.DVDRip.XviD-Zet  Lektor PL.avi' => 'Albert Nobbs 2011 .-Zet'"
"'Skazani Na Siebie  Good For Nothing (2011) PL.DVDR ip.XviD-BiDA  Lektor PL.avi' => 'Skazani Na Siebie  Good For Nothing  .DVDR ip-BiDA'"
"'Antoni, Boży Wojownik  Antonio, Guerriero di Dio ( 2006) PL.DVDRip.XviD-max184  Lektor PL.avi' => 'Antoni, Boży Wojownik  Antonio, Guerriero di Dio ( 2006) .-max184'"
"'Smiley (2012) DVDRip.XviD-LEKTOR.PL.IVO.avi' => 'Smiley '"
"'Lot  Flight (2012) PL.BDRip.XviD-max184  Lektor PL (1).avi' => 'Lot  Flight  .BDRip-max184    '"
"'Duch  Ghost (2012) DVDRip.XviD-LEKTOR PL IVO(1).avi' => 'Duch  Ghost    '"
"'Gangster Squad. Pogromcy Mafii  Gangster Squad (20 13) HDRip.XviD-LEKTOR PL IVO(1).avi' => 'Gangster Squad. Pogromcy Mafii  Gangster Squad (20 13) HDRip  '"

=== 'http://chomikuj.pl/SHREC'

"'Życie Pi 2012.PLDUB.BRRip.XviD-BiDA.avi' => 'Życie Pi 2012.DU-BiDA'"
"'Silent Hill Apokalipsa 2012.PL.BDRip.XviD-BiDA.avi' => 'Silent Hill Apokalipsa 2012..BDRip-BiDA'"
"'Silent Hill Revelation 2012.PL.BRRip.XviD-GHW.avi' => 'Silent Hill Revelation 2012..BRRip-GHW'"
"'Kryptonim Shadow Dancer 2012.PL.BDRip.XviD-BiDA.avi' => 'Kryptonim Shadow Dancer 2012..BDRip-BiDA'"
"'Likwidator --lektor.pl .ivo--cam.avi' => 'Likwidator -- .--cam'"
"'12 godzin--orginalny lektor.pl.avi' => '12 godzin'"
"'The.Tall.Man.lektor.pl ivo.avi' => 'The.Tall.Man'"
"'Potrzask - Brake --orginalny lektor.pl(1).avi' => 'Potrzask - Brake  '"
"'Wladcy umyslow--orginalny lektor.pl.avi' => 'Wladcy umyslow'"
"'Kontrabanda--orginalny lektor.pl.avi' => 'Kontrabanda'"
"'Magiczny Mike.avi' => 'Magiczny Mike'"
"'Potrzask - Brake --orginalny lektor.pl.avi' => 'Potrzask - Brake'"
"'Van Helsing--orginalny lektor.pl.avi' => 'Van Helsing'"
"'Zabić Bin Ladena---orginalny lektor.pl.avi' => 'Zabić Bin Ladena'"
"'Operacja Argo==orginalny lektor.pl.avi' => 'Operacja Argo=='"
"'Lot---orginalny lektor.pl.avi' => 'Lot'"
"'Albert Nobbs --orginalny lektor.pl.avi' => 'Albert Nobbs'"
"'Uprowadzona 2-orginalny lektor.pl.avi' => 'Uprowadzona 2'"
"'OCZY SMOKA--orginalny lekyor.pl.avi' => 'OCZY SMOKA'"
"'Straznicy marzen--dubbing.pl.avi' => 'Straznicy marzen'"
"'Miami Vice--orginalny lektor.pl.avi' => 'Miami Vice'"
"'Mama --lektor.pl ivo.avi' => 'Mama'"
"'The Baytown Outlaws .--orginalny lektor.pl.avi' => 'The Baytown Outlaws'"
"'Bez hamulców --orginalny lektor.pl.avi' => 'Bez hamulców'"
"'Zjawy - -orgonalny lektor.pl.avi' => 'Zjawy'"
"'Zemsta Po Śmierci -orginalny lektor.pl.avi' => 'Zemsta Po Śmierci'"
"'SKYFALL.--orginalny lektor.pl.avi' => 'SKYFALL'"
"'Nędznicy   --lektor.pl ivo.avi' => 'Nędznicy'"
"'Dziewczyna z Sushi --orginalny lektor.pl.avi' => 'Dziewczyna z Sushi'"
"'Savages - Poza Bezprawiem --orginalny lektor.pl.avi' => 'Savages - Poza Bezprawiem'"



=end
