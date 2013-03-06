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

describe 'MoviesReport::Sanitizer' do
  context 'with chomikuj movie descriptions' do
    it "should sanitize to nice movie titles" do
      titles = YAML::load(File.open("fixtures/expected/titles.yml"))
      # TODO
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
"'Lot --lektor.pl.avi' => 'Lot'"
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
"'Ralph Demolka --orginalny dubbing.pl.avi' => 'Ralph Demolka'"
"'6 kul - Six Bullets -- orginalny lektor.pl.avi' => '6 kul - Six Bullets'"
"'Step Up 3D orginalny lektor.pl.avi' => 'Step Up 3D'"
"'Akademia Wojskowa --orginalny lektor.pl.avi' => 'Akademia Wojskowa'"
"'11-11-11--orginalny lektor.pl.avi' => '11-11-11'"
"'Cichy dom --orginalny lektor.pl.avi' => 'Cichy dom'"
"'The Tall Man--.napisy .pl.avi' => 'The Tall Man'"
"'Bucky Larson. Urodzony gwiazdor .orginalny lektor. pl.avi' => 'Bucky Larson. Urodzony gwiazdor'"
"'Winda . Elevator .-lektor ivo.avi' => 'Winda . Elevator'"
"'Żona na niby ---orginalny lektor.pl.avi' => 'Żona na niby'"
"'Nawiedzona narzeczona --orginalny lektor.pl.avi' => 'Nawiedzona narzeczona'"
"'Love guru--orginalny lektor.pl.avi' => 'Love guru'"
"'Młody Einstein--orginalny lektor.pl.avi' => 'Młody Einstein'"
"'Łatwa Dziewczyna--orginalny lektor.pl.avi' => 'Łatwa Dziewczyna'"
"'Poznaj moich spartan --orgoinalny lektor.pl.avi' => 'Poznaj moich spartan'"
"'Stare Wygi--orginalny lektor.pl.avi' => 'Stare Wygi'"
"'Święto piwa lektor --orginalny lektor.pl.avi' => 'Święto piwa'"

=== 'http://chomikuj.pl/chomikuj.filmy.pl'

"'Pies - wampir (2010) - PL.DVDRiP.XviD.AC3-PBWT.avi' => 'Pies - wampir '"
"'Zabić Bono (2011) - PL.480p.BRRip.XViD.AC3-MORS.avi' => 'Zabić Bono  - ..BRRip'"
"'Zwierzę 2 - Animal 2 (2008) - PL.DVDRiP.XViD-J25.avi' => 'Zwierzę 2 - Animal 2  - ..-J25'"
"'Zabić Bono (2011) - PL.BRRip.XviD-BiDA.avi' => 'Zabić Bono  - .BRRip-BiDA'"
"'Pies - wampir (2010) - PL.DVDRip.XviD.Zet.avi' => 'Pies - wampir  - ..Zet'"
"'MoniKa (2012) - PL.PDTV.XViD-Zet.avi' => 'MoniKa  - .-Zet'"
"'Air Collision (2012) - PL.DVDRip.XviD-Zet.avi' => 'Air Collision  - .-Zet'"
"'Święty - Sint (2010) - PL.DVDRip.XviD-BiDA.avi' => 'Święty - Sint  - .-BiDA'"
"'Zimowy ojciec (2011) - PLSUBBED.DVDRip.XviD-BiDA.avi' => 'Zimowy ojciec  - .-BiDA'"
"'Burza stulecia - Mega Cyclone (2011) - PL.BRRip.Xv iD-BiDA.avi' => 'Burza stulecia - Mega Cyclone  - .BRRip.Xv i'"
"'Pitch Perfect (2012) - PLSUBBED.BRRip.XviD-BiDA.avi' => 'Pitch Perfect  - RRip-BiDA'"
"'Vares Tango w ciemności (2012) - PL.DVDRip.XviD.avi' => 'Vares Tango w ciemności '"
"'Dobry Doktor - The Good Doctor (2012) - PLSUBBED.B DRip.XviD-BiDA.avi' => 'Dobry Doktor - The Good Doctor  -  DRip-BiDA'"
"'R2B Return 2 Base (2012) - PLSUBBED.DVDRiP.XViD-MX.avi' => 'R2B Return 2 Base '"
"'Pęknięcia - Cracks (2009) - PL.DVDRiP.XViD.avi' => 'Pęknięcia - Cracks '"
"'Eksperyment Filadelfia (2012) - PL.BRRip.XviD-BiDA.avi' => 'Eksperyment Filadelfia  - .BRRip-BiDA'"
"'Ósmoklasiści nie płaczą - Cool Kids Dont Cry (2012 ) - PL.BRRiP.XViD-PSiG.avi' => 'Ósmoklasiści nie płaczą - Cool Kids Dont Cry (2012 )'"
"'Operacja Argo (2012) - PLSUBBED.WEBRiP.LiNE.XViD-M X.avi' => 'Operacja Argo  - .WEBRiP.LiNE.-M X'"
"'Lewy Brzeg - Linkeroever (2008) - PL.DVDRip.XviD.avi' => 'Lewy Brzeg - Linkeroever '"
"'Śniegi Wojny - Into The White (2012) - PL.BRRip.Xv iD-BiDA.avi' => 'Śniegi Wojny - Into The White  - .BRRip.Xv i'"
"'Fałszerze- Fakers (2010) - PL.PDTV.XviD.avi' => 'Fałszerze- Fakers '"
"'Miłość - Amour (2012) - PLSUBBED.BRRiP.XViD-BiDA.avi' => 'Miłość - Amour  - RRiP.-BiDA'"
"'Grave Encounters 2 (2012) - PLSUBBED.WEBRip.XviD-B iDA.avi' => 'Grave Encounters 2  - .WEBRip-B iDA'"
"'Miłość i Blizny - Love and Bruises (2011) - PL.DVD Rip.XViD.avi' => 'Miłość i Blizny - Love and Bruises  - .DVD Rip'"
"'Pamięc Grace - A Fall From Grace (2012) - PL.HDTV. XviD-PSiG.avi' => 'Pamięc Grace - A Fall From Grace '"
"'Agent ubezpieczeniowy (2011) - PL.PDTV.XViD.avi' => 'Agent ubezpieczeniowy '"
"'Hasta La Vista (2011) - PL.BRRip.XviD-BiDA.avi' => 'Hasta La Vista  - .BRRip-BiDA'"
"'Konserwator - Boker tov adon Fidelman (2011) - PL. TVRip.XviD.avi' => 'Konserwator - Boker tov adon Fidelman '"
"'Arachnoquake (2012) - PL.480p.BRRip.XviD.AC3-sav.avi' => 'Arachnoquake  - ..BRRip.AC3-sav'"
"'Przyjaciel Świętego Mikołaja 2 Świąteczne szczenia ki (2012) - PL.DVDRip.XviD-BiDA.avi' => 'Przyjaciel Świętego Mikołaja 2 Świąteczne szczenia ki  - .-BiDA'"

=end
