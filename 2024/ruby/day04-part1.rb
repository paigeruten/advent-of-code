ws = DATA.readlines.map(&:chomp)

width = ws.first.length
height = ws.length

num_found = 0
(0...height).each do |y|
  (0...width).each do |x|
    [[0, 1], [1, 1], [1, 0], [0, -1], [-1, -1], [-1, 0], [1, -1], [-1, 1]].each do |(dx, dy)|
      cx = x
      cy = y
      found = false
      ['X', 'M', 'A', 'S'].each do |c|
        break if cx < 0 || cx >= width || cy < 0 || cy >= height
        break if c != ws[cy][cx]
        found = true if c == 'S'
        cx += dx
        cy += dy
      end
      num_found += 1 if found
    end
  end
end
p num_found

__END__
AAMXMSMMMSMMSSMMXMASMAMXXMAMAMXXMASMXMXXMMMXMMXMAMXMXSMMMXMXSAMXSASXMAMXAMAMXSXSSSMXXMASAMMMMASXMAMXAMXAXMASXMASAMXSSMMSAMXAXXAMMXXXXSMAAMAM
SMSSMMMAAMAAAAAXMAXAMAMXASXSSMMSMMAXAXXASAXAAXSMMSAMMAAASXSASASAMXMMSAMXMMAMMMAMMAMAXMXXMMSAMMSASASASASAXMMXXMASXMASAAAMAMXXMAMXMMMXXAMXXMAA
MAAAAXSMSSMMSXMMXMSSSMMXMAXAXSAXASMXMMSMMASMSMXAASAMAMMMXAMASMMAMXMASASAASAMAMAMSAMSXSSMSXXAXAXAMASAMAAXMMAMXSAXMXMSMMMSSMAASMSMAXAASAMMSSMS
MMMSMMMAMAXAMXMSAMAMAMMSXMXMMMXMMMMAAMMXMMMXAMMSMSMMXSAMMAMAMASXMAMXSMMMMSAXXSSXXASXMXSMXASXMSMSMXMAMSMSMXAMMMAXMAAXAMAAAMSMAAAMAMSMMAAAMAMX
SXXXXXMAMSASAXMAXMASMMAMAXMXASMSMAMSMSMAXSASMMAAAMMMASAXSAMMSAMAXMXAXXMAMMAMXMMMSSMAMAMMMMMXAAAAMAMAMAAXMXASAMXASMSXAMMMSMAMMSMMXXXASMMXSAMX
XAMMMSSSSXAMMMSAMMXMMMAMMMAMSAAAMSXXAAXAMXMMXMSSSMAMXMMMSASAMASMMSMMSMSASMAMXAMMMAAAMAXSASAMXMSMSASASMSMMSASMSSMXAXXXMXXMXMMAMXMMASAMMAMSMSS
XXSAAXAMXMMMAASAMSXSASMSSXSXXMSMSMAMSMMXSSMXXXAMAMXXMAMXSAMXSAMMAXAMXAMAMMAMMXMAMXMMMXMSASXSXXXASMSXSAMXXAMMAAAXMMMXXSSXMASMMSAMAXAAXMAMXAAM
XASMSXXMSXMSMMSXMAXSAMXAMAXMSMMXMMAMXAXXXMASXMXSAMXSSMMMMAMAMXSMSSSMXMMSMMXSMMSSSMSSXXMMASASXAMXMAMAMAMXMASMXMXMAMXXMMMXSAMAASAMSSXMMSXSMMMS
SMXAXMAMSAMXMASMXSMMAMMAMXMASAMXMSAMSAMSAMXMAAXMASMXAMXXSMMMMMMXAAAAXXAMASAAAAAAAAAXSAXMXMAXMMXAMXMAMAMASXMXMMASASXXMAAMSAMMMMMMMAASAMXXAXAA
MXMXMSSXXAMXMASAAXMXSMSSXMMAMAMAXMAXMAMXAMSSMMMXMMXSXMMXSMMASAAMMSXMXMMSAMSSXMMSMMMSMXSAXMSMMMSMSAMXXAXXSMMAMSASASAMSMSXSAMMSXMAMSMMASMSMMMS
SSMMXAXAMSMSSSMMMSAXMMMXAAMSSXMXSMMMMSMXAMXSAMSASMXMMMSAMXSASXSXAMMMMMAMXXMXMAMXAMSMMASMAMAAAXAAAMSMSSSMSASAXMAMMMMMAXMXMAMSMXXAXXASAMMAXXXX
XAAXMMSMXXAMXMXAAMAMMASMMMXXAASXSXAAXMAXMAMXMMMAMXXMAXMAMMMMSMXMMSAAAMASMSASMSMSSMAAMAMSAMSSMSMSMXAAAAAASAMMSMXMXASMMSSMSMMAAMSSMMXMAXSAMMSM
SSMMSAAXAMAMMMXMAMXAXAMAAMXMSMSAMXSSSMAXXAXMSSMAMSMSSSXSSMAAXAMAASMSMSMXAMAMAAAAASXSMMMSXMAAAXXAXMMMMMMMMAMXAMMSMMSAMMXAAXMMXMAAAXSSSMSAMXXA
MMSAMMSMMSAMAMXMAMXSSMXSMMAAAXMMMAMAMMAMSMMAAXSXMXAAAXAAAMMMSXSMMSXMASAMSMSMSMMMMXMAMXAMMMXSMSSMMMXMXXMXMAXXASASAMXAMXMXMSXSXMSSMMMAXAMXXMAS
SAMXSAXAMAXSSMSAMXAAAAAXASXSAXMASAMAMMAMAMMMSXMMMMMMSMSMMAMASMXAAMAMXMAMMAMXMASMSMSSSMASMSXXAXAXASXSMXSASASXXMASMMSMMMXSAXAMXMMMMXMAMMMMAMAA
MAMSAMXAMXXAXASAMMMSMMMSAMMXMMSASASMSSXSAXXAXAMASAMXAAXXXXMAMMSMMSXMXSMMMAMAMSMMAAAAAMAAAAXMXMMSMSAAAASAMASXXMMSAAAAAAMAXMAMSXMASMMMXAXSSMMS
SSMSAMSAMXMAMMSSMAAAXMXMAMXXAAMAMAMXAAMSXMXXSSMMSASXMSMSXMMMSAAXMAAMASAASMSSXMASMSMSMMMSMMXMAAXMAMMMMMMAMAMXXMASMXSSMXAMXMXMSAMAXXAMMMMXMAMX
MMAMAMSSMMAAAXSAXMXMMXAMAMSSMMSSMMAMMSMSAMXMXAMMMMMAMMAXAXAAMMMSMMSMASXMSXAMASMMXXMXMAXAAXXSMSMMSMMXMAXAMAMXMMMSMAMMMMSXXASXSXMAMSXSAMXXXAMX
AMAMMMMXMASXSSXMMSSMSSMSASXAAAAAAMAXAXMXAMAAXMSSMSSSMMMMSXMASAXXAXXMXSXMMMXMASASAMXMSMXSXMMMAXMMMAMXMMSMSAMASAXMMMSAAXMXMASAMMMXXMASMMAMXSSM
MMASAAXMXMMAMMMSAAAAAAXSMMXSMMSSMMXMASMMXSMSMXAAXMAMMAMAMXMMMMXMAMXMAXAXMASMXSAMXSAAXMAXAXSMAMAAXMMAAMAAMXMMXASXXXMMMMXXMASXSAMMAMXMAMXSAAAA
XSASMSMMMAXMSAAMMSMMMMMMSMXXXAXAXXMASMMAAXAAAMSMMMMMSAMSXSAAAXXASMSMXSMMMSAMXMAMXMASMMASAMSMMSSMSSSXMAMMMSXMSAAMASXAXAMXMMSXSASMSXMSXMAMAXAS
XMASAXASXMMXAMMSAMMXAMAMMSSMMSMSMSSXMASMMMSMSMMXXAXXMXSMASXMXSMXXAAXXAASXMMSMSAMXMMMXMASMXMAXXAAXMASAMXSAAAMAMXMAMSMSSMASMXAMAMXMAXXAMASMSMX
XMAMXMAMMAMXMXAMAMXSXMASXAXMAXAAAMXMMAXXSXXSXAAAXSXSXMXMMMMSAAMAMMMMSSXSAMAAAAAMAXAMXMASMSSSMAMMMMMMSXAMXSXMMSSMAMAMXAMASMMXMAMASMMSXMAXAAMX
XSASXMAMSAMAMMMSAMXXASASMAMMAMMMMMAXMMXXSAXAXMMMMMAMMSSXMAAMMXMASAAXAAMMAMMMMMMXMXMXAMXMMAAMXSMSXSAAAMMMAAXSXMASXSMMSSMXXMAAMAXXXXXMASAMXAMS
MSASXSXMXASAXAASASAMXMASMMMSXSXXASMSMAMSMMMMXSAMSMAMAAXAMMSXXMAXSAMMASXXAMXSSMSXXSAASAMXMMSMXMAXAXMSSXAXSMAXASAMMAAAAAXMMMMXSAMSSMASAMAMXAMX
MMMMMMAMMMMMXMXSXXXAXMXMXSMSAMASMMMXMAXSASAXMSASMSMMMMSAMAXXXMXXMAMSXMASXMAMAAXAAMAMXASXMMAMAMXMSMAAMMXXASMSMMMSSXMMXSMAXSAMMXMAAMAMXMAMSSSM
MAMAXXAMASXMASMMMSASXMXMAMMMAMAXMSSSSXMXXMASAMXMXAXSAAXMSASMMMMMSAMXAXMASMASMMMMMSMMXAMMAXSSXSXAMXMAXAXSAMMAMAAMAMSSMXASAMASAAMSSMSAXMXXAMAA
SASMXMASASASXSAAAAMMASXMSSMSSMMSSMAAAMMSSMMXAXMSSSMSMASMMAXXAAAASMSSMMMAMXXMASXMAAAXMMMSSMAMAMMMMSMSMSAMXMSSSMSMAMAAAMSXMSAMMMMMXXMASXXMXSMX
SXSAASMMAMXMASXMSSXXAMAAAXMAXAAXAMMMMSAAAAMSSMAXAMAMXMXXMAMSMSSMMMXXXAMASXMASMSASMSMSAXAMMMMAMAMMMSMAMXAAXAAXMAMMSSMMMXAXMXSMMSSSXSXSAMSAAXS
MASMXXAMXMSMXSAMXXXMXSMMMSMMXSAXMMSAXMMXSMMAASMMSMMMSMASMSXMMAXAASMSSXXAMAXXMAXMMAAAXMMMSMXSMXAXASAMAMASMMSSMMAAXXAAMXMAMXAXAAMAMAMAMMAMASMA
MAMMMXSXSXAASMAMXMASXAAMMXMXAXMXSASMSMSAMAMSXMXAAAAAAMAMAXMAMMMMMMAMXMMSSMMXMAMXMXMSAMAAXMAMASMSMSASXSAXXAAMAMMSASXMMMSAMAMSMMSAMAMXMAXMMMXX
MASAMMMAMMMXAAAMXAASXXMMMAMMASXXMASASAMASAMXMXXSSSMMXMAMMMSMMXSAXMAMMXAXAXMXAAMXMXXMMSXSXMXSAXAAASAMXMXSMSAMSXXXMXAXXASXSXXXMASASXSXSXXSAMXS
MAXASAMAMAXXMSMSXMASAXSASAXXAMAMMXMMMAMASASAMSMMMMMSSMXSXAAAMAAMSXMSAMMXMAMSSMSXSAXMASMMMMMMXSSMMMAMAAMXXMAMXXAMXXMMMMSASASAMAMXMMXAXXMSASAM
MSMMMMXAMMSXMAAXXMAMAMMASMSMXSAMXSAXSXMASASASAAAAXXAXMAMMSXMMASXSAMXXAMASAMAAAAAXMMXMXXSAAXXMAXAXXAMSXXSASAMAMSXSASXMXSAMAMXMMSMXAMAMMXMXMAS
XMASAMSSSSMMSMMMXSXMSMMXMMAMXSASXSAMAXMASXMXMMXMSSMSXMASMMSMMAXAMXMAMXXASASMSMMMMSMSMSASXMSMAMSXMSSXMMASXMMXXAAASAAXAAMMMSMMMSAMXSAXSAMXMSXM
XSMMAXAASMAAXMSSXMAMAMXSASASASAMXMAMXSMXSASXSSSXAAAMSMXSAAASXAMXASMMSMMASAMAMMASXSMAAAXMASMXSXSAMAMAXMXMASMSSMMXMMMMMMSAAAAAXXASAASAMXMAXMMM
AMXSXMMXMMMMMAAMASMMSXXMASASXMASXSSMXXMAMXMAAAXMMMSMAXSXMXMXMXXMAXAAAASXMMMXMSAMMSMMSMMSXMAAXXSAMAMAMMMSAXAAMXXAAAXXMMXMMSMMSXSMMSMMSASXXAAS
SXASMMSMXMASMMASAMXMMAMMMMAMAMASMAASXAMAMXMMMMMAXXAMMMMASXXXSAMSSSMMSMMAAXXXMMXXAXAMXAXXXMMSSMSMMASASAAMMMMMMSSSMMSMASXMMXAMAXXAMXAXXAMSMSAS
AMMSAAMAXXAXXSASASAMSAAXSSMSMSMXMSMMSMSAMMSSXMXSSSXXSAMAMAMMXAXAAXXAMASMMMMMXASXSSXMASMMXMAMAAMASMSAMMMMAAAAXMAMMAAMAMAMASAMAMMAMSMSMSMAMXAX
MXSXMMSMMMMMXMASASAXSSXMAMAAAMXSMMAXAMXAMAAMASAMXMMAMAMMXXMSASMMSMMXSAMAMSASMXSAAAXSXASMAMASMMMMXAMAMSASMSSSMMAMMXMMMSSMAMXMAAMAMAAXAXMMMMSM
XMMMSASAMXAAMMAMMMMMXMSAMMSMSMASAMXMASXMMMASXMXMASXSSSMSSMXMAMXXXAMAMXSXMMAMMMMMMMXMMSASMSAXMMXXMXMAMMAMXAXMASMMMAXAAMXMASMSMSSSSMMMMMXXXAMX
MAAXMASMMSMSSSSXSAXXXMAMXXAXXMMMAMXMASXXASMSMMMSMMSXAMAASAAMSMSXSXMAXMMMSMSMAAXAAXAXMXASMMMSAMSAMMSASXSSMXMSASAASASMXXAMAAXAAMAAAXXASMMMMSSS
MXSSMAMAAAXAAAMASMXXXSASXSSSMSMSAMSMXSMSXSASXSASAMXMAMSMXSASAAMMMMSMXMAAXAMXSSMSXSMXAMMMAAXSAMAAXXAXMAMAMXXMASXMSMMAMSMXSASMSMMMSXXAXSASAMMM
SAMXMASMXSSMMMMXMMSMMMASAAXAAAASXMAMAMAMASAMXMMSAMXMAXMAMMMSMSMAAMXXAXMSMSMAXAAXASMSMXASMMMXMASMMAAMMSMMMMXMAMAXMASAMAAXMAMMAMSXMAMSMSXMASAS
MMSASMSAAXMMMXMXXAAAAMAMMMMMSMMMSXMSSSMMXMAMXMASXMAXMAMXMAAXXMMSMSAMXSAAAXMAMMMMAMAAMSMSMMMAMAMAXMMAXAXXAXSMXSXMAASASXSAMAMSSXXAMXMAASMSXMAS
XXMXMMMMXXAAMASMMSSSMMASXAXXAXXAMMXAAAMSSSSMSMASAMXMSASASMMSMSAMXMASAAXXMXMXXXAMAMMMMAXXAASAMAXMMXASMMXSMMAXAXMXMMSXMAMMMAXAMXSMSSSMXSAMXMAM
MSSMSXXMMSSMSAXAMMMXMSASXSSMMSMXSAMMMMMAAMAAMMMXAMAXMASAMSAAAMAXXXMMMSMMXMASMSMMXXASMSXSSMMXSSSMSXMMASMAMMMMMXAMXXXMASXSSSSSMMMAAASXASXSAMXX
AMAAXMXSAAMXMMSSMSAMXMASAXXAAXMAAMXXASMMSMMAMMMMMMXMMAMMMMMSSMSMSXMASAXXAAXAAAAXSXMSAAAXAMSAMAAASAXMAMXAMASMSMMSXMXMAMAAAAAAMXMAMSMMASAXASXX
SSMMMSAMMSMAAMAMXMASXMXMXMMMMXMSSMXMXMASAAXMAMMAXSMMMXSMSSXXXAAAMMXXSXXXXSAMXMMMSAMMMMMMAASAMMMMMXXMAMSMSMSAAAMSAMXMASMXMMSXMAMMXXAMAMAMSAXA
XAAMAMASAMXMMMASXSAMXSXSASMXSAMMAMMSMSSMXAMMXASXXXAAMMMAAXSAMSMSMSMAMMMSAMXSXAAAXAMXMSSMMMSAMMXSAAXSAMAAAXMXMXMSAMXMASXMXMAASAMMAMAMSMMMXAMM
SSMMXXMXXMASXMASXAXXMMAXAAAASAXMAMAAXXXAXSMMXMXMASXMSAMMMSMXMAAAAAMAMAXAASAMXSMSXMMXASXAXXSXMSAAMSXMASMXMSXAXSMXXMXMXXMAAMXXSXSMMMXMAAAAMMMM
MAAXSSSXASASAMASMMMSXMAMXMMMSAMSSMSSSMMMMMAMMXMMXMAASMSMXMAASMSMMXSXXSSSXMASAMXMAMXMSMSXMASMMMMSAXMSMMXSXSAMXAMAMSXMMSASMXSAMASASASXMSMSXMAS
SSMMSAMXMMXSAMASAXAXXMASMSMXMXMXMAXMXAAAAMAMSMSMSMMMMAAXSMXMMAXXXMMXAAXXXMSMMSAMAMXXMXAMXASMAAXMAMMXAASAAXXXXMASAMASASAAAAXAMMSAMMASXXAAMSMS
XAMXMMMSXAASXMAXXMSSXSAXAMXMASXMMSMSXSSXSSMMSAAAAXAAMXMXMAAMSMAXXAAMMSSSSXAAAMASMMMMMMMMMMSXSXSXSXSSSMMMSMMSSXMMSSXMAXXMMMSAMXMXMMAMMXMAMAAM
SXMXMXAXMMXSSMMSSMMXASASXSAMASAMMAMXAXAXMAMAMSMSMXSMSAMXMAMXAMMMMMMMXMXAMMMMMSAAAAAAAAAAAXMAMSAAMAMAAXMXAAXAMASAMXXMMMMAXMXMMMMMXMAMSAMXSMSM
XMMAMMXSMXXMASAAAAMMMSAMASMSASAMXSAMSMAMSAMMMAMAXMAAAXSAMXXXXSASAMXSXMMMMSMAXMASXSSMSSSSSMMAMXMXMAMAMMMSSSMMSAMMSAXSAAMAMXXSASASASXMXAMAMMAM
MSSMSAASMSMMAMMSXMMAXMAMXMASXSXMAMXSAMXMAXMAXASASMMMMSAMXSXMASASXMMAAMMMAAMMXAMXAAAAMAAMAASMMXMASXSASXXMXAMXMAXSXMMSXSXAXMASASASASMSSSMMMXAM
AXAXMMXSAMXMASAMAXSSMSAMXMMMMMMXAMMMMXAMXXXXSXMASAXXXXXXAXSAAMMMXMSSSMXMSSSXMSAMMMMMMAMMMMMASAXMAMMMAMXSMMMASXMAAXAMAMXMSMMSMMMMAMAXAAXAAXSX
SSMMXMXMMMXSXSASXMMXAMMMMMAAAASMMSASAASMMMMMAAXXMXMMMMMMMSMMMSMAAXXAAMSAAAXAAMASMAMAMSMMXXSXMAXAMMSSSMMSAXMXSAASXMMSAXAMXAAXAAXMAMMMXMMMSXMA
MAMXSASXXMXMMMMMAAAMXMAAXXSXSMSAMSASMXMAAAAXMSMXMXAAAAAASAXAAAMMSSMMMMSXMSMMMSAMXAMAXXMXSXAAMMSSMXAAASAMMMXMXMMMMMASMSMSSSMSSMSSSSSMSMSXMAMX
XAMXMAMMAMXMASASXMMSSSSSSXMAXXSAMMMMMASXMSXXAAAASXMSSXSXSASMMMSAMMASMASAMMASAMASMSSMMASXMASXXAAAMMMMMMMSXSAMMXAAXXMXAXAAAAMXAAAAAAXAAAXMMSMX
SMMAMAMXAXASXSASXASAMAAAXMMAMASXMMXXSAMAMAASMMSMSAMAXMXAMMMXAAMASMSAMASXMMAMXXAMAMAXSXMASXMMMMSSMAXSMSXAXSASXMMMMMMMSSMMSMMSMMMMMXMSMSMXXAXS
AAXXSXMSMMASAMXMXXMASMMMMMMASAMXSXAMXMSSMMMAAXXXSXMAXXMXMXAMXXSAMXMMMXSXSMMMSMMMAMXMAMSAMAMXAAMAXXSAAXAXASAMMSMXMAMAAAXAMXXXMXXMXSAXAAMXXMMA
MSSMMAXAMMSMXMXMAMSMMXMAASMMSAMASMMMAMAXAXXSSMAMMAMMMSXMMMSSMXMMMAMXSAMAMASAAAXXMSSSMMMXSAMXMSXMMSAMXMASMMAMAAAASAMMSSMXSMMMSMMSASMMSMSMAXAA
XAAASAMXSXMASXMSAXAXSXXMXSAASXMAMAASAMASXMMXAXMAMMMSAMXSAAAAXMAXSASAMASXSAMMSMSAAAAXXXMMSASMXMASXSMXXMASXSXSSMSMSASXMAAXMASAAASMASAMXXSMSMSX
MMSXMAAAMAMSMXAMMSXSMMSSXXXMMXMXXSASXSXXAASMMMSSMMAMAXAXMXXXMSAMXXMAXXMXMASMAAXMMMSMMMSXSAMXAMSMAXXMXMMSAAAAXXXASMMMSAMXSXSSMSMMXMMXXAMXMXXS
SXMASXMXMAMXMMSMMMMMMAAMAMSMSXMXMMASXSMSSMMAXMAXAMXXAMXSXSAMXMASMMSSMASAMXSMMSMMAXXASAMXMAXSMSMMMMXMAXMMXMXMXSMMMAAXXAXAXXXAXMMSASXSMAXXXAMX
AASAMMMXSASXMAXMASAMMSSMAMAAXAAMXSXSASAMXAXXMMASMMSXXSAAAXMAXSAMAXAAMAMASXSAMAASASXSMASMMMMAMXXAAXMSXSAMXMMMAMAMMSMXSSMMSSMSMMASXSAASAMSMSMX
MMMMXAAAMAMMMSXSAMXXAAAXSSMSMMSMMSAMXMAMMSXSSMAXAAAXAMMSMXMAMMMMXMMSMSXMMXSAMSMMAMXXMMMMASAASXMMMXMAMXMAMSAMASAMMMSAMXAXXMAMXMAMMMMMAXMSAAAM
XSASMMMXXAMAMMAMXSXMMXXMXMAMXAXAAMSMASMMAAXSXMSSMMSMXMAXXMMXSAMASXMMAMAMXMSAMXAMSMMMMSAMMMAMMMSSSXMXSAMXAMASXXAXAAMXXSAAMMAMAMAMAAXMXMXMMMSA
SMASXMASXMSASMAMSAXSSSSSSMSMMMSMMSMXAMAMMSSMAMXSXAXMASMSSXMAMAMXAAAMASAMXAXXMXXMXAMAAMAMXSAMXXAAXXAAMAXMMSXMAXSSMMMXAMMMSSXSXSASMSSSXMASAMAX
XMAMXMASAASASMMMXMMAAAAXMAMAAAAAXMXMASAMXXAMXMAXMAMMMXMAMAMASXMMMMXMXMAMSSMXXSSMSXMASXXMAMMAXMMSMMMASXMMMAMXMMAAXSSXSXAAMMMMMMMMAAXMASASASAS
XSAMXXAMMMMXMXMMMXSMMMMMSASXMMSMMXMAXSASXSMMXMMSMSSMAAMASMMMSAAAXXXXMSAMAASXSMAAXMSMMASXMMSSXXAAXMMMAMAMAMMSXXSXMXAAMMMMSAAXAAMMMXMSAMMSAMAS
MSAMSMSXMXSMMXXAMMASAMXAMXSASAMXSASXMMAMXAMXMMAAAAAASXMASAAASXMMMAMMMSAMMXAMAXMMMAAAXAMASAMAAXSASXAXXASAMSAXMXMMSMMMMASASXMSSXSASMMMMSAMAMAX
AMAMMAAXSAAASMSMSAMXXSMMSAMAMXSMSASXMSAMXSAAAMMSSSSMMAMASMMXSMMASAMAMMMSSMMSSMSSXSSSMMSXMASMXMMAXMSMMMXAXMASXAXSAAAXSAMAMXXXXASASAAAAMASMMMM
SSSMMSMSMSSMMAAAAMXMXMAXMASXMMMAMAMXMAMXAMMSXSAMXMAXSXMASAMMXMSAXASMSAAAAMXMXAAAMXMXMMAXXXMXASMSMAMAMXSAMXSXMMXSASMMMAMAMSMSMMMAMMMMSMMMAASA
MAMXAAXXAXMASMMSMSAAAXXMMMMAAXMAMAMMMAMMXMXMAAXSXSMMMAMXSAMSAMMSSXMAMMXSXMAMMMMSAMXMASASXSMSXSAAXMSSMXMSMXXAMMAXXMXXMAMAXSAMXASXMASAMASMSMMS
MAMMSSSMSMMASAAMASMSSSMAAASXMMMASXMASAMMAASMAMXMASAMMSMAMXMSASAAMAMMMSAMXSSSMSAMXSAAASAMXAAMMMXMMMAMXAAXXXMAMXXXMMXXXAMMMMSMMASMMXMASAMMAAAX
SMMMAXXAAAMAXMMMAMMAAAXMMMMAAXSXXXSMSXSMSXSASXSMAMAMAXMMXMMMAMMXXAMXAMASMSAAMSXMASASXMAMSMMMAMAMXMMSSMMMMMSAMXMSMSAMXSMSAAASMASASMMMMMMSSMMS
AMAMMSXSSSMSSSSSMMMMXMMSSXSMMXMSMASAXAAAMAMXMAXMAMSMASASAMMMSMSASXSMMSMXMMSMMMMMMSXXMSXMMXMSSSSMMSAMASAXAAXAMMMAMMXSAAASMSMXMASMMAMSAAXXMASA
MSXSAXMAXAMMXMAAASXSAAAAAAAXMXAAMAMMMMMMMAMSMXMMSAAMXMASASXMAAMAXXAXMAMMSXMSAAASXMXXASAMMAXMASXAAMASAMXSSXSXMAXAMXMAMMMMMXMMMASMMAMSSMSMSMMM
XXAMMSMSXMMSXSXSMMASXXMSMMMSAMXMSMSXXSAMXXSAMXXAMXAASMXSAMASMXMMMXSMSASAXAASMXXXAXAXMSAMSSSMMMSMMSAMASAXAMXXSMSMSMMAMXAAXAMXAMXASXMXAXXAAXAX
MMMMASXXASXSAMMXAMXMSMAXMAXXAMXMAAMAASMSMXMAXXMXSXMAAXXMASMMAXSASXMASMMXSMMMAMSSMMAMXSMMXMAMXMASAMXSAMMMMSAMXMAAAAMASXSSMMSAMXMMMMXSAMMSMSMS
MAAMXXASAMAMXMAMAMXAXMAMSXSXAXMSSSSMMXSAXXSSMSXMXMSMMXMMASAMXMXASAMMSXMAXAAMAMXAAXAAMMXXAMSMXSASMSMSMMMAXMXSAXSSSXSMMMXMAAAXSASXXSAAAMMAAXAX
SSSSSSXMMMAMAMMSSMMMMMXXXAMXXMMXMAXXXXMMMMAXMASMMMASXAAMASAMMSMXMXMAXAMMSMMSXSXXMSMXSASXSMASXMAMMAAXSAXSMMASAMXAMXSMMSAMSMMMMXSAAMASAMXMSMAM
XAAAXXAAXSSSXSAAAMMSAMMAMXMXMASAMAMXMXMAXMAMXMXXASMXSMSMMXAMAMMSMAMMXXMAAAXSAMXSXXMAMMSAASMMMSSXSMSMMMXMAMAMMMMAMAXAASAXMAAAXMMMMMXMMMMXMASM
XSMSMMMMMMAAAMMSXMASAMSAMASAMASXSAAMASMSXSASXSMAXMXXSXMASMSMXMAAAAAXMSMSSSMMXMAXXAMXSXMMMMXAXXAASAMAXMAMAMXSSMSMMMSMMSMMSSMXXAXSXSAMXAAXXXMA
AXXAAMMSASMMMXAMAMXSAMXASASASXSXMAMAXAAAASMXAAMSSMMMSASAMXAMMMSSSXSAAAAMAMAXMMASXSMSSXMMSXSMSMMMMASXMMSSSMMXAAXSMMMAAXAAXMSSMXSAMXAMXSSSMMSM
SSMSSMASASXSXMASAMAMMMSXMMSAMASXSMSXSMXMASAMSMMAAMXASXMMSMMSAMMAAAXMSMSMSMSAAXAMXXMMSAXASMMASAMXSAMXSAMXAXXSMXMAXXXMXMMMSAAXAMXMSSMMMXAMXAAX
XAAAMMMMXMMMMSAMAMASMMMMAMMXMAMMSASAAXXXXMXMAAMMXMMMSASASMASASMMMAMAMAMAXAAMSMMSMMAAXMMMSAMAMMSAMASXMMSXMMMMAMSMMMMMSMAMSXSMSAXAXXAAXMAMMXSS
AMMMSMMMSASAAMASASXSMAASAMXMMXXAMAMSMMMMMMAXXMMMSAXXSAMAMSMXXMXMAXMMMAMAMAMAAXMAMXMMSSSXXXMXSAMAXAMXMASAXAMMAMAAASMAASXMMAMAMMMSMSXSXMXXSAXM
MXMXAAAAXASMSSXMASXSXSMSXSXXXASMMXMXMMMAAXMMXSAAMXMAMXMXMSXSSMMSXXXXMXMMMSXSMXSAXSAMAAMMSMSAMXSSMSSSMASMMXXSSMMSXXMAMAMAMSMAMXAAASAMMSAAMMSS
MASXSSMSMMMAMMMSAMASAMMXMMMMXXMAAMXMMAMMSMSAAMMMSMMASAMAAMAXAAAAMSMSMXXAAAXAMXMAMSAMMSMAAAMASMXXAXAAMAMMAMXMMAMMMMXSAASMMXSSXMXMXMAMAMMSMSAM
MAXXAXXAMAAAAAAMASMMAMAAAAASXSMSSMAMSASXAAMMSMSXAASASASXSMSMSMMSSMAAAMSMMSSSXSAMXSAMXMMSXSXAMXMMSMSMMSXMASAASXMSAMXASXMAMXAXSMASAMAMMMAMMMMS
MSSMMMSMSSSSSMXXAMAMXMSXMSMSAAMAAMAMXAMMMMMXMASXMMMASASAXAMAMXXXAMSMSMAAXAMXMMMAXSAMXSAMMXMASXMAAXMASAASAMMMMMMSSSMMMMSSMMAMMXASASXMXXXXMAXX
AXAMMASXAXXAAMMXXXAMMXMSXMMMXMMSSMSSSSMSXASAMXMAMSMAMAMMMAMSSSSSMMMXXXSXMMSAMASMXMASMXAMAXAXAXMAMXXMMMMMAMSAXAMMMXMAXXAMXMMMSMMSAMXASMMMSMSM
XMAMMMMMXSXMASAAMXSMXAAMXMAXMXXMAXXMAAAXMASASASAMAMASXMMSSMMXAAXXXMASMMXSSXXXAMMASMMMSSMXSSMMXMAXMSMAXMMXMSAMSSSSSMSAMXSXMSAMAAMAMSMSAAXAAAX
SSSMAXSAMXMASMMMSAXSSMSMASAXSAMXMAXMMMMMMAXMMXSXSMSAMAMMAMAXMMMMMAMASAMASAMSMMSAMXMAMAXAMXAXXSMXMAASXXMMSXMSMAAAAAAXASMSAMMAMMMSSMXXXMSSMSMM
XAAMXMAMXAMXXAAXMXMAXAAMXMAAXAXSSSXMXSAXMMSSSXMASMMXSSMMASXMXAMMMSMMMAMXMMAXAASASMMMMASMSSMMXMAASMMMMMAAMXAAMMMMMMMMASASXMSSMSAMAAXMSMXXXMMS
MSMMMXSSSXSASMMSMMMMMSMSXMXMMMMMAXAMAXASMAMMAAMAMASAMXAMMMAASMSAAMASXSSSSXMMMMSAMAASMMXMXAAMAMAMAAAAMSAMXMAMXSAAXSMMAMMMAMAMASAMXSMXSAAMMMAA
AAXXMAMAMAMASMAAAAMXAAMMASAXMSSMMMAMMXSAMASXSMMAXXMASXSMASXMASXMMSAMAAAXMAXXXXSXMXMSASMASXMSSSMXSXMAXSASXSMSMSSMXAXMASASMMASXSSMSAMXMMMSAMXS
SAMSAMSAMMSMMMSSMMSMSMXSAXXMSAAXXSASXXMASXXAAAXMSSMXMAASAMMMXXMAXMAMMMMMSSMSMAMXSXAXAMMMSAMAAAMAMXMXXMAMAXXAAMASMMMXMSASXSAMMMXSAMMXXAAMASAM
MAAMAMXAXXAAXAXAXSMXMSAMASMMMMMSAMXSAMSXMMMSMMXMAXMMMMMMMSMSASMMMSXMXAAAAXAAMXMAMMSMMMAXMAMMSMMASXMXSMMMAMSSSMAMMMXSAMXMASXMASMMMXMSMMMSAMMA
MAMMMMXSSSSSMXSAMXMASMMMSAXXAXAMASAMAAMMMXAMAMXMAMSMSMXAAAXMASMSAXASXMMMSSSSSSMXSAMXMXXSXXMAMXMASAXAMASMSXMAAMXSXAASAMMMMMMSXMAMXMSMXAAMXMAS
MAMAMMXAAAAMMAMAMASMSAXMMAMSMMMSXMASMSMAMMXSAMSXSAXAAXSMSSSMSMAMXSAMXMAMAMAMAAMSMMMASMAMXAMXMAMASMMMSAMAMAMSMMXMMMMSAMXMMAMXAXSASMAMMMSXMAMX
XAXASMMMSMMMMAMASXXXXAMXMAMAAXXAAXAXMAMXXAAMASXAMMMSMMAMAMAXXMXMASAMMSXSSMAMSMMMAMSASXASAMXMSAMXSXAMXXMASAMAAMMSMXMXAMAMXMSMXMMASMMSAMXAMSMS
SXSASXXMMMSXSSSXSMSSMASASMSMMSSSSMMSSSMSMMSMXMMMMXAMMSSMASXMSMSMASAMXAASASXXAMXMAMSXMMXXAMXAXXSSXXXSAMSASASMSMASXMMSMMASAAXMSMMMMAXSASMMMAAM
AAMAMMMMMAXAAAXXXAAAXASMSXAXMAAXMASAXAAXMAXMMMXMAMXXAXXSASAAAAXMASXSMMSMAMSAMAXMAXXAMSSMXSXMXSMXAXXMAMMMSXMAMMASAMXAXSAXMSMXAXAMMXMSMMAASMSM
MMMAMAAAMMMMMMMMMMSSMAXMSXMMMMSMSSMAMMMMMAMAASASXMSMMSXMXSMSMMMXXMASMXAMAMSSMMSMSXSMMAASAMAXXMASXMXMMXSAMAMAMMXSAMSMMMMSAMASMSSSMXMXMSSMSAXX
SXMXXXSXSAAAAMXXAAXXMMSSMASXXXXMXAMMMSSXMASMMSMSAAAAASXSAXMAXAXXAMXMXXXSXMMAMSXAXAMAMSSMXSAMXMAMXAXSMAXAXXMAXXAMXMAXAAAMAMMSAAAAMAMXMAMAMMMS
AAXSMMMASXMMXSASMSXXAAMASAMASXMMSSMAAXAXMXAAMSXSMMMMMSAMMSMMSAMSSMMMMSAMMSSMMMMMMXMAXMAXXAMXSXAXXMAMMMSMSSSSSMSSSSMSMSMSAMXMMMMMMMXMSMMMMAAA
MSMSASMAMAMXMMMAAMMSMXSMMMSAMAAAAXSMSSMSMMSSMMAXXXXXSMMMAAAXMAXAAAMAAMAMAAXXAASASMSMSAMSMSMASXSMMSSMAXXMAAAXAAAXAAXXXXASAXMMMSASASAAAXSASMSS
SXAXAAMSMXMAAAXMXMASAASXMAMASMMMSMMMAAXAAMMXAMXMSASMSAMXSSSXSMMSSMMMSSSMMMSSSXSASAMXMAXMAXMXMAMXAAMMMSXMMSMMMMMMSAMXAMMMMXAAAMAMAXMSMSXAXAAX
XMMMMMMXMASXSMXXMMAMMMXAMMSAMAXXXMAMSSSSSMAXMMSASAMASXMXMAMXAAAMAXSMMXMASMAMMMMXMMMAMAMMMMMSMMMMMXSAMXMXMAXXXSXAXAMXSXXAMMSMSMSMAMXAMXMXMMMM
MXAAAXSAMXMAAAMSMMXXAMXMMXMASMSSMSSXXMAXXMSMSASMMAMAMAMAMXMSSSMSAMXAXXMASMSMSASMMSSSSXSAMAAXAAAMAASXSXAASASXAAXMXMXAMMMMSAXAAAXMSMMAAAAAMASX
AXSSXSASAMSSMMMSAAMSMSAMXXSAMXAAMAMSMMMMXMXXMAMAMXMMSAMAMAMXXAAMMMSMMSMMXAMAMAXXAAAXAASASXSSSMSMMXSASASXSXMMMMMMSXMMXXAAMMSXMSMAMASMMMSMSAMA
SMAAXXMASAAXAAAXMMMAAXAXSAMXXMSMMASAXAAMSAMSMSMSMSMAXXXAXAMXXMSMSMXMAXAAMMMAMXMMMSSMMMMAMMAAXSAMXXMXMAXAMXXAAXAMXAXAASMSSXAXMXMSMAMMAMAXMAMX
MAMAMXXAASMSSMSXSASMSMAXSXSASMMXSXSMSSXSAMXAAXAAAAMMMSSMXSSMMXAAAAXMASMMSASXSSMXAAAASAMXMSMXMMMXSAMXMXMXMASMSSSMXMMSMSAMMMSSMAXMASASAMSMSAXM
SSSMASMMMMXAAAAASASAMMMMXMAXMAAASXMXAAXSAMXMXMSMSMXSAMAMAXAAAAMSMSMMMSAASMSMMAXMSSSMMXMAMAMSXSAAAAXASAMXMAXXXAMXXXAXMMXMAAAAXAMMXAAMXXAMXXXX
XAAAXMASAXMSMMMMMAMXMASXSSMAMMMMSAMMMSMSASAXXMMMXXAMASAMXSAMSMXXAAMAMSMMMAMMSAMMAAXAXMAMXAXAAMMSSMMMSXSAMXSMMMMXMAMMMMASMMXSMMSXMMSSSMMSMMMX
MSMMSSXMAXXXXXMAMXMSSMSAAAXMASMXSAMXMXAMAXXXMXAXMMXSAMXAXAXMMXAMXMSMXXXMASMAMMXMASMSMSASMSSMSMMAAAXXMASASXXAASASXSAAASASMSAAAAAAXXAAAAXAAAXX
MXMAXMMMMSSMMMXXSMMXAASMSMMXAAAASAMXSMMMSMMXMAXSAMAMASXMMMXXAMXAAXXMASMMAMMXSMXSAXAMASMXAXXXXAMSSMMASXMASXSSMSAMAMXXMMXSAMSSMMSMMXMSMMSSSMSM
XAMMXMAXAAAAAMSMXASXMMMXXASXMASXSXMXMASAMAXASAXXAMASAMASAXMMXMMXMSAMXMAMMSASXMASAMAMAMAMAMSMMXMAMASAMAMMMAAAXMAMSMMSSMSMMMXXMXMXSSMXAXAAAAAA
SSMSASXMMSSMMAAAMAMAXMXASAMXMAXAMASXSMMASXSMMSMSMMXMMSAMXMSAMXSMXAAMASAMXSXMAXXXMXMMXSMAAAXSMXSASXMASXSAMXMAMXMMXAAAAXMASXSASAMAMAASXMMXMMMX
SAASASXAXXXMMSSSXASMMSAMMMMSMXSAMAMMAAMAMAMMAMMASXAAMMMSMMMAXAXAMMMXXMAXAXAMSMMMMSXMASXSXSAMXAMXXXSMMXMXSAMASXMASMMXMMMAMASAMMMASMMMMASMSSSS
MMAMMMMSMSMSAAAAMXMXASXXAAMASMSMMXMSSMMAMAMMASMMMXMXMAXXAASXMASMSXSXMSMMSMSMAAXAAAAMAXAASMXAMSSSMXMASAMAMAMAXAMXSSSMMAXAMXMSMASAMXXAXMAAAAAX
SMMMXAXAAXAMMMMXSMMMXMASXMXAMXMMMAMXMXSAMAMMAXAXSXSASXMSSMSXMMAAAASMMAXXXAAXMXMMSMSMMMSMMSXXXXAAAAXAMAMSXSMSXMMSMAMASXSSSSMMXXMMSMSXSXMMMMMM
XAMMSSSMSMMMSAXXMAXSAMMMMSMSSXMSSSSXSASMSSSMSSSXMASASAMXAAXXXAMXMAMASXXMMSMMMXMMXXXAXXXAAAXSMMSMMXMSSSMMAXAXMAMASMSXMAAMMAAXXMAXAAXAXMSXMSSM
SSMAMXAAXAAAXMSMSSMSXSAMXXAAAAAAAMAMMAXAAAMAXSXAMAMXMAMXMMMMSMXAMXSXMMXSAMMSAASAMXMXMAXMMMXAAMMMXMXMAMXMAMAMSXSASXSMMSMASMMMXMASMSMXMASAAAAM
SMMASXMMMXMSXXAAAMXMXSMMMMMMXMMMSMXMMSMMMSMSXMSXMSMSSSMXMXAAAXAMXXSAAAXMASAMSSMASMMSAMXSMSSSSMMXMAAMSMMMAMSMAMMMMXMXAMAMSAMXSXAXAXXXAXMMMSSM
SASASXSXSAXAMSMSMSSMAMXASXMASXAXXXXMAMAMAXXMAXXMAMAMAXXAMXSSMXSAMASXMMXSAMMMXXMMXAAAXXMXAAMAAMXAXSAXAAMMMSAMXMAMSSMMMSSXSAMASAMSSSMMSSXMXMAM
XMMAMXSASMSXAXAMXAXMASXMSAMXAMXXMSXMASAMASASXMMMAMAMXMMMSAMAMMMAMMMAMXXMXMXAMXAAMXAMXSASMXXSXMMSXMMSSSMMSXMAMMAMAMAXAAAAMXMAMMMAAAXAAMAXMMXA
MSMSMAMAMXSASMSMMSSMASAASAMXSMSMXMASASASASAMMMAMXSXMAMXAMXMAMAXXXAXAMXAASMSASXMAXSAXAXMMMSMMASAMAAAAAMAXMAXXSASMMSMMMSMMSMMMSMMXSMMMSSSMMSSM
MAAXMXMAMXXAMAMAMXXMAMMMMMMMMAAASXMMMSAMAMAMASXSXMXXASMASMSMSMSMSMSAXAMXMASASXMAMSXMXXXSAAASAXASMMMSSSMMSXMASAMXXAAXXXXAAAAXAAXAMXXAAMMAMAAX
SMSMXAMAXXMMMMMSSMXMMMSXXAXAMSMSAMSAMMAMAXAXXXAXMAMXMSAMAXXAAAAXAMSAMSMSMAMAMXMSMMMSSXAMSSMMMXMMAXAMXAAAXAAMMXXXSXSMMXMXSMMMSSMSAAMMMMXAMSSM
XMAASASAMSMSXXMAAAMSSXMASMSMXMMAAASXMSXMMSMSMMMSMAMASMMMMMMSMSMMXMMXMMAAMAMMMXMXAAAAMMXMAXMASAMXAMSSSSMMSXMXMXMASAXMASXAMXSAAMMMMMXMXMXMMAMX
MSMMXMXAXSAMXSAMXSAAMMSAMXAXAXXSMMXAXSAMXAMAXAMXMSSMAAAMASXMAAXAMMMMMMXMSMSMSMMSSMMSSSSMAXXASASXSSMAMAXXXAMXSAAAMAMASAMXSAMXXXAAASXSASASMMSS
AAMMAMSXMMAMAMAXSMMMSXSASAMSXSAMASMMMSAMSXSASMSAMXAXMSMSASAMXMSSMMAAAAAXXMXMAAMAAXMMMMAMAMMMSAMXMAMMMSMMMSMASMSAMMMMMMMAMAMMMSSSMSASASMSASAM
SXSSXMAAXSAMXSAMXASXSAMXMAXAMAAMAMAAASMMMXMASXMASMSMAXAMASAMXXSAASMSSSSSXXASXSMSSMSAASAMAXSAXAMXSAMXAXAXAAMXSMMXAAAAAAMASAMAMAAXMXAMAMMSXMAS
XAXMASXSMXXXXAMXSAMXMXMASXMAMSAMXSSMMXSXMASMSMSMMXMASMXMXMXAMXSSMMMXAAXXXSMSAXAMMASXMSXSAXMASMAASXMMASXMSSSMXMASXSSSSMSASMSMSMSMMMAMXMXMASAM
