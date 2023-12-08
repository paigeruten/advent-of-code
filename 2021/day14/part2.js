const rules = {
  CF: 'H',
  PP: 'H',
  SP: 'V',
  NO: 'C',
  SF: 'F',
  FS: 'H',
  OF: 'P',
  PN: 'B',
  SH: 'V',
  BO: 'K',
  ON: 'V',
  VP: 'S',
  HN: 'B',
  PS: 'P',
  FV: 'H',
  NC: 'N',
  FN: 'S',
  PF: 'F',
  BF: 'F',
  NB: 'O',
  HS: 'C',
  SC: 'V',
  PC: 'K',
  KF: 'K',
  HC: 'C',
  OK: 'H',
  KS: 'P',
  VF: 'C',
  NV: 'S',
  KK: 'F',
  HV: 'H',
  SV: 'V',
  KC: 'N',
  HF: 'P',
  SN: 'F',
  VS: 'P',
  VN: 'F',
  VH: 'C',
  OB: 'K',
  VV: 'O',
  VC: 'O',
  KP: 'V',
  OP: 'C',
  HO: 'S',
  NP: 'K',
  HB: 'C',
  CS: 'S',
  OO: 'S',
  CV: 'K',
  BS: 'F',
  BH: 'P',
  HP: 'P',
  PK: 'B',
  BB: 'H',
  PV: 'N',
  VO: 'P',
  SS: 'B',
  CC: 'F',
  BC: 'V',
  FF: 'S',
  HK: 'V',
  OH: 'N',
  BV: 'C',
  CP: 'F',
  KN: 'K',
  NN: 'S',
  FB: 'F',
  PH: 'O',
  FH: 'N',
  FK: 'P',
  CK: 'V',
  CN: 'S',
  BP: 'K',
  CH: 'F',
  FP: 'K',
  HH: 'N',
  NF: 'C',
  VB: 'B',
  FO: 'N',
  PB: 'C',
  KH: 'K',
  PO: 'K',
  OV: 'F',
  NH: 'H',
  KV: 'B',
  OS: 'K',
  OC: 'K',
  FC: 'H',
  SO: 'H',
  KO: 'P',
  NS: 'F',
  CB: 'C',
  CO: 'F',
  KB: 'V',
  BK: 'K',
  NK: 'O',
  SK: 'C',
  SB: 'B',
  VK: 'O',
  BN: 'H',
};

let polymer = 'PSVVKKCNBPNBBHNSFKBO';

// AB -> AX XB
const insertPairs = pairs => {
    return pairs.reduce((acc, pair) => {
        const charToInsert = rules[pair];
        const firstPair = pair[0] + charToInsert;
        const secondPair = charToInsert + pair[1];
        acc.push(firstPair);
        acc.push(secondPair);
        return acc;
    }, []);
};

let zeroCounts = {};
Object.keys(rules).forEach(pair => {
    zeroCounts[pair] = 0;
});

const characters = polymer.split('');
const initialPairs = characters.reduce((acc, c, i) => {
    if (i + 1 >= characters.length) {
        return acc;
    }
    const pair = c + characters[i + 1];
    acc.push(pair);
    return acc;
}, []);

let counts = {...zeroCounts};
initialPairs.forEach(pair => {
    counts[pair]++;
});

let letter_counts = {};
characters.forEach(letter => {
    letter_counts[letter] ||= 0;
    letter_counts[letter]++;
});

for (let step = 0; step < 40; step++) {
    let nextCounts = {...zeroCounts};
    Object.entries(counts).forEach(([pair, count]) => {
        const [pair1, pair2] = insertPairs([pair]);
        nextCounts[pair1] += count;
        nextCounts[pair2] += count;

        const inner_letter = pair1[1];
        letter_counts[inner_letter] ||= 0;
        letter_counts[inner_letter] += count;
    });
    counts = {...nextCounts};
}

counts = Object.values(letter_counts);
counts.sort((a, b) => a - b);

const answer = counts[counts.length - 1] - counts[0];
console.log(answer);
