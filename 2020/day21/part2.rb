Food = Struct.new(:ingredients, :allergens)

foods = []
DATA.readlines.each do |line|
  if line =~ /^([a-z ]+) \(contains ([a-z, ]+)\)$/
    foods << Food.new($1.split, $2.split(', '))
  else
    p "oops"
  end
end

foods_by_allergen = {}
foods.each do |food|
  food.allergens.each do |allergen|
    foods_by_allergen[allergen] ||= []
    foods_by_allergen[allergen] << food
  end
end

ingredients_by_allergen = {}
foods_by_allergen.each do |allergen, foods|
  ingredients_by_allergen[allergen] = foods.map(&:ingredients).inject(:&)
end

loop do
  done = true
  ingredients_by_allergen.keys.each do |allergen|
    if ingredients_by_allergen[allergen].length == 1
      ingredient = ingredients_by_allergen[allergen].first
      ingredients_by_allergen.keys.each do |cur_allergen|
        ingredients_by_allergen[cur_allergen] -= [ingredient] if allergen != cur_allergen
      end
    else
      done = false
    end
  end
  break if done
end

puts ingredients_by_allergen
  .map { |allergen, ingredients| [allergen, ingredients.first] }
  .sort_by(&:first)
  .map(&:last)
  .join(',')

__END__
nmjbg vvqj kndxsc ndhcb lvxgx mcmphgh pvjd csbpcjf gvzmlh shkr zgjzs nmrsgx bfvqkskq gjsmct dvbtn mjmqst thnqpr mdjh ngzpst fxrrz dgs pqnhxp pbnhgjb zlxj cvck skvh srbmm bsqq zvlpg qpsx dbznsv xxscc gbfsk dzrhrp ddp pgqct mgb pvvvd tzbsgz gxgzc tqs cgmz hskcfs tvdgh fgrtd mxxmt dllbjr vpck jhcjmm jvrgp kzpn trnnvn ktlzpb gbcjqbm vhgtl mpbb mffxl xvlhsr gzxnc hkgx cdqjnm bhmfd pmv xbczcq vtxth bzlfb (contains shellfish, peanuts)
ktlzpb pdps mdjh mgjgj bxb pgqct pvvvd dllbjr ntq gbcjqbm ffrdgc trlgr cmgk vhgtl lsfp pbtrt tfdn nmjbg thnqpr nmrk tvdgh nckqzsg rsrkc jxtbj qcghs xxscc xpkjlcq hlhpc vvqj hvgfp qpsx lsbr hrpmhx fhrjf hvbq tzbsgz gjsmct zthsm xxrtl mcncq mgc gxxqx dgs zdbqvd lncn sztrp xbczcq kxpt tbmtv bfvqkskq jftnvc zlxj vtxth bsqq jcjfnj rlchh hnktb zgjzs gzxnc fbftx txhfzt rlpjgk mpmldsk mxxmt mmpg mjmqst vghzrm vpck tfcqf gxgzc gdmtrhq ndcp (contains nuts, wheat, fish)
jhcjmm dbznsv kjtsc hkhgtn bdzmz pbtrt xxscc mdjh gll vtsdjkz pvjd nmrk gbcjqbm kxpt mxxmt csbpcjf dllbjr mgb nctjht gbfsk mxddn nmfplnv lncn pqnhxp tqs fxrrz nckqzsg mffxl mjmqst tlxbfr tzbsgz zmrln mcncq ngzpst jrvrkv gftk nmrsgx vvqj lvh scp gdthgl kvxvk rfgh hvgfp bvnkcn tfjf rlpjgk zlxj plslmj gzxnc vtxth vbhzkd sxnl hnktb xglxt (contains nuts, shellfish)
jvrgp kndxsc jdqc rlpjgk jrvrkv mdjh jhcjmm qglnzfc lndhcg gbcjqbm mjmqst fhxr xvlhsr rztsxd zntpxs rfgh qpsx lsbr dgnngb zmrln mxxmt bkktnzb lvh lpvl vgggc xtrnc kzpn mqbmfz tlxbfr gxgzc tfdn xxscc mxnvp zlxj dgs sztrp ktlzpb nmfplnv pftfbf trnnvn lsnkg vvqj mgmvrxq ndhcb gvzmlh rsj ffrdgc jftnvc hrpmhx hmkdrp gxxqx jbb dgltt dllbjr ntq gzxnc pvztpzx gdmtrhq dvbtn zdbqvd tfl pbnhgjb (contains shellfish)
nckqzsg xpkjlcq xfmh gbcjqbm fmsqq hrpmhx xxrtl tlxbfr mcncq gzxnc mdjh mmpg gxgzc hlhpc hkgx zdbqvd hskcfs zvlpg trnnvn vpck xtrnc vplq mcmphgh jxtbj btbxl dgltt lgjmn zvdkkq mqbmfz kndxsc dmcc lvh skvh fdmt hvgfp zgjzs gll jrvrkv pbnhgjb vhgtl xvlhsr zbjdh tfcqf dvbtn tfjf vnzb cvck bfvqkskq vvqj mxddn rlchh bhmfd mgmvrxq vgggc lncn mgb vbhzkd scp dllbjr tbmtv pbtrt tqs gbfsk nmrsgx rsj qblbbrx cgmz lndhcg jbb ddp zlxj frgqxt qpsx mqggk txhfzt mjmqst (contains peanuts)
cjnlts djdpg vvqj vplq vbhzkd trnnvn zbjdh jhcjmm bdzmz mxhnbj bplh lvh xxscc jrvrkv shkr lgjmn cmgk mcncq pbtrt mdjh hkgx xvlhsr nckqzsg sjjkz gxxqx dzrhrp hmkdrp pvztpzx gvzmlh qpsx bfvqkskq srbmm dllbjr gxgzc hvbq kjtsc jcjfnj mjmqst zvdkkq gnbrsz pvvvd frgqxt pftfbf mqggk tmxvpsnx lvxgx nctjht kkltvbdv dvbtn tfdn gdmtrhq scp cgmz jdqc gbcjqbm nmrk mcmphgh rfgh bvnkcn fjtlf ntq (contains eggs)
mjmqst tbmtv zdbqvd pmv trlgr rfgh vvqj dllbjr fmsqq lgjmn jrvrkv tvdgh fbftx rgxkhz ktlzpb nmrsgx zthsm lncn dbznsv mxddn trnnvn fxrrz gftk pgqct gzxnc sxnl nckqzsg mmpg gvzmlh kxpt xxscc czprn txhfzt rsj lsnkg zvlpg gbfsk mxxmt gxxqx mxhnbj fhxr xvlhsr gjsmct jbb frgqxt jdqc jftnvc qblbbrx vhgtl (contains fish)
trlgr lsfp mcmphgh mqbmfz tgsh pmv mgjgj hskcfs ngzpst qcghs gnbrsz zlxj kvxvk tlxbfr trnnvn bzlfb lsnkg zvlpg vhgtl gftk dgnngb gdmtrhq lpvl vvqj nckqzsg thnqpr kzpn mffxl dllbjr mxxmt gzxnc xxscc sjjkz vtsdjkz mjmqst dgs pbtrt dbznsv fhrjf tfdn gjsmct nmrk zbjdh vnzb xglxt dvbtn dgltt mpbb fltg (contains eggs, nuts)
vghzrm bfvqkskq mgjgj tvdgh dbznsv kkltvbdv thnqpr gvzmlh mpmldsk btbxl fjtlf gxxqx xvlhsr jrvrkv bplh thxzhb sztrp ndcp fmsqq gbcjqbm rztsxd srbmm pvvvd pqnhxp kzpn csbpcjf pbnhgjb jjvt mqggk kvxvk gzxnc bvnkcn bhmfd fxrrz trnnvn vpck tbmtv nmrsgx mgb xxscc vvqj bxb lpvl mjmqst bkktnzb trlgr lsbr hnktb jjhjk nckqzsg jbb lgjmn ndhcb gnbrsz tgsh kxpt xpkjlcq (contains fish, wheat)
fmsqq tmxvpsnx mhff xxscc nzvdv cvck gbfsk trnnvn rlchh mqggk lndhcg nckqzsg xpkjlcq ptgbslr rgxkhz nmjbg pqnhxp gxxqx hkhgtn cgmz kxpt zdbqvd pdps rztsxd fxrrz gdthgl kndxsc vplq tvdgh mdjh txhfzt qpsx dllbjr jjvt pbtrt bhmfd gvzmlh ngzpst jrvrkv xglxt lsfp bxb vvqj nmrsgx mgmvrxq kjtsc nmfplnv gdmtrhq jbb gbcjqbm csbpcjf ndcp gzxnc tfl fhrjf gll nctjht vnfgr gftk rqfl pvjd bkktnzb mcmphgh (contains peanuts, soy, shellfish)
hlhpc zthsm rlchh thnqpr mcncq gzxnc mdjh scp mqggk sxnl dgs nmrsgx lvh sztrp dtppr srlhbg lsfp mcmphgh gbcjqbm tlxbfr mgmvrxq nckqzsg cmgk xxrtl vhgtl jcjfnj hrpmhx zvdkkq hvgfp mxnvp dllbjr lndhcg mpbb xbczcq jdqc kndxsc zvlpg mpmldsk bfvqkskq bdzmz fmsqq rztsxd vvqj qpsx djdpg nmrk vnfgr txhfzt dbznsv rsj mjmqst skvh mgc mgb mxhnbj nzvdv xxscc xtrnc ntq vgggc hmkdrp zlxj fhrjf nmfplnv (contains eggs, nuts, fish)
mdjh hvbq dtppr tfdn dgnngb fhrjf jbb ngzpst fmsqq xbczcq kvxvk xxscc hkgx skvh vnzb vtsdjkz mbk djdpg sjxs scp tfjf fjtlf hvgfp rsrkc zqnnr trlgr plslmj thxzhb tfcqf dgs nmfplnv ntq srlhbg tgsh pvztpzx vvqj rsj gftk nckqzsg gxxqx xvlhsr lvh mpmldsk srbmm pdps lvxgx xfmh sjjkz nzvdv ddp mjmqst hrpmhx lsfp mgmvrxq qpsx fhxr pbnhgjb trnnvn gbcjqbm gvhpd gbfsk pbtrt bmvhsbk ndcp fgrtd nctjht gzxnc pmv fxrrz pqnhxp tlxbfr cjnlts (contains shellfish, eggs)
ndcp tfjf xxscc sjxs jcjfnj srlhbg tfcqf dgltt hkgx hkhgtn mhff hvgfp mxnvp mxxmt gbcjqbm bfvqkskq jvrgp lsnkg qcghs fhxr vhgtl gzxnc mpmldsk djdpg gvzmlh cmgk xbczcq mmpg bhmfd mpbb gnbrsz lsbr zntpxs ptgbslr jrvrkv mcmphgh trnnvn fbftx vnfgr bkktnzb pqnhxp mxhnbj dllbjr dgnngb thxzhb vplq csbpcjf tgsh fhrjf jftnvc nmfplnv rlpjgk cgmz shkr xvlhsr sjjkz gxxqx kjtsc frgqxt mgb nckqzsg bzlfb mgc mcncq mjmqst mqggk rsj ndhcb fxrrz ntq gll bxb (contains wheat, shellfish)
sjxs gxxqx xxscc mpmldsk fjtlf trnnvn nckqzsg pqnhxp hvgfp mgc zvlpg jftnvc pgqct mdjh zlxj gvhpd xglxt hkgx pvjd tfjf mmpg gzxnc gbcjqbm tfdn rlpjgk zqnnr vhgtl cmgk plslmj czprn xbczcq dtppr mxxmt dvbtn zthsm tfl vplq nmfplnv lvh bhmfd vghzrm pbnhgjb cjnlts lsbr nctjht dbznsv skvh csbpcjf nzvdv xxrtl rsrkc nmrk btbxl hnktb bdzmz pbtrt hvbq cgmz sjjkz cvck shkr xtrnc fgrtd fltg vvqj kvxvk bkktnzb kndxsc djdpg gftk gvzmlh qblbbrx rztsxd dgs dllbjr vgggc (contains soy, nuts, sesame)
nmrsgx nmrk rsj bxb rqfl sxnl xxscc zvdkkq nctjht qglnzfc tmxvpsnx gll skvh mgjgj hrpmhx pdps jjhjk mgmvrxq cdqjnm mxhnbj hkgx hlhpc gvzmlh zlxj dmcc mgb vvqj mbk trnnvn bfvqkskq dllbjr tqs vnzb nckqzsg bplh zntpxs rfgh fgrtd scp dgs vpck xxrtl zmrln dzrhrp ntq lsnkg bhmfd kndxsc mjmqst rscs zvlpg gbcjqbm pvvvd mgc (contains wheat, peanuts)
dllbjr rlpjgk lpvl fmsqq jrvrkv mdjh bxb dtppr dzrhrp mjmqst tfdn mgb mpbb sjxs txhfzt mgjgj pbtrt nzvdv gbcjqbm qblbbrx pqnhxp xxscc plslmj vtxth vnfgr vvqj nckqzsg bzlfb gvhpd pdps fbftx hnktb fxrrz gxxqx jcjfnj jdqc lndhcg mqggk hrpmhx gvzmlh gxgzc skvh hvgfp trnnvn (contains fish)
pqnhxp txhfzt cjnlts nmfplnv mjmqst sztrp mpbb vvqj kkltvbdv tqs ngzpst vtsdjkz xtrnc lsnkg fbftx skvh xfmh vgggc dllbjr mmpg nmjbg bmvhsbk gxxqx jhcjmm rztsxd vnzb bxb lsfp xpkjlcq pftfbf gftk pdps nzvdv qglnzfc mffxl dgnngb tfcqf cmgk tmxvpsnx xvlhsr jjvt kjtsc tbmtv mxnvp mdjh nckqzsg zthsm bvnkcn tfjf hkhgtn dbznsv pmv fmsqq xglxt fdmt qcghs hrpmhx gvhpd lndhcg csbpcjf scp tfl sxnl pgqct ndhcb ntq hlhpc nmrsgx cgmz bfvqkskq gbcjqbm hmkdrp trlgr mbk xxscc gzxnc lsbr (contains eggs)
hvgfp zmrln mjmqst hskcfs plslmj xglxt fxrrz bhmfd gbcjqbm cvck trnnvn mxhnbj jrvrkv gjsmct tqs zgjzs bdzmz tfcqf pdps vvqj fbftx bfvqkskq pmv jhcjmm lpvl bmvhsbk pqnhxp xpkjlcq mgmvrxq bxb ffrdgc rztsxd zlxj tlxbfr hmkdrp frgqxt zqnnr btbxl gzxnc bzlfb nckqzsg trlgr xxscc vbhzkd ptgbslr gxxqx fgrtd dtppr mxnvp vhgtl shkr (contains wheat)
dvbtn nckqzsg tqs gdthgl dzrhrp rfgh lpvl bvnkcn tvdgh pmv sztrp mdjh sjxs zntpxs bzlfb srbmm vtsdjkz vbhzkd mqbmfz xpkjlcq lgjmn mpmldsk rgxkhz gbcjqbm pbnhgjb trnnvn vplq dgs xxscc mmpg zvdkkq jftnvc lncn tfjf vnzb hlhpc vtxth gnbrsz fgrtd hnktb lndhcg xtrnc kzpn thxzhb kjtsc zthsm dllbjr lvxgx gzxnc vnfgr hvbq xfmh tbmtv lsbr hkgx kxpt ngzpst kkltvbdv sjjkz bsqq nctjht vvqj djdpg nmjbg zqnnr mbk pbtrt (contains soy, wheat)
plslmj tfjf pvvvd pqnhxp trnnvn czprn shkr scp fbftx gdthgl thnqpr trlgr gvhpd fxrrz ngzpst mmpg mcncq btbxl zvlpg qglnzfc mcmphgh hvgfp cdqjnm mxddn rlpjgk mxhnbj nzvdv sztrp qblbbrx mmcd gbcjqbm gll vgggc tbmtv gjsmct dzrhrp nctjht mxxmt jrvrkv mpmldsk gzxnc gdmtrhq vpck pvjd tzbsgz xglxt xfmh lncn nmfplnv ktlzpb mqbmfz fhrjf xbczcq dllbjr rsrkc csbpcjf mjmqst lsbr vhgtl qpsx mbk vvqj nckqzsg tqs mhff tgsh cjnlts qcghs lvxgx xpkjlcq srbmm jdqc vnzb gftk rztsxd hlhpc sjjkz kvxvk nmrk lvh hkgx mffxl jxtbj zmrln sxnl (contains wheat, sesame, soy)
lgjmn rlchh zqnnr gnbrsz zntpxs mgb vplq rqfl vtxth tfjf vhgtl gxgzc hnktb rztsxd qglnzfc fjtlf ddrfz kjtsc bmvhsbk mmpg jbb nzvdv mgjgj mqggk btbxl vtsdjkz xpkjlcq vvqj tfdn ndcp bkktnzb tfl xbczcq mmcd pvjd vnfgr nckqzsg mcmphgh mgmvrxq tlxbfr gftk dtppr kkltvbdv tqs fbftx kvxvk ktlzpb lsfp dllbjr dzrhrp rlpjgk pdps pftfbf gzxnc gbfsk thxzhb fdmt nmfplnv xxscc pmv trnnvn jcjfnj trlgr mjmqst fhrjf rsj bxb sxnl ntq vnzb lncn fltg pqnhxp (contains soy)
nckqzsg tfdn mmpg gvzmlh ptgbslr gzxnc bfvqkskq vnfgr rqfl rsrkc jftnvc fjtlf ndcp zthsm skvh xxrtl thnqpr gbcjqbm tbmtv sxnl lncn xxscc lvxgx mhff plslmj rfgh hkhgtn gdthgl hmkdrp lgjmn mjmqst tqs hlhpc zqnnr trnnvn bsqq zlxj tfl pgqct fgrtd mgjgj mmcd kjtsc pbtrt dbznsv zbjdh dllbjr mcmphgh gnbrsz lsnkg mbk bmvhsbk mxhnbj pvvvd (contains nuts)
mxddn czprn bfvqkskq mpmldsk mpbb hskcfs bmvhsbk vvqj rztsxd qcghs xbczcq dtppr mqggk nmrk bvnkcn hvgfp jcjfnj hkgx dvbtn pmv rscs hmkdrp bhmfd bdzmz nmfplnv pbtrt vpck fxrrz mxxmt tmxvpsnx gzxnc gll mgjgj plslmj qglnzfc cgmz xxscc trnnvn fjtlf mcncq zdbqvd jjvt zvlpg nckqzsg gvzmlh shkr vghzrm xpkjlcq fbftx ktlzpb tbmtv tfjf txhfzt gbcjqbm rfgh rlchh rsrkc xtrnc gbfsk mjmqst dmcc rqfl vbhzkd qblbbrx pvztpzx (contains fish, peanuts)
dmcc fmsqq cjnlts mxxmt pmv pbtrt zqnnr fdmt gxgzc plslmj lsfp gnbrsz mmpg rgxkhz xfmh ffrdgc thnqpr qcghs fxrrz kxpt dllbjr fbftx mgc fjtlf nckqzsg hvbq jdqc hkgx vplq tfl hvgfp tbmtv jcjfnj mjmqst jhcjmm mqggk zbjdh gbcjqbm gdthgl xbczcq kkltvbdv trlgr sxnl fgrtd zvdkkq vtsdjkz tlxbfr vbhzkd rsrkc rqfl mqbmfz xxscc kzpn pqnhxp trnnvn cmgk ddp vnfgr pvztpzx csbpcjf bplh mgjgj bmvhsbk jftnvc gzxnc vghzrm zmrln ndhcb lvh lncn tvdgh mdjh (contains eggs)
dbznsv fgrtd tfl qglnzfc zntpxs kxpt mdjh mjmqst xvlhsr bmvhsbk nmrk xxscc qpsx tfdn vpck mgc rscs dgltt fhxr srlhbg kjtsc srbmm djdpg ddrfz mhff vbhzkd hlhpc sxnl pgqct scp sjjkz jjvt dmcc ffrdgc lncn pvvvd pbtrt dgnngb cjnlts tzbsgz nmfplnv gjsmct tlxbfr jjhjk hnktb xtrnc thnqpr zlxj ngzpst cmgk qcghs pqnhxp pftfbf ptgbslr kzpn mxddn bsqq gbfsk rztsxd dvbtn nmrsgx cgmz hkgx gxgzc cdqjnm trnnvn gzxnc dzrhrp lvxgx ndcp vtxth txhfzt tfjf dgs mgjgj mpmldsk lvh tbmtv shkr jhcjmm gbcjqbm lpvl zgjzs zmrln mgb lgjmn vvqj rlpjgk bkktnzb gvhpd hvgfp fhrjf nckqzsg kndxsc bvnkcn mffxl jxtbj tqs pmv (contains shellfish)
mqbmfz srlhbg jrvrkv hnktb srbmm bvnkcn bzlfb rlchh gxgzc xbczcq jjvt jhcjmm cjnlts jbb mhff dgs rfgh djdpg mgmvrxq zlxj rsj gzxnc jftnvc ptgbslr mjmqst kkltvbdv vghzrm mxxmt kjtsc hskcfs vnzb tfjf pdps dgnngb dgltt trnnvn mgb nzvdv mdjh jcjfnj pmv qpsx nctjht cgmz ndcp lndhcg mxddn gdthgl jdqc dmcc skvh mpmldsk nckqzsg gbcjqbm sztrp vgggc dllbjr fltg vtxth zmrln jvrgp xxscc mgjgj lvxgx hmkdrp dzrhrp pftfbf mcmphgh ddrfz (contains shellfish, eggs, fish)
ntq nzvdv dbznsv mgc tfl thxzhb qglnzfc gvhpd ngzpst nmrk mbk pbnhgjb fhxr ndhcb xglxt sjxs dmcc sjjkz kjtsc vhgtl gbcjqbm zgjzs pbtrt qblbbrx gxgzc lvh csbpcjf dllbjr trnnvn lgjmn cgmz rsj dtppr xbczcq hlhpc ddrfz lsnkg cmgk fhrjf trlgr xxscc mjmqst mmpg vgggc vnfgr zbjdh tfdn srbmm nckqzsg gzxnc nmfplnv (contains soy, sesame, wheat)
qblbbrx tfjf czprn mqbmfz mgjgj scp jcjfnj lndhcg mbk kndxsc trnnvn pbnhgjb bplh gzxnc mcncq lgjmn kkltvbdv ktlzpb ddp mjmqst dvbtn dgnngb nmrsgx bzlfb hmkdrp pmv mgb bvnkcn vplq gbcjqbm dgltt sztrp mpmldsk zlxj xxscc zmrln jhcjmm dgs xglxt xtrnc srlhbg vvqj mxddn csbpcjf gftk cdqjnm nckqzsg mpbb gjsmct ptgbslr rsj tvdgh ddrfz (contains sesame, eggs)
tfjf bsqq nzvdv pbnhgjb zbjdh gzxnc kjtsc nckqzsg mgc cgmz pdps bdzmz hrpmhx vvqj hkhgtn gxxqx gll dvbtn btbxl lsbr vbhzkd srbmm lvxgx dzrhrp pbtrt bhmfd kndxsc pgqct jftnvc rlchh fxrrz shkr xbczcq xxscc fbftx nmrsgx mmpg rscs rqfl rlpjgk tvdgh trnnvn gdmtrhq mgjgj gbcjqbm trlgr rfgh zlxj mcncq vgggc hvbq hnktb bplh qglnzfc tfl mjmqst gxgzc kkltvbdv pmv sxnl gbfsk fdmt ndcp bxb gnbrsz (contains wheat, eggs)
xxscc cgmz mcncq mjmqst txhfzt nckqzsg vhgtl vnfgr vvqj zgjzs vnzb jxtbj gxxqx qglnzfc fjtlf trnnvn mbk csbpcjf gzxnc gftk bkktnzb rsj pqnhxp tfl zvlpg mdjh dvbtn mxnvp gvzmlh fdmt jvrgp mpbb kzpn zthsm fmsqq mxxmt fltg dzrhrp vpck kkltvbdv mxhnbj mhff qblbbrx zbjdh hkgx jcjfnj xvlhsr scp pvvvd trlgr dllbjr jrvrkv nmfplnv vtsdjkz hlhpc lpvl djdpg kjtsc btbxl cdqjnm hvbq srlhbg fgrtd tfjf plslmj vbhzkd pftfbf hkhgtn vtxth bdzmz gjsmct (contains wheat, nuts, fish)
rsrkc vvqj hlhpc dtppr zvlpg btbxl mcmphgh pvjd vplq rztsxd lpvl lgjmn vtxth nmfplnv mqbmfz hkhgtn dgltt trlgr nctjht lncn pmv bxb djdpg kkltvbdv jvrgp txhfzt mffxl lsfp qblbbrx plslmj xtrnc jxtbj dmcc fgrtd dzrhrp shkr jhcjmm pbnhgjb sjjkz xpkjlcq gbcjqbm qglnzfc gbfsk tvdgh fjtlf mgc nckqzsg gll rlchh trnnvn mxxmt zdbqvd xxscc rfgh bdzmz fmsqq mhff gdmtrhq ndcp cgmz rlpjgk hvgfp dllbjr hrpmhx tzbsgz xglxt zlxj bfvqkskq gzxnc dvbtn (contains eggs, sesame, nuts)
sxnl pqnhxp xxscc gzxnc qcghs vghzrm trnnvn mqbmfz mpbb frgqxt trlgr zmrln czprn djdpg mdjh kndxsc vvqj nmjbg fmsqq kzpn jvrgp gbfsk tmxvpsnx dgnngb pvjd skvh cvck fhxr mhff ndhcb mjmqst nckqzsg mxhnbj zntpxs plslmj pbtrt jcjfnj tbmtv mxnvp tzbsgz gdthgl mcncq gbcjqbm fbftx zlxj hvgfp sztrp lsnkg (contains sesame, nuts, fish)
jvrgp vpck tfl plslmj jrvrkv tmxvpsnx gxgzc jhcjmm lvxgx mcmphgh vnfgr mpbb gzxnc pqnhxp srlhbg kjtsc sztrp lsbr xxrtl dllbjr tfcqf nckqzsg xtrnc gbcjqbm trnnvn rgxkhz zdbqvd frgqxt bzlfb zbjdh tfjf gxxqx nmfplnv gll hmkdrp zmrln nmrk bvnkcn fhxr bkktnzb gdmtrhq mdjh ngzpst xxscc sjjkz mgb pftfbf fmsqq hnktb vvqj ptgbslr (contains peanuts, soy, shellfish)
zdbqvd gbcjqbm tfjf sjjkz bvnkcn mgmvrxq nckqzsg gjsmct fdmt bzlfb dllbjr jvrgp mmpg bxb jxtbj xpkjlcq fmsqq ktlzpb pvvvd rsj cgmz jbb hskcfs vnfgr nmrk tfcqf lvh zlxj rztsxd gbfsk gzxnc mqbmfz cvck mqggk frgqxt mjmqst gll tbmtv bplh nmrsgx trlgr jcjfnj zbjdh gvzmlh sjxs plslmj ndcp gnbrsz mffxl fjtlf kvxvk rfgh tgsh thxzhb tzbsgz qblbbrx vbhzkd jjvt fltg jftnvc gdmtrhq tfl dvbtn ptgbslr bhmfd sztrp lndhcg kzpn dgltt vvqj dtppr jjhjk zmrln rsrkc pmv pftfbf gdthgl hnktb lsfp hkhgtn bmvhsbk sxnl xxscc (contains soy, shellfish)
