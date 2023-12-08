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
bbddn gkgvg csspt srm lffgc dpkvsdk gvcn vbk zhvfrl rnnsn xmmpt zltlhp zmzq jrgsgfb jdbcr vnvxb dzntt pjzmvrq mnrjrf nmxbgzp jbvhc pmvjg vgbrv hvtc vbkdkkfg cxjqxbt mxpsg bhsj jpqsk lhbj tzsr drbq kjgl bqprg nlrtm dfkmmb (contains peanuts, sesame, shellfish)
hvtc qtks zgzfp tprtg rkcpxs fmfsj pzhgbgm cxjqxbt tsbrr pkjhc njbz qsqvl dn skbm tqkt cqmlld mnrjrf jx pjzmvrq fzjz zhvfrl snvdgh grlclk vs tkrnqq gfz hgmb pqdpmn phmpskz ndb hvpnmp plgm dxfdt xmmpt glhjs mdnjkh lcvjkgp hdvt xzjjk kchndf lkncxkl bhsj kxhrx dpkvsdk xjr tdfr tsjxnmht qbfq hvnq drbq xgjsf cbpdq tcgk gvcn jrs dfkmmb lmjbg zskzx htzxnr ldszb zmzq xllbcpk nbnlj glchj vtfnl lvtdxj cqcdr nlrtm (contains nuts, dairy)
dfkmmb ftccm jdbcr vgbrv xmmpt pzhgbgm srm rkcpxs drbq ckjzjk kjgl knszm rmrpb bqprg grlclk lmjbg dmpnxx pjzmvrq dpkvsdk zskzx jhxfr lcgbz nlrtm qmxfsx bpth tsjxnmht scf fpsgzjk jfkltc ljvjmc jrgsgfb zgzfp dsqhb cnqjxst qktjs jhdbqk htzxnr kjmqh dxfdt pmch pmvjg nnkzh cqmlld rxqvp fstg cxjqxbt hvtc dzjznv fzjz zmzq jpqsk xbxbfq (contains fish, peanuts, eggs)
cqcdr hgmb nmxbgzp ncpcjs dzjznv ldszb cxjqxbt csspt hhpjtf hzktr zhvfrl tmnstvv qshtc vdcrrr knszm pqdpmn jpgsgz xjr kgctbt zkzlc ndb bsfd mnrjrf kcqz lnchnvz tmvd snvdgh kjpcp nhqnq njbz tcgk drbq zltlhp jkzv svbgn lzpmf qsqvl zskzx kjgl pckfr tzsr chqpzs mnmmbqt ghtt qmxfsx ftccm vcbxz plgm djndkb xllbcpk pmvjg ljvjmc dpkvsdk qssdvh jdbcr rkcpxs fstg zmzq rxqvp fmfsj fpsgzjk qdqdcm xhkngk vbkdkkfg hvtc rnnsn pkjhc dmpnxx cbrg (contains wheat, peanuts, shellfish)
kchndf zqtmj hgmb tzsr lnchnvz tsjxnmht kjgl kcntmgd zbqsk chqpzs hjxj skbm fmfsj knszm vnvxb cmmhk tsbrr pxbzrp dmpnxx mnrjrf shkd vgbrv jkzv bhsj ftccm rnqrg drbq lffgc nmxbgzp gfz zmzq jbdzbg rnnsn tdfr ttsmfm kjpcp jtgqb rmrpb svbgn kjmqh cqcdr bsfd qdqdcm cqmlld qbfq plq sqscg hvtc rlfd fpkzft qpvrq ckjzjk xmmpt dpkvsdk hvpnmp cxjqxbt lljl tcv kxhrx (contains peanuts, sesame, nuts)
zzgfr dpkvsdk hjxj qrvtbhj rkcpxs ndpmss gkgvg sdxsk hvpnmp kjgl vnvxb zpbd xmmpt dksprx jpqsk xdjmjl pxbzrp csspt ndb nbxjsxx fstg lljl zskzx lkncxkl cxjqxbt qtks xjr htzxnr jbdzbg qktjs jkzv rmrpb pckfr qbfq dsqhb knszm kgctbt xgjsf jrgsgfb njbz fpkzft ttsmfm jx zmzq pcnt jbvhc bbddn cqcdr bhsj hzktr mnrjrf gjjfrr jhdbqk rlfd cnqjxst vkbqls kjmqh (contains wheat, shellfish, peanuts)
ndpmss tzsr zqtmj jhxfr xmmpt bhsj drbq plgm rkcpxs hvpnmp qdqdcm gjjfrr vkbqls lcgbz zmzq kjgl shkd pzhgbgm cxjqxbt hjxj tcgk jrgsgfb lljl kcntmgd lkncxkl jhdbqk lhbj pqdpmn ghtt xjr fzjz hdvt zzgfr qmvlc zkzlc rmrpb pmch ncpcjs gffhns ttsmfm zskzx dmpnxx mtpjm xhkngk tsjxnmht dzjznv qdrt rqfpmm zxnrv tcv hjr cbrg gdpcgnc cjfdqs zbqsk pxbzrp tprtg mnrjrf qshtc nmxbgzp fmfsj (contains eggs, peanuts)
tdfr knszm pxbzrp blfnxq jfkltc drbq mxpsg kjpcp djndkb dpkvsdk ljvjmc llpmsz zmzq gkgvg qssdvh mnrjrf rlfd dzntt ckjzjk kcntmgd fmfsj svbgn jhdbqk dzjznv zpbd rqfpmm lljl qdqdcm sqscg mnmmbqt jbvhc lcgbz dsqhb gffhns rnnsn jpgsgz zskzx ns rxqvp ghtt xzjjk tmnstvv hvnq kxhrx pmvjg rkcpxs qtks pmch tzpvrq tsbrr njbz grlclk jnnhmlf lmjbg jrs qsqvl tzsr dxfdt pckfr kjgl pmfjd xhkngk vgbrv jdbcr xjf hjxj ljkt skbm nbnlj lffgc lnchnvz gfz xllbcpk zltlhp ttsmfm nhqnq bqprg phmpskz pkjhc cjfdqs kcqz jkzv xmmpt lcvjkgp (contains nuts, sesame, eggs)
mnrjrf jtgqb jfkltc lnchnvz cqcdr pcnt grlclk bbddn qsqvl rlfd tkrnqq gffhns knszm fpkzft dzjznv vgbrv hgmb mtpjm jx pjzmvrq zmzq dzntt hjr xjr kxhrx jnnhmlf hhpjtf pmch kjpcp vtfnl qtks csspt qpvrq rkcpxs tqkt pmfjd jhxfr plgm tzsr snvdgh nhqnq zqtmj hjxj tmvd jpgsgz hzktr lmjbg ns qshtc drbq pzhgbgm tdfr mnmmbqt xbxbfq zltlhp zfkf fstg vdcrrr dmpnxx dn tmnstvv lffgc lcvjkgp jrs fzjz ndb zpbd gjjfrr kcntmgd jbvhc bpth phmpskz fpsgzjk vcbxz xmmpt dfkmmb lvtdxj kjgl gvcn dpkvsdk rnqrg rxs (contains wheat, peanuts, nuts)
qdrt glchj hzktr kjgl pckfr hvnq tsjxnmht srm jnnhmlf qktjs qmxfsx rkcpxs vcbxz ckjzjk pxk tsbrr kgctbt knszm tmnstvv jkzv tprtg dpkvsdk fzjz bbddn nbnlj bqprg bhsj tsrqj nhqnq cxjqxbt zmzq zzgfr hjxj drbq ggsjrlb kchndf ljkt nbxjsxx scf zxnrv dksprx gfz dmpnxx xmmpt lkncxkl fstg vdcrrr tqkt zgzfp jtgqb zskzx (contains nuts)
zkzlc tprtg jpgsgz tsbrr ns jrs vnvxb hvpnmp cxhfpp vgbrv dxfdt gvcn tsjxnmht srm kjgl sdxsk pqdpmn pcnt llpmsz gjjfrr drbq blfnxq kcqz nbxjsxx tzpvrq pzhgbgm djndkb hhpjtf rkcpxs xmmpt dsqhb vhxnmt bqprg rnqrg qktjs grlclk tcgk jfkltc qtks nhqnq mnmmbqt xgjsf njbz mnrjrf mtpjm lkncxkl qbfq bpth mxpsg ggsjrlb tsrqj tzsr lcgbz dn jnnhmlf plq ftccm jhxfr ndb zmzq rnnsn zqtmj jbvhc xqjfdc qpvrq dzjznv lmjbg cxjqxbt sqscg hdvt rmrpb zzbh (contains nuts)
jkzv pxbzrp vcbxz cxjqxbt mxpsg plgm cmmhk zqtmj fpsgzjk bbddn rkcpxs hvnq rlfd qssdvh vtfnl tzpvrq qmxfsx lhbj vs tsrqj hvtc dpkvsdk dzntt pcnt jhxfr vbkdkkfg vkbqls drbq xmmpt hvpnmp zpbd tdfr pjzmvrq lkncxkl zzgfr nnkzh tsjxnmht grlclk nbxjsxx mnrjrf djndkb lcgbz kjgl (contains fish, eggs)
blfnxq xqjfdc lkncxkl zltlhp dpkvsdk cbpdq mdnjkh srm kjpcp kjgl svbgn plq fzjz drbq cxjqxbt jrgsgfb nbnlj vnvxb ljkt rkcpxs kcqz jpqsk xmmpt mnrjrf kjmqh pmch jfkltc hdvt rxs pxbzrp jhdbqk tcgk pqdpmn pcnt zskzx gffhns dn qshtc htzxnr sqscg zbqsk snvdgh qmxfsx jdbcr ldszb jkzv kgctbt mtpjm gdpcgnc lmjbg (contains sesame)
ns qrvtbhj kxhrx kcqz glhjs pzhgbgm mnrjrf vnvxb xzjjk pxbzrp gkgvg jnnhmlf jdbcr xhkngk nlrtm qsqvl vbkdkkfg jrs nmxbgzp zzgfr zgzfp csspt tmvd xdjmjl lvtdxj jtgqb cxjqxbt htzxnr djndkb bbddn qdrt zltlhp dzjznv vs tdfr vgbrv glchj njbz dfkmmb llpmsz rkcpxs plq chqpzs mnmmbqt xgjsf hjr phmpskz gffhns ljkt xbxbfq pmvjg sdxsk snvdgh lhbj tkrnqq dpkvsdk knszm lljl jfkltc xmmpt tcgk drbq pxk nbxjsxx dsqhb zxnrv qpvrq zhvfrl cqmlld tzsr kjgl (contains fish, sesame)
qsqvl qrvtbhj jhxfr shkd hvpnmp pqdpmn zzbh dfkmmb rnqrg jbdzbg rnnsn xzjjk lkncxkl lmjbg dpkvsdk lnchnvz tqkt glchj hhpjtf zmzq cxhfpp vcbxz zzgfr ndb cjfdqs snvdgh rkcpxs hzktr xdjmjl lljl zskzx jrgsgfb zltlhp fpkzft cxjqxbt fpsgzjk rmrpb tcgk chqpzs hjxj ttsmfm pxk llpmsz bhsj tsbrr plq xmmpt pzhgbgm dbgcsl tsrqj lzpmf jpgsgz mnrjrf bbddn hdvt cqmlld xqjfdc cmmhk ghtt cnqjxst pmfjd nmxbgzp njbz ckjzjk ljvjmc mxpsg jpqsk bpth qpvrq pkjhc gffhns tcv nbxjsxx ljkt pmch vbk vtfnl vbkdkkfg gjjfrr zfkf zbqsk lvtdxj pcnt drbq (contains fish, dairy, eggs)
tdfr rkcpxs kchndf cxjqxbt qdrt hzktr ljkt jbdzbg nmxbgzp kgctbt zfkf lhbj xqjfdc tzsr ldszb dpkvsdk kjmqh qshtc drbq zltlhp hvtc zmzq rnqrg zgzfp nbnlj dksprx vbk cbpdq pckfr bsfd cqmlld jrgsgfb hhpjtf shkd kjgl ftccm ttsmfm glhjs tqkt cqcdr zskzx pjzmvrq gdpcgnc xmmpt gffhns hjxj gkgvg vgbrv hjr kcntmgd cmmhk dxfdt zbqsk kxhrx ncpcjs lcvjkgp tzpvrq tsrqj ggsjrlb (contains nuts, peanuts)
zpbd pmvjg csspt xmmpt jpgsgz fpkzft ljkt plgm hdvt zzgfr rkcpxs kjgl hjr ckjzjk jbdzbg jkzv gvcn tdfr ns chqpzs mnmmbqt rmrpb xllbcpk zgzfp vhxnmt vbkdkkfg dpkvsdk bbddn hvpnmp svbgn cxjqxbt hzktr mnrjrf xzjjk tmnstvv htzxnr vnvxb hgmb kcntmgd thrrh vcbxz njbz cbpdq rxs grlclk pcnt sdxsk qssdvh zmzq llpmsz lzpmf xgjsf glhjs hhpjtf vkbqls zzbh pmch (contains shellfish, eggs, wheat)
ckjzjk vkbqls lljl vtfnl rkcpxs rmrpb ldszb xllbcpk bsfd tsrqj gkgvg cqcdr ghtt xmmpt nhqnq bqprg mnrjrf drbq lnchnvz qpvrq jfkltc cxjqxbt vbkdkkfg pqdpmn phmpskz cnqjxst dmpnxx pmvjg zgzfp zltlhp pjzmvrq vbk jnnhmlf pxbzrp grlclk qtks tsbrr rlfd bbddn hjxj zmzq xqjfdc qdqdcm vs dzjznv vdcrrr xzjjk qrvtbhj jbvhc hhpjtf pmch vcbxz zhvfrl qssdvh nlrtm tsjxnmht tcv kcqz dpkvsdk jkzv pcnt (contains sesame, nuts)
fstg blfnxq csspt dksprx pmfjd drbq cxhfpp jrgsgfb kjpcp kjmqh tmnstvv xdjmjl fpkzft tdfr zltlhp jbvhc hgmb hhpjtf zmzq zqtmj xllbcpk mnrjrf tkrnqq jtgqb zpbd lzpmf lnchnvz skbm ljkt vs snvdgh xgjsf ckjzjk pxk vbkdkkfg pzhgbgm kjgl vhxnmt pckfr bqprg cxjqxbt tcgk rkcpxs ljvjmc pmch pxbzrp mxpsg bpth hjr zgzfp tprtg qmvlc dxfdt dpkvsdk ndpmss ldszb hvnq tmvd qsqvl (contains wheat)
plq ftccm qssdvh bpth tsrqj fzjz zltlhp dzjznv mnrjrf qmvlc lmjbg drbq mtpjm tsbrr zqtmj lcgbz bhsj dn rkcpxs jhdbqk tdfr ckjzjk dpkvsdk jtgqb knszm cqcdr gdpcgnc pxbzrp cbpdq zzgfr jbvhc qdqdcm pjzmvrq cqmlld llpmsz jdbcr plgm cxjqxbt djndkb pcnt jkzv ghtt kjgl lkncxkl jrgsgfb dxfdt zmzq lcvjkgp csspt xjf hjr snvdgh gkgvg fmfsj pzhgbgm zfkf tmnstvv vdcrrr mnmmbqt jbdzbg ldszb phmpskz pmch blfnxq cbrg hzktr htzxnr (contains wheat, sesame)
jhdbqk tsbrr dzntt cmmhk plq ckjzjk gvcn gjjfrr hjxj cqcdr jrs pzhgbgm glchj jbvhc dbgcsl tzpvrq cxjqxbt svbgn sqscg mnmmbqt lvtdxj vbk jdbcr fmfsj rnnsn phmpskz zfkf dpkvsdk rmrpb kjpcp tzsr ghtt rkcpxs mnrjrf pxbzrp pckfr glhjs jbdzbg zhvfrl hhpjtf gkgvg zmzq tsrqj tmvd mdnjkh zqtmj skbm qktjs pqdpmn nmxbgzp rqfpmm pjzmvrq djndkb cqmlld dfkmmb pkjhc dsqhb xmmpt hvnq nbxjsxx zkzlc hvpnmp plgm ncpcjs zzbh jfkltc gffhns qtks zbqsk ttsmfm drbq sdxsk xdjmjl kcqz lzpmf qrvtbhj jrgsgfb zxnrv qdqdcm mxpsg (contains dairy, peanuts, sesame)
vgbrv tmnstvv kcntmgd nbxjsxx hvnq pxbzrp lkncxkl tcgk ggsjrlb zltlhp mnrjrf xmmpt tmvd ghtt xzjjk drbq lffgc cqcdr snvdgh kxhrx zzbh ndpmss nnkzh rmrpb dzjznv grlclk kjgl mtpjm rkcpxs ljvjmc vbk vbkdkkfg xgjsf gdpcgnc ljkt zmzq rxs qshtc bbddn cbpdq dxfdt lhbj qbfq gjjfrr qdrt bsfd dn zhvfrl hgmb pckfr xhkngk llpmsz pmch zbqsk tkrnqq cxjqxbt htzxnr knszm tzsr hhpjtf fpkzft sdxsk jtgqb (contains shellfish, wheat)
hhpjtf cmmhk zfkf rkcpxs pjzmvrq cxjqxbt xjf xmmpt bqprg lvtdxj ns rxqvp tsrqj pqdpmn pzhgbgm grlclk gffhns nlrtm hjxj lhbj sdxsk zhvfrl pxk tdfr plgm drbq zbqsk jnnhmlf djndkb cbpdq lcgbz gkgvg jkzv gfz ljvjmc jbvhc tsjxnmht dmpnxx cqmlld ftccm jdbcr hdvt fmfsj nbnlj gjjfrr vnvxb mnrjrf kjmqh cbrg xjr zzbh hvpnmp cqcdr zmzq lnchnvz rmrpb hvtc fzjz jrs qpvrq bbddn zkzlc qshtc dpkvsdk njbz ghtt ckjzjk lkncxkl fpsgzjk kcqz ndb vkbqls xgjsf (contains wheat)
jpqsk gfz tsjxnmht nlrtm sdxsk dmpnxx kxhrx vgbrv mdnjkh mnrjrf dsqhb tmnstvv skbm jhxfr bqprg zltlhp kchndf zzgfr zpbd pjzmvrq bbddn jnnhmlf zkzlc qdqdcm qbfq vs dzntt ndpmss bsfd lzpmf lcvjkgp dpkvsdk cnqjxst zmzq pmvjg qpvrq nbxjsxx xgjsf phmpskz ghtt zfkf fpsgzjk tsrqj jdbcr dxfdt lffgc qmvlc hzktr cbrg zzbh vnvxb pmch qmxfsx kjgl mnmmbqt drbq srm nbnlj bhsj plgm dfkmmb xmmpt jbvhc rnnsn svbgn zqtmj shkd zxnrv rkcpxs ljkt xjf tqkt ldszb fmfsj (contains wheat, dairy, nuts)
plq dpkvsdk hvpnmp mnrjrf zqtmj phmpskz svbgn xmmpt gvcn xdjmjl pmch tmvd srm xzjjk zbqsk kjmqh vkbqls vbkdkkfg pjzmvrq pmvjg shkd dxfdt kjgl thrrh jhdbqk rmrpb cbrg hvtc dksprx tcv lnchnvz qsqvl tdfr glchj zkzlc tsjxnmht pzhgbgm bhsj tkrnqq lvtdxj tzpvrq cqmlld htzxnr fpkzft zzgfr zgzfp skbm zpbd pxk pckfr zhvfrl zskzx pqdpmn dzjznv nhqnq qrvtbhj lffgc dn rxs snvdgh bpth qmxfsx xjf ggsjrlb kgctbt qbfq zmzq qdrt rnnsn csspt drbq ckjzjk gffhns glhjs kchndf rxqvp rkcpxs cxhfpp (contains shellfish)
vbkdkkfg qdrt vtfnl tzsr zltlhp nmxbgzp dmpnxx bsfd njbz vnvxb xjr mnrjrf cnqjxst fpsgzjk ncpcjs dksprx drbq rkcpxs ndpmss htzxnr zmzq jfkltc knszm ndb lhbj pxk fpkzft xdjmjl xjf xzjjk pjzmvrq bbddn sdxsk zxnrv hdvt skbm ftccm dzntt mxpsg jbdzbg ldszb zskzx cxjqxbt fzjz ckjzjk qmvlc kjgl dpkvsdk cbrg qmxfsx fstg qsqvl qssdvh lzpmf hgmb pckfr rxqvp (contains peanuts, shellfish)
hgmb zhvfrl zgzfp pmch lcgbz hvtc tmnstvv fpsgzjk rqfpmm rxqvp pcnt xjr kjmqh pkjhc cxjqxbt jnnhmlf jpqsk drbq nnkzh qbfq rxs dfkmmb nbxjsxx xjf dn cbrg tprtg kgctbt gdpcgnc kxhrx cxhfpp ldszb qsqvl zmzq vkbqls zltlhp phmpskz kjgl pmvjg fstg lnchnvz blfnxq mnrjrf mdnjkh vcbxz qmxfsx bsfd dpkvsdk gffhns cnqjxst bpth xmmpt cbpdq dksprx ndb lljl cqcdr (contains peanuts)
tsrqj kchndf ncpcjs rnqrg kjpcp tqkt ckjzjk gvcn htzxnr cxhfpp sdxsk zgzfp zskzx fpsgzjk qssdvh jnnhmlf zkzlc pmvjg glchj mnrjrf mxpsg qdrt fpkzft hvtc qmxfsx ljvjmc pmfjd csspt pcnt tprtg jrs llpmsz qdqdcm gffhns kgctbt thrrh ghtt rnnsn plgm hgmb qtks rlfd snvdgh dpkvsdk xmmpt djndkb bsfd zmzq zqtmj kjgl tmvd tcv ns gdpcgnc ljkt jx lnchnvz ldszb jhxfr svbgn tzpvrq jpqsk vgbrv vdcrrr bhsj tdfr jrgsgfb lcvjkgp fzjz rkcpxs rqfpmm drbq jbvhc (contains shellfish, eggs)
tqkt mnmmbqt kjgl rqfpmm qssdvh ghtt jbdzbg dn zzgfr kxhrx vkbqls lcvjkgp hvtc tcgk xzjjk rkcpxs cxjqxbt zqtmj xhkngk rxs zxnrv hgmb sdxsk tprtg dfkmmb dbgcsl xmmpt jbvhc cqcdr lnchnvz plgm rmrpb jrgsgfb rxqvp cbpdq jkzv gdpcgnc qdrt glchj tzsr pcnt vbkdkkfg lffgc thrrh ndb tsrqj hjr vhxnmt rlfd zltlhp jx dxfdt ttsmfm glhjs dzjznv pmfjd mxpsg vgbrv tsbrr bpth hzktr lcgbz kcntmgd nmxbgzp jhxfr ggsjrlb jnnhmlf gkgvg lmjbg drbq zmzq grlclk nhqnq jfkltc tzpvrq qmxfsx fpkzft vnvxb dksprx mdnjkh mnrjrf jpqsk (contains nuts, wheat, fish)
drbq chqpzs zfkf rkcpxs fmfsj xjf kjmqh qktjs lnchnvz blfnxq qshtc qtks zpbd xmmpt zbqsk kjgl ndpmss vdcrrr dpkvsdk kxhrx zskzx rqfpmm sqscg cmmhk ghtt pxk tqkt gfz cqcdr fzjz dzjznv zltlhp grlclk tkrnqq xgjsf pkjhc djndkb qbfq qrvtbhj jrs dsqhb csspt zmzq jrgsgfb cxjqxbt xdjmjl hhpjtf (contains wheat)
zmzq jpqsk dfkmmb hzktr vbk ggsjrlb plq ftccm bsfd hgmb nhqnq pmch zzbh cbpdq fstg dpkvsdk ckjzjk nmxbgzp kjmqh zltlhp rmrpb lzpmf tcv bhsj zskzx kjgl dsqhb pxk rxqvp pqdpmn lcgbz bqprg dksprx njbz ndpmss jhdbqk xjf gffhns jdbcr glhjs ghtt xllbcpk jbdzbg pzhgbgm zhvfrl hvnq srm pmvjg htzxnr dmpnxx lmjbg nlrtm gvcn xgjsf scf kchndf jnnhmlf fzjz rqfpmm jfkltc vbkdkkfg phmpskz nbxjsxx qpvrq tmvd llpmsz blfnxq mnrjrf xbxbfq xjr drbq lhbj vtfnl chqpzs fpsgzjk zpbd hvpnmp sqscg tprtg rkcpxs gjjfrr kxhrx tzsr zqtmj lffgc jrs kgctbt xmmpt hdvt cqcdr csspt jhxfr qdqdcm (contains sesame, peanuts)
dn rkcpxs xjf ggsjrlb zmzq kjgl zzbh hgmb zhvfrl tsjxnmht jdbcr ljvjmc kcntmgd skbm scf pmvjg jtgqb pmch cqmlld kcqz mtpjm vhxnmt mnrjrf bqprg dfkmmb tsbrr rxs pxbzrp sqscg hzktr cxjqxbt ndb xmmpt thrrh vcbxz vnvxb drbq pjzmvrq zgzfp ncpcjs pzhgbgm ttsmfm htzxnr lvtdxj tcv vgbrv qshtc (contains eggs, peanuts, fish)
jkzv xdjmjl nnkzh drbq njbz ttsmfm pcnt dfkmmb dpkvsdk bpth zkzlc tkrnqq cxjqxbt zltlhp lvtdxj zmzq rxqvp hvtc rqfpmm glhjs dzntt rmrpb zhvfrl xhkngk pxbzrp cbrg pzhgbgm hvnq hjr gdpcgnc gfz cxhfpp xjf cqmlld htzxnr hjxj hzktr gjjfrr jdbcr kcqz xmmpt jx qpvrq tsjxnmht pjzmvrq ckjzjk zbqsk rnnsn xzjjk kjgl rkcpxs csspt gffhns vcbxz vs jrs tsrqj cbpdq (contains eggs, wheat, dairy)
qmxfsx rlfd zgzfp drbq pcnt cxhfpp mdnjkh mnrjrf xjf zkzlc cxjqxbt xmmpt ljkt hdvt gfz tqkt tcv nbxjsxx bhsj pkjhc zfkf lmjbg fmfsj jdbcr lnchnvz rkcpxs grlclk zhvfrl ldszb tmvd qshtc ns jnnhmlf kjgl qsqvl snvdgh jx ncpcjs tkrnqq pmch fpkzft hvnq dbgcsl hhpjtf nlrtm fzjz cmmhk xqjfdc xjr pxk dpkvsdk (contains dairy, sesame, nuts)
tsjxnmht qtks gjjfrr lcgbz rkcpxs gkgvg lkncxkl dzntt dsqhb drbq bsfd dpkvsdk pcnt hjr glchj ggsjrlb zkzlc sqscg vs rnnsn ljkt jrs vkbqls pqdpmn nlrtm kjgl svbgn zmzq mnrjrf qpvrq jhdbqk dn cxjqxbt mtpjm blfnxq xdjmjl nmxbgzp fzjz scf xjr shkd jdbcr htzxnr vbk jnnhmlf zxnrv chqpzs (contains shellfish)
