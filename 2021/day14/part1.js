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
  BN: 'H'
};

let polymer = 'PSVVKKCNAAAAAABPNBBHNSFKBO';

for (let step = 0; step < 10; step++) {
    for (let i = 0; i < polymer.length - 1; i++) {
        let pair = polymer[i] + polymer[i + 1];
        let letter = rules[pair];
        if (letter) {
            polymer = polymer.slice(0, i + 1)
                + letter
                + polymer.slice(i + 1);
            i++;
        }
    }
}

let letter_counts = {};
for (let i = 0; i < polymer.length; i++) {
    letter_counts[polymer[i]] ||= 0;
    letter_counts[polymer[i]]++;
}

let counts = Object.values(letter_counts);
counts.sort((a, b) => a - b);

const answer = counts[counts.length - 1] - counts[0];
console.log(answer);
